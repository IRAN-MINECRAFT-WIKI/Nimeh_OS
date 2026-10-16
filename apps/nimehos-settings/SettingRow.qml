// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// SettingRow.qml — ردیف تنظیمات افقی
// ============================================================
// چیدمان: آیکون ۳۶px | عنوان + توضیح | کنترل (سوییچ/اسلایدر)
// کنترل به‌صورت فرزند مستقیم اضافه می‌شود (default property).
//
// آیکون‌ها با Canvas کشیده می‌شوند (نه emoji). برای تعیین آیکون از
// پراپرتی `iconKind` استفاده کنید (مقادیر: bright/dark/notif/airplane/
// update/bluetooth/wifi/ethernet/vpn/hotspot/proxy/sound/battery/...).

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
    property string iconKind: ""
    property string iconText: ""     // fallback (در صورت خالی بودن iconKind)
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

        // آیکون کشیده‌شده با Canvas (نه emoji)
        Canvas {
            anchors.centerIn: parent
            width: 22
            height: 22
            visible: root.iconKind.length > 0
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.strokeStyle = SettingsTheme.accentSoft
                ctx.fillStyle = SettingsTheme.accentSoft
                ctx.lineWidth = 1.5
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                const k = root.iconKind
                if (k === "sound") {
                    ctx.beginPath()
                    ctx.moveTo(5, 9); ctx.lineTo(8, 9); ctx.lineTo(12, 5); ctx.lineTo(12, 17); ctx.lineTo(8, 13); ctx.lineTo(5, 13); ctx.closePath()
                    ctx.fill()
                    ctx.beginPath()
                    ctx.arc(12, 11, 4, -Math.PI * 0.35, Math.PI * 0.35)
                    ctx.stroke()
                } else if (k === "bright") {
                    // خورشید با پرتوها
                    ctx.beginPath()
                    ctx.arc(11, 11, 3.5, 0, 2 * Math.PI)
                    ctx.stroke()
                    for (let i = 0; i < 8; i++) {
                        const a = (i / 8) * 2 * Math.PI
                        ctx.beginPath()
                        ctx.moveTo(11 + Math.cos(a) * 5.5, 11 + Math.sin(a) * 5.5)
                        ctx.lineTo(11 + Math.cos(a) * 8,   11 + Math.sin(a) * 8)
                        ctx.stroke()
                    }
                } else if (k === "dark") {
                    // ماه
                    ctx.beginPath()
                    ctx.arc(11, 11, 7, 0, 2 * Math.PI)
                    ctx.fillStyle = SettingsTheme.accentSoft
                    ctx.fill()
                    ctx.fillStyle = SettingsTheme.cardBg
                    ctx.beginPath()
                    ctx.arc(14, 9, 6, 0, 2 * Math.PI)
                    ctx.fill()
                } else if (k === "notif") {
                    // زنگ
                    ctx.beginPath()
                    ctx.moveTo(7, 16); ctx.lineTo(15, 16)
                    ctx.lineTo(13, 12); ctx.lineTo(13, 8); ctx.lineTo(9, 8); ctx.lineTo(9, 12); ctx.closePath()
                    ctx.fill()
                    ctx.beginPath()
                    ctx.arc(11, 5, 1.4, 0, 2 * Math.PI)
                    ctx.fill()
                } else if (k === "airplane") {
                    // هواپیما
                    ctx.beginPath()
                    ctx.moveTo(11, 3); ctx.lineTo(13, 9); ctx.lineTo(20, 11); ctx.lineTo(20, 13); ctx.lineTo(13, 12); ctx.lineTo(12, 18); ctx.lineTo(14, 19); ctx.lineTo(14, 20); ctx.lineTo(11, 19); ctx.lineTo(8, 20); ctx.lineTo(8, 19); ctx.lineTo(10, 18); ctx.lineTo(9, 12); ctx.lineTo(2, 13); ctx.lineTo(2, 11); ctx.lineTo(9, 9); ctx.closePath()
                    ctx.fill()
                } else if (k === "update") {
                    ctx.beginPath()
                    ctx.arc(11, 11, 7, -Math.PI / 2, Math.PI * 1.3)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(11, 3); ctx.lineTo(15, 5); ctx.lineTo(13, 8); ctx.closePath()
                    ctx.fill()
                } else if (k === "bluetooth") {
                    ctx.beginPath()
                    ctx.moveTo(8, 4); ctx.lineTo(14, 11); ctx.lineTo(8, 18); ctx.lineTo(8, 4); ctx.lineTo(14, 18)
                    ctx.stroke()
                } else if (k === "wifi") {
                    ctx.beginPath()
                    ctx.arc(11, 17, 8, -Math.PI * 0.75, -Math.PI * 0.25)
                    ctx.arc(11, 17, 5, -Math.PI * 0.75, -Math.PI * 0.25)
                    ctx.arc(11, 17, 2.5, -Math.PI * 0.75, -Math.PI * 0.25)
                    ctx.stroke()
                } else if (k === "ethernet") {
                    // کابل شبکه
                    ctx.strokeRect(5, 6, 12, 10)
                    ctx.beginPath()
                    ctx.moveTo(11, 16); ctx.lineTo(11, 20)
                    ctx.stroke()
                } else if (k === "vpn" || k === "proxy") {
                    // سپر با قفل
                    ctx.beginPath()
                    ctx.moveTo(11, 3); ctx.lineTo(18, 6); ctx.lineTo(18, 11); ctx.quadraticCurveTo(18, 17, 11, 20); ctx.quadraticCurveTo(4, 17, 4, 11); ctx.lineTo(4, 6); ctx.closePath()
                    ctx.stroke()
                    ctx.fillRect(9, 10, 4, 5)
                    ctx.beginPath()
                    ctx.arc(11, 10, 2, Math.PI, 0)
                    ctx.stroke()
                } else if (k === "hotspot") {
                    // نقطه‌ی دسترسی
                    ctx.beginPath()
                    ctx.arc(11, 14, 2, 0, 2 * Math.PI)
                    ctx.fill()
                    ctx.beginPath()
                    ctx.arc(11, 14, 5, -Math.PI * 0.75, -Math.PI * 0.25)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(11, 14, 8, -Math.PI * 0.75, -Math.PI * 0.25)
                    ctx.stroke()
                } else if (k === "battery") {
                    ctx.strokeRect(5, 7, 12, 8)
                    ctx.fillRect(17, 9, 2, 4)
                    ctx.fillRect(6, 8, 10 * 0.7, 6)
                } else if (k === "person") {
                    ctx.beginPath()
                    ctx.arc(11, 7, 3, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(11, 18, 6, Math.PI, 2 * Math.PI)
                    ctx.stroke()
                } else if (k === "shield") {
                    ctx.beginPath()
                    ctx.moveTo(11, 3); ctx.lineTo(18, 6); ctx.lineTo(18, 11); ctx.quadraticCurveTo(18, 17, 11, 20); ctx.quadraticCurveTo(4, 17, 4, 11); ctx.lineTo(4, 6); ctx.closePath()
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(8, 11); ctx.lineTo(10, 13); ctx.lineTo(14, 9)
                    ctx.stroke()
                } else if (k === "globe") {
                    ctx.beginPath()
                    ctx.arc(11, 11, 7, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(4, 11); ctx.lineTo(18, 11)
                    ctx.moveTo(11, 4); ctx.lineTo(11, 18)
                    ctx.stroke()
                } else if (k === "controller") {
                    ctx.beginPath()
                    ctx.moveTo(4, 9); ctx.lineTo(18, 9); ctx.lineTo(17, 17); ctx.lineTo(5, 17); ctx.closePath()
                    ctx.stroke()
                    ctx.beginPath(); ctx.arc(8, 13, 1.2, 0, 2 * Math.PI); ctx.fill()
                    ctx.beginPath(); ctx.arc(14, 13, 1.2, 0, 2 * Math.PI); ctx.fill()
                } else if (k === "text") {
                    // Aa
                    ctx.font = "11px " + SettingsTheme.fontPersian
                    ctx.fillText("Aa", 4, 14)
                } else if (k === "eye") {
                    ctx.beginPath()
                    ctx.ellipse(11, 11, 7, 4, 0, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.arc(11, 11, 2, 0, 2 * Math.PI)
                    ctx.fill()
                } else if (k === "mic") {
                    ctx.strokeRect(9, 4, 4, 8)
                    ctx.beginPath()
                    ctx.arc(11, 14, 3, 0, Math.PI)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(11, 17); ctx.lineTo(11, 19)
                    ctx.stroke()
                } else if (k === "camera") {
                    ctx.strokeRect(4, 7, 14, 9)
                    ctx.beginPath()
                    ctx.arc(11, 11, 3, 0, 2 * Math.PI)
                    ctx.stroke()
                } else if (k === "info") {
                    ctx.beginPath()
                    ctx.arc(11, 11, 7, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.font = "bold 11px " + SettingsTheme.fontPersian
                    ctx.fillText("i", 10, 15)
                } else if (k === "clock") {
                    ctx.beginPath()
                    ctx.arc(11, 11, 7, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(11, 11); ctx.lineTo(11, 6)
                    ctx.moveTo(11, 11); ctx.lineTo(15, 11)
                    ctx.stroke()
                } else if (k === "calendar") {
                    ctx.strokeRect(4, 5, 14, 13)
                    ctx.beginPath()
                    ctx.moveTo(4, 9); ctx.lineTo(18, 9)
                    ctx.moveTo(8, 3); ctx.lineTo(8, 6)
                    ctx.moveTo(14, 3); ctx.lineTo(14, 6)
                    ctx.stroke()
                } else if (k === "list") {
                    for (let i = 0; i < 3; i++) {
                        ctx.beginPath()
                        ctx.moveTo(5, 7 + i * 5); ctx.lineTo(7, 7 + i * 5)
                        ctx.moveTo(9, 7 + i * 5); ctx.lineTo(18, 7 + i * 5)
                        ctx.stroke()
                    }
                } else if (k === "apps") {
                    ctx.strokeRect(4, 4, 6, 6)
                    ctx.strokeRect(12, 4, 6, 6)
                    ctx.strokeRect(4, 12, 6, 6)
                    ctx.strokeRect(12, 12, 6, 6)
                } else if (k === "key") {
                    ctx.beginPath()
                    ctx.arc(8, 11, 3, 0, 2 * Math.PI)
                    ctx.stroke()
                    ctx.beginPath()
                    ctx.moveTo(11, 11); ctx.lineTo(18, 11)
                    ctx.moveTo(15, 11); ctx.lineTo(15, 14)
                    ctx.stroke()
                }
            }
        }

        // fallback متن (وقتی iconKind خالی است)
        Text {
            anchors.centerIn: parent
            text: root.iconText
            font.pixelSize: 16
            font.family: SettingsTheme.fontPersian
            visible: root.iconKind.length === 0
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
