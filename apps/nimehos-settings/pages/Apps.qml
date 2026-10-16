// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Apps.qml — صفحه‌ی برنامه‌ها
// ============================================================
// فهرست برنامه‌های نصب‌شده (دو نمونه‌ی hardcode: PhotoCraft و Firefox)
// با آیکون، نام، نسخه، اندازه و فرمت.

import QtQuick
import ".."

Item {
    id: root

    // ── فهرست برنامه‌ها (hardcode) ──
    readonly property var apps: [
        { name: "PhotoCraft", version: "1.2.0", size: "۸۴ مگابایت", format: "AppImage", icon: "🎨", color: "#4a9eff" },
        { name: "Firefox",    version: "127.0",  size: "۲۱۲ مگابایت", format: "DEB",     icon: "🦊", color: "#f59e0b" }
    ]

    // ── عنوان صفحه ──
    Text {
        id: header
        anchors.top: parent.top
        anchors.right: parent.right
        text: "برنامه‌ها"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 24
        font.weight: Font.DemiBold
    }

    Text {
        id: subheader
        anchors { top: header.bottom; topMargin: 6; right: parent.right }
        text: "برنامه‌های نصب‌شده روی سیستم"
        color: SettingsTheme.textMute
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 12
    }

    // ── شمارش برنامه‌ها ──
    Rectangle {
        id: countCard
        anchors { top: subheader.bottom; topMargin: 18; left: parent.left; right: parent.right }
        height: 64
        radius: SettingsTheme.rMd
        color: SettingsTheme.cardBg
        border.width: 1
        border.color: SettingsTheme.border

        Row {
            anchors.centerIn: parent
            spacing: 14
            layoutDirection: Qt.RightToLeft

            Rectangle {
                width: 36; height: 36; radius: 10
                color: Qt.rgba(0.29, 0.62, 1.0, 0.16)
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    anchors.centerIn: parent
                    text: "📦"
                    font.pixelSize: 16
                }
            }

            Column {
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: root.apps.length + " برنامه نصب شده"
                    color: SettingsTheme.text
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
                Text {
                    text: "مدیریت برنامه‌های نصب‌شده — به‌زودی کامل می‌شود"
                    color: SettingsTheme.textMute
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 11
                }
            }
        }
    }

    // ── فهرست برنامه‌ها ──
    ListView {
        id: appList
        anchors {
            top: countCard.bottom
            topMargin: 12
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        clip: true
        spacing: 10
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        model: root.apps
        delegate: Rectangle {
            width: appList.width
            height: 72
            radius: SettingsTheme.rMd
            color: SettingsTheme.cardBg
            border.width: 1
            border.color: SettingsTheme.border

            // ── آیکون ──
            Rectangle {
                id: appIcon
                width: 44; height: 44; radius: 12
                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                color: modelData.color
                opacity: 0.85

                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    font.pixelSize: 20
                }
            }

            // ── نام + اطلاعات ──
            Column {
                anchors { left: appIcon.right; leftMargin: 12; verticalCenter: parent.verticalCenter; right: actionBtn.left; rightMargin: 12 }
                spacing: 3
                Text {
                    text: modelData.name
                    color: SettingsTheme.text
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: "نسخه " + modelData.version + " • " + modelData.size + " • " + modelData.format
                    color: SettingsTheme.textMute
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    width: parent.width
                }
            }

            // ── دکمه‌ی جزئیات ──
            Rectangle {
                id: actionBtn
                width: 36; height: 36; radius: 8
                anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                color: actionMa.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.04)
                border.width: 1
                border.color: SettingsTheme.border
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: "⋯"
                    color: SettingsTheme.textDim
                    font.pixelSize: 18
                }

                MouseArea {
                    id: actionMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
