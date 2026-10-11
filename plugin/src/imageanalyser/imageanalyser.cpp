// NimehOS imageanalyser.cpp — Implementation.

#include "imageanalyser.hpp"

#include <QImage>
#include <QLoggingCategory>
#include <QPromise>
#include <QtConcurrent>
#include <cmath>
#include <unordered_map>

namespace {
Q_LOGGING_CATEGORY(lcImageAnalyser, "nimehos.imageanalyser", QtWarningMsg)

// 5-bit quantisation mask: top 5 bits of an 8-bit channel.
// 0xF8 = 11111000 — bins of width 8, 32 bins per channel.
constexpr quint8 k_quantMask = 0xF8;

// BT.601 luma weights.
constexpr qreal k_rWeight = 0.299;
constexpr qreal k_gWeight = 0.587;
constexpr qreal k_bWeight = 0.114;
} // namespace

ImageAnalyser::ImageAnalyser(QObject *parent)
    : QObject(parent) {
    // Wire up the future watcher so results land on the GUI thread.
    connect(&m_futureWatcher, &QFutureWatcher<AnalyseResult>::finished, this, [this]() {
        if (!m_futureWatcher.future().isResultReadyAt(0)) {
            emit runningChanged();
            return;
        }
        const auto result = m_futureWatcher.result();
        if (m_dominantColour != result.first) {
            m_dominantColour = result.first;
            emit dominantColourChanged();
        }
        if (!qFuzzyCompare(m_luminance + 1.0, result.second + 1.0)) {
            m_luminance = result.second;
            emit luminanceChanged();
        }
        emit runningChanged();
    });
}

ImageAnalyser::~ImageAnalyser() = default;

// ---------------------------------------------------------------------------
// Property setters
// ---------------------------------------------------------------------------

void ImageAnalyser::setSource(const QString &source) {
    if (m_source == source)
        return;
    m_source = source;
    emit sourceChanged();
    requestUpdate();
}

void ImageAnalyser::setRescaleSize(int size) {
    if (m_rescaleSize == size)
        return;
    m_rescaleSize = size;
    emit rescaleSizeChanged();
    requestUpdate();
}

// ---------------------------------------------------------------------------
// Async entry point
// ---------------------------------------------------------------------------

void ImageAnalyser::requestUpdate() {
    if (m_source.isEmpty())
        return;
    QImage img(m_source);
    if (img.isNull()) {
        qCWarning(lcImageAnalyser) << "requestUpdate: failed to load image" << m_source;
        return;
    }
    startAsync(img);
}

void ImageAnalyser::startAsync(const QImage &image) {
    if (m_futureWatcher.isRunning()) {
        m_futureWatcher.cancel();
    }
    emit runningChanged();

    const int rescale = m_rescaleSize;
    // QtConcurrent::run with a QPromise gives us cancellation support so a
    // rapid succession of source changes doesn't pile up work.
    m_futureWatcher.setFuture(QtConcurrent::run([image, rescale](QPromise<AnalyseResult> &p) {
        p.addResult(analyseSync(image, rescale));
    }));
}

// ---------------------------------------------------------------------------
// Synchronous Q_INVOKABLE helpers
// ---------------------------------------------------------------------------

QColor ImageAnalyser::analyze(const QString &path) {
    if (path.isEmpty()) {
        qCWarning(lcImageAnalyser) << "analyze: empty path";
        return QColor(0, 0, 0);
    }
    QImage img(path);
    if (img.isNull()) {
        qCWarning(lcImageAnalyser) << "analyze: failed to load" << path;
        return QColor(0, 0, 0);
    }
    const auto result = analyseSync(img, m_rescaleSize);
    if (m_dominantColour != result.first) {
        m_dominantColour = result.first;
        emit dominantColourChanged();
    }
    if (!qFuzzyCompare(m_luminance + 1.0, result.second + 1.0)) {
        m_luminance = result.second;
        emit luminanceChanged();
    }
    return result.first;
}

QColor ImageAnalyser::getDominant(const QImage &image) {
    if (image.isNull()) {
        qCWarning(lcImageAnalyser) << "getDominant: null image";
        return QColor(0, 0, 0);
    }
    return analyseSync(image, m_rescaleSize).first;
}

qreal ImageAnalyser::getLuminance(const QColor &color) const {
    // BT.601 luma on linearised channels (square -> weight -> sum -> sqrt),
    // which is what QML Color.luminance returns. This avoids the gamma
    // distortion you'd get applying the weights directly to sRGB values.
    const qreal r = color.redF();
    const qreal g = color.greenF();
    const qreal b = color.blueF();
    return std::sqrt(k_rWeight * r * r + k_gWeight * g * g + k_bWeight * b * b);
}

// ---------------------------------------------------------------------------
// Core analysis
// ---------------------------------------------------------------------------

ImageAnalyser::AnalyseResult ImageAnalyser::analyseSync(const QImage &image, int rescaleSize) {
    if (image.isNull()) {
        qCWarning(lcImageAnalyser) << "analyseSync: null image";
        return { QColor(0, 0, 0), 0.0 };
    }

    QImage img = image;

    // Downscale for speed. KeepAspectRatio + FastTransformation gives a
    // very fast nearest-neighbour result that's perfectly adequate for
    // colour statistics.
    if (rescaleSize > 0 && (img.width() > rescaleSize || img.height() > rescaleSize)) {
        img = img.scaled(rescaleSize, rescaleSize, Qt::KeepAspectRatio,
                         Qt::FastTransformation);
    }

    // Force a consistent 32-bit ARGB byte order so we can index channels
    // directly. Format_ARGB32 is BGRA on little-endian.
    if (img.format() != QImage::Format_ARGB32)
        img = img.convertToFormat(QImage::Format_ARGB32);

    const int width = img.width();
    const int height = img.height();
    const qsizetype bpl = img.bytesPerLine();
    const uchar *data = img.bits();

    // Bin counter: 32*32*32 = up to 32K entries; unordered_map is fine.
    std::unordered_map<quint32, int> colours;
    colours.reserve(4096);

    qreal totalLuminance = 0.0;
    int count = 0;

    for (int y = 0; y < height; ++y) {
        const uchar *line = data + static_cast<qsizetype>(y) * bpl;
        for (int x = 0; x < width; ++x) {
            const uchar *px = line + static_cast<qsizetype>(x) * 4;

            // Skip fully-transparent pixels so transparent borders on
            // PNGs don't bias the result toward black.
            if (px[3] == 0)
                continue;

            // 5-bit quantisation (3 trailing bits dropped). The mask is
            // applied to each channel and the three are packed into a
            // 15-bit key (5 bits per channel, 32 bins each).
            const quint32 r = static_cast<quint32>(px[2] & k_quantMask);
            const quint32 g = static_cast<quint32>(px[1] & k_quantMask);
            const quint32 b = static_cast<quint32>(px[0] & k_quantMask);
            ++colours[(r << 16) | (g << 8) | b];

            // Linearise sRGB by squaring, then apply BT.601 weights, then
            // sqrt to get back to display luminance. (This is the same
            // formula caelestia::images::ImageAnalyser uses and matches
            // QColor::luminance in Qt 6.8+.)
            const qreal rf = px[2] / 255.0;
            const qreal gf = px[1] / 255.0;
            const qreal bf = px[0] / 255.0;
            totalLuminance += std::sqrt(k_rWeight * rf * rf +
                                        k_gWeight * gf * gf +
                                        k_bWeight * bf * bf);
            ++count;
        }
    }

    if (count == 0) {
        // Image is fully transparent — fall back to black.
        return { QColor(0, 0, 0), 0.0 };
    }

    // Pick the bin with the highest pixel count. Ties go to the first
    // inserted (arbitrary but deterministic).
    quint32 dominantKey = 0;
    int maxCount = 0;
    for (const auto &kv : colours) {
        if (kv.second > maxCount) {
            maxCount = kv.second;
            dominantKey = kv.first;
        }
    }

    // Reconstruct an opaque QColor from the quantised bin. We bump the
    // low bits to 4 (mid-bin) so the reported colour isn't always a
    // multiple of 8, which looks visually wrong.
    const int r = static_cast<int>((dominantKey >> 16) & 0xFF) | 0x04;
    const int g = static_cast<int>((dominantKey >> 8) & 0xFF) | 0x04;
    const int b = static_cast<int>(dominantKey & 0xFF) | 0x04;

    return { QColor(r, g, b, 255), totalLuminance / count };
}
