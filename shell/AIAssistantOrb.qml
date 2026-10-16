import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import QtQuick.Layouts

// ============================================================
// AIAssistantOrb — Floating AI orb in taskbar
// Feature P: AI Assistant Orb (offline via Ollama)
// ============================================================

Item {
    id: aiOrb
    width: 40
    height: 40

    signal clicked()
    property bool listening: false

    Rectangle {
        id: orbCore
        anchors.centerIn: parent
        width: 28
        height: 28
        radius: 14

        // Gradient core
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#A78BFA" }
            GradientStop { position: 1.0; color: "#6366F1" }
        }

        scale: ma.containsMouse ? 1.15 : 1.0
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

        // Breathing animation
        SequentialAnimation on opacity {
            loops: Animation.Infinite; running: visible
            NumberAnimation { to: 1.0; duration: 2000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.75; duration: 2000; easing.type: Easing.InOutSine }
        }

        // Outer glow
        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 12
            height: parent.height + 12
            radius: width / 2
            color: "#A78BFA"
            opacity: ma.containsMouse ? 0.35 : 0.15
            z: -1
            Behavior on opacity { NumberAnimation { duration: 200 } }

            SequentialAnimation on scale {
                loops: Animation.Infinite; running: visible
                NumberAnimation { to: 1.15; duration: 2500; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 2500; easing.type: Easing.InOutSine }
            }
        }

        // Inner ring (rotating)
        Rectangle {
            anchors.centerIn: parent
            width: parent.width - 6
            height: parent.height - 6
            radius: width / 2
            color: "transparent"
            border.color: Qt.rgba(255,255,255,0.4)
            border.width: 1

            RotationAnimation on rotation {
                loops: Animation.Infinite; running: visible
                from: 0
                to: 360
                duration: 3000
            }
        }

        // Sparkle
        Text {
            anchors.centerIn: parent
            text: "✦"
            color: "white"
            font.family: "Vazirmatn"
            font.pixelSize: 12
            opacity: 0.9

            SequentialAnimation on scale {
                loops: Animation.Infinite; running: visible
                NumberAnimation { to: 1.2; duration: 1500; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
            }
        }
    }

    // Listening state - waves
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -2
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2
        visible: aiOrb.listening

        Repeater {
            model: 3
            Rectangle {
                width: 2
                height: 6 + Math.random() * 8
                radius: 1
                color: "#A78BFA"
                opacity: 0.9

                SequentialAnimation on height {
                    loops: Animation.Infinite; running: visible
                    NumberAnimation { to: 14; duration: 300 + index * 100; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 4; duration: 300 + index * 100; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // Tooltip
    Rectangle {
        anchors.bottom: parent.top
        anchors.bottomMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: tooltipText.width + 16
        height: 24
        radius: 6
        color: Qt.rgba(20/255,20/255,24/255,0.95)
        border.color: Qt.rgba(1,1,1,0.10)
        border.width: 1
        opacity: ma.containsMouse ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: "دستیار AI"
            color: "#F0F4FF"
            font.family: "Vazirmatn"
            font.pixelSize: 11
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: aiOrb.clicked()
    }
}
