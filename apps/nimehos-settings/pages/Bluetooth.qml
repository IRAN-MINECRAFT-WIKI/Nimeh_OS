// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Bluetooth.qml — صفحه‌ی بلوتوث
// ============================================================
// سوییچ بلوتوث (محلی) + دکمه‌ی «افزودن دستگاه» (غیرفعال — در انتظار سرویس)
// + فهرست دسته‌بندی دستگاه‌ها (موس، کیبورد، پرینتر، دوربین — همگی «در انتظار سرویس»).
// هیچ Process — هیچ bluetoothctl — همه‌چیز تزئینی/محلی.

import QtQuick
import ".."

Item {
    id: root
    anchors.fill: parent

    // ── حالت محلی ──
    property bool btEnabled: false

    // ── عنوان صفحه ──
    Text {
        id: header
        anchors.top: parent.top
        anchors.right: parent.right
        text: "بلوتوث"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 24
        font.weight: Font.DemiBold
    }

    Text {
        id: subheader
        anchors { top: header.bottom; topMargin: 6; right: parent.right }
        text: root.btEnabled ? "در حال جستجوی دستگاه‌ها… (در انتظار سرویس)" : "بلوتوث خاموش است"
        color: root.btEnabled ? SettingsTheme.amber : SettingsTheme.textMute
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 12
    }

    // ── سوییچ بلوتوث (SettingRow استاندارد با آیکون Canvas) ──
    SettingRow {
        id: toggleRow
        anchors {
            top: subheader.bottom
            topMargin: 18
            left: parent.left
            right: parent.right
        }
        width: parent.width
        iconKind: "bluetooth"
        title: "بلوتوث"
        description: root.btEnabled ? "روشن — در انتظار سرویس" : "خاموش"
        SettingsSwitch {
            anchors.centerIn: parent
            checked: root.btEnabled
            onToggled: (c) => root.btEnabled = c
        }
    }

    // ── دکمه‌ی «افزودن دستگاه» — غیرفعال (در انتظار سرویس) ──
    Rectangle {
        id: addCard
        anchors {
            top: toggleRow.bottom
            topMargin: 10
            left: parent.left
            right: parent.right
        }
        height: 64
        radius: SettingsTheme.rMd
        color: SettingsTheme.cardBg
        border.width: 1
        border.color: SettingsTheme.border
        opacity: 0.7

        // متن توضیحی (راست)
        Text {
            anchors {
                right: parent.right
                rightMargin: 14
                verticalCenter: parent.verticalCenter
            }
            text: "افزودن دستگاه بلوتوث"
            color: SettingsTheme.textDim
            font.family: SettingsTheme.fontPersian
            font.pixelSize: 13
            font.weight: Font.Medium
        }

        // دکمه (چپ) — غیرفعال
        Rectangle {
            id: addBtn
            width: 130
            height: 36
            radius: SettingsTheme.rSm
            anchors {
                left: parent.left
                leftMargin: 14
                verticalCenter: parent.verticalCenter
            }
            color: Qt.rgba(0.29, 0.62, 1.0, 0.08)
            border.width: 1
            border.color: SettingsTheme.borderHi

            Text {
                anchors.centerIn: parent
                text: "در انتظار سرویس"
                color: SettingsTheme.textMute
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 11
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.ArrowCursor
                enabled: false
            }
        }
    }

    // ── فهرست دسته‌بندی دستگاه‌ها ──
    Text {
        id: catHeader
        anchors { top: addCard.bottom; topMargin: 18; right: parent.right }
        text: "دسته‌بندی دستگاه‌ها"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 14
        font.weight: Font.Medium
    }

    Column {
        id: catList
        anchors {
            top: catHeader.bottom
            topMargin: 10
            left: parent.left
            right: parent.right
        }
        spacing: 8
        width: parent.width

        ChevronRow {
            width: parent.width
            iconKind: "mouse"
            title: "موس"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "keyboard"
            title: "کیبورد"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "printer"
            title: "پرینتر، اسکنر و فکس"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "camera"
            title: "دوربین"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
    }
}
