// NimehOS blobrect.hpp — Deformable rounded-rectangle primitive.
//
// Approach A (default, compiled): QQuickPaintedItem + QPainter.
//   - Portable across every Qt6 backend (software, GL, Vulkan, Metal, D3D)
//   - Renders the rounded rect via QPainter::drawRoundedRect, then applies
//     the spring-driven deformation as a painter transform.
//   - Works without Qt Shader Tools at runtime.
//
// Approach B (reference, provided as commented block in blobrect.cpp):
//   - QSGGeometryNode + custom QSGMaterialShader wrapping blob.frag
//   - Real SDF rendering on the GPU, ~10x faster, true 2x2 deformation
//   - Matches the caelestia::blobs::BlobRect approach
//   - Enabled via the NIMEHOS_BLOB_USE_SDF preprocessor switch.

#pragma once

#include <QColor>
#include <QElapsedTimer>
#include <QQuickPaintedItem>

class BlobGroup;

class BlobRect : public QQuickPaintedItem {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(qreal radius READ radius WRITE setRadius NOTIFY radiusChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(qreal deformX READ deformX WRITE setDeformX NOTIFY deformChanged)
    Q_PROPERTY(qreal deformY READ deformY WRITE setDeformY NOTIFY deformChanged)
    Q_PROPERTY(qreal deformAngle READ deformAngle WRITE setDeformAngle NOTIFY deformChanged)

    // Spring tuning. Defaults match caelestia::blobs::BlobRect (stiffness=200,
    // damping=16, deformScale=0.0005) which is well below critical damping
    // (ζ = 16/(2*sqrt(200)) ≈ 0.57 — underdamped, so the blob overshoots).
    Q_PROPERTY(qreal stiffness READ stiffness WRITE setStiffness NOTIFY stiffnessChanged)
    Q_PROPERTY(qreal damping READ damping WRITE setDamping NOTIFY dampingChanged)
    Q_PROPERTY(qreal deformScale READ deformScale WRITE setDeformScale NOTIFY deformScaleChanged)
    Q_PROPERTY(qreal maxStretch READ maxStretch WRITE setMaxStretch NOTIFY maxStretchChanged)

    // Optional group reference (used by BlobGroup to mark neighbours dirty
    // when this blob deforms; safe to leave null).
    Q_PROPERTY(BlobGroup *group READ group WRITE setGroup NOTIFY groupChanged)

public:
    explicit BlobRect(QQuickItem *parent = nullptr);
    ~BlobRect() override;

    // Property getters
    qreal radius() const { return m_radius; }
    QColor color() const { return m_color; }
    qreal deformX() const { return m_deformX; }
    qreal deformY() const { return m_deformY; }
    qreal deformAngle() const { return m_deformAngle; }

    qreal stiffness() const { return m_stiffness; }
    qreal damping() const { return m_damping; }
    qreal deformScale() const { return m_deformScale; }
    qreal maxStretch() const { return m_maxStretch; }

    BlobGroup *group() const { return m_group; }

    // Property setters
    void setRadius(qreal r);
    void setColor(const QColor &c);
    void setDeformX(qreal x);
    void setDeformY(qreal y);
    void setDeformAngle(qreal a);

    void setStiffness(qreal s);
    void setDamping(qreal d);
    void setDeformScale(qreal s);
    void setMaxStretch(qreal s);

    void setGroup(BlobGroup *g);

    // Approach A rendering hook
    void paint(QPainter *painter) override;

    // Drive the spring physics by delta-ms. Public so a parent BlobGroup
    // can tick all its children from a single animation timer.
    void tickPhysics(qint64 deltaMs);

    // Mark this blob (and its group) as needing a repaint
    void markDirty();

signals:
    void radiusChanged();
    void colorChanged();
    void deformChanged();
    void stiffnessChanged();
    void dampingChanged();
    void deformScaleChanged();
    void maxStretchChanged();
    void groupChanged();

protected:
    void componentComplete() override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;

private:
    // Visual properties
    qreal m_radius = 12.0;
    QColor m_color = Qt::black;

    // Deformation (target of the spring). deformX/deformY are eigenvalue
    // stretch factors (1.0 = rest), deformAngle rotates the eigenframe.
    qreal m_deformX = 1.0;
    qreal m_deformY = 1.0;
    qreal m_deformAngle = 0.0;

    // Spring physics state. The spring pulls deformX/deformY toward m_targetX/Y
    // (which is computed from the item's scene-space velocity when physics is
    // active, or held at 1.0 when at rest).
    qreal m_velX = 0.0;
    qreal m_velY = 0.0;
    qreal m_targetX = 1.0;
    qreal m_targetY = 1.0;

    // Spring tuning
    qreal m_stiffness = 200.0;
    qreal m_damping = 16.0;
    qreal m_deformScale = 0.0005;
    qreal m_maxStretch = 0.35; // 35% — matches caelestia k_maxStretch

    // Group backreference (weak; not owned)
    BlobGroup *m_group = nullptr;

    // Physics state
    QElapsedTimer m_timer;
    QPointF m_prevScenePos;
    bool m_hasPrevPos = false;
    bool m_physicsActive = false;

    // Helper: integrate the spring one step
    void stepSpring(qreal dt);
    // Helper: check if at rest and snap to identity
    void checkAtRest(qreal speed);
    // Helper: rebuild painter transform from current deform state
    QTransform deformTransform() const;
};
