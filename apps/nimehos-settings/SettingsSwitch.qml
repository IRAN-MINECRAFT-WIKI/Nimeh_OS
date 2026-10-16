// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// SettingsSwitch.qml — سوییچ ۴۸×۲۸ با ۴ حالت و انیمیشن فنری
// ============================================================
// حالت‌ها:
//   • on      → سبز، knob سمت چپ (در RTL: روی)
//   • off     → خاکستری نیمه‌شفاف، knob سمت راست (در RTL: خاموش)
//   • locked  → قرمز، غیرفعال، cursor ممنوع (قفل سیستم)
//   • unknown → علامت «؟»، غیرفعال (در انتظار سرویس)
//
// knob با SpringAnimation حرکت می‌کند (حس فنری).
// هیچ emoji استفاده نمی‌شود — قفل با Canvas کشیده می‌شود.

import QtQuick

Item {
    id: root
    width: 48
    height: 28
    implicitWidth: 48
    implicitHeight: 28

    // ── API عمومی ──
    property bool checked: false
    // اگر true باشد سوییچ غیرفعال و قرمز دیده می‌شود (قفل سیستم).
    property bool locked: false
    // اگر true باشد سوییچ غیرفعال و علامت «؟» نشان داده می‌شود.
    property bool unknown: false
    signal toggled(bool checked)

    // فعال بودن تعاملی — در حالت locked/unknown غیرفعال است.
    readonly property bool interactive: !root.locked && !root.unknown

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.locked
               ? Qt.rgba(0.93, 0.24, 0.24, 0.35)
               : root.unknown
                 ? Qt.rgba(1, 1, 1, 0.06)
                 : (root.checked ? SettingsTheme.green : Qt.rgba(1, 1, 1, 0.1))
        border.width: 1
        border.color: root.locked
                      ? SettingsTheme.red
                      : root.unknown
                        ? SettingsTheme.borderHi
                        : (root.checked ? Qt.rgba(1, 1, 1, 0.18) : SettingsTheme.borderHi)

        Behavior on color {
            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        // دکمه (knob) — فقط وقتی حالت on/off است
        Rectangle {
            id: knob
            width: 20
            height: 20
            radius: 10
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? (parent.width - width - 4) : 4
            color: "#ffffff"
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.06)
            visible: !root.locked && !root.unknown

            Behavior on x {
                SpringAnimation {
                    spring: 3.2
                    damping: 0.34
                    mass: 0.9
                }
            }
        }

        // علامت «؟» در حالت unknown
        Text {
            anchors.centerIn: parent
            text: "؟"
            color: SettingsTheme.textDim
            font.family: SettingsTheme.fontPersian
            font.pixelSize: 14
            font.weight: Font.DemiBold
            visible: root.unknown
        }

        // قفل کشیده‌شده با Canvas در حالت locked (نه emoji)
        Canvas {
            anchors.centerIn: parent
            width: 14
            height: 14
            visible: root.locked
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.strokeStyle = "#ffffff"
                ctx.fillStyle = "#ffffff"
                ctx.lineWidth = 1.4
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                // بدنه‌ی قفل (مستطیل ساده — roundedRect در Context2D Qt موجود نیست)
                ctx.fillRect(3, 6, 8, 6)
                ctx.strokeRect(3, 6, 8, 6)
                // شکلک قفل (نیم‌دایره)
                ctx.beginPath()
                ctx.arc(7, 6, 2.6, Math.PI, 0, false)
                ctx.stroke()
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.locked ? Qt.ForbiddenCursor
                                 : (root.unknown ? Qt.ArrowCursor : Qt.PointingHandCursor)
        hoverEnabled: true
        enabled: root.interactive
        onClicked: {
            if (!root.interactive) return
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
