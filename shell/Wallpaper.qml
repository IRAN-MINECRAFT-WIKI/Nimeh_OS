import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: wp
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    WlrLayershell.namespace: "nimeh-wallpaper"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    Rectangle {
        id: bgRect
        anchors.fill: parent
        property var cc: {
            const h = new Date().getHours()
            if (h >= 5 && h < 9) return ["#FF6B6B", "#2D1B4E"]
            if (h >= 9 && h < 17) return ["#0A0A0C", "#151820"]
            if (h >= 17 && h < 20) return ["#2D1B4E", "#0A0A0C"]
            return ["#0A0A0C", "#121024"]
        }
        gradient: Gradient {
            GradientStop { position: 0.0; color: bgRect.cc[0] }
            GradientStop { position: 1.0; color: bgRect.cc[1] }
        }
    }

    Rectangle {
        id: a1
        width: wp.width * 0.7
        height: wp.height * 0.7
        x: -wp.width * 0.1
        y: -wp.height * 0.1
        radius: Math.min(width, height) / 2
        color: "#0099FF"
        opacity: 0.10
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.15; duration: 4000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.08; duration: 4000; easing.type: Easing.InOutSine }
        }
    }

    Rectangle {
        id: a2
        width: wp.width * 0.5
        height: wp.height * 0.5
        x: wp.width * 0.5
        y: wp.height * 0.3
        radius: Math.min(width, height) / 2
        color: "#A78BFA"
        opacity: 0.08
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.12; duration: 5000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.06; duration: 5000; easing.type: Easing.InOutSine }
        }
    }

    Rectangle {
        id: a3
        width: wp.width * 0.4
        height: wp.height * 0.4
        x: wp.width * 0.2
        y: wp.height * 0.7
        radius: Math.min(width, height) / 2
        color: "#22D3EE"
        opacity: 0.07
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.10; duration: 6000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.05; duration: 6000; easing.type: Easing.InOutSine }
        }
    }

    Item {
        id: particlesBox
        anchors.fill: parent
        Repeater {
            model: 30
            Rectangle {
                property real px: Math.random() * wp.width
                property real py: Math.random() * wp.height
                property real psize: Math.random() * 2 + 0.5
                property real psp: Math.random() * 0.3 + 0.1
                property real pof: Math.random() * Math.PI * 2
                x: px + Math.sin(tickObj.t * psp + pof) * 30
                y: py + Math.cos(tickObj.t * psp * 0.7 + pof) * 20
                width: psize
                height: psize
                radius: psize / 2
                color: "white"
                opacity: 0.15 + Math.sin(tickObj.t * 2 + pof) * 0.1
            }
        }
    }

    QtObject { id: tickObj; property real t: 0 }
    Timer {
        interval: 50
        running: true
        repeat: true
        onTriggered: tickObj.t += 0.05
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height * 0.3
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0,0,0,0.4) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height * 0.3
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Qt.rgba(0,0,0,0.5) }
        }
    }
}
