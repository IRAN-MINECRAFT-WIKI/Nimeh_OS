// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// SettingsTheme.qml — توکن‌های طراحی اپلیکیشن تنظیمات NimehOS
// ============================================================
//
// این فایل یک Singleton است که تمام توکن‌های رنگ، فونت، شعاع و فاصله‌ی
// اپلیکیشن تنظیمات را بر اساس reference HTML در خود نگه می‌دارد.
// تمام صفحات و کامپوننت‌ها باید از این سینگلتون استفاده کنند و از
// رنگ‌های هاردکد شده پرهیز کنند.
//
// نحوه استفاده:
//   import ".."   // از داخل pages/
//   Rectangle { color: SettingsTheme.bgCard; radius: SettingsTheme.rMd }

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    // ============================================================
    // ۱. پس‌زمینه‌ها (Backgrounds)
    // ============================================================

    readonly property color bgDeep:   "#0f1420"
    readonly property color bgBase:   "#141a28"
    readonly property color bgCard:   "#1e2538"

    // ============================================================
    // ۲. حاشیه‌ها (Borders)
    // ============================================================

    readonly property color border:    Qt.rgba(1, 1, 1, 0.06)
    readonly property color borderHi:  Qt.rgba(1, 1, 1, 0.14)

    // ============================================================
    // ۳. متن (Text)
    // ============================================================

    readonly property color text:     "#e8ecf4"
    readonly property color textDim:  "#a0a8bc"
    readonly property color textMute: "#6b7289"

    // ============================================================
    // ۴. رنگ‌های تأکیدی (Accent)
    // ============================================================

    readonly property color accent:      "#4a9eff"
    readonly property color accentSoft:  "#6eb0ff"
    readonly property color accentDeep:  "#2b7fe0"

    // ============================================================
    // ۵. رنگ‌های وضعیت (Status)
    // ============================================================

    readonly property color green: "#22c55e"
    readonly property color red:   "#ef4444"
    readonly property color amber: "#f59e0b"

    // ============================================================
    // ۶. سطوح شفاف (Surfaces)
    // ============================================================

    // پس‌زمینه‌ی کارت‌ها — rgba(255,255,255,0.06)
    readonly property color cardBg: Qt.rgba(1, 1, 1, 0.06)
    // پس‌زمینه‌ی پنل شیشه‌ای — rgba(255,255,255,0.12)
    readonly property color glassBg: Qt.rgba(1, 1, 1, 0.12)
    // پس‌زمینه‌ی ورودی‌ها (inputs)
    readonly property color inputBg: Qt.rgba(1, 1, 1, 0.04)
    // هاله‌ی پشت پنجره (dim)
    readonly property color dim: Qt.rgba(0, 0, 0, 0.45)

    // ============================================================
    // ۷. شعاع گوشه‌ها (Radii) — px
    // ============================================================

    readonly property real rSm: 10
    readonly property real rMd: 14
    readonly property real rLg: 20
    readonly property real rXl: 24

    // ============================================================
    // ۸. فاصله‌گذاری (Spacing) — px
    // ============================================================

    readonly property real spXs:  4
    readonly property real spSm:  8
    readonly property real spMd:  16
    readonly property real spLg:  24
    readonly property real spXl:  32

    // ============================================================
    // ۹. فونت‌ها (Fonts)
    // ============================================================

    // فونت فارسی: Vazirmatn
    readonly property string fontPersian: "Vazirmatn"
    // فونت لاتین/اعداد: Inter
    readonly property string fontLatin:   "Inter"

    // ============================================================
    // ۱۰. اندازه‌های پنجره (Window metrics)
    // ============================================================

    readonly property real windowWidth:  1120
    readonly property real windowHeight: 720
    readonly property real titlebarHeight: 46
    readonly property real sidebarWidth:  270
}
