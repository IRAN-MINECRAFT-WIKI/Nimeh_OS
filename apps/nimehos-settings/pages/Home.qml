// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Home.qml — صفحه‌ی خانه
// ============================================================
// ردیف هیرو (۳ کارت)، دو ستون: چپ (کارت حساب + کارت شخصی‌سازی
// با ۶ والپیپر) و راست (تنظیمات پیشنهادی).

import QtQuick
import ".."

Item {
    id: root

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

    // ── ردیف هیرو (۳ کارت) ──
    Row {
        id: heroRow
        anchors.top: header.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 12
        layoutDirection: Qt.RightToLeft

        HeroCard { title: "دستگاه"; value: "NimehOS PC"; emoji: "💻"; width: (parent.width - 24) / 3 }
        HeroCard { title: "شبکه"; value: "در انتظار سرویس"; emoji: "🌐"; width: (parent.width - 24) / 3 }
        HeroCard { title: "به‌روزرسانی"; value: "شما به‌روز هستید"; emoji: "🔄"; width: (parent.width - 24) / 3 }
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
                            text: "ن"
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
                            text: "کاربر NimehOS"
                            color: SettingsTheme.text
                            font.family: SettingsTheme.fontPersian
                            font.pixelSize: 14
                            font.weight: Font.Medium
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
                        text: "🎨 شخصی‌سازی"
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
                            model: [
                                { c1: "#0f1420", c2: "#2b7fe0" },
                                { c1: "#1a1330", c2: "#4a9eff" },
                                { c1: "#0a0e27", c2: "#22c55e" },
                                { c1: "#3a1a30", c2: "#f59e0b" },
                                { c1: "#0f1420", c2: "#ef4444" },
                                { c1: "#1e2538", c2: "#6eb0ff" }
                            ]
                            delegate: Rectangle {
                                width: (parent.width - 16) / 3
                                height: 60
                                radius: SettingsTheme.rSm
                                border.width: 1
                                border.color: SettingsTheme.border

                                gradient: Gradient {
                                    GradientStop { position: 0; color: modelData.c1 }
                                    GradientStop { position: 1; color: modelData.c2 }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
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
                    text: "✨ تنظیمات پیشنهادی"
                    color: SettingsTheme.text
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    anchors.right: parent.right
                }

                // لیست پیشنهادات
                Repeater {
                    model: [
                        { icon: "🌙", title: "حالت تاریک", desc: "تم تیره را برای چشم راحت‌تر فعال کنید" },
                        { icon: "🔊", title: "صدا", desc: "بلندی صدای خروجی را تنظیم کنید" },
                        { icon: "🔋", title: "باتری", desc: "وضعیت باتری و حالت صرفه‌جویی" },
                        { icon: "🖼", title: "پس‌زمینه", desc: "والپیپر دسکتاپ را تغییر دهید" },
                        { icon: "🌐", title: "شبکه", desc: "اتصال Wi-Fi یا سیمی را مدیریت کنید" }
                    ]
                    delegate: Rectangle {
                        width: rightCol.width - 32
                        height: 54
                        radius: SettingsTheme.rSm
                        color: suggMa.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 10
                            layoutDirection: Qt.RightToLeft

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 8
                                color: Qt.rgba(1, 1, 1, 0.05)
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    font.pixelSize: 14
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
                                    width: 220
                                }
                            }
                        }

                        MouseArea {
                            id: suggMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }
    }

    // ── کامپوننت داخلی HeroCard ──
    component HeroCard: Rectangle {
        id: heroCard
        property string title: ""
        property string value: ""
        property string emoji: ""
        height: 90
        radius: SettingsTheme.rMd
        color: SettingsTheme.cardBg
        border.width: 1
        border.color: SettingsTheme.border

        Row {
            anchors.centerIn: parent
            spacing: 10
            layoutDirection: Qt.RightToLeft

            Text {
                text: heroCard.emoji
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
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
                    color: SettingsTheme.text
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
            }
        }
    }
}
