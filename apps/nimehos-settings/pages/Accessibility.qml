// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Accessibility.qml — صفحه‌ی دسترسی‌پذیری
// ============================================================
// اسلایدر اندازه‌ی متن (محلی) + سوییچ هشدارهای تصویری (محلی) +
// سوییچ کنتراست بالا (محلی) + نوار روایت‌گر غیرفعال («در انتظار سرویس»).

import QtQuick
import ".."

Item {
    id: root
    anchors.fill: parent

    // ── حالت‌های محلی ──
    property real textSize: 1.0
    property bool visualAlerts: false
    property bool highContrast: false

    // ── عنوان صفحه ──
    Text {
        id: header
        anchors.top: parent.top
        anchors.right: parent.right
        text: "دسترسی‌پذیری"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 24
        font.weight: Font.DemiBold
    }

    Text {
        id: subheader
        anchors { top: header.bottom; topMargin: 6; right: parent.right }
        text: "ابزارهایی برای دید، شنیدایی و تعامل آسان‌تر"
        color: SettingsTheme.textMute
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 12
    }

    // ── بخش بینایی ──
    Text {
        id: visionHeader
        anchors { top: subheader.bottom; topMargin: 18; right: parent.right }
        text: "بینایی"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 14
        font.weight: Font.Medium
    }

    // ── اسلایدر اندازه‌ی متن ──
    Rectangle {
        id: textSliderCard
        anchors { top: visionHeader.bottom; topMargin: 10; left: parent.left; right: parent.right }
        height: 84
        radius: SettingsTheme.rMd
        color: SettingsTheme.cardBg
        border.width: 1
        border.color: SettingsTheme.border

        Canvas {
            id: tsIcon
            width: 36; height: 36
            anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.fillStyle = SettingsTheme.accentSoft
                ctx.font = "bold 14px " + SettingsTheme.fontPersian
                ctx.fillText("Aa", 6, 22)
            }
        }

        Column {
            anchors { right: tsIcon.left; rightMargin: 12; verticalCenter: parent.verticalCenter; left: tsSlider.right; leftMargin: 12 }
            spacing: 2
            Text {
                text: "اندازه‌ی متن"
                color: SettingsTheme.text
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 13
                font.weight: Font.Medium
            }
            Text {
                text: Math.round(root.textSize * 100) + "٪"
                color: SettingsTheme.textMute
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 11
            }
        }

        SettingsSlider {
            id: tsSlider
            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
            width: 200
            from: 0.75; to: 1.5
            value: root.textSize
            onMoved: (v) => root.textSize = v
        }
    }

    // ── سوییچ هشدارهای تصویری ──
    SettingRow {
        id: visualAlertsRow
        anchors { top: textSliderCard.bottom; topMargin: 10; left: parent.left; right: parent.right }
        width: parent.width
        iconKind: "eye"
        title: "هشدارهای تصویری"
        description: "نمایش هشدار صوتی به‌صورت تصویری"
        SettingsSwitch {
            anchors.centerIn: parent
            checked: root.visualAlerts
            onToggled: (c) => root.visualAlerts = c
        }
    }

    // ── سوییچ کنتراست بالا ──
    SettingRow {
        id: contrastRow
        anchors { top: visualAlertsRow.bottom; topMargin: 10; left: parent.left; right: parent.right }
        width: parent.width
        iconKind: "info"
        title: "کنتراست بالا"
        description: "افزایش تضاد رنگ برای خوانایی بهتر"
        SettingsSwitch {
            anchors.centerIn: parent
            checked: root.highContrast
            onToggled: (c) => root.highContrast = c
        }
    }

    // ── بخش شنیدایی/تعامل ──
    Text {
        id: audioHeader
        anchors { top: contrastRow.bottom; topMargin: 18; right: parent.right }
        text: "شنیدایی و تعامل"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 14
        font.weight: Font.Medium
    }

    Column {
        id: listCol
        anchors {
            top: audioHeader.bottom
            topMargin: 10
            left: parent.left
            right: parent.right
        }
        spacing: 8
        width: parent.width

        // نوار روایت‌گر — غیرفعال
        ChevronRow {
            width: parent.width
            iconKind: "info"
            title: "نوار روایت‌گر (Narrator)"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "info"
            title: "زیرنویس بسته‌ی زنده"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "info"
            title: "صفحه‌کلید تصویری"
            description: "نمایش صفحه‌کلید روی صفحه"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "info"
            title: "کنترل با چشم"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
    }
}
