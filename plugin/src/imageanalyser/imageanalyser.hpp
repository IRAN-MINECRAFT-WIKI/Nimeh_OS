// NimehOS imageanalyser.hpp — Dominant colour extractor.
//
// Mirrors caelestia::images::ImageAnalyser but exposes Q_INVOKABLE methods
// so it can be used directly from QML without binding properties first.
//
// Algorithm
// ---------
// 1. Rescale the input image down to `rescaleSize`x`rescaleSize` (preserve
//    aspect ratio, fast transform) — 256x256 is enough for colour stats
//    and keeps the analysis well under a millisecond.
// 2. Walk every pixel, skip fully-transparent ones.
// 3. Quantise each channel to 5 bits (8 bits -> 0xE0 mask, i.e. bins of 8)
//    and pack R,G,B into a 32-bit key. This gives 32x32x32 = 32,768 bins
//    which is fine-grained enough to distinguish dominant colours but
//    coarse enough that near-duplicate pixels collapse to one bin.
// 4. Tally counts per bin; the bin with the highest count wins.
// 5. Luminance is BT.601: 0.299*R + 0.587*G + 0.114*B, averaged across
//    non-transparent pixels in linear RGB space (square each channel,
//    apply weights, take sqrt). Square-root is the perceptual compromise
//    that caelestia uses and matches what QML Color.luminance returns.
//
// The whole pass runs off the GUI thread via QtConcurrent::run, with
// cancellation through QFutureWatcher. A second invocation cancels the
// in-flight one and starts a fresh one.

#pragma once

#include <QColor>
#include <QFutureWatcher>
#include <QObject>
#include <QPair>
#include <QPointer>
#include <QQmlEngine>
#include <QQuickItem>
#include <QString>

class ImageAnalyser : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // Path on disk of the image to analyse. Setting this kicks off an async
    // analysis pass; results come back via dominantColourChanged / luminanceChanged.
    Q_PROPERTY(QString source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(int rescaleSize READ rescaleSize WRITE setRescaleSize NOTIFY rescaleSizeChanged)
    Q_PROPERTY(QColor dominantColour READ dominantColour NOTIFY dominantColourChanged)
    Q_PROPERTY(qreal luminance READ luminance NOTIFY luminanceChanged)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)

public:
    explicit ImageAnalyser(QObject *parent = nullptr);
    ~ImageAnalyser() override;

    QString source() const { return m_source; }
    void setSource(const QString &source);

    int rescaleSize() const { return m_rescaleSize; }
    void setRescaleSize(int size);

    QColor dominantColour() const { return m_dominantColour; }
    qreal luminance() const { return m_luminance; }
    bool running() const { return m_futureWatcher.isRunning(); }

    // Synchronous helpers — safe to call from QML via Q_INVOKABLE. They
    // load the image from disk themselves and block the calling thread,
    // so prefer the async `source` path for live wallpaper updates.
    Q_INVOKABLE QColor analyze(const QString &path);
    Q_INVOKABLE QColor getDominant(const QImage &image);
    Q_INVOKABLE qreal getLuminance(const QColor &color) const;

    // Trigger an async re-analysis of the current source.
    Q_INVOKABLE void requestUpdate();

signals:
    void sourceChanged();
    void rescaleSizeChanged();
    void dominantColourChanged();
    void luminanceChanged();
    void runningChanged();

private:
    using AnalyseResult = QPair<QColor, qreal>;

    QFutureWatcher<AnalyseResult> m_futureWatcher;
    QString m_source;
    int m_rescaleSize = 128;
    QColor m_dominantColour { 0, 0, 0 };
    qreal m_luminance = 0.0;

    void startAsync(const QImage &image);
    static AnalyseResult analyseSync(const QImage &image, int rescaleSize);
};
