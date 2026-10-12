import QtQuick
import QtQuick.Controls as Controls
import Quickshell.Io
import QtQuick.Layouts

// ============================================================
// MediaControls — MPRIS-based media player
// Feature R: Media Controls (in Quick Settings)
// ============================================================

Rectangle {
    id: mcRoot
    width: parent ? parent.width : 320
    height: 88
    radius: 12
    color: Qt.rgba(28/255,28/255,30/255,0.6)
    border.color: Qt.rgba(1,1,1,0.06)
    border.width: 1
    visible: hasPlayer

    property bool hasPlayer: false
    property string trackTitle: ""
    property string trackArtist: ""
    property string trackArt: ""
    property bool isPlaying: false
    property double position: 0
    property double length: 0

    function refresh() { mprisProc.running = true }

    Process {
        id: mprisProc
        command: ["sh","-c","playerctl metadata --format '{{title}}|||{{artist}}|||{{mpris:artUrl}}|||{{status}}|||{{position}}|||{{mpris:length}}' 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const txt = this.text.trim()
                if (!txt || txt === "") {
                    mcRoot.hasPlayer = false
                    return
                }
                const parts = txt.split("|||")
                if (parts.length < 4) {
                    mcRoot.hasPlayer = false
                    return
                }
                mcRoot.trackTitle = parts[0] || ""
                mcRoot.trackArtist = parts[1] || ""
                mcRoot.trackArt = parts[2] || ""
                mcRoot.isPlaying = parts[3] === "Playing"
                mcRoot.position = parseFloat(parts[4]) || 0
                mcRoot.length = parseFloat(parts[5]) || 0
                mcRoot.hasPlayer = true
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: mcRoot.refresh()
    }

    Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 12

        // Album art
        Rectangle {
            width: 68
            height: 68
            radius: 8
            color: "#1C1C1E"
            anchors.verticalCenter: parent.verticalCenter

            Image {
                anchors.fill: parent
                anchors.margins: 2
                source: mcRoot.trackArt
                fillMode: Image.PreserveAspectCrop
                visible: mcRoot.trackArt
                cache: false
            }

            // Fallback icon
            Text {
                anchors.centerIn: parent
                visible: !mcRoot.trackArt
                text: "♫"
                color: "#7A8598"
                font.family: "Vazirmatn"
                font.pixelSize: 26
            }
        }

        // Track info + controls
        Column {
            width: parent.width - 80
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                width: parent.width
                text: mcRoot.trackTitle || "نامشخص"
                color: "#F0F4FF"
                font.family: "Vazirmatn"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                width: parent.width
                text: mcRoot.trackArtist || ""
                color: "#7A8598"
                font.family: "Vazirmatn"
                font.pixelSize: 10
                elide: Text.ElideRight
            }

            // Controls + progress
            Row {
                width: parent.width
                spacing: 8

                // Prev
                Rectangle {
                    width: 22; height: 22; radius: 11
                    color: prevMa.containsMouse ? Qt.rgba(1,1,1,0.10) : "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        anchors.centerIn: parent
                        source: "file://$HOME/NimehOS/shell/icons/png/ic_fluent_previous_24_regular.png"
                        width: 14; height: 14
                        sourceSize: Qt.size(14,14)
                        opacity: 0.85
                    }
                    MouseArea {
                        id: prevMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: { Quickshell.execDetached(["playerctl","previous"]); mcRoot.refresh() }
                    }
                }

                // Play/Pause
                Rectangle {
                    width: 28; height: 28; radius: 14
                    color: playMa.containsMouse ? "#0099FF" : Qt.rgba(0,153/255,1,0.20)
                    anchors.verticalCenter: parent.verticalCenter
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Image {
                        anchors.centerIn: parent
                        source: mcRoot.isPlaying ?
                            "file://$HOME/NimehOS/shell/icons/png/ic_fluent_pause_24_regular.png" :
                            "file://$HOME/NimehOS/shell/icons/png/ic_fluent_play_24_regular.png"
                        width: 16; height: 16
                        sourceSize: Qt.size(16,16)
                    }
                    MouseArea {
                        id: playMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["playerctl","play-pause"])
                            mcRoot.refresh()
                        }
                    }
                }

                // Next
                Rectangle {
                    width: 22; height: 22; radius: 11
                    color: nextMa.containsMouse ? Qt.rgba(1,1,1,0.10) : "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        anchors.centerIn: parent
                        source: "file://$HOME/NimehOS/shell/icons/png/ic_fluent_next_24_regular.png"
                        width: 14; height: 14
                        sourceSize: Qt.size(14,14)
                        opacity: 0.85
                    }
                    MouseArea {
                        id: nextMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: { Quickshell.execDetached(["playerctl","next"]); mcRoot.refresh() }
                    }
                }

                // Progress bar
                Rectangle {
                    width: parent.width - 90
                    height: 4
                    radius: 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: Qt.rgba(1,1,1,0.08)
                    Rectangle {
                        width: mcRoot.length > 0 ? parent.width * (mcRoot.position / mcRoot.length) : 0
                        height: parent.height
                        radius: 2
                        color: "#0099FF"
                        Behavior on width { NumberAnimation { duration: 250 } }
                    }
                }
            }
        }
    }
}
