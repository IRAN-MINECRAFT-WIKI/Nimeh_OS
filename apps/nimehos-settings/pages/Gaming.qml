// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Gaming.qml — صفحه‌ی بازی
// ============================================================
// سوییچ Game Mode (محلی) + سوییچ Xbox Game Bar (محلی) +
// فهرست تنظیمات ضبط (همگی غیرفعال، «در انتظار سرویس»).

import QtQuick
import ".."

Item {
    id: root
    anchors.fill: parent

    // ── حالت‌های محلی ──
    property bool gameMode: false
    property bool xboxGameBar: false

    // ── عنوان صفحه ──
    Text {
        id: header
        anchors.top: parent.top
        anchors.right: parent.right
        text: "بازی"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 24
        font.weight: Font.DemiBold
    }

    Text {
        id: subheader
        anchors { top: header.bottom; topMargin: 6; right: parent.right }
        text: "تنظیمات بازی، Game Bar و ضبط"
        color: SettingsTheme.textMute
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 12
    }

    // ── سوییچ Game Mode ──
    SettingRow {
        id: gameModeRow
        anchors { top: subheader.bottom; topMargin: 18; left: parent.left; right: parent.right }
        width: parent.width
        iconKind: "controller"
        title: "Game Mode"
        description: "اولویت دادن به بازی برای عملکرد بهتر"
        SettingsSwitch {
            anchors.centerIn: parent
            checked: root.gameMode
            onToggled: (c) => root.gameMode = c
        }
    }

    // ── سوییچ Xbox Game Bar ──
    SettingRow {
        id: xboxRow
        anchors { top: gameModeRow.bottom; topMargin: 10; left: parent.left; right: parent.right }
        width: parent.width
        iconKind: "controller"
        title: "Xbox Game Bar"
        description: "ضبط، اسکرین‌شات و همپوشانی بازی"
        SettingsSwitch {
            anchors.centerIn: parent
            checked: root.xboxGameBar
            onToggled: (c) => root.xboxGameBar = c
        }
    }

    // ── فهرست تنظیمات ضبط ──
    Text {
        id: capturesHeader
        anchors { top: xboxRow.bottom; topMargin: 18; right: parent.right }
        text: "ضبط‌ها"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 14
        font.weight: Font.Medium
    }

    Column {
        id: listCol
        anchors {
            top: capturesHeader.bottom
            topMargin: 10
            left: parent.left
            right: parent.right
        }
        spacing: 8
        width: parent.width

        ChevronRow {
            width: parent.width
            iconKind: "video"
            title: "ضبط بازی"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "camera"
            title: "اسکرین‌شات"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "info"
            title: "محل ذخیره‌ی ضبط‌ها"
            statusText: "نامشخص"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "info"
            title: "کیفیت ضبط"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
    }

    // ── یادداشت ──
    Rectangle {
        id: note
        anchors { top: listCol.bottom; topMargin: 18; left: parent.left; right: parent.right }
        height: 64
        radius: SettingsTheme.rMd
        color: SettingsTheme.cardBg
        border.width: 1
        border.color: SettingsTheme.border
        opacity: 0.7

        Text {
            anchors.centerIn: parent
            text: "تنظیمات ضبط در فاز بعدی به‌وسیله‌ی یک سرویس Python ارائه می‌شود."
            color: SettingsTheme.textMute
            font.family: SettingsTheme.fontPersian
            font.pixelSize: 11
            horizontalAlignment: Text.AlignHCenter
            width: parent.width - 32
            wrapMode: Text.WordWrap
        }
    }
}
