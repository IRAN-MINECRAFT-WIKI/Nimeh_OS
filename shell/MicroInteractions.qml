import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland

// ============================================================
// MicroInteractions — Cursor trail + click ripple
// Feature S: Micro-interactions
// ============================================================

PanelWindow {
    id: miRoot
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    WlrLayershell.namespace: "nimeh-microinteractions"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    property real mouseX: 0
    property real mouseY: 0
    property bool enabled: true

    // Cursor trail particles
    Repeater {
        model: 8
        Rectangle {
            id: trail
            property int idx: index
            x: miRoot.mouseX - 2
            y: miRoot.mouseY - 2
            width: 4
            height: 4
            radius: 2
            color: "#0099FF"
            opacity: 0.6 * (1 - index / 8)
            visible: miRoot.enabled

            Behavior on x { NumberAnimation { duration: 80 + idx * 10; easing.type: Easing.OutCubic } }
            Behavior on y { NumberAnimation { duration: 80 + idx * 10; easing.type: Easing.OutCubic } }
        }
    }

    // Click ripple container
    Item {
        id: rippleContainer
        anchors.fill: parent
    }

    function spawnRipple(x, y) {
        const cmp = Qt.createComponent("ClickRipple.qml")
        if (cmp.status === Component.Ready) {
            const r = cmp.createObject(rippleContainer, { startX: x, startY: y })
            if (r) r.start()
        }
    }

    // Mouse tracker
    MouseArea {
        id: tracker
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onPositionChanged: (mouse) => {
            miRoot.mouseX = mouse.x
            miRoot.mouseY = mouse.y
            mouse.accepted = false
        }
        onClicked: (mouse) => {
            mouse.accepted = false
        }
    }
}
