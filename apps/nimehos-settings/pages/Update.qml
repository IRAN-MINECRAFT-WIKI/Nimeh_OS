// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Update.qml — صفحه‌ی به‌روزرسانی
// ============================================================
// وضعیت: «نامشخص» (نه «شما به‌روز هستید» — هیچ backend فعلی وجود ندارد) +
// دکمه‌ی «بررسی دوباره» غیرفعال («در انتظار سرویس») +
// آخرین بررسی: «نامشخص» + نسخه: «NimehOS» + Quickshell.env یا «نامشخص».
// هیچ Process — همه‌چیز تزئینی.

import QtQuick
import ".."
import Quickshell

Item {
    id: root
    anchors.fill: parent

    // ── اطلاعات نسخه ──
    readonly property string userName: Quickshell.env("USER") || ""
    readonly property string versionString: userName.length > 0
        ? ("NimehOS (" + userName + ")")
        : "NimehOS"

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
        anchors { top: header.bottom; topMargin: 6; right: parent.right }
        text: "آخرین به‌روزرسانی‌های NimehOS را بررسی کنید."
        color: SettingsTheme.textMute
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 12
    }

    // ── کارت وضعیت — «نامشخص» (نه سبز «شما به‌روز هستید») ──
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
        color: Qt.rgba(0.96, 0.62, 0.04, 0.08)  // amber tint (نامشخص)
        border.width: 1
        border.color: Qt.rgba(0.96, 0.62, 0.04, 0.30)

        Column {
            anchors.centerIn: parent
            spacing: 14

            // علامت «؟» در دایره — Canvas
            Canvas {
                width: 60
                height: 60
                anchors.horizontalCenter: parent.horizontalCenter
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    ctx.fillStyle = SettingsTheme.amber
                    ctx.beginPath()
                    ctx.arc(30, 30, 30, 0, 2 * Math.PI)
                    ctx.fill()
                    ctx.fillStyle = "#ffffff"
                    ctx.font = "bold 32px " + SettingsTheme.fontPersian
                    ctx.textAlign = "center"
                    ctx.textBaseline = "middle"
                    ctx.fillText("؟", 30, 32)
                }
            }

            Text {
                text: "وضعیت: نامشخص"
                color: SettingsTheme.text
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 18
                font.weight: Font.DemiBold
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "آخرین بررسی: نامشخص"
                color: SettingsTheme.textDim
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ── دکمه‌ی «بررسی دوباره» — غیرفعال ──
    Rectangle {
        id: checkBtn
        anchors {
            top: statusCard.bottom
            topMargin: 18
            horizontalCenter: parent.horizontalCenter
        }
        width: 220
        height: 40
        radius: SettingsTheme.rSm
        color: checkMa.containsMouse ? SettingsTheme.accentDeep : SettingsTheme.accent
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.12)
        opacity: 0.55  // غیرفعال
        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            anchors.centerIn: parent
            text: "بررسی دوباره — در انتظار سرویس"
            color: "#ffffff"
            font.family: SettingsTheme.fontPersian
            font.pixelSize: 12
            font.weight: Font.Medium
        }

        MouseArea {
            id: checkMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.ArrowCursor  // غیرفعال
            enabled: false
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

            InfoLine { width: parent.width; label: "نسخه‌ی سیستم‌عامل";  value: root.versionString }
            InfoLine { width: parent.width; label: "کانال به‌روزرسانی";   value: "نامشخص" }
            InfoLine { width: parent.width; label: "آخرین به‌روزرسانی";   value: "نامشخص" }
            InfoLine { width: parent.width; label: "شناسه‌ی دستگاه";      value: "نامشخص" }
        }
    }

    // ── کامپوننت داخلی InfoLine ──
    component InfoLine: Item {
        width: parent ? parent.width : 400
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
            elide: Text.ElideRight
            width: parent.width * 0.6
        }
    }
}
