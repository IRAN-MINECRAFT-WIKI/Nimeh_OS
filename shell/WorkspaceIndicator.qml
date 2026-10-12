import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

// ============================================================
// WorkspaceIndicator — Dots in taskbar for each workspace
// Feature G: Workspace Indicator
// ============================================================

Row {
    id: wsRow
    spacing: 6
    layoutDirection: Qt.RightToLeft
    height: 28

    Repeater {
        model: Hyprland.workspaces
        delegate: Item {
            width: 24
            height: 24
            anchors.verticalCenter: parent.verticalCenter

            property bool active: Hyprland.focusedWorkspace !== null && modelData.id === Hyprland.focusedWorkspace.id

            Rectangle {
                anchors.centerIn: parent
                width: active ? 22 : 8
                height: 8
                radius: 4
                color: active ? "#0099FF" : "#525C6E"
                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            // Window count indicator (small dots above)
            Row {
                anchors.bottom: parent.top
                anchors.bottomMargin: 1
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 1
                visible: modelData.windows > 0 && !active

                Repeater {
                    model: Math.min(modelData.windows, 3)
                    delegate: Rectangle {
                        width: 2
                        height: 2
                        radius: 1
                        color: "#7A8598"
                    }
                }
            }

            // Tooltip
            Rectangle {
                id: wsTooltip
                anchors.bottom: parent.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                width: wsTooltipText.width + 14
                height: 22
                radius: 6
                color: Qt.rgba(20/255,20/255,24/255,0.95)
                border.color: Qt.rgba(1,1,1,0.10)
                border.width: 1
                opacity: wsMa.containsMouse ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 150 } }

                Text {
                    id: wsTooltipText
                    anchors.centerIn: parent
                    text: "دسکتاپ " + Theme.toFa(modelData.id)
                    color: "#F0F4FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 10
                }
            }

            MouseArea {
                id: wsMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace", modelData.id)
                onDoubleClicked: Hyprland.dispatch("movetoworkspace", "special")
            }
        }
    }
}
