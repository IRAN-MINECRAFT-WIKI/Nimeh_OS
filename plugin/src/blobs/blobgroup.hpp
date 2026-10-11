// NimehOS blobgroup.hpp — Container for multiple BlobRect items.
//
// A BlobGroup is a QQuickItem that owns a list of BlobRect children. It
// drives their spring physics from a single animation timer (so all
// children share one tick instead of each running their own), and provides
// a "smoothing" property that approximates the SDF smooth-min blend that
// caelestia achieves in its fragment shader — here, by simply tinting the
// overlapping region with the group colour.

#pragma once

#include <QColor>
#include <QList>
#include <QObject>
#include <QPointer>
#include <QQmlEngine>
#include <QQmlListProperty>
#include <QQuickItem>

class BlobRect;

class BlobGroup : public QQuickItem {
    Q_OBJECT
    QML_ELEMENT

    // Default property: children declared inside the BlobGroup block become
    // entries in `blobs`. (Standard QQuickItem children like Rectangle still
    // work; only BlobRect children are tracked for physics/blending.)
    Q_PROPERTY(QQmlListProperty<BlobRect> blobs READ blobs NOTIFY blobsChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(qreal smoothing READ smoothing WRITE setSmoothing NOTIFY smoothingChanged)
    Q_PROPERTY(bool physicsEnabled READ physicsEnabled WRITE setPhysicsEnabled NOTIFY physicsEnabledChanged)

public:
    explicit BlobGroup(QQuickItem *parent = nullptr);
    ~BlobGroup() override;

    QQmlListProperty<BlobRect> blobs();
    int blobCount() const { return m_blobs.size(); }
    BlobRect *blobAt(int index) const { return m_blobs.value(index); }

    QColor color() const { return m_color; }
    void setColor(const QColor &c);

    qreal smoothing() const { return m_smoothing; }
    void setSmoothing(qreal s);

    bool physicsEnabled() const { return m_physicsEnabled; }
    void setPhysicsEnabled(bool e);

    // Internal API used by BlobRect
    void addShape(BlobRect *shape);
    void removeShape(BlobRect *shape);
    void markDirty();

signals:
    void blobsChanged();
    void colorChanged();
    void smoothingChanged();
    void physicsEnabledChanged();

protected:
    void componentComplete() override;
    void itemChange(ItemChange change, const ItemChangeData &data) override;

private:
    QList<QPointer<BlobRect>> m_blobs;
    QColor m_color { 0x44, 0x88, 0xff };
    qreal m_smoothing = 32.0;
    bool m_physicsEnabled = true;
    bool m_animating = false;

    // Single-shot animation driver: ticks every child's spring physics.
    void startAnimationIfNeeded();
    void onTick();

    // QQmlListProperty callbacks (so QML can use [ ... ] syntax on `blobs`)
    static void appendBlob(QQmlListProperty<BlobRect> *list, BlobRect *blob);
    static qsizetype blobCountCb(QQmlListProperty<BlobRect> *list);
    static BlobRect *blobAtCb(QQmlListProperty<BlobRect> *list, qsizetype index);
    static void clearBlobs(QQmlListProperty<BlobRect> *list);
    static void replaceBlob(QQmlListProperty<BlobRect> *list, qsizetype index, BlobRect *blob);
    static void removeLastBlob(QQmlListProperty<BlobRect> *list);
};
