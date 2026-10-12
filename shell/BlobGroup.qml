// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// BlobGroup.qml — ظرف مدیریت چند BlobRect با ترکیب بصری (نسخه QML-only)
// ============================================================
//
//
// با AABB intersection انجام می‌داد و shader SDF تمام blob‌های مجاور را در
// یک draw call با smin (smooth-min) با هم merge می‌کرد. نتیجه: blob‌های
// مجاور به‌صورت ارگانیک به‌هم متصل می‌شدند (نه simple overlay).
//
// محدودیت نسخه QML-only:
//   - بدون SDF shader، merge ارگانیک بین blob‌ها امکان‌پذیر نیست.
//   - به‌جای آن، از overlay شفاف + blur اختیاری برای حس بصری نزدیک‌تر استفاده
//     می‌کنیم. نتیجه تقریباً مشابه نیست ولی برای موارد استفاده معمولی
//     (panel‌های جدا) کافی است.
//
// الگوبرداری شده از:
//   - modules/drawers/ContentWindow.qml (الگوی استفاده از BlobGroup)
//
// نحوه استفاده:
//   import NimehOS
//
//   BlobGroup {
//       width: 400; height: 300
//       color: Theme.surface
//       blurEnabled: true
//
//       BlobRect { x: 0;   y: 0;   width: 200; height: 100 }
//       BlobRect { x: 200; y: 100; width: 200; height: 100 }
//   }

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects

Item {
    id: root

    // ============================================================
    // ۱. پراپرتی‌های عمومی (Public API)
    // ============================================================

    // رنگ پیش‌فرض برای BlobRect‌های فرزند (هر فرزند می‌تواند override کند).
    property color color: Theme.surface
    // شدت blur برای ترکیب بصری (0..1). 0 = بدون blur.
    property real smoothing: 0.0
    // فعال‌سازی blur کلی روی گروه.
    property bool blurEnabled: false
    // شدت shadow (0..1). 0 = بدون shadow.
    property real shadowOpacity: 0.4
    // فعال‌سازی shadow کلی روی گروه.
    property bool shadowEnabled: true

    // ============================================================
    // ۲. ظرف فرزندان (Children Container)
    // ============================================================
    //
    // default property alias باعث می‌شود فرزندان مستقیماً در BlobGroup
    // تعریف شوند و به container منتقل شوند.

    default property alias contents: contentItem.children

    Item {
        id: contentItem
        anchors.fill: parent

        // layer.enabled برای اعمال افکت (blur/shadow) روی کل گروه.
        // این کار یک offscreen texture از همه فرزندان می‌سازد و سپس
        // MultiEffect را روی آن اعمال می‌کند.
        layer.enabled: root.blurEnabled || root.shadowEnabled
        layer.effect: MultiEffect {
            // blur برای ترکیب بصری blob‌های مجاور
            blurEnabled: root.blurEnabled && root.smoothing > 0
            blur: Math.min(1.0, root.smoothing)
            blurMax: 16
            shadowEnabled: root.shadowEnabled
            shadowColor: Qt.alpha(Theme.m3shadow, root.shadowOpacity)
            shadowBlur: 0.7
            shadowVerticalOffset: 6
        }
    }

    // ============================================================
    // ۳. رفتار نرم برای تغییر رنگ
    // ============================================================

    Behavior on color {
        ColorAnimation {
            duration: Animations.medium02
            easing.type: Animations.smooth
        }
    }

    Behavior on smoothing {
        NumberAnimation {
            duration: Animations.medium02
            easing.type: Animations.smooth
        }
    }

    Behavior on shadowOpacity {
        NumberAnimation {
            duration: Animations.slow01
            easing.type: Animations.smooth
        }
    }
}
