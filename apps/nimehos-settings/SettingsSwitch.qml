// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// SettingsSwitch.qml — سوییچ 48×28 با انیمیشن فنری
// ============================================================
// وقتی روشن است سبز، وقتی خاموش است خاکستری نیمه‌شفاف.
// دکمه با SpringAnimation حرکت می‌کند (حس فنری).

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
    signal toggled(bool checked)

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.locked
               ? Qt.rgba(0.93, 0.24, 0.24, 0.35)
               : (root.checked ? SettingsTheme.green : Qt.rgba(1, 1, 1, 0.1))
        border.width: 1
        border.color: root.locked
                      ? SettingsTheme.red
                      : (root.checked ? Qt.rgba(1, 1, 1, 0.18) : SettingsTheme.borderHi)

        Behavior on color {
            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        // دکمه (knob)
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

            Behavior on x {
                SpringAnimation {
                    spring: 3.2
                    damping: 0.34
                    mass: 0.9
                }
            }
        }

        // قفل کوچک وقتی locked=true
        Text {
            anchors.centerIn: parent
            text: "🔒"
            font.pixelSize: 9
            color: "#ffffff"
            visible: root.locked
            opacity: 0.85
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.locked ? Qt.ForbiddenCursor : Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
            if (root.locked) return
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
