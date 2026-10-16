// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Update.qml — صفحه‌ی به‌روزرسانی
// ============================================================
// پیام «شما به‌روز هستید» با کارت سبز، آخرین بررسی و دکمه‌ی بررسی دوباره.

import QtQuick
import ".."

Item {
    id: root

    // ── عنوان صفحه ──
    Text {
        id: header
        anchors.top: parent.top
        anchors.right: parent.right
        text: "به‌روزرسانی"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 24
        font.weight: Font.DemiBold
    }

    Text {
        id: subheader
        anchors.top: header.bottom
        anchors.topMargin: 6
        anchors.right: parent.right
        text: "آخرین به‌روزرسانی‌های NimehOS را بررسی کنید."
        color: SettingsTheme.textMute
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 12
    }

    // ── کارت وضعیت به‌روز ──
    Rectangle {
        id: statusCard
        anchors {
            top: subheader.bottom
            topMargin: 22
            left: parent.left
            right: parent.right
        }
        height: 180
        radius: SettingsTheme.rLg
        color: Qt.rgba(0.13, 0.77, 0.37, 0.10)
        border.width: 1
        border.color: Qt.rgba(0.13, 0.77, 0.37, 0.35)

        Column {
            anchors.centerIn: parent
            spacing: 14

            // دایره‌ی چک سبز
            Rectangle {
                width: 60
                height: 60
                radius: 30
                color: SettingsTheme.green
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "#ffffff"
                    font.pixelSize: 30
                    font.weight: Font.Bold
                }
            }

            Text {
                text: "شما به‌روز هستید"
                color: SettingsTheme.text
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 18
                font.weight: Font.DemiBold
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "آخرین بررسی: همین الان"
                color: SettingsTheme.textDim
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ── دکمه‌ی بررسی دوباره ──
    Rectangle {
        id: checkBtn
        anchors {
            top: statusCard.bottom
            topMargin: 18
            horizontalCenter: parent.horizontalCenter
        }
        width: 200
        height: 40
        radius: SettingsTheme.rSm
        color: checkMa.containsMouse ? SettingsTheme.accentDeep : SettingsTheme.accent
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.12)
        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            anchors.centerIn: parent
            text: "بررسی دوباره‌ی به‌روزرسانی"
            color: "#ffffff"
            font.family: SettingsTheme.fontPersian
            font.pixelSize: 12
            font.weight: Font.Medium
        }

        MouseArea {
            id: checkMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }

    // ── کارت اطلاعات نسخه ──
    Rectangle {
        id: versionCard
        anchors {
            top: checkBtn.bottom
            topMargin: 18
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        radius: SettingsTheme.rMd
        color: SettingsTheme.cardBg
        border.width: 1
        border.color: SettingsTheme.border

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            Text {
                text: "اطلاعات نسخه"
                color: SettingsTheme.text
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 13
                font.weight: Font.Medium
            }

            Rectangle {
                width: parent.width
                height: 1
                color: SettingsTheme.border
            }

            InfoLine { label: "نسخه‌ی سیستم‌عامل"; value: "NimehOS 1.0 (Trixie)" }
            InfoLine { label: "کانال به‌روزرسانی"; value: "پایدار" }
            InfoLine { label: "آخرین به‌روزرسانی"; value: "—" }
        }
    }

    // ── کامپوننت داخلی InfoLine ──
    component InfoLine: Item {
        width: parent.width
        height: 22
        property string label: ""
        property string value: ""

        Text {
            text: parent.label
            color: SettingsTheme.textMute
            font.family: SettingsTheme.fontPersian
            font.pixelSize: 12
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: parent.value
            color: SettingsTheme.text
            font.family: SettingsTheme.fontPersian
            font.pixelSize: 12
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
