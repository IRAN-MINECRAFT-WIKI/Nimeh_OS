// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Accounts.qml — صفحه‌ی حساب کاربری
// ============================================================
// کارت کاربر (نام از Quickshell.env("USER")، «حساب محلی») +
// فهرست ۴ آیتم chevron (اطلاعات شما، ایمیل، گزینه‌های ورود، خانواده).
// هیچ Process — همه‌چیز تزئینی/محلی.

import QtQuick
import ".."
import Quickshell

Item {
    id: root
    anchors.fill: parent

    // ── نام کاربر واقعی از env ──
    readonly property string userName: {
        const u = Quickshell.env("USER") || Quickshell.env("LOGNAME") || ""
        return u.length > 0 ? u : "کاربر NimehOS"
    }
    readonly property string userInitial: userName.length > 0 ? userName.charAt(0).toUpperCase() : "ن"

    // ── عنوان صفحه ──
    Text {
        id: header
        anchors.top: parent.top
        anchors.right: parent.right
        text: "حساب کاربری"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 24
        font.weight: Font.DemiBold
    }

    Text {
        id: subheader
        anchors { top: header.bottom; topMargin: 6; right: parent.right }
        text: "اطلاعات شما، ایمیل، گزینه‌های ورود و خانواده"
        color: SettingsTheme.textMute
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 12
    }

    // ── کارت کاربر ──
    Rectangle {
        id: userCard
        anchors { top: subheader.bottom; topMargin: 18; left: parent.left; right: parent.right }
        height: 130
        radius: SettingsTheme.rMd
        color: SettingsTheme.cardBg
        border.width: 1
        border.color: SettingsTheme.border

        Row {
            anchors.centerIn: parent
            spacing: 18
            layoutDirection: Qt.RightToLeft

            Rectangle {
                width: 64
                height: 64
                radius: 32
                color: SettingsTheme.accentDeep
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: root.userInitial
                    color: "#ffffff"
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 26
                    font.weight: Font.DemiBold
                }
            }

            Column {
                spacing: 4
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: root.userName
                    color: SettingsTheme.text
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                }
                Text {
                    text: "حساب محلی"
                    color: SettingsTheme.textMute
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 12
                }
                Text {
                    text: "مدیر سیستم"
                    color: SettingsTheme.accentSoft
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 11
                }
            }
        }
    }

    // ── فهرست آیتم‌های chevron ──
    Column {
        id: listCol
        anchors {
            top: userCard.bottom
            topMargin: 18
            left: parent.left
            right: parent.right
        }
        spacing: 8
        width: parent.width

        ChevronRow {
            width: parent.width
            iconKind: "person"
            title: "اطلاعات شما"
            description: "نام، عکس و حساب"
        }
        ChevronRow {
            width: parent.width
            iconKind: "email"
            title: "ایمیل و حساب‌ها"
            description: "مدیریت حساب‌های متصل"
        }
        ChevronRow {
            width: parent.width
            iconKind: "key"
            title: "گزینه‌های ورود"
            description: "Windows Hello، رمز عبور، پین"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "family"
            title: "خانواده و سایر کاربران"
            description: "افزودن یا حذف کاربر"
            rowEnabled: false
        }
    }
}
