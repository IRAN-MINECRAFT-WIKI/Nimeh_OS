import QtQuick
import QtQuick.Controls as Controls

Item {
    id: orb
    width: 44
    height: 44
    signal clicked()

    Rectangle {
        id: core
        anchors.centerIn: parent
        width: 36
        height: 36
        radius: 18

        property var tc: {
            const h = new Date().getHours()
            if (h >= 5 && h < 9) return ["#FF6B6B", "#FFB84D"]
            if (h >= 9 && h < 17) return ["#0099FF", "#33B1FF"]
            if (h >= 17 && h < 20) return ["#A78BFA", "#E879F9"]
            return ["#6366F1", "#8B5CF6"]
        }

        gradient: Gradient {
            GradientStop { position: 0.0; color: core.tc[0] }
            GradientStop { position: 1.0; color: core.tc[1] }
        }

        scale: ma.pressed ? 0.92 : (ma.containsMouse ? 1.08 : 1.0)
        Behavior on scale {
            NumberAnimation { duration: 180; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
        }

        Item {
            anchors.centerIn: parent
            width: 20
            height: 20
            Rectangle { x: 0;  y: 0;  width: 9; height: 9; color: "white"; radius: 1.5 }
            Rectangle { x: 11; y: 0;  width: 9; height: 9; color: "white"; radius: 1.5 }
            Rectangle { x: 0;  y: 11; width: 9; height: 9; color: "white"; radius: 1.5 }
            Rectangle { x: 11; y: 11; width: 9; height: 9; color: "white"; radius: 1.5 }
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 20
            height: parent.height + 20
            radius: width / 2
            color: core.tc[0]
            opacity: ma.containsMouse ? 0.35 : 0.12
            z: -1
            Behavior on opacity { NumberAnimation { duration: 200 } }
            SequentialAnimation on scale {
                loops: Animation.Infinite; running: visible
                NumberAnimation { to: 1.08; duration: 2500; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 2500; easing.type: Easing.InOutSine }
            }
        }

        Rectangle {
            id: ripple
            anchors.centerIn: parent
            width: 0
            height: 0
            radius: width / 2
            color: "transparent"
            border.color: core.tc[0]
            border.width: 2
            opacity: 0
        }
        SequentialAnimation {
            id: ripAnim
            ParallelAnimation {
                NumberAnimation { target: ripple; property: "width"; from: 36; to: 90; duration: 600; easing.type: Easing.OutCubic }
                NumberAnimation { target: ripple; property: "height"; from: 36; to: 90; duration: 600; easing.type: Easing.OutCubic }
                NumberAnimation { target: ripple; property: "opacity"; from: 0.8; to: 0; duration: 600 }
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { ripAnim.start(); orb.clicked() }
    }
}
