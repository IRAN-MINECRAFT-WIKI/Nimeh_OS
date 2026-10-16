// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// SettingRow.qml — ردیف تنظیمات افقی
// ============================================================
// چیدمان: آیکون ۳۶px | عنوان + توضیح | کنترل (سوییچ/اسلایدر)
// کنترل به‌صورت فرزند مستقیم اضافه می‌شود (default property).

import QtQuick

Rectangle {
    id: root
    width: parent ? parent.width : 400
    height: 64
    color: SettingsTheme.cardBg
    border.width: 1
    border.color: SettingsTheme.border
    radius: SettingsTheme.rMd

    // ── API عمومی ──
    property string iconText: ""
    property string title: ""
    property string description: ""

    // فرزندان مستقیم این ردیف، داخل کنترل‌اسلات قرار می‌گیرند
    default property alias controlChildren: controlSlot.data

    Rectangle {
        id: iconBox
        width: 36
        height: 36
        radius: 10
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.rgba(1, 1, 1, 0.05)
        border.width: 1
        border.color: SettingsTheme.border

        Text {
            anchors.centerIn: parent
            text: root.iconText
            font.pixelSize: 16
            font.family: SettingsTheme.fontPersian
        }
    }

    Column {
        id: textCol
        anchors.left: iconBox.right
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: controlSlot.left
        anchors.rightMargin: 12
        spacing: 2

        Text {
            text: root.title
            color: SettingsTheme.text
            font.family: SettingsTheme.fontPersian
            font.pixelSize: 13
            elide: Text.ElideRight
            width: textCol.width
        }

        Text {
            text: root.description
            color: SettingsTheme.textMute
            font.family: SettingsTheme.fontPersian
            font.pixelSize: 11
            elide: Text.ElideRight
            width: textCol.width
            visible: root.description.length > 0
        }
    }

    // ── اسلات کنترل (سمت راست) ──
    Item {
        id: controlSlot
        width: 120
        height: parent.height
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
    }
}
