// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// StateLayer.qml — لایه تعامل Material 3 با افکت ripple
// ============================================================
//
// این کامپوننت یک MouseArea است که روی هر آیتم والد قرار می‌گیرد و:
//   - هنگام hover: یک overlay نازک (8% opacity) نشان می‌دهد.
//   - هنگام press: overlay پررنگ‌تر (12% opacity).
//   - هنگام click: افکت ripple از نقطه کلیک گسترش می‌یابد و سپس fade می‌شود.
//
// الگوبرداری شده از:
//   - components/StateLayer.qml در caelestia-shell v2.5.0 (۱۹۹ خط)
//   - بخش ۴.۸ تحلیل caelestia (الگوهای hover و press)
//
// تفاوت با caelestia:
//   - به‌جای Shape با PathArc و RadialGradient، از Rectangle ساده با clip:true
//     برای ripple استفاده می‌کنیم (ساده‌تر، بدون نیاز به QtQuick.Shapes).
//   - duration‌ها و easing‌ها از Animations.qml می‌آیند.
//   - radius از والد خوانده می‌شود (با null-safe access).
//
// نحوه استفاده:
//   import NimehOS
//
//   Rectangle {
//       width: 100; height: 40; radius: 20
//       color: Theme.accent
//
//       Text { anchors.centerIn: parent; text: "Click"; color: Theme.textOnAccent }
//
//       StateLayer {
//           color: Theme.textOnAccent
//           rippleEnabled: true
//       }
//   }

import QtQuick

MouseArea {
    id: root

    // ============================================================
    // ۱. پراپرتی‌های عمومی (Public API)
    // ============================================================

    // رنگ overlay و ripple. معمولاً رنگ متن روی والد (مثلاً onPrimary روی Primary).
    property color color: Theme.text
    // ضریب opacity کلی (برای کاهش شدت در صورت نیاز).
    property real opacity: 1.0
    // فعال‌سازی افکت ripple هنگام کلیک.
    property bool rippleEnabled: true
    // غیرفعال‌سازی کامل (state layer نشان داده نمی‌شود).
    property bool disabled: false

    // ============================================================
    // ۲. وضعیت داخلی (Internal State)
    // ============================================================

    // موقعیت کلیک برای شروع ripple
    property real _pressX: width / 2
    property real _pressY: height / 2
    // شعاع فعلی ripple (با انیمیشن از 0 تا _endRadiusAtPress)
    property real _rippleRadius: 0
    // opacity فعلی ripple (با fadeAnim به 0 می‌رسد)
    property real _rippleOpacity: 0
    // شعاع هدف ripple (در زمان کلیک ثبت می‌شود)
    property real _endRadiusAtPress: 0

    // opacity حالت (hover/press) — از Behavior برای نرم شدن استفاده می‌شود
    // (readonly حذف شده تا Behavior بتواند مقدار را در حین انیمیشن بنویسد)
    property real _stateOpacity: {
        if (root.disabled) return 0
        if (root.pressed) return 0.12
        if (root.containsMouse) return 0.08
        return 0
    }

    // ماکزیمم فاصله از نقطه کلیک تا هر گوشه (برای target ripple radius)
    function _maxRadius(): real {
        const px = root._pressX
        const py = root._pressY
        const d1 = Math.sqrt(px * px + py * py)
        const d2 = Math.sqrt((root.width - px) ** 2 + py * py)
        const d3 = Math.sqrt(px * px + (root.height - py) ** 2)
        const d4 = Math.sqrt((root.width - px) ** 2 + (root.height - py) ** 2)
        return Math.max(d1, d2, d3, d4) * 1.3
    }

    // ============================================================
    // ۳. تنظیمات MouseArea
    // ============================================================

    anchors.fill: parent
    enabled: !root.disabled
    hoverEnabled: true
    cursorShape: root.disabled ? undefined : Qt.PointingHandCursor
    // جلوگیری از steal موس توسط فرزندان (تا hover/state درست کار کند)
    preventStealing: true

    // ============================================================
    // ۴. هندلرهای رویداد (Event Handlers)
    // ============================================================

    // هنگام کلیک: ثبت موقعیت، شروع ripple
    onPressed: mouse => {
        if (!root.rippleEnabled) return
        root._pressX = mouse.x
        root._pressY = mouse.y
        root._endRadiusAtPress = root._maxRadius()
        root._rippleRadius = 0
        root._rippleOpacity = 0.12 * root.opacity
        rippleAnim.restart()
    }

    // هنگام رها کردن: fade out ripple
    onReleased: _ => {
        if (root._rippleOpacity > 0)
            fadeAnim.start()
    }

    // Note: نسخه caelestia یک هندلر onCircleRadiusChanged نیز داشت تا اگر ripple
    // به انتها رسید ولی هنوز pressed بود، fade را شروع کند. در نسخه QML-only
    // ما از onRunningChanged در rippleAnim استفاده می‌کنیم زیرا QML نام signal
    // handler برای پراپرتی‌های زیرخط‌دار (مثل _rippleRadius) را به‌درستی تشخیص
    // نمی‌دهد.

    // ============================================================
    // ۵. انیمیشن‌ها (Animations)
    // ============================================================

    // انیمیشن گسترش ripple (600ms = 2x expressiveSlowEffects)
    NumberAnimation {
        id: rippleAnim
        target: root
        property: "_rippleRadius"
        from: 0
        to: root._endRadiusAtPress
        duration: 600
        easing.type: Animations.standard
        alwaysRunToEnd: true

        // وقتی انیمیشن تمام شد، اگر هنوز pressed نیستیم و fade شروع نشده، fade را شروع کن
        onRunningChanged: {
            if (!running && !root.pressed && !fadeAnim.running && root._rippleOpacity > 0)
                fadeAnim.start()
        }
    }

    // انیمیشن fade out ripple (300ms = expressiveSlowEffects)
    NumberAnimation {
        id: fadeAnim
        target: root
        property: "_rippleOpacity"
        to: 0
        duration: 300
        easing.type: Animations.smooth
    }

    // Behavior برای تغییر نرم _stateOpacity (مطابق DefaultEffects در caelestia)
    Behavior on _stateOpacity {
        NumberAnimation {
            duration: 200
            easing.type: Animations.smooth
        }
    }

    // ============================================================
    // ۶. لایه overlay پایه (Base Hover/Press Overlay)
    // ============================================================
    //
    // یک Rectangle ساده با opacity = _stateOpacity. این overlay هم روی
    // hover و هم روی press فعال است. radius از والد خوانده می‌شود.

    Rectangle {
        id: baseOverlay
        anchors.fill: parent
        color: root.color
        opacity: root._stateOpacity * root.opacity
        // qmllint disable missing-property
        radius: root.parent ? (root.parent.radius || 0) : 0
        // qmllint enable missing-property
        visible: opacity > 0

        Behavior on color {
            ColorAnimation {
                duration: Animations.medium02
                easing.type: Animations.smooth
            }
        }
    }

    // ============================================================
    // ۷. افکت Ripple (Click Ripple)
    // ============================================================
    //
    // یک Rectangle با clip:true (و radius والد) که دایره ripple را درون
    // خود نگه می‌دارد. clip باعث می‌شود ripple از گوشه‌های گرد والد بیرون
    // نزند.

    Rectangle {
        id: rippleClip
        anchors.fill: parent
        color: "transparent"
        // qmllint disable missing-property
        radius: root.parent ? (root.parent.radius || 0) : 0
        // qmllint enable missing-property
        clip: true
        visible: root._rippleOpacity > 0

        // دایره ripple — یک Rectangle با radius = نصف عرض (دایره کامل)
        Rectangle {
            id: rippleCircle
            x: root._pressX - root._rippleRadius
            y: root._pressY - root._rippleRadius
            width: root._rippleRadius * 2
            height: root._rippleRadius * 2
            radius: root._rippleRadius
            color: root.color
            opacity: root._rippleOpacity

            Behavior on color {
                ColorAnimation {
                    duration: Animations.medium02
                    easing.type: Animations.smooth
                }
            }
        }
    }
}
