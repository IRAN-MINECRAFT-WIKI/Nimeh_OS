// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Time.qml — صفحه‌ی زمان و زبان
// ============================================================
// ساعت زنده (Timer ۱۰۰۰ms — فقط وقتی صفحه visible است) +
// نمایش تاریخ + تقویم جلالی (محاسبه‌ی محلی JS — بدون timedatectl) +
// منطقه‌ی زمانی «نامشخص» + سوییچ فرمت ۲۴ساعته (محلی).
// هیچ Process — هیچ timedatectl — همه‌چیز محلی/تزئینی.

import QtQuick
import ".."

Item {
    id: root
    anchors.fill: parent

    // ── حالت محلی ──
    property bool format24h: true

    // ── زمان فعلی (هر ۱ ثانیه به‌روزرسانی) ──
    property date currentTime: new Date()

    // ── منطقه‌ی زمانی «نامشخص» (بدون timedatectl) ──
    readonly property string timezoneLabel: "نامشخص"

    // ── Timer فقط وقتی صفحه visible است اجرا می‌شود ──
    // صفحه وقتی لود شده باشد visible=true است (Loader فقط صفحه‌ی فعال را لود می‌کند).
    Timer {
        interval: 1000
        repeat: true
        running: root.visible  // gate: فقط وقتی صفحه visible
        triggeredOnStart: true
        onTriggered: root.currentTime = new Date()
    }

    // ── توابع کمکی ──
    function _pad(n) { return n < 10 ? "0" + n : "" + n }
    function _persianDigits(s) {
        const m = {"0":"۰","1":"۱","2":"۲","3":"۳","4":"۴","5":"۵","6":"۶","7":"۷","8":"۸","9":"۹"}
        return String(s).replace(/[0-9]/g, d => m[d])
    }
    function _formatTime() {
        let h = root.currentTime.getHours()
        const m = root.currentTime.getMinutes()
        const s = root.currentTime.getSeconds()
        if (!root.format24h) {
            const ampm = h >= 12 ? "ب.ظ" : "ق.ظ"
            h = h % 12; if (h === 0) h = 12
            return _persianDigits(_pad(h) + ":" + _pad(m) + ":" + _pad(s)) + " " + ampm
        }
        return _persianDigits(_pad(h) + ":" + _pad(m) + ":" + _pad(s))
    }
    function _gregorianDateLabel() {
        const d = root.currentTime
        const months = ["ژانویه","فوریه","مارس","آوریل","مه","ژوئن","ژوئیه","اوت","سپتامبر","اکتبر","نوامبر","دسامبر"]
        return _persianDigits(d.getDate()) + " " + months[d.getMonth()] + " " + _persianDigits(d.getFullYear())
    }
    // ── تبدیل میلادی به جلالی (الگوریتم استاندارد) ──
    function _toJalali() {
        const d = root.currentTime
        const gy = d.getFullYear()
        const gm = d.getMonth() + 1
        const gd = d.getDate()
        const g_d_m = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
        let jy
        if (gy > 1600) { jy = 979; gy -= 1600 } else { jy = 0; gy -= 621 }
        const gy2 = (gm > 7) ? (gy + 1) : gy
        let days = (365 * gy) + (Math.floor((gy2 + 3) / 4)) - (Math.floor((gy2 + 99) / 100)) + (Math.floor((gy2 + 399) / 400)) - 80 + gd + g_d_m[gm - 1]
        jy += 33 * (Math.floor(days / 12053))
        days %= 12053
        jy += 4 * (Math.floor(days / 1461))
        days %= 1461
        if (days > 365) {
            jy += Math.floor((days - 1) / 365)
            days = (days - 1) % 365
        }
        let jm, jd
        if (days < 186) {
            jm = 1 + Math.ceil(days / 31)
            jd = days - (31 * (jm - 1)) + 1
        } else {
            jm = 7 + Math.ceil((days - 186) / 30)
            jd = (days - 186) - (30 * (jm - 7)) + 1
        }
        const months = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور","مهر","آبان","آذر","دی","بهمن","اسفند"]
        return _persianDigits(jd) + " " + months[jm - 1] + " " + _persianDigits(jy)
    }

    // ── عنوان صفحه ──
    Text {
        id: header
        anchors.top: parent.top
        anchors.right: parent.right
        text: "زمان و زبان"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 24
        font.weight: Font.DemiBold
    }

    // ── کارت ساعت زنده ──
    Rectangle {
        id: clockCard
        anchors { top: header.bottom; topMargin: 20; left: parent.left; right: parent.right }
        height: 160
        radius: SettingsTheme.rLg
        color: SettingsTheme.cardBg
        border.width: 1
        border.color: SettingsTheme.border

        Column {
            anchors.centerIn: parent
            spacing: 12

            // ساعت بزرگ
            Text {
                text: root._formatTime()
                color: SettingsTheme.text
                font.family: SettingsTheme.fontLatin
                font.pixelSize: 48
                font.weight: Font.DemiBold
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // تاریخ میلادی
            Text {
                text: root._gregorianDateLabel()
                color: SettingsTheme.textDim
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // تاریخ جلالی
            Text {
                text: "تقویم جلالی: " + root._toJalali()
                color: SettingsTheme.accentSoft
                font.family: SettingsTheme.fontPersian
                font.pixelSize: 13
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    // ── فهرست تنظیمات ──
    Column {
        id: listCol
        anchors {
            top: clockCard.bottom
            topMargin: 18
            left: parent.left
            right: parent.right
        }
        spacing: 8
        width: parent.width

        // منطقه‌ی زمانی
        SettingRow {
            width: parent.width
            iconKind: "globe"
            title: "منطقه‌ی زمانی"
            description: "نامشخص"
            Item {
                anchors.centerIn: parent
                width: 100; height: 28
                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.06)
                    border.width: 1
                    border.color: SettingsTheme.borderHi
                    Text {
                        anchors.centerIn: parent
                        text: "نامشخص"
                        color: SettingsTheme.textMute
                        font.family: SettingsTheme.fontPersian
                        font.pixelSize: 10
                    }
                }
            }
        }

        // سوییچ فرمت ۲۴ساعته
        SettingRow {
            width: parent.width
            iconKind: "clock"
            title: "فرمت ۲۴ ساعته"
            description: "نمایش زمان با ساعت ۰۰ تا ۲۳"
            SettingsSwitch {
                anchors.centerIn: parent
                checked: root.format24h
                onToggled: (c) => root.format24h = c
            }
        }

        // تاریخ جلالی — فقط اطلاعاتی
        SettingRow {
            width: parent.width
            iconKind: "calendar"
            title: "تقویم پیش‌فرض"
            description: "جلالی (نمایش داده شده در بالا)"
            Item {
                anchors.centerIn: parent
                width: 100; height: 28
                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: Qt.rgba(0.13, 0.77, 0.37, 0.10)
                    border.width: 1
                    border.color: Qt.rgba(0.13, 0.77, 0.37, 0.35)
                    Text {
                        anchors.centerIn: parent
                        text: "جلالی"
                        color: SettingsTheme.green
                        font.family: SettingsTheme.fontPersian
                        font.pixelSize: 11
                    }
                }
            }
        }

        // زبان نمایش — غیرفعال
        ChevronRow {
            width: parent.width
            iconKind: "info"
            title: "زبان نمایش"
            statusText: "فارسی"
            rowEnabled: false
        }

        // منطقه‌ی زبانی — غیرفعال
        ChevronRow {
            width: parent.width
            iconKind: "globe"
            title: "منطقه‌ی زبانی"
            statusText: "ایران"
            rowEnabled: false
        }

        // صفحه‌کلید — غیرفعال
        ChevronRow {
            width: parent.width
            iconKind: "keyboard"
            title: "زبان‌های صفحه‌کلید"
            statusText: "در انتظار سرویس"
            rowEnabled: false
        }
    }
}
