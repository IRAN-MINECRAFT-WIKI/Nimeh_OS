// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Privacy.qml — صفحه‌ی حریم خصوصی
// ============================================================
// وضعیت امنیت: «در انتظار سرویس» + سوییچ داده‌های تشخیصی (محلی) +
// سوییچ میکروفون و دوربین (محلی) + فهرست دسترسی‌های برنامه («در انتظار سرویس»).

import QtQuick
import ".."

Item {
    id: root
    anchors.fill: parent

    // ── حالت‌های محلی ──
    property bool diagnosticData: false
    property bool micEnabled: true
    property bool cameraEnabled: true

    // ── عنوان صفحه ──
    Text {
        id: header
        anchors.top: parent.top
        anchors.right: parent.right
        text: "حریم خصوصی و امنیت"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 24
        font.weight: Font.DemiBold
    }

    Text {
        id: subheader
        anchors { top: header.bottom; topMargin: 6; right: parent.right }
        text: "امنیت، مجوز برنامه‌ها و داده‌های تشخیصی"
        color: SettingsTheme.textMute
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 12
    }

    // ── کارت وضعیت امنیت ──
    Rectangle {
        id: securityCard
        anchors { top: subheader.bottom; topMargin: 18; left: parent.left; right: parent.right }
        height: 100
        radius: SettingsTheme.rLg
        color: Qt.rgba(0.96, 0.62, 0.04, 0.10)  // amber tint
        border.width: 1
        border.color: Qt.rgba(0.96, 0.62, 0.04, 0.35)

        Row {
            anchors.centerIn: parent
            spacing: 14
            layoutDirection: Qt.RightToLeft

            // آیکون سپر — Canvas
            Canvas {
                width: 40; height: 40
                anchors.verticalCenter: parent.verticalCenter
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = SettingsTheme.amber
                    ctx.fillStyle = SettingsTheme.amber
                    ctx.lineWidth = 1.8
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"
                    ctx.beginPath()
                    ctx.moveTo(20, 5); ctx.lineTo(33, 10); ctx.lineTo(33, 22); ctx.quadraticCurveTo(33, 33, 20, 38); ctx.quadraticCurveTo(7, 33, 7, 22); ctx.lineTo(7, 10); ctx.closePath()
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(14, 20); ctx.lineTo(18, 25); ctx.lineTo(27, 15)
                    ctx.stroke()
                }
            }

            Column {
                spacing: 3
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: "امنیت ویندوز"
                    color: SettingsTheme.text
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }
                Text {
                    text: "در انتظار سرویس"
                    color: SettingsTheme.amber
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 12
                }
            }
        }
    }

    // ── بخش داده‌های تشخیصی ──
    Text {
        id: diagHeader
        anchors { top: securityCard.bottom; topMargin: 18; right: parent.right }
        text: "داده‌های تشخیصی و مجوزها"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 14
        font.weight: Font.Medium
    }

    SettingRow {
        id: diagRow
        anchors { top: diagHeader.bottom; topMargin: 10; left: parent.left; right: parent.right }
        width: parent.width
        iconKind: "diagnostic"
        title: "داده‌های تشخیصی"
        description: "ارسال داده‌های استفاده به توسعه‌دهنده"
        SettingsSwitch {
            anchors.centerIn: parent
            checked: root.diagnosticData
            onToggled: (c) => root.diagnosticData = c
        }
    }

    // ── بخش دسترسی‌های دستگاه ──
    Text {
        id: devHeader
        anchors { top: diagRow.bottom; topMargin: 18; right: parent.right }
        text: "دسترسی‌های دستگاه"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 14
        font.weight: Font.Medium
    }

    SettingRow {
        id: micRow
        anchors { top: devHeader.bottom; topMargin: 10; left: parent.left; right: parent.right }
        width: parent.width
        iconKind: "mic"
        title: "میکروفون"
        description: "اجازه‌ی دسترسی برنامه‌ها به میکروفون"
        SettingsSwitch {
            anchors.centerIn: parent
            checked: root.micEnabled
            onToggled: (c) => root.micEnabled = c
        }
    }

    SettingRow {
        id: camRow
        anchors { top: micRow.bottom; topMargin: 10; left: parent.left; right: parent.right }
        width: parent.width
        iconKind: "camera"
        title: "دوربین"
        description: "اجازه‌ی دسترسی برنامه‌ها به دوربین"
        SettingsSwitch {
            anchors.centerIn: parent
            checked: root.cameraEnabled
            onToggled: (c) => root.cameraEnabled = c
        }
    }

    // ── فهرست مجوزهای برنامه ──
    Column {
        id: listCol
        anchors {
            top: camRow.bottom
            topMargin: 18
            left: parent.left
            right: parent.right
        }
        spacing: 8
        width: parent.width

        ChevronRow {
            width: parent.width
            iconKind: "permissions"
            title: "مجوزهای برنامه"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "info"
            title: "موقعیت مکانی"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "info"
            title: "اطلاعات حساب"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "info"
            title: "مخاطبین و تقویم"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
    }
}
