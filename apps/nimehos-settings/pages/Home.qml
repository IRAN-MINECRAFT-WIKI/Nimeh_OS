// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Home.qml — صفحه‌ی خانه
// ============================================================
// کارت دستگاه (نام از Quickshell.env("USER")، مدل NimehOS) +
// ۳ کارت وضعیت (شبکه/به‌روزرسانی/بلوتوث — «در انتظار سرویس» یا «نامشخص»)
// + ۳ آیتم پیشنهادی قابل کلیک (با navigateRequested به shell) +
// کارت شخصی‌سازی با ۶ والپیپر (انتخاب محلی).
// هیچ Process — تماماً تزئینی.

import QtQuick
import ".."
import Quickshell

Item {
    id: root
    anchors.fill: parent

    // سیگنال ناوبری — shell.qml به آن گوش می‌دهد
    signal navigateRequested(string page)

    // ── ۶ گرادیان والپیپر ──
    readonly property var wallpapers: [
        { c1: "#0f1420", c2: "#2b7fe0", name: "آبی عمیق" },
        { c1: "#1a1330", c2: "#4a9eff", name: "بنفش شب" },
        { c1: "#0a0e27", c2: "#22c55e", name: "جنگل" },
        { c1: "#3a1a30", c2: "#f59e0b", name: "غروب" },
        { c1: "#0f1420", c2: "#ef4444", name: "شفق" },
        { c1: "#1e2538", c2: "#6eb0ff", name: "مه" }
    ]
    property int selectedWallpaper: 0

    // ── ۳ آیتم پیشنهادی ──
    readonly property var suggestions: [
        { kind: "personalization", title: "شخصی‌سازی", desc: "تم و والپیپر دسکتاپ را تغییر دهید", target: "Personalization" },
        { kind: "system",          title: "حالت تاریک و صدا", desc: "نمایش، صدا و اعلان‌ها", target: "System" },
        { kind: "update",          title: "به‌روزرسانی", desc: "بررسی به‌روزرسانی‌های NimehOS", target: "Update" }
    ]

    // ── عنوان صفحه ──
    Text {
        id: header
        anchors.top: parent.top
        anchors.right: parent.right
        text: "خانه"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 24
        font.weight: Font.DemiBold
    }

    // ── ردیف هیرو: ۳ کارت وضعیت ──
    Row {
        id: heroRow
        anchors.top: header.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 12
        layoutDirection: Qt.RightToLeft

        HeroCard { kind: "device";    title: "دستگاه";       value: "NimehOS";            width: (parent.width - 24) / 3 }
        HeroCard { kind: "network";   title: "شبکه";         value: "در انتظار سرویس";    width: (parent.width - 24) / 3; valueColor: SettingsTheme.amber }
        HeroCard { kind: "update";    title: "به‌روزرسانی";  value: "نامشخص";             width: (parent.width - 24) / 3; valueColor: SettingsTheme.textMute }
    }

    // ── دو ستون محتوای اصلی ──
    Item {
        id: columnsRow
        anchors {
            top: heroRow.bottom
            topMargin: 18
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        // ── ستون چپ: کارت حساب + کارت شخصی‌سازی ──
        Column {
            id: leftCol
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
            width: (parent.width - 12) * 0.5
            spacing: 12

            // ── کارت حساب کاربر ──
            Rectangle {
                width: parent.width
                height: 110
                radius: SettingsTheme.rMd
                color: SettingsTheme.cardBg
                border.width: 1
                border.color: SettingsTheme.border

                Row {
                    anchors.centerIn: parent
                    spacing: 14
                    layoutDirection: Qt.RightToLeft

                    Rectangle {
                        width: 54
                        height: 54
                        radius: 27
                        color: SettingsTheme.accentDeep
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            anchors.centerIn: parent
                            text: root._userInitial()
                            color: "#ffffff"
                            font.family: SettingsTheme.fontPersian
                            font.pixelSize: 22
                            font.weight: Font.DemiBold
                        }
                    }

                    Column {
                        spacing: 4
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: root._userName()
                            color: SettingsTheme.text
                            font.family: SettingsTheme.fontPersian
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                            width: 220
                        }
                        Text {
                            text: "حساب محلی — session فعال"
                            color: SettingsTheme.textMute
                            font.family: SettingsTheme.fontPersian
                            font.pixelSize: 11
                        }
                    }
                }
            }

            // ── کارت شخصی‌سازی با ۶ والپیپر ──
            Rectangle {
                width: parent.width
                height: 220
                radius: SettingsTheme.rMd
                color: SettingsTheme.cardBg
                border.width: 1
                border.color: SettingsTheme.border

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Text {
                        text: "شخصی‌سازی"
                        color: SettingsTheme.text
                        font.family: SettingsTheme.fontPersian
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        anchors.right: parent.right
                    }

                    // ── گرید ۶ والپیپر ──
                    Grid {
                        width: parent.width
                        columns: 3
                        spacing: 8

                        Repeater {
                            model: root.wallpapers
                            delegate: Rectangle {
                                width: (parent.width - 16) / 3
                                height: 60
                                radius: SettingsTheme.rSm
                                border.width: root.selectedWallpaper === index ? 2 : 1
                                border.color: root.selectedWallpaper === index
                                              ? SettingsTheme.accent : SettingsTheme.border
                                Behavior on border.color { ColorAnimation { duration: 120 } }

                                gradient: Gradient {
                                    GradientStop { position: 0; color: modelData.c1 }
                                    GradientStop { position: 1; color: modelData.c2 }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.selectedWallpaper = index
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── ستون راست: تنظیمات پیشنهادی ──
        Rectangle {
            id: rightCol
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width: (parent.width - 12) * 0.5
            radius: SettingsTheme.rMd
            color: SettingsTheme.cardBg
            border.width: 1
            border.color: SettingsTheme.border

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Text {
                    text: "تنظیمات پیشنهادی"
                    color: SettingsTheme.text
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    anchors.right: parent.right
                }

                // لیست پیشنهادات (۳ آیتم — کلیک = ناوبری)
                Repeater {
                    model: root.suggestions
                    delegate: Rectangle {
                        width: rightCol.width - 32
                        height: 58
                        radius: SettingsTheme.rSm
                        color: suggMa.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 10
                            layoutDirection: Qt.RightToLeft

                            // آیکون کشیده‌شده با Canvas (نه emoji)
                            Canvas {
                                width: 32
                                height: 32
                                anchors.verticalCenter: parent.verticalCenter
                                onPaint: {
                                    const ctx = getContext("2d")
                                    ctx.reset()
                                    ctx.strokeStyle = SettingsTheme.accentSoft
                                    ctx.fillStyle = SettingsTheme.accentSoft
                                    ctx.lineWidth = 1.4
                                    ctx.lineCap = "round"
                                    ctx.lineJoin = "round"
                                    const k = modelData.kind
                                    if (k === "personalization") {
                                        ctx.beginPath()
                                        ctx.arc(16, 16, 10, 0, 2 * Math.PI)
                                        ctx.stroke()
                                        ctx.beginPath(); ctx.arc(12, 12, 2, 0, 2 * Math.PI); ctx.fill()
                                        ctx.beginPath(); ctx.arc(20, 12, 2, 0, 2 * Math.PI); ctx.fill()
                                        ctx.beginPath(); ctx.arc(16, 20, 2, 0, 2 * Math.PI); ctx.fill()
                                    } else if (k === "system") {
                                        ctx.strokeRect(6, 6, 20, 14)
                                        ctx.beginPath()
                                        ctx.moveTo(11, 24); ctx.lineTo(21, 24)
                                        ctx.moveTo(16, 20); ctx.lineTo(16, 24)
                                        ctx.stroke()
                                    } else if (k === "update") {
                                        ctx.beginPath()
                                        ctx.arc(16, 16, 9, -Math.PI / 2, Math.PI * 1.3)
                                        ctx.stroke()
                                        ctx.beginPath()
                                        ctx.moveTo(16, 4); ctx.lineTo(22, 7); ctx.lineTo(19, 12); ctx.closePath()
                                        ctx.fill()
                                    }
                                }
                            }

                            Column {
                                spacing: 2
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: modelData.title
                                    color: SettingsTheme.text
                                    font.family: SettingsTheme.fontPersian
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                }
                                Text {
                                    text: modelData.desc
                                    color: SettingsTheme.textMute
                                    font.family: SettingsTheme.fontPersian
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    width: 240
                                }
                            }
                        }

                        MouseArea {
                            id: suggMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.navigateRequested(modelData.target)
                        }
                    }
                }
            }
        }
    }

    // ── توابع کمکی ──
    function _userName() {
        const u = Quickshell.env("USER") || Quickshell.env("LOGNAME") || ""
        return u.length > 0 ? u : "کاربر NimehOS"
    }
    function _userInitial() {
        const u = _userName()
        return u.length > 0 ? u.charAt(0).toUpperCase() : "ن"
    }

    // ── کامپوننت داخلی HeroCard ──
    component HeroCard: Rectangle {
        id: heroCard
        property string kind: ""
        property string title: ""
        property string value: ""
        property color valueColor: SettingsTheme.text
        height: 90
        radius: SettingsTheme.rMd
        color: SettingsTheme.cardBg
        border.width: 1
        border.color: SettingsTheme.border

        Row {
            anchors.centerIn: parent
            spacing: 10
            layoutDirection: Qt.RightToLeft

            // آیکون کشیده‌شده با Canvas (نه emoji)
            Canvas {
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = SettingsTheme.accentSoft
                    ctx.fillStyle = SettingsTheme.accentSoft
                    ctx.lineWidth = 1.4
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"
                    const k = heroCard.kind
                    if (k === "device") {
                        // مانیتور
                        ctx.strokeRect(3, 3, 18, 12)
                        ctx.beginPath()
                        ctx.moveTo(8, 21); ctx.lineTo(16, 21)
                        ctx.moveTo(12, 15); ctx.lineTo(12, 21)
                        ctx.stroke()
                    } else if (k === "network") {
                        // قوس‌های Wi-Fi
                        ctx.beginPath()
                        ctx.arc(12, 18, 8, -Math.PI * 0.75, -Math.PI * 0.25)
                        ctx.arc(12, 18, 5, -Math.PI * 0.75, -Math.PI * 0.25)
                        ctx.arc(12, 18, 2.5, -Math.PI * 0.75, -Math.PI * 0.25)
                        ctx.stroke()
                    } else if (k === "update") {
                        // فلش دایره‌ای
                        ctx.beginPath()
                        ctx.arc(12, 12, 7, -Math.PI / 2, Math.PI * 1.3)
                        ctx.stroke()
                        ctx.beginPath()
                        ctx.moveTo(12, 5); ctx.lineTo(16, 7); ctx.lineTo(14, 11); ctx.closePath()
                        ctx.fill()
                    }
                }
            }

            Column {
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: heroCard.title
                    color: SettingsTheme.textMute
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 10
                }
                Text {
                    text: heroCard.value
                    color: heroCard.valueColor
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    width: 180
                }
            }
        }
    }
}
