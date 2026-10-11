// NimehOS blobrect.cpp — Implementation of the deformable blob rectangle.
//
// Default rendering path (Approach A): QQuickPaintedItem + QPainter.
// The spring physics that drive deformX/deformY/deformAngle is independent
// of the rendering path and works for either Approach A or B.
//
// Physics model
// -------------
// On each frame we measure the item's scene-space velocity (px/s) by
// comparing mapToScene(center) with the previous frame. From the velocity
// vector (vx, vy) we compute a target deformation:
//
//   speed   = sqrt(vx*vx + vy*vy)
//   stretch = 1 + min(speed * deformScale, maxStretch)   // capped at 35%
//   compress= 1 / stretch
//   θ       = atan2(vy, vx)                                // eigen-frame angle
//   targetX = stretch (along motion direction)
//   targetY = compress (perpendicular)
//
// Then we integrate an underdamped spring on deformX/deformY toward the
// target using the same closed-form implicit-damping integrator as
// caelestia::blobs::BlobRect, which is stable for any dt:
//
//   v = (v - k * (x - target) * dt) / (1 + c * dt)
//   x += v * dt
//
// The integrator stays in (0,1) for any dt and never injects energy on
// slow frames, so the blob never diverges.
//
// The angle (deformAngle) is set instantly to the velocity direction
// whenever physics is active; smoothing the angle through a second spring
// would add complexity without much visual benefit.

#include "blobrect.hpp"

#include "blobgroup.hpp"

#include <QPainter>
#include <QPainterPath>
#include <QTransform>
#include <QtMath>
#include <algorithm>
#include <cmath>

namespace {
// Epsilon for "at rest" detection — same value caelestia uses.
constexpr qreal k_atRestEpsilon = 0.002;
// Speed threshold (px/s) below which physics is considered dormant.
constexpr qreal k_minSpeed = 5.0;
} // namespace

BlobRect::BlobRect(QQuickItem *parent)
    : QQuickPaintedItem(parent) {
    // Render on every update tick — the deformation changes continuously.
    setFlag(ItemHasContents, true);
    setAntialiasing(true);
    m_timer.start();
}

BlobRect::~BlobRect() {
    if (m_group) {
        // BlobGroup::removeShape is safe to call from destructor — it just
        // removes the pointer from the group's list.
        m_group->removeShape(this);
    }
}

// ---------------------------------------------------------------------------
// Property setters
// ---------------------------------------------------------------------------

void BlobRect::setRadius(qreal r) {
    if (qFuzzyCompare(m_radius, r))
        return;
    m_radius = r;
    emit radiusChanged();
    markDirty();
}

void BlobRect::setColor(const QColor &c) {
    if (m_color == c)
        return;
    m_color = c;
    emit colorChanged();
    markDirty();
}

void BlobRect::setDeformX(qreal x) {
    if (qFuzzyCompare(m_deformX, x))
        return;
    m_deformX = x;
    emit deformChanged();
    markDirty();
}

void BlobRect::setDeformY(qreal y) {
    if (qFuzzyCompare(m_deformY, y))
        return;
    m_deformY = y;
    emit deformChanged();
    markDirty();
}

void BlobRect::setDeformAngle(qreal a) {
    if (qFuzzyCompare(m_deformAngle, a))
        return;
    m_deformAngle = a;
    emit deformChanged();
    markDirty();
}

void BlobRect::setStiffness(qreal s) {
    if (qFuzzyCompare(m_stiffness, s))
        return;
    m_stiffness = s;
    emit stiffnessChanged();
}

void BlobRect::setDamping(qreal d) {
    if (qFuzzyCompare(m_damping, d))
        return;
    m_damping = d;
    emit dampingChanged();
}

void BlobRect::setDeformScale(qreal s) {
    if (qFuzzyCompare(m_deformScale, s))
        return;
    m_deformScale = s;
    emit deformScaleChanged();
}

void BlobRect::setMaxStretch(qreal s) {
    if (qFuzzyCompare(m_maxStretch, s))
        return;
    m_maxStretch = s;
    emit maxStretchChanged();
}

void BlobRect::setGroup(BlobGroup *g) {
    if (m_group == g)
        return;
    if (m_group)
        m_group->removeShape(this);
    m_group = g;
    if (m_group)
        m_group->addShape(this);
    emit groupChanged();
}

// ---------------------------------------------------------------------------
// Lifecycle hooks
// ---------------------------------------------------------------------------

void BlobRect::componentComplete() {
    QQuickPaintedItem::componentComplete();
    m_prevScenePos = mapToScene(QPointF(width() / 2.0, height() / 2.0));
    m_hasPrevPos = true;
    m_timer.restart();
}

void BlobRect::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) {
    QQuickPaintedItem::geometryChange(newGeometry, oldGeometry);
    if (newGeometry.size() != oldGeometry.size())
        markDirty();
}

void BlobRect::markDirty() {
    update();
    if (m_group)
        m_group->markDirty();
}

// ---------------------------------------------------------------------------
// Physics
// ---------------------------------------------------------------------------

void BlobRect::tickPhysics(qint64 deltaMs) {
    if (!isComponentComplete())
        return;
    stepSpring(static_cast<qreal>(deltaMs) / 1000.0);
}

void BlobRect::stepSpring(qreal dt) {
    // Reject dt outside (1ms, 100ms) — too small is noise, too large is a stall
    // (e.g. the window was minimised); snap to rest and bail.
    if (dt < 0.001 || dt > 0.1) {
        m_prevScenePos = mapToScene(QPointF(width() / 2.0, height() / 2.0));
        if (m_physicsActive)
            checkAtRest(0.0);
        return;
    }

    const QPointF scenePos = mapToScene(QPointF(width() / 2.0, height() / 2.0));
    if (!m_hasPrevPos) {
        m_prevScenePos = scenePos;
        m_hasPrevPos = true;
        return;
    }

    const qreal vx = (scenePos.x() - m_prevScenePos.x()) / dt;
    const qreal vy = (scenePos.y() - m_prevScenePos.y()) / dt;
    m_prevScenePos = scenePos;
    const qreal speed = std::sqrt(vx * vx + vy * vy);

    if (!m_physicsActive) {
        if (speed < k_minSpeed)
            return;
        m_physicsActive = true;
    }

    // Compute target deformation (eigenvalues stretch/compress) and the
    // eigenframe angle from the velocity direction.
    qreal targetX = 1.0;
    qreal targetY = 1.0;
    qreal targetAngle = m_deformAngle;

    if (speed > k_minSpeed) {
        const qreal stretch = 1.0 + std::min(speed * m_deformScale, m_maxStretch);
        const qreal compress = 1.0 / stretch;
        targetX = stretch;
        targetY = compress;
        targetAngle = std::atan2(vy, vx) * 180.0 / M_PI;
    }

    // Implicit-damping spring integrator (matches caelestia). Stable for any
    // dt because the damping term 1/(1 + c*dt) stays in (0,1].
    const qreal k = m_stiffness;
    const qreal c = m_damping;
    const qreal invDamp = 1.0 / (1.0 + c * dt);

    m_velX = (m_velX - k * (m_deformX - targetX) * dt) * invDamp;
    m_deformX += m_velX * dt;

    m_velY = (m_velY - k * (m_deformY - targetY) * dt) * invDamp;
    m_deformY += m_velY * dt;

    // Set angle directly (no spring on angle — keeps the math simple and
    // avoids angle wrap issues).
    if (!qFuzzyCompare(m_deformAngle, targetAngle)) {
        m_deformAngle = targetAngle;
        emit deformChanged();
    }

    checkAtRest(speed);
    markDirty();
}

void BlobRect::checkAtRest(qreal speed) {
    const bool atRest = std::abs(m_deformX - 1.0) < k_atRestEpsilon &&
                        std::abs(m_deformY - 1.0) < k_atRestEpsilon &&
                        std::abs(m_velX) < k_atRestEpsilon &&
                        std::abs(m_velY) < k_atRestEpsilon &&
                        speed < k_minSpeed;

    if (atRest) {
        m_deformX = 1.0;
        m_deformY = 1.0;
        m_velX = 0.0;
        m_velY = 0.0;
        m_physicsActive = false;
        emit deformChanged();
        markDirty();
    }
}

// ---------------------------------------------------------------------------
// Rendering — Approach A: QPainter
// ---------------------------------------------------------------------------

QTransform BlobRect::deformTransform() const {
    // Build a transform that, in local space centred on the blob, applies
    // rotate(angle) then scale(deformX, deformY). This is the 2x2 symmetric
    // deformation matrix R(θ) * diag(dx, dy) * R(θ)^T expressed as a QTransform.
    //
    // Qt's transform composition order means the last-specified op is applied
    // first to the input point, so we say: translate to centre, rotate, scale,
    // translate back.
    const QPointF c(width() / 2.0, height() / 2.0);
    QTransform t;
    t.translate(c.x(), c.y());
    t.rotate(m_deformAngle);
    t.scale(m_deformX, m_deformY);
    t.translate(-c.x(), -c.y());
    return t;
}

void BlobRect::paint(QPainter *painter) {
    painter->save();

    // Apply the deformation. Done in local coordinates so that the rounded
    // rect is drawn in deformed space directly.
    painter->setTransform(deformTransform(), true);

    painter->setRenderHint(QPainter::Antialiasing, true);
    painter->setRenderHint(QPainter::SmoothPixmapTransform, true);

    // Cap the radius so it never exceeds half the smaller dimension —
    // otherwise QPainter draws a circle and our deformation looks wrong.
    const qreal w = width();
    const qreal h = height();
    const qreal maxR = std::min(w, h) * 0.5;
    const qreal r = std::clamp(m_radius, 0.0, maxR);

    // Fill colour with the item's opacity baked in.
    QColor fill = m_color;
    fill.setAlphaF(fill.alphaF() * opacity());

    painter->setPen(Qt::NoPen);
    painter->setBrush(fill);
    painter->drawRoundedRect(QRectF(0, 0, w, h), r, r, Qt::AbsoluteSize);

    painter->restore();
}

// ===========================================================================
// Approach B reference (SDF shader via QSGMaterialShader) — NOT compiled by
// default. Kept here as documentation of how the SDF path would look. To
// enable, derive from QQuickItem instead of QQuickPaintedItem and replace
// paint() with the updatePaintNode() below. Requires Qt Shader Tools at
// build time and a QSGMaterialShader subclass that loads
// ":/qt/qml/NimehOS/shaders/blob.frag.qsb" via QShader::fromSerialized().
//
// #include <QtQuick/QSGGeometryNode>
// #include <QtQuick/QSGMaterial>
// #include <QtQuick/QSGMaterialShader>
// #include <QtGui/QMatrix4x4>
//
// struct BlobUniforms {
//     float opacity = 1.0f;
//     float radius  = 12.0f;
//     float pad0 = 0, pad1 = 0;
//     QVector2D size;
//     QColor color;
//     QMatrix2x2 deform;  // column-major, identity by default
// };
//
// class BlobMaterial : public QSGMaterial {
// public:
//     QSGMaterialType *type() const override { static QSGMaterialType t; return &t; }
//     QSGMaterialShader *createShader(QSGRendererInterface::RenderMode) const override;
//     int compare(const QSGMaterial *other) const override {
//         return memcmp(&m_u, &static_cast<const BlobMaterial*>(other)->m_u, sizeof(m_u));
//     }
//     BlobUniforms m_u;
// };
//
// class BlobMaterialShader : public QSGMaterialShader {
// public:
//     BlobMaterialShader() {
//         setShaderFileName(VertexStage,   ":/qt/qml/NimehOS/shaders/blob.vert.qsb");
//         setShaderFileName(FragmentStage, ":/qt/qml/NimehOS/shaders/blob.frag.qsb");
//     }
//     bool updateUniformData(RenderState &state, QSGMaterial *newMat,
//                            QSGMaterial *oldMat) override {
//         auto *m = static_cast<BlobMaterial*>(newMat);
//         char *buf = state.uniformData();
//         // Layout must match blob.frag: mat4 qt_Matrix, float qt_Opacity,
//         // vec4 u_color, vec2 u_size, float u_radius, mat2 u_deform.
//         memcpy(buf, state.compositeMatrix().constData(), 64);
//         *reinterpret_cast<float*>(buf + 64) = state.opacity();
//         // ... copy remaining fields from m->m_u ...
//         return true;
//     }
// };
//
// QSGMaterialShader *BlobMaterial::createShader(QSGRendererInterface::RenderMode) const {
//     return new BlobMaterialShader;
// }
//
// QSGNode *BlobRect::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) {
//     auto *node = static_cast<QSGGeometryNode*>(oldNode);
//     if (!node) {
//         node = new QSGGeometryNode;
//         auto *m = new BlobMaterial;
//         m->setFlag(QSGMaterial::Blending);
//         node->setMaterial(m);
//         node->setFlag(QSGNode::OwnsMaterial);
//         // Allocate QSGGeometry for a 4-vertex quad (two triangles) and
//         // set qt_VertexTexCoord to 0..1 across the item. Omitted for brevity.
//     }
//     // Push the current deform/radius/size into the material uniforms.
//     auto *m = static_cast<BlobMaterial*>(node->material());
//     m->m_u.radius = m_radius;
//     m->m_u.size   = QVector2D(width(), height());
//     m->m_u.color  = m_color;
//     // Build the 2x2 symmetric deformation matrix:
//     //   D = R(θ) * diag(dx, dy) * R(θ)^T
//     const float a = qDegreesToRadians(float(m_deformAngle));
//     const float ca = std::cos(a), sa = std::sin(a);
//     const float dx = float(m_deformX), dy = float(m_deformY);
//     m->m_u.deform = QMatrix2x2{
//         ca*ca*dx + sa*sa*dy, sa*ca*(dx - dy),
//         sa*ca*(dx - dy),     sa*sa*dx + ca*ca*dy
//     };
//     node->markDirty(QSGNode::DirtyMaterial);
//     return node;
// }
// ===========================================================================
