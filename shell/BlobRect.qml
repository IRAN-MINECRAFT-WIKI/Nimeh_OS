// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// BlobRect.qml — مستطیل ارگانیک با فیزیک کشش و فشرده‌سازی (نسخه QML-only)
// ============================================================
//
// به‌جای SDF rendering و ماتریس deformation 2x2، از:
//   - Scale transform مستقل روی X و Y
//   - Rotation جزئی برای حس ارگانیک
//   - SpringAnimation برای فیزیک فنری
//   - Gradient برای عمق بصری
// استفاده می‌کنیم.
//
// محدودیت‌ها در مقابل نسخه C++:
//   1. بدون SDF shader، ترکیب (smin) با blob‌های مجاور انجام نمی‌شود.
//      یعنی هر BlobRect مستقل render می‌شود، نه merge شده با همسایه‌ها.
//   2. ماتریس deformation کامل (3 مؤلفه m00, m01, m11) با Scale ساده روی
//      محورهای اصلی تقریب زده می‌شود. در حرکت قطری، کشش بین دو محور
//      پخش می‌شود (تقریب قابل قبول).
//   3. At-rest detection در نسخه C++ فعال است؛ این نسخه نیز با threshold
//      سرعت < 0.1 پیکسل به حالت سکون برمی‌گردد.
//
// الگوبرداری شده از:
//   - components/controls/LoadingIndicator.qml (الگوی SpringAnimation)
//
// نحوه استفاده:
//   import NimehOS
//
//   BlobRect {
//       width: 200; height: 100
//       color: Theme.surface
//       radius: Theme.radiusLg
//       deformation: 0.15
//       // x, y به‌صورت پویا (مثلا با drag) تغییر کنند تا فیزیک فعال شود.
//   }

import QtQuick

Item {
    id: root

    // ============================================================
    // ۱. پراپرتی‌های عمومی (Public API)
    // ============================================================

    // رنگ بدنه blob. پیش‌فرض: surface از Theme.
    property color color: Theme.surface
    // شعاع گوشه‌ها. پیش‌فرض: radiusLg (14).
    property real radius: Theme.radiusLg
    // حداکثر میزان کشش (0..0.35). هر چه بیشتر، کشش شدیدتر.
    property real deformation: 0.15
    property real stiffness: 200
    property real damping: 16
    // فعال/غیرفعال کردن فیزیک.
    property bool physicsEnabled: true
    // رنگ حاشیه (border). null = بدون حاشیه.
    property color borderColor: Theme.border
    // ضخامت حاشیه.
    property real borderWidth: 1

    // ============================================================
    // ۲. وضعیت داخلی (Internal State)
    // ============================================================

    // موقعیت قبلی برای محاسبه سرعت
    property real _prevX: 0
    property real _prevY: 0
    property bool _hasPrev: false

    // مقادیر هدف Scale و Rotation (از فیزیک محاسبه می‌شوند)
    property real _targetScaleX: 1.0
    property real _targetScaleY: 1.0
    property real _targetRotation: 0.0

    // مقادیر فعلی — با binding به target.
    // Behavior روی این پراپرتی‌ها تغییرات را با spring animation نرم می‌کند.
    // (الگوی استاندارد QML: binding + Behavior = animation روی binding update)
    property real _scaleX: root._targetScaleX
    property real _scaleY: root._targetScaleY
    property real _rotation: root._targetRotation

    // ============================================================
    // ۳. تنظیمات transform
    // ============================================================

    transformOrigin: Item.Center

    // Scale مستقل روی X و Y + Rotation جزئی برای حس ارگانیک.
    transform: [
        Scale {
            xScale: root._scaleX
            yScale: root._scaleY
            origin.x: root.width / 2
            origin.y: root.height / 2
        },
        Rotation {
            angle: root._rotation
            origin.x: root.width / 2
            origin.y: root.height / 2
        }
    ]

    // ============================================================
    // ۴. ردیابی حرکت و محاسبه سرعت
    // ============================================================

    // هر بار x یا y تغییر می‌کند، فیزیک به‌روز می‌شود.
    onXChanged: root._updatePhysics()
    onYChanged: root._updatePhysics()

    function _updatePhysics(): void {
        if (!root.physicsEnabled) return

        // اولین فریم: فقط prev را ثبت کن
        if (!root._hasPrev) {
            root._prevX = root.x
            root._prevY = root.y
            root._hasPrev = true
            return
        }

        const dx = root.x - root._prevX
        const dy = root.y - root._prevY
        root._prevX = root.x
        root._prevY = root.y

        const speed = Math.sqrt(dx * dx + dy * dy)

        // اگر حرکت کم است، به حالت سکون برگرد
        if (speed < 0.1) {
            root._targetScaleX = 1.0
            root._targetScaleY = 1.0
            root._targetRotation = 0.0
            return
        }

        // محاسبه کشش و فشردگی
        // compress = 1 / stretch (حفظ حجم تقریبی)
        const k_maxStretch = Math.min(0.35, root.deformation)
        // فاکتور 0.02 برای تطبیق با حرکت‌های معمولی QML (نسبت به 0.0005 در C++ که
        // بر اساس px/s بود، اینجا بر اساس px/frame است).
        const stretch = 1.0 + Math.min(speed * 0.02, k_maxStretch)
        const compress = 1.0 / stretch

        // زاویه حرکت
        const motionAngle = Math.atan2(dy, dx)
        const cosA = Math.cos(motionAngle)
        const sinA = Math.sin(motionAngle)
        const cos2 = cosA * cosA
        const sin2 = sinA * sinA

        // تقریب ماتریس deformation 2x2 با Scale روی محورهای اصلی.
        // در نسخه C++، ماتریس کامل شامل m01 (off-diagonal) است که با
        // rotation در shader اعمال می‌شود. اینجا ما فقط مؤلفه‌های اصلی را
        // مدل می‌کنیم و از rotation جداگانه برای حس قطری استفاده می‌کنیم.
        root._targetScaleX = stretch * cos2 + compress * sin2
        root._targetScaleY = stretch * sin2 + compress * cos2

        // چرخش جزئی متناسب با زاویه حرکت (۵٪ از زاویه حرکت)
        // این چرخش باعث می‌شود حرکت‌های قطری طبیعی‌تر به‌نظر برسند.
        root._targetRotation = motionAngle * 180 / Math.PI * 0.05
    }

    // ============================================================
    // ۵. Behavior برای انیمیشن فنری
    // ============================================================
    //
    // الگوی کار: _scaleX با binding به _targetScaleX متصل است. وقتی
    // _targetScaleX (از روی فیزیک) تغییر می‌کند، binding مقدار جدید را به
    // _scaleX می‌دهد، و Behavior این تغییر را با SpringAnimation نرم می‌کند.
    // (مستندات Qt Behavior: "changes to a property's value ... by a binding")

    // Behavior: فیزیک فنری برای _scaleX
    Behavior on _scaleX {
        SpringAnimation {
            spring: root.stiffness
            damping: root.damping
            epsilon: 0.01
        }
    }

    // Behavior: فیزیک فنری برای _scaleY
    Behavior on _scaleY {
        SpringAnimation {
            spring: root.stiffness
            damping: root.damping
            epsilon: 0.01
        }
    }

    // Behavior: فیزیک فنری برای _rotation (با سفتی کمتر)
    Behavior on _rotation {
        SpringAnimation {
            spring: root.stiffness * 0.5
            damping: root.damping
            epsilon: 0.05
        }
    }

    // ============================================================
    // ۶. بصری (Visual)
    // ============================================================

    // مستطیل اصلی با gradient برای عمق
    Rectangle {
        id: blob
        anchors.fill: parent
        color: root.color
        radius: root.radius

        // gradient داخلی برای حس سه‌بعدی (روشن در بالا، تیره در پایین)
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop {
                position: 0.0
                color: Qt.rgba(1, 1, 1, root.color.a * 0.08)
            }
            GradientStop {
                position: 1.0
                color: Qt.rgba(0, 0, 0, root.color.a * 0.10)
            }
        }

        // حاشیه نازک برای تعریف لبه
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: parent.radius
            border.color: root.borderColor
            border.width: root.borderWidth
            z: 1
        }

        Behavior on color {
            ColorAnimation {
                duration: Animations.medium02
                easing.type: Animations.smooth
            }
        }

        Behavior on radius {
            NumberAnimation {
                duration: Animations.medium02
                easing.type: Animations.smooth
            }
        }
    }
}
