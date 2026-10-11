import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// ============================================================
// OSD — On-Screen Display for volume/brightness changes
// Feature L: Volume/Brightness OSD
// ============================================================

PanelWindow {
    id: osdRoot
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    margins.bottom: 80
    implicitWidth: 280
    implicitHeight: 56
    color: "transparent"
    visible: false
    WlrLayershell.namespace: "nimeh-osd"
    WlrLayershell.layer: WlrLayer.Overlay

    property string osdType: "volume"  // "volume" | "brightness"
    property int level: 50
    property bool muted: false

    function show(type, value, isMuted) {
        osdType = type
        level = value
        muted = isMuted || false
        visible = true
        appear.start()
        hideTimer.restart()
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: Qt.rgba(20/255,20/255,24/255,0.95)
        border.color: Qt.rgba(1,1,1,0.10)
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 14

            // Icon
            Image {
                id: osdIcon
                anchors.verticalCenter: parent.verticalCenter
                width: 22
                height: 22
                sourceSize: Qt.size(22,22)
                source: {
                    if (osdRoot.osdType === "volume") {
                        if (osdRoot.muted || osdRoot.level === 0)
                            return "file:///home/nimeh/NimehOS/shell/icons/png/ic_fluent_speaker_off_24_regular.png"
                        if (osdRoot.level < 33)
                            return "file:///home/nimeh/NimehOS/shell/icons/png/ic_fluent_speaker_0_24_regular.png"
                        if (osdRoot.level < 66)
                            return "file:///home/nimeh/NimehOS/shell/icons/png/ic_fluent_speaker_1_24_regular.png"
                        return "file:///home/nimeh/NimehOS/shell/icons/png/ic_fluent_speaker_2_24_regular.png"
                    } else {
                        if (osdRoot.level < 33)
                            return "file:///home/nimeh/NimehOS/shell/icons/png/ic_fluent_brightness_low_24_regular.png"
                        return "file:///home/nimeh/NimehOS/shell/icons/png/ic_fluent_brightness_high_24_regular.png"
                    }
                }
            }

            // Progress bar
            Rectangle {
                id: bar
                width: 180
                height: 6
                radius: 3
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(1,1,1,0.10)

                Rectangle {
                    width: parent.width * (osdRoot.level / 100)
                    height: parent.height
                    radius: 3
                    color: osdRoot.muted ? "#7A8598" : "#0099FF"
                    Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            // Value
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Theme.toFa(osdRoot.level) + "٪"
                color: "#F0F4FF"
                font.family: "Vazirmatn"
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
        }
    }

    // Auto-poller برای volume change
    property int lastVolume: -1
    property bool lastMuted: false

    Process {
        id: volCheck
        command: ["sh","-c","wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = this.text.trim()
                if (!t) return
                const m = t.match(/Volume:\s*([0-9.]+)/)
                if (!m) return
                const v = Math.round(parseFloat(m[1]) * 100)
                const muted = t.includes("MUTED")
                if (osdRoot.lastVolume >= 0 && (v !== osdRoot.lastVolume || muted !== osdRoot.lastMuted)) {
                    osdRoot.show("volume", v, muted)
                }
                osdRoot.lastVolume = v
                osdRoot.lastMuted = muted
            }
        }
    }

    Timer {
        interval: 800
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volCheck.running = true
    }

    ParallelAnimation {
        id: appear
        NumberAnimation { target: osdRoot; property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
        NumberAnimation { target: osdRoot; property: "scale"; from: 0.9; to: 1; duration: 180; easing.type: Easing.OutBack }
    }
    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: {
            disappear.start()
            hideAfter.start()
        }
    }
    ParallelAnimation {
        id: disappear
        NumberAnimation { target: osdRoot; property: "opacity"; to: 0; duration: 200 }
        NumberAnimation { target: osdRoot; property: "scale"; to: 0.9; duration: 200 }
    }
    Timer { id: hideAfter; interval: 200; onTriggered: osdRoot.visible = false }
}
