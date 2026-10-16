// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Network.qml — صفحه‌ی شبکه و اینترنت
// ============================================================
// وضعیت Wi-Fi (نمایش «در انتظار سرویس» — بدون nmcli) و سوییچ
// حالت هواپیما (تنها یک پراپرتی محلی — هیچ فرمان سیستمی اجرا نمی‌شود).

import QtQuick
import ".."

Item {
    id: root

    // ── پراپرتی محلی — هیچ backend متصل نیست ──
    property bool airplaneMode: false

    // ── عنوان صفحه ──
    Text {
        id: header
        anchors.top: parent.top
        anchors.right: parent.right
        text: "شبکه و اینترنت"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 24
        font.weight: Font.DemiBold
    }

    Column {
        id: list
        anchors {
            top: header.bottom
            topMargin: 20
            left: parent.left
            right: parent.right
        }
        spacing: 10
        width: parent.width

        // ── کارت وضعیت Wi-Fi ──
        Rectangle {
            width: parent.width
            height: 90
            radius: SettingsTheme.rMd
            color: SettingsTheme.cardBg
            border.width: 1
            border.color: SettingsTheme.border

            Rectangle {
                id: wifiIcon
                width: 36; height: 36; radius: 10
                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                color: Qt.rgba(1, 1, 1, 0.05)
                border.width: 1; border.color: SettingsTheme.border

                // ── نمودار میله‌ای Wi-Fi (تزئینی) ──
                Row {
                    anchors.centerIn: parent
                    spacing: 2
                    layoutDirection: Qt.LeftToRight

                    Rectangle { width: 3; height: 5;  radius: 1; color: SettingsTheme.textMute; anchors.bottom: parent.bottom }
                    Rectangle { width: 3; height: 9;  radius: 1; color: SettingsTheme.textMute; anchors.bottom: parent.bottom }
                    Rectangle { width: 3; height: 13; radius: 1; color: SettingsTheme.textMute; anchors.bottom: parent.bottom }
                    Rectangle { width: 3; height: 17; radius: 1; color: SettingsTheme.textMute; anchors.bottom: parent.bottom }
                }
            }

            Column {
                anchors { left: wifiIcon.right; leftMargin: 12; verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 14 }
                spacing: 2
                Text {
                    text: "Wi-Fi"
                    color: SettingsTheme.text
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
                Text {
                    text: "در انتظار سرویس"
                    color: SettingsTheme.amber
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 11
                }
            }
        }

        // ── کارت شبکه‌ی سیمی (Ethernet) ──
        Rectangle {
            width: parent.width
            height: 90
            radius: SettingsTheme.rMd
            color: SettingsTheme.cardBg
            border.width: 1
            border.color: SettingsTheme.border

            Rectangle {
                id: ethIcon
                width: 36; height: 36; radius: 10
                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                color: Qt.rgba(1, 1, 1, 0.05)
                border.width: 1; border.color: SettingsTheme.border
                Text { anchors.centerIn: parent; text: "🔗"; font.pixelSize: 16 }
            }

            Column {
                anchors { left: ethIcon.right; leftMargin: 12; verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: 14 }
                spacing: 2
                Text {
                    text: "اتصال سیمی (Ethernet)"
                    color: SettingsTheme.text
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
                Text {
                    text: "در انتظار سرویس"
                    color: SettingsTheme.amber
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 11
                }
            }
        }

        // ── سوییچ حالت هواپیما ──
        SettingRow {
            iconText: "✈"
            title: "حالت هواپیما"
            description: "قطع تمام ارتباط‌های بی‌سیم"
            width: parent.width
            SettingsSwitch {
                anchors.centerIn: parent
                checked: root.airplaneMode
                onToggled: (c) => root.airplaneMode = c
            }
        }
    }
}
