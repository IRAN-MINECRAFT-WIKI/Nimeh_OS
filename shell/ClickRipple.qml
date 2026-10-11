import QtQuick
import QtQuick.Controls as Controls

// Click ripple effect (spawned by MicroInteractions)
Item {
    id: rippleRoot
    property real startX: 0
    property real startY: 0

    x: startX
    y: startY

    Rectangle {
        id: circle
        anchors.centerIn: parent
        width: 0
        height: 0
        radius: width / 2
        color: "transparent"
        border.color: "#0099FF"
        border.width: 2
        opacity: 0.8
    }

    function start() {
        rippleAnim.start()
        killTimer.start()
    }

    SequentialAnimation {
        id: rippleAnim
        ParallelAnimation {
            NumberAnimation { target: circle; property: "width"; from: 0; to: 60; duration: 400; easing.type: Easing.OutCubic }
            NumberAnimation { target: circle; property: "height"; from: 0; to: 60; duration: 400; easing.type: Easing.OutCubic }
            NumberAnimation { target: circle; property: "opacity"; from: 0.8; to: 0; duration: 400 }
        }
    }

    Timer {
        id: killTimer
        interval: 450
        onTriggered: rippleRoot.destroy()
    }
}
