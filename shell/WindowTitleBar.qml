import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

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
    // visible از طریق readonly property پایین‌تر بایند می‌شود
    WlrLayershell.namespace: "nimeh-windowtitle"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    anchors.left: true
    implicitWidth: Math.max(winW, 0)
    implicitHeight: 32
    margins.top: winY
    margins.left: winX

    // ============================================================
    // 🔁 بازطراحی (Phase 2): حذف Process + Timer
    // به‌جای polling با `hyprctl activewindow -j` هر ۱۵۰ms، از سرویس
    // داخلی Quickshell.Hyprland استفاده می‌کنیم که event-driven است و
    // به‌صورت خودکار با تغییر پنجره‌ی فعال آپدیت می‌شود.
    // مزایا:
    //   • حذف CPU overhead ناشی از fork+exec هربار hyprctl
    //   • آپدیت آنی به‌جای تأخیر ۱۵۰ms
    //   • حذف import Quickshell.Io (دیگر نیازی به Process/StdioCollector نیست)
    // ============================================================
    readonly property var activeWin: Hyprland.activeToplevel
    readonly property int winX: activeWin?.at?.x ?? 0
    readonly property int winY: activeWin?.at?.y ?? 0
    readonly property int winW: activeWin?.size?.width ?? 0
    readonly property int winH: activeWin?.size?.height ?? 0
    readonly property string winAddr: activeWin?.address ?? ""
    readonly property string winClass: activeWin?.class ?? ""
    readonly property string winTitle: activeWin?.title ?? ""
    readonly property bool isFloating: activeWin?.floating ?? false
    readonly property bool isFullscreen: activeWin?.fullscreen ?? false
    // visible به‌صورت مستقیم بایند شده — نه set در onStreamFinished
    readonly property bool visible: !!activeWin && !isFullscreen && winW > 200 && winH > 100

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
