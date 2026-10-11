import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Layouts

// ============================================================
// TaskView — Win+Tab view of all windows
// Feature D: Task View with live previews + virtual desktops
// ============================================================

PanelWindow {
    id: tvRoot
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: Qt.rgba(5/255, 5/255, 7/255, 0.85)
    WlrLayershell.namespace: "nimeh-taskview"
    WlrLayershell.layer: WlrLayer.Overlay

    signal closeRequested()

    function show() {
        visible = true
        appear.start()
    }
    function hide() {
        disappear.start()
        hideTimer.start()
    }

    // ----- Backdrop blur -----
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0,0,0,0.55)
        opacity: 0
        id: backdrop
    }

    // ----- Content -----
    Item {
        anchors.fill: parent
        opacity: 0
        id: content
        scale: 0.96

        Column {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 24

            // Header
            Row {
                width: parent.width
                spacing: 16

                Text {
                    text: "نمای وظایف"
                    color: "#F0F4FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 22
                    font.weight: Font.Bold
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item { width: 1; height: 1; Layout.fillWidth: true }

                // New desktop button
                Rectangle {
                    width: 130
                    height: 36
                    radius: 18
                    color: ndMa.containsMouse ? "#0099FF" : Qt.rgba(0,153/255,1,0.18)
                    border.color: "#0099FF"
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text {
                        anchors.centerIn: parent
                        text: "+ دسکتاپ جدید"
                        color: "#F0F4FF"
                        font.family: "Vazirmatn"
                        font.pixelSize: 11
                    }
                    MouseArea {
                        id: ndMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            // Window previews grid
            Controls.ScrollView {
                width: parent.width
                height: parent.height - 200
                clip: true

                Flow {
                    width: parent.width
                    spacing: 20

                    Repeater {
                        model: Hyprland.windows
                        delegate: Rectangle {
                            width: 280
                            height: 180
                            radius: 12
                            color: Qt.rgba(28/255,28/255,30/255,0.94)
                            border.color: cardMa.containsMouse ? "#0099FF" : Qt.rgba(1,1,1,0.08)
                            border.width: 1
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            scale: cardMa.containsMouse ? 1.03 : 1.0
                            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                            // Window title bar
                            Rectangle {
                                id: tb
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 30
                                radius: 12
                                color: Qt.rgba(1,1,1,0.04)

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: 1
                                    color: Qt.rgba(1,1,1,0.06)
                                }

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Rectangle { width: 8; height: 8; radius: 4; color: "#EF4444" }
                                    Rectangle { width: 8; height: 8; radius: 4; color: "#F59E0B" }
                                    Rectangle { width: 8; height: 8; radius: 4; color: "#22D3AE" }
                                }
                            }

                            // Live preview (screenshot via hyprland)
                            Image {
                                anchors.top: tb.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.margins: 1
                                source: "image://hyprland/window/" + modelData.id
                                fillMode: Image.PreserveAspectCrop
                                cache: false
                            }

                            Text {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: 8
                                text: modelData.title
                                color: "#F0F4FF"
                                font.family: "Vazirmatn"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }

                            MouseArea {
                                id: cardMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Hyprland.dispatch("focuswindow", "address:" + modelData.address)
                                    tvRoot.hide()
                                }
                            }
                        }
                    }
                }
            }

            // Workspace bar (bottom)
            Row {
                width: parent.width
                spacing: 12
                layoutDirection: Qt.RightToLeft

                Repeater {
                    model: Hyprland.workspaces
                    delegate: Rectangle {
                        width: 200
                        height: 110
                        radius: 10
                        color: (Hyprland.focusedWorkspace && modelData.id === Hyprland.focusedWorkspace.id) ?
                               Qt.rgba(0,153/255,1,0.18) : Qt.rgba(28/255,28/255,30/255,0.8)
                        border.color: (Hyprland.focusedWorkspace && modelData.id === Hyprland.focusedWorkspace.id) ?
                                      "#0099FF" : Qt.rgba(1,1,1,0.06)
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        scale: wsMa.containsMouse ? 1.04 : 1.0
                        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

                        Text {
                            anchors.centerIn: parent
                            text: "دسکتاپ " + Theme.toFa(modelData.id)
                            color: "#F0F4FF"
                            font.family: "Vazirmatn"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            id: wsMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Hyprland.dispatch("workspace", modelData.id)
                        }
                    }
                }
            }
        }
    }

    // Click anywhere to close
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: tvRoot.hide()
    }

    ParallelAnimation {
        id: appear
        NumberAnimation { target: backdrop; property: "opacity"; to: 1; duration: 200 }
        NumberAnimation { target: content; property: "opacity"; to: 1; duration: 250 }
        NumberAnimation { target: content; property: "scale"; to: 1; duration: 250; easing.type: Easing.OutBack }
    }
    ParallelAnimation {
        id: disappear
        NumberAnimation { target: backdrop; property: "opacity"; to: 0; duration: 200 }
        NumberAnimation { target: content; property: "opacity"; to: 0; duration: 200 }
        NumberAnimation { target: content; property: "scale"; to: 0.96; duration: 200 }
    }
    Timer { id: hideTimer; interval: 200; onTriggered: tvRoot.visible = false }
}
