// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Network.qml — صفحه‌ی شبکه و اینترنت
// ============================================================
// وضعیت Wi-Fi (نمایش «در انتظار سرویس» — بدون nmcli) و سوییچ
// Wi-Fi (محلی)، اترنت «در انتظار سرویس»، حالت هواپیما (محلی).
// VPN، هات‌اسپات، پروکسی: آیتم‌های chevron غیرفعال (در انتظار سرویس).
// هیچ Process — هیچ nmcli — همه‌چیز تزئینی/محلی.

import QtQuick
import ".."

Item {
    id: root
    anchors.fill: parent

    // ── حالت‌های محلی ──
    property bool wifiEnabled: false
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
            spacing: 10

            // ── کارت وضعیت Wi-Fi ──
            Rectangle {
                width: parent.width
                height: 90
                radius: SettingsTheme.rMd
                color: SettingsTheme.cardBg
                border.width: 1
                border.color: SettingsTheme.border

                // آیکون Wi-Fi — Canvas
                Canvas {
                    id: wifiIcon
                    width: 36; height: 36
                    anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.reset()
                        ctx.strokeStyle = SettingsTheme.accentSoft
                        ctx.lineWidth = 1.6
                        ctx.lineCap = "round"
                        // قوس‌های Wi-Fi
                        ctx.beginPath()
                        ctx.arc(18, 24, 12, -Math.PI * 0.75, -Math.PI * 0.25)
                        ctx.arc(18, 24, 8, -Math.PI * 0.75, -Math.PI * 0.25)
                        ctx.arc(18, 24, 4, -Math.PI * 0.75, -Math.PI * 0.25)
                        ctx.stroke()
                    }
                }

                Column {
                    anchors { right: wifiIcon.left; rightMargin: 12; verticalCenter: parent.verticalCenter; left: wifiSwitch.left; leftMargin: 12 }
                    spacing: 2
                    Text {
                        text: "Wi-Fi"
                        color: SettingsTheme.text
                        font.family: SettingsTheme.fontPersian
                        font.pixelSize: 13
                        font.weight: Font.Medium
                    }
                    Text {
                        text: root.wifiEnabled ? "در انتظار سرویس" : "خاموش"
                        color: root.wifiEnabled ? SettingsTheme.amber : SettingsTheme.textMute
                        font.family: SettingsTheme.fontPersian
                        font.pixelSize: 11
                    }
                }

                SettingsSwitch {
                    id: wifiSwitch
                    anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                    checked: root.wifiEnabled
                    onToggled: (c) => root.wifiEnabled = c
                }
            }

            // ── کارت شبکه‌ی سیمی (Ethernet) ──
            SettingRow {
                width: parent.width
                iconKind: "ethernet"
                title: "اتصال سیمی (Ethernet)"
                description: "در انتظار سرویس"
                Item {
                    anchors.centerIn: parent
                    width: 100; height: 28
                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: Qt.rgba(1, 1, 1, 0.06)
                        border.width: 1
                        border.color: SettingsTheme.borderHi
                        Text {
                            anchors.centerIn: parent
                            text: "در انتظار سرویس"
                            color: SettingsTheme.amber
                            font.family: SettingsTheme.fontPersian
                            font.pixelSize: 10
                        }
                    }
                }
            }

            // ── حالت هواپیما ──
            SettingRow {
                width: parent.width
                iconKind: "airplane"
                title: "حالت هواپیما"
                description: "قطع تمام ارتباط‌های بی‌سیم"
                SettingsSwitch {
                    anchors.centerIn: parent
                    checked: root.airplaneMode
                    onToggled: (c) => root.airplaneMode = c
                }
            }

            // ── VPN ──
            ChevronRow {
                width: parent.width
                iconKind: "vpn"
                title: "VPN"
                statusText: "در انتظار سرویس"
                rowEnabled: false
            }

            // ── هات‌اسپات ──
            ChevronRow {
                width: parent.width
                iconKind: "hotspot"
                title: "هات‌اسپات تلفن همراه"
                statusText: "در انتظار سرویس"
                rowEnabled: false
            }

            // ── پروکسی ──
            ChevronRow {
                width: parent.width
                iconKind: "proxy"
                title: "پروکسی"
                statusText: "در انتظار سرویس"
                rowEnabled: false
            }

            // ── حالت شبکه‌ی دستی (اطلاعات) ──
            Rectangle {
                width: parent.width
                height: 64
                radius: SettingsTheme.rMd
                color: SettingsTheme.cardBg
                border.width: 1
                border.color: SettingsTheme.border
                opacity: 0.7

                Text {
                    anchors.centerIn: parent
                    text: "تنظیمات پیشرفته‌ی شبکه در فاز بعدی به‌وسیله‌ی یک سرویس Python ارائه می‌شود."
                    color: SettingsTheme.textMute
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width - 32
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
