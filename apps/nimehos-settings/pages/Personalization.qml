// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Personalization.qml — صفحه‌ی شخصی‌سازی
// ============================================================
// گرید ۶ والپیپر (با انتخاب محلی) + ۴ swatch رنگ accent (با حلقه‌ی سفید)
// + سوییچ حالت تاریک/روشن (محلی) + فهرست ۷ آیتم chevron
// (پس‌زمینه، رنگ‌ها، تم‌ها، قفل صفحه، شروع، نوار وظیفه، فونت‌ها).

import QtQuick
import ".."

Item {
    id: root
    anchors.fill: parent

    // ── انتخاب محلی ──
    property int selectedWallpaper: 0
    property int selectedAccent: 0
    property bool darkMode: true

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

    Flickable {
        id: flick
        anchors {
            top: header.bottom
            topMargin: 20
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentWidth: width
        contentHeight: col.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        Column {
            id: col
            width: parent.width
            spacing: 18

            // ── بخش والپیپر ──
            Text {
                text: "پس‌زمینه"
                color: SettingsTheme.text
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 14
                font.weight: Font.Medium
                anchors.right: parent.right
            }

            Grid {
                id: wallpaperGrid
                width: parent.width
                columns: 3
                spacing: 10

                Repeater {
                    model: root.wallpapers
                    delegate: Rectangle {
                        width: (parent.width - 20) / 3
                        height: 84
                        radius: SettingsTheme.rMd
                        border.width: root.selectedWallpaper === index ? 2 : 1
                        border.color: root.selectedWallpaper === index ? SettingsTheme.accent : SettingsTheme.border
                        Behavior on border.color { ColorAnimation { duration: 120 } }
                        Behavior on border.width { NumberAnimation { duration: 120 } }

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

                        // چک‌مارک وقتی انتخاب شده — Canvas
                        Canvas {
                            visible: root.selectedWallpaper === index
                            width: 22; height: 22
                            anchors { top: parent.top; left: parent.left; topMargin: 8; leftMargin: 8 }
                            onPaint: {
                                const ctx = getContext("2d")
                                ctx.reset()
                                ctx.fillStyle = SettingsTheme.accent
                                ctx.beginPath()
                                ctx.arc(11, 11, 11, 0, 2 * Math.PI)
                                ctx.fill()
                                ctx.strokeStyle = "#ffffff"
                                ctx.lineWidth = 2
                                ctx.lineCap = "round"
                                ctx.lineJoin = "round"
                                ctx.beginPath()
                                ctx.moveTo(6, 11); ctx.lineTo(10, 15); ctx.lineTo(16, 8)
                                ctx.stroke()
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
                text: "رنگ اصلی"
                color: SettingsTheme.text
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 14
                font.weight: Font.Medium
                anchors.right: parent.right
            }

            Row {
                id: accentRow
                width: parent.width
                spacing: 18
                layoutDirection: Qt.RightToLeft

                Repeater {
                    model: root.accents
                    delegate: Column {
                        spacing: 6
                        Rectangle {
                            width: 44
                            height: 44
                            radius: 22
                            color: modelData.color
                            border.width: root.selectedAccent === index ? 3 : 1
                            border.color: root.selectedAccent === index ? "#ffffff" : SettingsTheme.borderHi
                            Behavior on border.width { NumberAnimation { duration: 120 } }

                            // حلقه‌ی داخلی سفید وقتی انتخاب شده
                            Rectangle {
                                visible: root.selectedAccent === index
                                anchors.centerIn: parent
                                width: 14; height: 14; radius: 7
                                color: "#ffffff"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectedAccent = index
                            }
                        }
                        Text {
                            text: modelData.name
                            color: root.selectedAccent === index ? SettingsTheme.text : SettingsTheme.textMute
                            font.family: SettingsTheme.fontPersian
                            font.pixelSize: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            // ── سوییچ حالت تاریک/روشن ──
            SettingRow {
                width: parent.width
                iconKind: "dark"
                title: "حالت تاریک"
                description: "تم تیره برای کل سیستم"
                SettingsSwitch {
                    anchors.centerIn: parent
                    checked: root.darkMode
                    onToggled: (c) => root.darkMode = c
                }
            }

            // ── فهرست ۷ آیتم ──
            Text {
                text: "بیشتر"
                color: SettingsTheme.text
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 14
                font.weight: Font.Medium
                anchors.right: parent.right
            }

            Column {
                width: parent.width
                spacing: 8

                ChevronRow { width: parent.width; iconKind: "image";     title: "پس‌زمینه";         description: "تصویر، اسلایدشو یا رنگ ساده" }
                ChevronRow { width: parent.width; iconKind: "palette";   title: "رنگ‌ها";           description: "رنگ اصلی، حالت تاریک/روشن" }
                ChevronRow { width: parent.width; iconKind: "themes";    title: "تم‌ها";            description: "تم پیش‌فرض سیستم" }
                ChevronRow { width: parent.width; iconKind: "lockscreen";title: "قفل صفحه";        description: "پس‌زمینه‌ی قفل، زمان نمایش" }
                ChevronRow { width: parent.width; iconKind: "start";     title: "شروع";             description: "نمایش، پوشه‌ها، برنامه‌های پین‌شده" }
                ChevronRow { width: parent.width; iconKind: "taskbar";   title: "نوار وظیفه";      description: "آیکون‌ها، گوشه‌ها، رفتار" }
                ChevronRow { width: parent.width; iconKind: "fonts";     title: "فونت‌ها";           description: "اندازه، خانواده‌ی فونت" }
            }
        }
    }
}
