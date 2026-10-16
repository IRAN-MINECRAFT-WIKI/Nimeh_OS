// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// PlaceholderPage.qml — صفحه‌ی نگهدارنده برای بخش‌های «به‌زودی»
// ============================================================
// یک کارت مرکزی با emoji، عنوان و پیام «این بخش در فاز بعدی تکمیل می‌شود.»

import QtQuick

Item {
    id: root

    // ── API عمومی ──
    property string pageTitle: ""
    property string emoji: "🚧"
    property string message: "این بخش در فاز بعدی تکمیل می‌شود."

    // ── عنوان صفحه (بالای صفحه) ──
    Text {
        id: header
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 0
        text: root.pageTitle
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 24
        font.weight: Font.DemiBold
    }

    // ── کارت مرکزی ──
    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(440, parent.width - 60)
        height: 260
        color: SettingsTheme.cardBg
        border.width: 1
        border.color: SettingsTheme.border
        radius: SettingsTheme.rLg

        Column {
            anchors.centerIn: parent
            spacing: 18

            // دایره‌ی emoji
            Rectangle {
                width: 72
                height: 72
                radius: 36
                anchors.horizontalCenter: parent.horizontalCenter
                color: Qt.rgba(1, 1, 1, 0.05)
                border.width: 1
                border.color: SettingsTheme.borderHi

                Text {
                    anchors.centerIn: parent
                    text: root.emoji
                    font.pixelSize: 34
                }
            }

            Text {
                text: "به‌زودی"
                color: SettingsTheme.text
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 20
                font.weight: Font.DemiBold
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: root.message
                color: SettingsTheme.textDim
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                width: card.width - 60
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
