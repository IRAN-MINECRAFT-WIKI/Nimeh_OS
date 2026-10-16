// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Personalization.qml — صفحه‌ی شخصی‌سازی
// ============================================================
// گرید ۶ والپیپر (با انتخاب محلی) و picker رنگ accent (۴ swatch).

import QtQuick
import ".."

Item {
    id: root

    // ── انتخاب محلی ──
    property int selectedWallpaper: 0
    property color selectedAccent: SettingsTheme.accent

    // ── ۶ گرادیان والپیپر ──
    readonly property var wallpapers: [
        { c1: "#0f1420", c2: "#2b7fe0", name: "آبی عمیق" },
        { c1: "#1a1330", c2: "#4a9eff", name: "بنفش شب" },
        { c1: "#0a0e27", c2: "#22c55e", name: "جنگل" },
        { c1: "#3a1a30", c2: "#f59e0b", name: "غروب" },
        { c1: "#0f1420", c2: "#ef4444", name: "شفق" },
        { c1: "#1e2538", c2: "#6eb0ff", name: "مه" }
    ]

    // ── ۴ swatch رنگ accent ──
    readonly property var accents: [
        { color: "#4a9eff", name: "آبی" },
        { color: "#22c55e", name: "سبز" },
        { color: "#f59e0b", name: "کهربایی" },
        { color: "#ef4444", name: "قرمز" }
    ]

    // ── عنوان صفحه ──
    Text {
        id: header
        anchors.top: parent.top
        anchors.right: parent.right
        text: "شخصی‌سازی"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 24
        font.weight: Font.DemiBold
    }

    // ── بخش والپیپر ──
    Text {
        id: wallpaperHeader
        anchors { top: header.bottom; topMargin: 20; right: parent.right }
        text: "🖼 پس‌زمینه"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 14
        font.weight: Font.Medium
    }

    Grid {
        id: wallpaperGrid
        anchors { top: wallpaperHeader.bottom; topMargin: 12; left: parent.left; right: parent.right }
        columns: 3
        spacing: 10
        width: parent.width

        Repeater {
            model: root.wallpapers
            delegate: Rectangle {
                width: (parent.width - 20) / 3
                height: 84
                radius: SettingsTheme.rMd
                border.width: root.selectedWallpaper === index ? 2 : 1
                border.color: root.selectedWallpaper === index ? SettingsTheme.accent : SettingsTheme.border
                Behavior on border.color { ColorAnimation { duration: 120 } }

                gradient: Gradient {
                    GradientStop { position: 0; color: modelData.c1 }
                    GradientStop { position: 1; color: modelData.c2 }
                }

                Text {
                    anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 8 }
                    text: modelData.name
                    color: "#ffffff"
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }

                // ── چک‌مارک وقتی انتخاب شده ──
                Rectangle {
                    visible: root.selectedWallpaper === index
                    width: 22; height: 22; radius: 11
                    anchors { top: parent.top; left: parent.left; topMargin: 8; leftMargin: 8 }
                    color: SettingsTheme.accent
                    Text {
                        anchors.centerIn: parent
                        text: "✓"
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selectedWallpaper = index
                }
            }
        }
    }

    // ── بخش رنگ accent ──
    Text {
        id: accentHeader
        anchors { top: wallpaperGrid.bottom; topMargin: 26; right: parent.right }
        text: "🎨 رنگ اصلی"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 14
        font.weight: Font.Medium
    }

    Row {
        id: accentRow
        anchors { top: accentHeader.bottom; topMargin: 12; right: parent.right }
        spacing: 14
        layoutDirection: Qt.RightToLeft

        Repeater {
            model: root.accents
            delegate: Rectangle {
                width: 44
                height: 44
                radius: 22
                color: modelData.color
                border.width: root.selectedAccent === modelData.color ? 3 : 1
                border.color: root.selectedAccent === modelData.color ? "#ffffff" : SettingsTheme.borderHi
                Behavior on border.width { NumberAnimation { duration: 120 } }

                // حلقه‌ی داخلی سفید وقتی انتخاب شده
                Rectangle {
                    visible: root.selectedAccent === modelData.color
                    anchors.centerIn: parent
                    width: 14; height: 14; radius: 7
                    color: "#ffffff"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selectedAccent = modelData.color
                }

                Text {
                    anchors { top: parent.bottom; topMargin: 4; horizontalCenter: parent.horizontalCenter }
                    text: modelData.name
                    color: SettingsTheme.textMute
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 10
                }
            }
        }
    }
}
