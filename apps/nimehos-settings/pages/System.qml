// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// System.qml — صفحه‌ی سیستم
// ============================================================
// صدا (Pipewire.defaultAudioSink.audio.volume)، باتری
// (UPower.displayDevice.percentage)، حالت تاریک، اعلان‌ها،
// حالت هواپیما (قفل سیستم — قرمز، locked=true)، به‌روزرسانی
// خودکار (نامشخص — unknown=true)، روشنایی نمایشگر (در انتظار سرویس).
//
// توجه: هیچ Process/execDetached استفاده نمی‌شود. تمام داده‌ها از
// Quickshell.Services.Pipewire و Quickshell.Services.UPower خوانده می‌شوند.
// روشنایی و شبکه: «در انتظار سرویس» (بدون nmcli/brightnessctl).

import QtQuick
import ".."
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

Item {
    id: root
    anchors.fill: parent

    // ── صدا (Pipewire) ──
    readonly property var audioSink: Pipewire.defaultAudioSink
    readonly property real volume: audioSink?.audio?.volume ?? 0
    readonly property bool muted: audioSink?.audio?.muted ?? false

    // ── باتری (UPower) ──
    // Quickshell UPower.displayDevice.percentage مقدار ۰..۱ برمی‌گرداند.
    readonly property bool hasBattery: UPower.displayDevice !== null
    readonly property int batteryPercent: hasBattery ? Math.round(UPower.displayDevice.percentage * 100) : -1
    readonly property bool charging: hasBattery ? (UPower.displayDevice.state === 1) : false

    // ── حالت‌های محلی (بدون backend) ──
    property bool darkMode: true
    property bool notificationsEnabled: true

    // ── عنوان صفحه ──
    Text {
        id: header
        anchors.top: parent.top
        anchors.right: parent.right
        text: "سیستم"
        color: SettingsTheme.text
        font.family: SettingsTheme.fontPersian
        font.pixelSize: 24
        font.weight: Font.DemiBold
    }

    // ── لیست قابل اسکرول ──
    ListView {
        id: list
        anchors {
            top: header.bottom
            topMargin: 20
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        clip: true
        spacing: 10
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        model: [
            { kind: "sound" },
            { kind: "battery" },
            { kind: "bright" },
            { kind: "dark" },
            { kind: "notif" },
            { kind: "airplane" },
            { kind: "autoupdate" }
        ]

        delegate: Item {
            width: list.width
            height: loader.item ? loader.item.height : 0
            Loader {
                id: loader
                sourceComponent: {
                    switch (modelData.kind) {
                        case "sound":     return soundComp
                        case "battery":   return batteryComp
                        case "bright":    return brightComp
                        case "dark":      return darkComp
                        case "notif":     return notifComp
                        case "airplane":  return airplaneComp
                        case "autoupdate":return autoUpdateComp
                    }
                    return null
                }
            }
        }
    }

    // ============================================================
    // کامپوننت‌های داخلی — هر یک با anchors.fill: parent
    // تا parent.width به‌صورت ایمن در دسترس باشد.
    // ============================================================

    // ── صدا ──
    component SoundRow: Item {
        width: parent ? parent.width : 600
        height: 84

        Rectangle {
            anchors.fill: parent
            color: SettingsTheme.cardBg
            border.width: 1
            border.color: SettingsTheme.border
            radius: SettingsTheme.rMd

            // آیکون صدا — Canvas (نه emoji)
            Canvas {
                id: sndIcon
                width: 36; height: 36
                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = SettingsTheme.accentSoft
                    ctx.fillStyle = SettingsTheme.accentSoft
                    ctx.lineWidth = 1.5
                    ctx.lineCap = "round"
                    ctx.lineJoin = "round"
                    // بلندگو
                    ctx.beginPath()
                    ctx.moveTo(9, 14); ctx.lineTo(13, 14); ctx.lineTo(18, 9); ctx.lineTo(18, 27); ctx.lineTo(13, 22); ctx.lineTo(9, 22); ctx.closePath()
                    ctx.fill()
                    // امواج صدا
                    ctx.beginPath()
                    ctx.arc(18, 18, 5, -Math.PI * 0.35, Math.PI * 0.35)
                    ctx.stroke()
                }
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                id: sndText
                anchors { left: sndIcon.right; leftMargin: 12; verticalCenter: parent.verticalCenter; right: sndSlider.left; rightMargin: 12 }
                spacing: 2
                Text {
                    text: "صدا"
                    color: SettingsTheme.text
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
                Text {
                    text: root.muted
                          ? "بی‌صدا"
                          : (root.volume > 0 ? Math.round(root.volume * 100) + "٪" : "در انتظار سرویس")
                    color: root.muted ? SettingsTheme.red : SettingsTheme.textMute
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 11
                }
            }

            SettingsSlider {
                id: sndSlider
                anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                width: 200
                from: 0; to: 1
                value: root.muted ? 0 : root.volume
                sliderEnabled: root.audioSink != null && !root.muted
                onMoved: (v) => {
                    if (root.audioSink) {
                        root.audioSink.audio.muted = false
                        root.audioSink.audio.volume = v
                    }
                }
            }
        }
    }

    // ── باتری ──
    component BatteryRow: Item {
        width: parent ? parent.width : 600
        height: 84

        Rectangle {
            anchors.fill: parent
            color: SettingsTheme.cardBg
            border.width: 1
            border.color: SettingsTheme.border
            radius: SettingsTheme.rMd

            Canvas {
                id: batIcon
                width: 36; height: 36
                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    ctx.strokeStyle = SettingsTheme.accentSoft
                    ctx.fillStyle = SettingsTheme.accentSoft
                    ctx.lineWidth = 1.5
                    // بدنه‌ی باتری
                    ctx.strokeRect(6, 12, 22, 12)
                    ctx.fillRect(28, 15, 2, 6)
                    // نوار شارژ
                    ctx.fillRect(8, 14, 18 * Math.max(0, Math.min(1, root.batteryPercent / 100)), 8)
                }
            }

            Column {
                anchors { left: batIcon.right; leftMargin: 12; verticalCenter: parent.verticalCenter; right: batteryWidget.left; rightMargin: 12 }
                spacing: 2
                Text {
                    text: "باتری"
                    color: SettingsTheme.text
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
                Text {
                    text: root.hasBattery
                          ? (root.batteryPercent + "٪" + (root.charging ? " — در حال شارژ" : " — روی باتری"))
                          : "باتری موجود نیست"
                    color: root.hasBattery ? (root.charging ? SettingsTheme.green : SettingsTheme.amber) : SettingsTheme.textMute
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 11
                }
            }

            // ── ویجت بصری باتری ──
            Item {
                id: batteryWidget
                anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                width: 90; height: 36

                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    layoutDirection: Qt.LeftToRight

                    Rectangle {
                        width: 60
                        height: 28
                        radius: 6
                        color: Qt.rgba(1, 1, 1, 0.06)
                        border.width: 1
                        border.color: SettingsTheme.borderHi
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 3 }
                            width: Math.max(0, Math.min(1, root.batteryPercent / 100)) * (parent.width - 6)
                            radius: 3
                            color: !root.hasBattery ? SettingsTheme.textMute
                                   : (root.batteryPercent <= 15 ? SettingsTheme.red
                                  : (root.batteryPercent <= 30 ? SettingsTheme.amber : SettingsTheme.green))
                            Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        }
                    }

                    // نوب باتری
                    Rectangle {
                        width: 4
                        height: 12
                        radius: 2
                        color: SettingsTheme.borderHi
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    // ── روشنایی نمایشگر (در انتظار سرویس — بدون brightnessctl) ──
    component BrightnessRow: SettingRow {
        iconKind: "bright"
        title: "روشنایی نمایشگر"
        description: "در انتظار سرویس"
        // هیچ کنترلی — فقط برچسب «در انتظار سرویس»
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
                    text: "در انتظار سرویس"
                    color: SettingsTheme.amber
                    font.family: SettingsTheme.fontPersian
                    font.pixelSize: 10
                }
            }
        }
    }

    // ── حالت تاریک ──
    component DarkRow: SettingRow {
        iconKind: "dark"
        title: "حالت تاریک"
        description: "تم تیره برای کل سیستم"
        SettingsSwitch {
            anchors.centerIn: parent
            checked: root.darkMode
            onToggled: (c) => root.darkMode = c
        }
    }

    // ── اعلان‌ها ──
    component NotifRow: SettingRow {
        iconKind: "notif"
        title: "اعلان‌ها"
        description: "نمایش اعلان‌های برنامه‌ها و سیستم"
        SettingsSwitch {
            anchors.centerIn: parent
            checked: root.notificationsEnabled
            onToggled: (c) => root.notificationsEnabled = c
        }
    }

    // ── حالت هواپیما (قفل شده — قرمز) ──
    component AirplaneRow: SettingRow {
        iconKind: "airplane"
        title: "حالت هواپیما"
        description: "قفل شده توسط مدیر سیستم"
        SettingsSwitch {
            anchors.centerIn: parent
            checked: false
            locked: true
        }
    }

    // ── به‌روزرسانی خودکار (نامشخص) ──
    component AutoUpdateRow: SettingRow {
        iconKind: "update"
        title: "به‌روزرسانی خودکار"
        description: "وضعیت نامشخص"
        SettingsSwitch {
            anchors.centerIn: parent
            checked: false
            unknown: true
        }
    }

    // ── کامپوننت‌های اصلی برای Loader ──
    Component { id: soundComp;     SoundRow {} }
    Component { id: batteryComp;   BatteryRow {} }
    Component { id: brightComp;    BrightnessRow {} }
    Component { id: darkComp;      DarkRow {} }
    Component { id: notifComp;     NotifRow {} }
    Component { id: airplaneComp;  AirplaneRow {} }
    Component { id: autoUpdateComp; AutoUpdateRow {} }
}
