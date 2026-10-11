// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// GlassPanel.qml — پنل شیشه‌ای/اکریلیک قابل استفاده مجدد
// ============================================================
//
// این کامپوننت یک پنل شیشه‌ای با ویژگی‌های زیر می‌سازد:
//   - پس‌زمینه نیمه‌شفاف با gradient عمودی برای عمق بصری
//   - حاشیه نازک با gradient (روشن در بالا، تیره در پایین)
//   - سایه اختیاری (با شدت قابل تنظیم)
//   - پرچم blurEnabled که alpha را برای هماهنگی با Hyprland blur تنظیم می‌کند
//
// توجه: blur واقعی توسط Hyprland (layerrule blur) انجام می‌شود، نه توسط QML.
// این کامپوننت فقط alpha را تنظیم می‌کند تا blur از زیر پنل دیده شود.
// برای فعال‌سازی blur در Hyprland:
//   layerrule blur, namespace:nimehos-*
//
// الگوبرداری شده از:
//   - components/effects/Elevation.qml در caelestia (سیستم سایه ۵ سطحی)
//   - بخش ۳.۵ تحلیل caelestia (سیستم Transparency / Acrylic)
//   - بخش ۵.۲ تحلیل caelestia (Elevation)
//
// نحوه استفاده:
//   import NimehOS
//
//   GlassPanel {
//       width: 300; height: 200
//       radius: Theme.radiusXl
//       tintOpacity: 0.7
//       blurEnabled: true
//       elevation: 2
//
//       Text {
//           anchors.centerIn: parent
//           text: "سلام NimehOS"
//           color: Theme.text
//       }
//   }

import QtQuick
import QtQuick.Effects

Rectangle {
    id: root

    // ============================================================
    // ۱. پراپرتی‌های عمومی (Public API)
    // ============================================================

    // شعاع گوشه‌ها. پیش‌فرض: radiusLg (14).
    property real radius: Theme.radiusLg
    // شدت tint پس‌زمینه (0..1). 0 = کاملاً شفاف، 1 = کاملاً کدر.
    property real tintOpacity: 0.7
    // فعال‌سازی blur (تنها alpha را تنظیم می‌کند، blur واقعی توسط Hyprland).
    property bool blurEnabled: true
    // شدت حاشیه (0..1).
    property real borderOpacity: 1.0
    // فعال‌سازی سایه.
    property bool shadowEnabled: true
    // سطح elevation (0..5) مطابق Material 3.
    property int elevation: 1

    // ============================================================
    // ۲. محاسبه مقادیر موثر (Effective Values)
    // ============================================================

    // اگر blur فعال است، tint کمی شفاف‌تر تا blur زیر آن دیده شود.
    // اگر blur غیرفعال است، tint پررنگ‌تر برای خوانایی کامل.
    readonly property real _effectiveTint: {
        const base = Math.max(0, Math.min(1, root.tintOpacity))
        return root.blurEnabled ? base : Math.min(1.0, base + 0.2)
    }

    // شدت سایه بر اساس elevation (مطابق Elevation.qml در caelestia).
    readonly property real _shadowAlpha: Math.max(0, Math.min(1, root.elevation * 0.10))
    readonly property real _shadowBlur: 0.3 + root.elevation * 0.10
    readonly property real _shadowOffset: root.elevation * 2

    // ============================================================
    // ۳. تنظیمات بصری پایه
    // ============================================================

    // radius و border
    radius: root.radius
    border.color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, root.borderOpacity)
    border.width: 1

    // gradient عمودی برای عمق (روشن‌تر در بالا، تیره‌تر در پایین).
    // مطابق caelestia، surface از Theme به‌عنوان رنگ پایه استفاده می‌شود.
    gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop {
            position: 0.0
            color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b,
                           Math.max(0, Math.min(1, root._effectiveTint + 0.04)))
        }
        GradientStop {
            position: 0.5
            color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b,
                           root._effectiveTint)
        }
        GradientStop {
            position: 1.0
            color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b,
                           Math.max(0, Math.min(1, root._effectiveTint - 0.04)))
        }
    }

    // ============================================================
    // ۴. سایه (Shadow) با MultiEffect
    // ============================================================
    //
    // از layer.effect MultiEffect برای سایه استفاده می‌کنیم (مشابه Elevation.qml).
    // وقتی shadowEnabled=false یا elevation=0، layer غیرفعال می‌شود تا هزینه
    // render کاهش یابد.

    layer.enabled: root.shadowEnabled && root.elevation > 0
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.alpha(Theme.m3shadow, root._shadowAlpha)
        shadowBlur: root._shadowBlur
        shadowVerticalOffset: root._shadowOffset
        shadowHorizontalOffset: 0
    }

    // ============================================================
    // ۵. حاشیه داخلی هایلایت (Inner Highlight)
    // ============================================================
    //
    // یک مستطیل نازک داخل پنل، در لبه بالا، با رنگ سفید کم‌رنگ برای حس
    // "نور از بالا". این تکنیک رایج در طراحی glass/acrylic است.

    Rectangle {
        id: topHighlight
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 1
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        height: 1
        color: Qt.rgba(1, 1, 1, 0.10)
        visible: root.radius > 0
        //TODO: clip to top radius (این مستطیل در گوشه‌های گرد تا حدودی بیرون می‌زند
        // ولی چون opacity کم است، چندان قابل مشاهده نیست.)
    }

    // ============================================================
    // ۶. رفتار نرم برای تغییرات
    // ============================================================

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

    Behavior on tintOpacity {
        NumberAnimation {
            duration: Animations.medium02
            easing.type: Animations.smooth
        }
    }

    Behavior on borderOpacity {
        NumberAnimation {
            duration: Animations.medium02
            easing.type: Animations.smooth
        }
    }

    Behavior on elevation {
        NumberAnimation {
            duration: Animations.slow01
            easing.type: Animations.smooth
        }
    }
}
