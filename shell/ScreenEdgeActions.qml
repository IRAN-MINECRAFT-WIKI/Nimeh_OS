import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// ============================================================
// ScreenEdgeActions — Corner hotspots
// Feature M: Screen Edge Actions
// ============================================================

PanelWindow {
    visible: false // تا بازطراحی با ۴ نوار باریک، غیرفعال
    id: seRoot
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    WlrLayershell.namespace: "nimeh-screenedges"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    signal topLeftTriggered()   // Show Desktop
    signal topRightTriggered()  // Quick Settings
    signal bottomLeftTriggered() // Start Menu
    signal bottomRightTriggered() // Notifications

    property int edgeSize: 8
    property int triggerDelay: 250

    // Top-left corner (Show Desktop)
    Item {
        anchors.top: parent.top
        anchors.left: parent.left
        width: seRoot.edgeSize
        height: seRoot.edgeSize
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                topLeftTimer.start()
            }
            onExited: topLeftTimer.stop()
        }
        Timer {
            id: topLeftTimer
            interval: seRoot.triggerDelay
            onTriggered: seRoot.topLeftTriggered()
        }
    }

    // Top-right corner (Quick Settings)
    Item {
        anchors.top: parent.top
        anchors.right: parent.right
        width: seRoot.edgeSize
        height: seRoot.edgeSize
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: topRightTimer.start()
            onExited: topRightTimer.stop()
        }
        Timer {
            id: topRightTimer
            interval: seRoot.triggerDelay
            onTriggered: seRoot.topRightTriggered()
        }
    }

    // Bottom-left corner (Start Menu)
    Item {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: seRoot.edgeSize
        height: seRoot.edgeSize
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: bottomLeftTimer.start()
            onExited: bottomLeftTimer.stop()
        }
        Timer {
            id: bottomLeftTimer
            interval: seRoot.triggerDelay
            onTriggered: seRoot.bottomLeftTriggered()
        }
    }

    // Bottom-right corner (Notifications)
    Item {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: seRoot.edgeSize
        height: seRoot.edgeSize
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: bottomRightTimer.start()
            onExited: bottomRightTimer.stop()
        }
        Timer {
            id: bottomRightTimer
            interval: seRoot.triggerDelay
            onTriggered: seRoot.bottomRightTriggered()
        }
    }
}
