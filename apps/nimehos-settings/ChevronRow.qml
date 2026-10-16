// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// ChevronRow.qml — ردیف با chevron (drill-down)
// ============================================================
// چیدمان RTL: chevron (◀) در سمت چپ، متن در وسط، آیکون در سمت راست.
// حالت‌ها:
//   • enabled (پیش‌فرض) — hover می‌شود و کلیک می‌خورد
//   • disabled — opacity ۰.۵، بدون hover، بدون کلیک
//   • statusText — به‌جای توضیح، برچسب وضعیت (مثلاً «در انتظار سرویس»)
// آیکون با Canvas بر اساس iconKind کشیده می‌شود.

import QtQuick

Rectangle {
    id: root
    width: parent ? parent.width : 400
    height: 56
    color: rowMa.containsMouse && rowEnabled
           ? Qt.rgba(1, 1, 1, 0.05)
           : SettingsTheme.cardBg
    border.width: 1
    border.color: SettingsTheme.border
    radius: SettingsTheme.rMd
    opacity: rowEnabled ? 1.0 : 0.55
    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on opacity { NumberAnimation { duration: 120 } }

    // ── API عمومی ──
    property string iconKind: ""
    property string title: ""
    property string description: ""
    property string statusText: ""
    property bool rowEnabled: true
    signal clicked()

    // آیکون
    Rectangle {
        id: iconBox
        width: 36
        height: 36
        radius: 10
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.rgba(1, 1, 1, 0.05)
        border.width: 1
        border.color: SettingsTheme.border

        Canvas {
            anchors.centerIn: parent
            width: 22
            height: 22
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.strokeStyle = SettingsTheme.accentSoft
                ctx.fillStyle = SettingsTheme.accentSoft
                ctx.lineWidth = 1.5
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                const k = root.iconKind
                if (k === "image") {
                    // تصویر/والپیپر
                    ctx.strokeRect(4, 5, 14, 12)
                    ctx.beginPath()
                    ctx.arc(8, 9, 1.5, 0, 2 * Math.PI)
                    ctx.fill()
                    ctx.beginPath()
                    ctx.moveTo(4, 16); ctx.lineTo(9, 11); ctx.lineTo(13, 15); ctx.lineTo(18, 10)
                    ctx.stroke()
                } else if (k === "palette") {
                    ctx.beginPath()
                    ctx.arc(11, 11, 7, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.beginPath(); ctx.arc(8, 8, 1.4, 0, 2 * Math.PI); ctx.fill()
                    ctx.beginPath(); ctx.arc(14, 8, 1.4, 0, 2 * Math.PI); ctx.fill()
                    ctx.beginPath(); ctx.arc(11, 14, 1.4, 0, 2 * Math.PI); ctx.fill()
                } else if (k === "themes") {
                    // تم — مستطیل با نوار رنگی
                    ctx.strokeRect(4, 5, 14, 12)
                    ctx.fillStyle = SettingsTheme.accent
                    ctx.fillRect(4, 14, 14, 3)
                } else if (k === "lockscreen") {
                    ctx.strokeRect(6, 9, 10, 8)
                    ctx.beginPath()
                    ctx.arc(11, 9, 3, Math.PI, 0)
                    ctx.stroke()
                } else if (k === "start") {
                    // لوگوی شروع — ۴ مربع
                    ctx.fillRect(5, 5, 5, 5)
                    ctx.fillRect(12, 5, 5, 5)
                    ctx.fillRect(5, 12, 5, 5)
                    ctx.fillRect(12, 12, 5, 5)
                } else if (k === "taskbar") {
                    // نوار وظیفه
                    ctx.strokeRect(3, 6, 16, 11)
                    ctx.fillStyle = SettingsTheme.accent
                    ctx.fillRect(5, 8, 4, 7)
                    ctx.fillRect(10, 8, 4, 7)
                } else if (k === "fonts") {
                    ctx.font = "bold 14px " + SettingsTheme.fontPersian
                    ctx.fillText("A", 6, 16)
                } else if (k === "apps") {
                    ctx.strokeRect(4, 4, 6, 6)
                    ctx.strokeRect(12, 4, 6, 6)
                    ctx.strokeRect(4, 12, 6, 6)
                    ctx.strokeRect(12, 12, 6, 6)
                } else if (k === "default") {
                    // ست — دایره با چک
                    ctx.beginPath()
                    ctx.arc(11, 11, 7, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(8, 11); ctx.lineTo(10, 13); ctx.lineTo(14, 9)
                    ctx.stroke()
                } else if (k === "startup") {
                    // روشنایی — صاعقه
                    ctx.beginPath()
                    ctx.moveTo(13, 3); ctx.lineTo(7, 13); ctx.lineTo(11, 13); ctx.lineTo(9, 19); ctx.lineTo(15, 9); ctx.lineTo(11, 9); ctx.closePath()
                    ctx.fill()
                } else if (k === "video") {
                    // پخش — مثلث در دایره
                    ctx.beginPath()
                    ctx.arc(11, 11, 7, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(9, 7); ctx.lineTo(15, 11); ctx.lineTo(9, 15); ctx.closePath()
                    ctx.fill()
                } else if (k === "person") {
                    ctx.beginPath()
                    ctx.arc(11, 7, 3, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(11, 18, 6, Math.PI, 2 * Math.PI)
                    ctx.stroke()
                } else if (k === "email") {
                    // پاکت
                    ctx.strokeRect(4, 6, 14, 10)
                    ctx.beginPath()
                    ctx.moveTo(4, 6); ctx.lineTo(11, 12); ctx.lineTo(18, 6)
                    ctx.stroke()
                } else if (k === "key") {
                    ctx.beginPath()
                    ctx.arc(7, 11, 3, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(10, 11); ctx.lineTo(18, 11)
                    ctx.moveTo(15, 11); ctx.lineTo(15, 14)
                    ctx.stroke()
                } else if (k === "family") {
                    // دو نفر
                    ctx.beginPath()
                    ctx.arc(7, 8, 2.5, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(15, 8, 2.5, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(7, 17, 4, Math.PI, 2 * Math.PI)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(15, 17, 4, Math.PI, 2 * Math.PI)
                    ctx.stroke()
                } else if (k === "shield") {
                    ctx.beginPath()
                    ctx.moveTo(11, 3); ctx.lineTo(18, 6); ctx.lineTo(18, 11); ctx.quadraticCurveTo(18, 17, 11, 20); ctx.quadraticCurveTo(4, 17, 4, 11); ctx.lineTo(4, 6); ctx.closePath()
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(8, 11); ctx.lineTo(10, 13); ctx.lineTo(14, 9)
                    ctx.stroke()
                } else if (k === "diagnostic") {
                    // چارت — سه میله
                    ctx.fillRect(5, 13, 3, 6)
                    ctx.fillRect(10, 9, 3, 10)
                    ctx.fillRect(15, 5, 3, 14)
                } else if (k === "permissions") {
                    // قفل با چرخ‌دنده
                    ctx.strokeRect(6, 9, 10, 8)
                    ctx.beginPath()
                    ctx.arc(11, 9, 3, Math.PI, 0)
                    ctx.stroke()
                } else if (k === "info") {
                    ctx.beginPath()
                    ctx.arc(11, 11, 7, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.font = "bold 11px " + SettingsTheme.fontPersian
                    ctx.fillText("i", 10, 15)
                } else if (k === "vpn") {
                    ctx.beginPath()
                    ctx.moveTo(11, 3); ctx.lineTo(18, 6); ctx.lineTo(18, 11); ctx.quadraticCurveTo(18, 17, 11, 20); ctx.quadraticCurveTo(4, 17, 4, 11); ctx.lineTo(4, 6); ctx.closePath()
                    ctx.stroke()
                    ctx.fillRect(9, 10, 4, 5)
                    ctx.beginPath()
                    ctx.arc(11, 10, 2, Math.PI, 0)
                    ctx.stroke()
                } else if (k === "hotspot") {
                    ctx.beginPath()
                    ctx.arc(11, 14, 2, 0, 2 * Math.PI)
                    ctx.fill()
                    ctx.beginPath()
                    ctx.arc(11, 14, 5, -Math.PI * 0.75, -Math.PI * 0.25)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(11, 14, 8, -Math.PI * 0.75, -Math.PI * 0.25)
                    ctx.stroke()
                } else if (k === "proxy") {
                    // سرور پروکسی
                    ctx.strokeRect(4, 5, 14, 8)
                    ctx.strokeRect(4, 14, 14, 4)
                    ctx.beginPath()
                    ctx.moveTo(7, 9); ctx.lineTo(15, 9)
                    ctx.moveTo(7, 16); ctx.lineTo(15, 16)
                    ctx.stroke()
                } else if (k === "mouse") {
                    ctx.beginPath()
                    ctx.ellipse(11, 11, 5, 7, 0, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(11, 4); ctx.lineTo(11, 9)
                    ctx.stroke()
                } else if (k === "keyboard") {
                    ctx.strokeRect(3, 6, 16, 9)
                    ctx.beginPath()
                    for (let i = 0; i < 5; i++) {
                        ctx.moveTo(5 + i * 3, 8); ctx.lineTo(5 + i * 3, 9)
                    }
                    ctx.moveTo(7, 12); ctx.lineTo(15, 12)
                    ctx.stroke()
                } else if (k === "printer") {
                    ctx.strokeRect(6, 4, 10, 6)
                    ctx.strokeRect(4, 10, 14, 6)
                    ctx.strokeRect(6, 16, 10, 4)
                } else if (k === "camera") {
                    ctx.strokeRect(4, 7, 14, 9)
                    ctx.beginPath()
                    ctx.arc(11, 11, 3, 0, 2 * Math.PI)
                    ctx.stroke()
                }
            }
        }
    }

    // متن: عنوان + (توضیح یا statusText)
    Column {
        id: textCol
        anchors.right: iconBox.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: chevronBox.right
        anchors.leftMargin: 12
        spacing: 2

        Text {
            text: root.title
            color: SettingsTheme.text
            font.family: SettingsTheme.fontPersian
            font.pixelSize: 13
            font.weight: Font.Medium
            elide: Text.ElideRight
            width: textCol.width
        }

        Text {
            text: root.statusText.length > 0 ? root.statusText : root.description
            color: root.statusText.length > 0 ? SettingsTheme.amber : SettingsTheme.textMute
            font.family: SettingsTheme.fontPersian
            font.pixelSize: 11
            elide: Text.ElideRight
            width: textCol.width
            visible: text.length > 0
        }
    }

    // chevron در سمت چپ (در RTL، سمت چپ = end)
    Item {
        id: chevronBox
        width: 24
        height: 24
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter

        Canvas {
            anchors.centerIn: parent
            width: 14
            height: 14
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.strokeStyle = root.rowEnabled ? SettingsTheme.textMute : SettingsTheme.textMute
                ctx.lineWidth = 1.6
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                // فلش چپ (در RTL = جهت drill-down)
                ctx.beginPath()
                ctx.moveTo(10, 3); ctx.lineTo(4, 7); ctx.lineTo(10, 11)
                ctx.stroke()
            }
        }
    }

    MouseArea {
        id: rowMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.rowEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.rowEnabled
        onClicked: root.clicked()
    }
}
