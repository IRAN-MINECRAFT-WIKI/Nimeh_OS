import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

// ============================================================
// WindowTitleBar — نوار عنوان کامل ویندوز ۱۱ (نسخه v3)
// • تمام عرض پنجره فعال
// • عنوان + آیکون + ۳ دکمه (─ ▢ ✕)
// • Drag از نوار = حرکت آزاد پنجره (مثل ویندوز)
// • Double-click = Maximize/Restore
// • بدون نیاز به plugin
// ============================================================

PanelWindow {
    id: tbRoot
    color: "transparent"
    visible: false
    WlrLayershell.namespace: "nimeh-windowtitle"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    anchors.left: true
    implicitWidth: Math.max(winW, 0)
    implicitHeight: 32
    margins.top: winY
    margins.left: winX

    property int winX: 0
    property int winY: 0
    // FIX v4 (Bug 10): default to 800 so the title bar has a sane width
    // before the first hyprctl poll completes (otherwise implicitWidth
    // collapses to 0 and the bar is invisible for one frame).
    property int winW: 800
    property int winH: 0
    property string winAddr: ""
    property string winClass: ""
    property string winTitle: ""
    property bool isFloating: false
    property bool isFullscreen: false

    // Poll active window
    Process {
        id: poll
        command: ["sh", "-c", "hyprctl activewindow -j 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = this.text.trim()
                if (!t || t === "{}" || t === "Invalid") {
                    tbRoot.visible = false
                    return
                }
                try {
                    const w = JSON.parse(t)
                    if (!w.address || w.address === "0x") {
                        tbRoot.visible = false
                        return
                    }
                    tbRoot.winX = w.at[0]
                    tbRoot.winY = w.at[1]
                    tbRoot.winW = w.size[0]
                    tbRoot.winH = w.size[1]
                    tbRoot.winAddr = w.address
                    tbRoot.winClass = w.class || ""
                    tbRoot.winTitle = w.title || ""
                    tbRoot.isFloating = w.floating || false
                    tbRoot.isFullscreen = w.fullscreen || false
                    tbRoot.visible = !w.fullscreen && w.size[0] > 200 && w.size[1] > 100
                } catch(e) {
                    tbRoot.visible = false
                }
            }
        }
    }
    Timer {
        // FIX v4 (Bug 10): poll every 150ms (was 200ms) for snappier
        // title-bar updates when switching windows.
        interval: 150
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: poll.running = true
    }

    // ===== بدنه نوار =====
    Rectangle {
        id: bar
        anchors.fill: parent
        color: "#1C1C1E"

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Qt.rgba(1,1,1,0.08)
        }

        Row {
            anchors.fill: parent
            spacing: 8

            // آیکون برنامه
            Item {
                width: 32
                height: parent.height
                Rectangle {
                    anchors.centerIn: parent
                    width: 20; height: 20
                    radius: 4
                    color: "#0099FF"
                    opacity: 0.8
                    Text {
                        anchors.centerIn: parent
                        text: tbRoot.winClass ? tbRoot.winClass.charAt(0).toUpperCase() : "?"
                        color: "white"
                        font.family: "Vazirmatn"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }
                }
            }

            // عنوان پنجره
            Text {
                width: parent.width - 32 - 138 - 16
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                text: tbRoot.winTitle || tbRoot.winClass || ""
                color: "#F0F4FF"
                font.family: "Vazirmatn"
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            // فاصله
            Item { width: 1; height: 1 }

            // ===== دکمه‌ها =====
            Row {
                height: parent.height
                spacing: 0

                // ─ Minimize
                Rectangle {
                    width: 46
                    height: parent.height
                    color: minMa.containsMouse ? Qt.rgba(1,1,1,0.12) : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 12; height: 1.5
                        color: "#F0F4FF"
                    }

                    MouseArea {
                        id: minMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("movetoworkspacesilent", "special:minimized")
                    }
                }

                // ▢ Maximize / Restore
                Rectangle {
                    width: 46
                    height: parent.height
                    color: maxMa.containsMouse ? Qt.rgba(1,1,1,0.12) : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 11; height: 11
                        color: "transparent"
                        border.color: "#F0F4FF"
                        border.width: 1.5
                        radius: 2
                    }

                    MouseArea {
                        id: maxMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (tbRoot.isFullscreen)
                                Hyprland.dispatch("fullscreen", "0")
                            else
                                Hyprland.dispatch("fullscreen", "1")
                        }
                    }
                }

                // ✕ Close
                Rectangle {
                    width: 46
                    height: parent.height
                    color: closeMa.containsMouse ? "#EF4444" : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: closeMa.containsMouse ? "white" : "#F0F4FF"
                        font.pixelSize: 13
                        font.family: "Vazirmatn"
                    }

                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("killactive", "")
                    }
                }
            }
        }

        // ===== Drag area — حرکت آزاد پنجره =====
        MouseArea {
            id: dragArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 138
            z: -1

            property point lastPos
            property bool isDragging: false

            onPressed: (mouse) => {
                lastPos = Qt.point(mouse.x, mouse.y)
                isDragging = false
            }

            onPositionChanged: (mouse) => {
                const dx = mouse.x - lastPos.x
                const dy = mouse.y - lastPos.y
                if (Math.abs(dx) > 2 || Math.abs(dy) > 2) {
                    isDragging = true
                    // حرکت پنجره با movewindowpixel
                    Hyprland.dispatch("movewindowpixel", `${dx} ${dy},address:${tbRoot.winAddr}`)
                }
            }

            onReleased: {
                isDragging = false
            }

            onDoubleClicked: {
                if (tbRoot.isFullscreen)
                    Hyprland.dispatch("fullscreen", "0")
                else
                    Hyprland.dispatch("fullscreen", "1")
            }
        }
    }
}
