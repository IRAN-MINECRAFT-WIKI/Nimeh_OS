// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Apps.qml — صفحه‌ی برنامه‌ها
// ============================================================
// هیچ برنامه‌ی fake — فهرست نصب‌شده‌ها «در انتظار سرویس».
// فهرست: برنامه‌های نصب‌شده، برنامه‌های پیش‌فرض، استارت‌آپ، پخش ویدئو
// (همگی chevron، غیرفعال یا «در انتظار سرویس»).

import QtQuick
import ".."

Item {
    id: root
    anchors.fill: parent

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
        text: "مدیریت برنامه‌های نصب‌شده و پیش‌فرض"
        color: SettingsTheme.textMute
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 12
    }

    // ── کارت شمارش برنامه‌ها — «در انتظار سرویس» ──
    Rectangle {
        id: countCard
        anchors { top: subheader.bottom; topMargin: 18; left: parent.left; right: parent.right }
        height: 84
        radius: SettingsTheme.rMd
        color: SettingsTheme.cardBg
        border.width: 1
        border.color: SettingsTheme.border

        Canvas {
            id: appIcon
            width: 36; height: 36
            anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.strokeStyle = SettingsTheme.accentSoft
                ctx.lineWidth = 1.6
                ctx.strokeRect(4, 4, 6, 6)
                ctx.strokeRect(12, 4, 6, 6)
                ctx.strokeRect(4, 12, 6, 6)
                ctx.strokeRect(12, 12, 6, 6)
            }
        }

        Column {
            anchors { right: appIcon.left; rightMargin: 12; verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 14 }
            spacing: 2
            Text {
                text: "برنامه‌های نصب‌شده"
                color: SettingsTheme.text
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 13
                font.weight: Font.Medium
            }
            Text {
                text: "در انتظار سرویس"
                color: SettingsTheme.amber
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 11
            }
        }
    }

    // ── فهرست آیتم‌های chevron ──
    Column {
        id: listCol
        anchors {
            top: countCard.bottom
            topMargin: 18
            left: parent.left
            right: parent.right
        }
        spacing: 8
        width: parent.width

        ChevronRow {
            width: parent.width
            iconKind: "apps"
            title: "برنامه‌های نصب‌شده"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "default"
            title: "برنامه‌های پیش‌فرض"
            description: "انتخاب برنامه‌ی پیش‌فرض برای وب، ایمیل و…"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "startup"
            title: "استارت‌آپ"
            description: "برنامه‌هایی که هنگام ورود اجرا می‌شوند"
            rowEnabled: false
        }
        ChevronRow {
            width: parent.width
            iconKind: "video"
            title: "پخش ویدئو"
            description: "تنظیمات پخش‌کننده‌ی ویدئو"
            rowEnabled: false
        }
    }

    // ── یادداشت پایین ──
    Rectangle {
        id: note
        anchors { top: listCol.bottom; topMargin: 18; left: parent.left; right: parent.right }
        height: 64
        radius: SettingsTheme.rMd
        color: SettingsTheme.cardBg
        border.width: 1
        border.color: SettingsTheme.border
        opacity: 0.7

        Text {
            anchors.centerIn: parent
            text: "فهرست برنامه‌ها در فاز بعدی به‌وسیله‌ی یک سرویس Python (پیمایش فایل‌های .desktop) ارائه می‌شود."
            color: SettingsTheme.textMute
            font.family: SettingsTheme.fontPersian
            font.pixelSize: 11
            horizontalAlignment: Text.AlignHCenter
            width: parent.width - 32
            wrapMode: Text.WordWrap
        }
    }
}
