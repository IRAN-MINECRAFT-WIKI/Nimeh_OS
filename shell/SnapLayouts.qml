import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// ============================================================
// SnapLayouts — Grid layouts on hover of maximize button
// Feature A: Snap Layouts (Windows 11 style)
// ============================================================

PanelWindow {
    id: snapRoot
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    WlrLayershell.namespace: "nimeh-snap"
    WlrLayershell.layer: WlrLayer.Overlay

    signal layoutSelected(string layout)
    signal closeRequested()

    property var targetWindow: null

    function show(window) {
        targetWindow = window
        visible = true
        appear.start()
    }
    function hide() {
        disappear.start()
        hideTimer.start()
    }

    // ----- Layout grid -----
    Rectangle {
        id: snapPanel
        anchors.centerIn: parent
        width: 420
        height: 240
        radius: 14
        color: Qt.rgba(20/255,20/255,24/255,0.96)
        border.color: Qt.rgba(1,1,1,0.10)
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            Text {
                text: "چیدمان پنجره"
                color: "#F0F4FF"
                font.family: "Vazirmatn"
                font.pixelSize: 13
                font.weight: Font.Bold
            }

            // 6 layout options
            Row {
                width: parent.width
                spacing: 8

                Repeater {
                    model: [
                        { name: "left-half",    cells: [[0,0,1,2]] },
                        { name: "right-half",   cells: [[1,0,1,2]] },
                        { name: "two-cols",     cells: [[0,0,1,2],[1,0,1,2]] },
                        { name: "three-cols",   cells: [[0,0,1,2],[1,0,1,2],[2,0,1,2]] },
                        { name: "quad",         cells: [[0,0,1,1],[1,0,1,1],[0,1,1,1],[1,1,1,1]] },
                        { name: "focus",        cells: [[0,0,3,2]] }
                    ]

                    delegate: Rectangle {
                        width: (parent.width - 40) / 6
                        height: 140
                        radius: 8
                        color: cellMa.containsMouse ? Qt.rgba(0,153/255,1,0.18) : Qt.rgba(1,1,1,0.04)
                        border.color: cellMa.containsMouse ? "#0099FF" : Qt.rgba(1,1,1,0.06)
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        scale: cellMa.containsMouse ? 1.05 : 1.0
                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                        // Mini grid preview
                        Item {
                            anchors.centerIn: parent
                            width: 50
                            height: 60

                            Repeater {
                                model: modelData.cells
                                delegate: Rectangle {
                                    property var cell: modelData
                                    x: cell[0] * (parent.width / 3)
                                    y: cell[1] * (parent.height / 2)
                                    width: cell[2] * (parent.width / 3) - 1
                                    height: cell[3] * (parent.height / 2) - 1
                                    radius: 3
                                    color: "#0099FF"
                                    opacity: cellMa.containsMouse ? 0.9 : 0.5
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }
                            }
                        }

                        MouseArea {
                            id: cellMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                applyLayout(modelData.name)
                                snapRoot.hide()
                            }
                        }
                    }
                }
            }

            Text {
                text: "برای انتخاب چیدمان، روی الگو کلیک کنید"
                color: "#7A8598"
                font.family: "Vazirmatn"
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    function applyLayout(layout) {
        const win = snapRoot.targetWindow
        if (!win) {
            // Fallback: apply to active window
            const active = Hyprland.activeWindow
            if (!active) return
        }

        const ws = Hyprland.activeWorkspace.id
        let cmd

        switch(layout) {
            case "left-half":
                cmd = "movewindowpixel 0 0," + Hyprland.activeWindow.address +
                      ";resizewindowpixel exact 50% 100%," + Hyprland.activeWindow.address
                break
            case "right-half":
                cmd = "movewindowpixel 50% 0," + Hyprland.activeWindow.address +
                      ";resizewindowpixel exact 50% 100%," + Hyprland.activeWindow.address
                break
            case "two-cols":
                Hyprland.dispatch("moveactive", "1 0")
                Hyprland.dispatch("resizeactive", "50% 100%")
                break
            case "three-cols":
                Hyprland.dispatch("moveactive", "0 0")
                Hyprland.dispatch("resizeactive", "33% 100%")
                break
            case "quad":
                Hyprland.dispatch("moveactive", "0 0")
                Hyprland.dispatch("resizeactive", "50% 50%")
                break
            case "focus":
                Hyprland.dispatch("fullscreen", "1")
                break
        }

        if (cmd) Hyprland.dispatch("dispatch", cmd)
        layoutSelected(layout)
    }

    ParallelAnimation {
        id: appear
        NumberAnimation { target: snapPanel; property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
        NumberAnimation { target: snapPanel; property: "scale"; from: 0.92; to: 1; duration: 200; easing.type: Easing.OutBack }
    }
    ParallelAnimation {
        id: disappear
        NumberAnimation { target: snapPanel; property: "opacity"; to: 0; duration: 150 }
        NumberAnimation { target: snapPanel; property: "scale"; to: 0.92; duration: 150 }
    }
    Timer { id: hideTimer; interval: 150; onTriggered: snapRoot.visible = false }


    // FIX v4: close on outside click
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: snapRoot.closeRequested()
    }
}
