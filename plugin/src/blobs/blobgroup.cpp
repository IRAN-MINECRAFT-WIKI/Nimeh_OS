// NimehOS blobgroup.cpp — Implementation.

#include "blobgroup.hpp"

#include "blobrect.hpp"

#include <QElapsedTimer>
#include <QMetaObject>
#include <algorithm>

BlobGroup::BlobGroup(QQuickItem *parent)
    : QQuickItem(parent) {
    setFlag(ItemHasContents, true);
}

BlobGroup::~BlobGroup() {
    // Detach from all blobs so they don't dereference us after free.
    for (const auto &ptr : std::as_const(m_blobs)) {
        if (ptr)
            ptr->setProperty("group", QVariant());
    }
}

// ---------------------------------------------------------------------------
// Property accessors
// ---------------------------------------------------------------------------

QQmlListProperty<BlobRect> BlobGroup::blobs() {
    return QQmlListProperty<BlobRect>(this, nullptr,
        &appendBlob, &blobCountCb, &blobAtCb, &clearBlobs,
        &replaceBlob, &removeLastBlob);
}

void BlobGroup::setColor(const QColor &c) {
    if (m_color == c)
        return;
    m_color = c;
    emit colorChanged();
    markDirty();
}

void BlobGroup::setSmoothing(qreal s) {
    if (qFuzzyCompare(m_smoothing, s))
        return;
    m_smoothing = s;
    emit smoothingChanged();
    markDirty();
}

void BlobGroup::setPhysicsEnabled(bool e) {
    if (m_physicsEnabled == e)
        return;
    m_physicsEnabled = e;
    emit physicsEnabledChanged();
    if (e)
        startAnimationIfNeeded();
}

// ---------------------------------------------------------------------------
// Internal API for BlobRect
// ---------------------------------------------------------------------------

void BlobGroup::addShape(BlobRect *shape) {
    if (!shape || m_blobs.contains(shape))
        return;
    m_blobs.append(shape);
    emit blobsChanged();
    startAnimationIfNeeded();
}

void BlobGroup::removeShape(BlobRect *shape) {
    if (m_blobs.removeOne(shape))
        emit blobsChanged();
}

void BlobGroup::markDirty() {
    // Each child re-paints independently; just trigger an update.
    update();
}

// ---------------------------------------------------------------------------
// Lifecycle
// ---------------------------------------------------------------------------

void BlobGroup::componentComplete() {
    QQuickItem::componentComplete();
    startAnimationIfNeeded();
}

void BlobGroup::itemChange(ItemChange change, const ItemChangeData &data) {
    QQuickItem::itemChange(change, data);
    if (change == ItemChildAddedChange && data.item) {
        // Auto-attach BlobRect children to this group. (QML users can
        // also set `group: parentBlobGroup` explicitly; this is a
        // convenience for the common case of inline BlobRect children.)
        auto *blob = qobject_cast<BlobRect *>(data.item);
        if (blob && blob->group() == nullptr)
            blob->setGroup(this);
    }
}

// ---------------------------------------------------------------------------
// Animation tick
// ---------------------------------------------------------------------------

void BlobGroup::startAnimationIfNeeded() {
    if (!m_physicsEnabled || m_animating || !isComponentComplete())
        return;
    if (m_blobs.isEmpty())
        return;

    m_animating = true;

    // Use a single-shot timer that re-arms itself, so the physics tick rate
    // matches the actual rendering rate (~60Hz on most displays). This avoids
    // running physics when the window is minimised or covered.
    QMetaObject::invokeMethod(this, [this]() { onTick(); }, Qt::QueuedConnection);
}

void BlobGroup::onTick() {
    if (!m_animating) return;

    // Use a static QElapsedTimer so the first tick is dt=0 (no jump).
    static QElapsedTimer timer;
    if (!timer.isValid())
        timer.start();
    const qint64 dt = timer.restart();

    bool anyActive = false;
    for (const auto &ptr : std::as_const(m_blobs)) {
        if (!ptr) continue;
        ptr->tickPhysics(dt);
        // If any child still has physics active, keep ticking.
        anyActive = true;
    }

    if (anyActive) {
        // Re-arm. Use the render-thread sync point via polish/update is
        // overkill here; a plain queued invocation lands at ~60Hz.
        QMetaObject::invokeMethod(this, [this]() { onTick(); }, Qt::QueuedConnection);
    } else {
        m_animating = false;
    }
}

// ---------------------------------------------------------------------------
// QQmlListProperty callbacks
// ---------------------------------------------------------------------------

void BlobGroup::appendBlob(QQmlListProperty<BlobRect> *list, BlobRect *blob) {
    auto *self = static_cast<BlobGroup *>(list->object);
    if (!blob) return;
    self->m_blobs.append(blob);
    blob->setGroup(self);
    emit self->blobsChanged();
    self->startAnimationIfNeeded();
}

qsizetype BlobGroup::blobCountCb(QQmlListProperty<BlobRect> *list) {
    auto *self = static_cast<BlobGroup *>(list->object);
    return self->m_blobs.size();
}

BlobRect *BlobGroup::blobAtCb(QQmlListProperty<BlobRect> *list, qsizetype index) {
    auto *self = static_cast<BlobGroup *>(list->object);
    return self->m_blobs.value(index);
}

void BlobGroup::clearBlobs(QQmlListProperty<BlobRect> *list) {
    auto *self = static_cast<BlobGroup *>(list->object);
    for (const auto &ptr : std::as_const(self->m_blobs))
        if (ptr && ptr->group() == self)
            ptr->setGroup(nullptr);
    self->m_blobs.clear();
    emit self->blobsChanged();
}

void BlobGroup::replaceBlob(QQmlListProperty<BlobRect> *list, qsizetype index, BlobRect *blob) {
    auto *self = static_cast<BlobGroup *>(list->object);
    if (index < 0 || index >= self->m_blobs.size() || !blob)
        return;
    if (self->m_blobs[index] && self->m_blobs[index]->group() == self)
        self->m_blobs[index]->setGroup(nullptr);
    self->m_blobs[index] = blob;
    blob->setGroup(self);
    emit self->blobsChanged();
}

void BlobGroup::removeLastBlob(QQmlListProperty<BlobRect> *list) {
    auto *self = static_cast<BlobGroup *>(list->object);
    if (self->m_blobs.isEmpty())
        return;
    auto last = self->m_blobs.takeLast();
    if (last && last->group() == self)
        last->setGroup(nullptr);
    emit self->blobsChanged();
}
