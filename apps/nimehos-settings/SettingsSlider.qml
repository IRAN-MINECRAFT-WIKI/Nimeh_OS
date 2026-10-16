// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// SettingsSlider.qml — اسلایدر کپسولی ۲۰۰px با knob متغیر
// ============================================================
// نوار کپسولی، fill با gradient، knob روی hover/drag بزرگ‌تر می‌شود.
// طول نوار ۲۰۰px و ارتفاع آن در حالت عادی ۸px و در drag ۱۲px است.
//
// توجه: از `sliderEnabled` به‌جای `enabled` استفاده شده — Item.enabled
// در QtQuick final است و override آن هشدار/خطای نوع تولید می‌کند.

import QtQuick

Item {
    id: root
    width: 200
    height: 32
    implicitWidth: 200
    implicitHeight: 32

    // ── API عمومی ──
    // مقدار فعلی
    property real value: 0
    // بازه‌ی مقدار
    property real from: 0
    property real to: 1
    // حالت فشردن (داخلی)
    property bool pressed: false
    // فعال/غیرفعال — نامشخص با `enabled` به‌دلیل final بودن Item.enabled
    property bool sliderEnabled: true
    // نمایش درصد کنار اسلایدر (اختیاری)
    property bool showValue: false
    // فرمت نمایش مقدار (پیش‌فرض: درصد)
    property string valueSuffix: "٪"
    signal moved(real value)

    readonly property real normalized: {
        if (to === from) return 0
        return Math.max(0, Math.min(1, (value - from) / (to - from)))
    }

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: root.pressed ? 12 : 8
        radius: height / 2
        color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1
        border.color: SettingsTheme.border
        opacity: root.sliderEnabled ? 1.0 : 0.5

        Behavior on height {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }

        // Fill با gradient
        Rectangle {
            width: parent.width * root.normalized
            height: parent.height
            radius: parent.radius
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: SettingsTheme.accentDeep }
                GradientStop { position: 1; color: SettingsTheme.accentSoft }
            }
        }

        // Knob
        Rectangle {
            id: knob
            width: (root.pressed || hoverMa.containsMouse) ? 18 : 12
            height: width
            radius: width / 2
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0, Math.min(parent.width - width,
                                     parent.width * root.normalized - width / 2))
            color: "#ffffff"
            border.width: 1
            border.color: SettingsTheme.accent

            Behavior on width {
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }
            Behavior on x {
                NumberAnimation { duration: 60; easing.type: Easing.OutCubic }
            }
        }
    }

    // نمایش مقدار کنار اسلایدر (اختیاری)
    Text {
        visible: root.showValue
        anchors.left: parent.right
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: Math.round(root.normalized * 100) + root.valueSuffix
        color: SettingsTheme.textDim
        font.family: SettingsTheme.fontLatin
        font.pixelSize: 11
    }

    MouseArea {
        id: hoverMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.sliderEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.sliderEnabled
        onPressed: (mouse) => { root.pressed = true; root._applyMouse(mouse.x) }
        onReleased: root.pressed = false
        onPositionChanged: (mouse) => {
            if (root.pressed) root._applyMouse(mouse.x)
        }
        onClicked: (mouse) => root._applyMouse(mouse.x)
    }

    function _applyMouse(mx) {
        const v = Math.max(0, Math.min(1, mx / track.width))
        root.value = root.from + v * (root.to - root.from)
        root.moved(root.value)
    }
}
