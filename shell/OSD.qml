// ═════════════════════════════════════════════════════════
//  OSD — پیام کوچک صدا و روشنایی (طبق نمونه‌ی HTML، کپسول شیشه‌ای)
//  API سازگار با shell.qml:
//    show(type, value, muted)   type: "volume" | "brightness"
//    property level (۰..۱۰۰)، property muted
// ═════════════════════════════════════════════════════════
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire  // سرویس صدا (Pipewire) برای خواندن خودکار volume هنگام تغییر

PanelWindow {
    id: osd

    property string osdType: "volume"
    property int level: 50
    property bool muted: false
    property bool shownNow: false

    function show(type, value, isMuted) {
        osdType = type
        level = Math.max(0, Math.min(100, Math.round(value)))
        muted = isMuted
        shownNow = true
        hideTimer.restart()
    }

    // ── خواندن صدای فعلی از Pipewire و نمایش OSD (بدون نیاز به فراخوانی خارجی) ──
    function showVolume() {
        const v = Pipewire.defaultAudioSink
        if (v && v.audio) {
            osd.show("volume", Math.round(v.audio.volume * 100), v.audio.muted)
        }
    }

    // ── نمایش خودکار OSD هنگام تغییر volume یا mute (کلیدهای صدا در hyprland.conf) ──
    Connections {
        target: Pipewire.defaultAudioSink?.audio ?? null
        function onVolumeChanged() { osd.showVolume() }
        function onMutedChanged() { osd.showVolume() }
    }

    anchors { bottom: true; left: true; right: true }
    margins { bottom: 96 }
    implicitHeight: 64
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.namespace: "nimeh-osd"
    WlrLayershell.layer: WlrLayer.Overlay
    visible: shownNow || pill.opacity > 0.01

    Timer {
        id: hideTimer
        interval: 1600
        onTriggered: osd.shownNow = false
    }

    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: 300
        height: 52
        radius: 26
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.12)
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.20, 0.21, 0.26, 0.92) }
            GradientStop { position: 1.0; color: Qt.rgba(0.11, 0.12, 0.16, 0.95) }
        }

        opacity: osd.shownNow ? 1 : 0
        transform: Translate { y: osd.shownNow ? 0 : 14 }
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 14

            Text {
                text: osd.muted ? "×" : (osd.osdType === "volume" ? "♪" : "☀")
                color: osd.muted ? "#FCA5A5" : "#4CC2FF"
                font.pixelSize: 18
                Layout.preferredWidth: 22
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                radius: 3
                color: Qt.rgba(1, 1, 1, 0.14)
                Rectangle {
                    width: parent.width * (osd.muted ? 0 : osd.level / 100)
                    height: parent.height
                    radius: 3
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#0078D4" }
                        GradientStop { position: 1.0; color: "#4CC2FF" }
                    }
                    Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                }
            }

            Text {
                text: osd.muted ? "بی‌صدا" : osd.level + "٪"
                color: "#E5E7EB"
                font.family: "Vazirmatn"
                font.pixelSize: 12
                Layout.preferredWidth: 46
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
