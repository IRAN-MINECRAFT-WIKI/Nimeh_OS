// ═════════════════════════════════════════════════════════
//  LockScreen — لایه‌ی بصری قفل (طبق نمونه‌ی HTML)
//  قفل واقعی و احراز هویت با hyprlock است؛ این پنجره فقط وقتی hyprlock
//  در حال اجراست نمایش داده می‌شود. API قبلی حفظ شده (closeRequested).
// ═════════════════════════════════════════════════════════
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: lockRoot

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: shownNow || body.opacity > 0.01
    WlrLayershell.namespace: "nimeh-lockscreen-overlay"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    property bool shownNow: false
    property date now: new Date()
    signal closeRequested()

    // بررسی اینکه hyprlock در حال اجراست یا نه
    Process {
        id: lockCheck
        command: ["sh", "-c", "pgrep -x hyprlock >/dev/null && echo LOCKED || echo UNLOCKED"]
        stdout: StdioCollector {
            onStreamFinished: lockRoot.shownNow = (this.text.trim() === "LOCKED")
        }
    }
    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: lockCheck.running = true
    }
    Timer {
        interval: 1000; running: lockRoot.visible; repeat: true
        onTriggered: lockRoot.now = new Date()
    }

    Rectangle {
        id: body
        anchors.fill: parent
        opacity: lockRoot.shownNow ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0A0E1A" }
            GradientStop { position: 1.0; color: "#131829" }
        }

        // هاله‌ی رنگی پس‌زمینه
        Rectangle {
            width: parent.width * 0.7; height: width; radius: width / 2
            x: parent.width * 0.1; y: parent.height * 0.05
            color: Qt.rgba(0.0, 0.47, 0.83, 0.10)
        }
        Rectangle {
            width: parent.width * 0.6; height: width; radius: width / 2
            x: parent.width * 0.45; y: parent.height * 0.45
            color: Qt.rgba(0.66, 0.55, 0.98, 0.10)
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.16
            spacing: 6
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(lockRoot.now, "HH:mm")
                color: "#F3F4F6"
                font.family: "Inter"
                font.pixelSize: 110
                font.weight: Font.Light
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(lockRoot.now, "dddd, d MMMM")
                color: "#9CA3AF"
                font.family: "Vazirmatn"
                font.pixelSize: 16
            }
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height * 0.12
            spacing: 12
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 72; height: 72; radius: 36
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#0078D4" }
                    GradientStop { position: 1.0; color: "#4CC2FF" }
                }
                Text {
                    anchors.centerIn: parent
                    text: (Quickshell.env("USER") || "u").charAt(0).toUpperCase()
                    color: "white"
                    font.pixelSize: 28
                    font.weight: Font.Bold
                }
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Quickshell.env("USER") || "user"
                color: "#E5E7EB"
                font.family: "Inter"
                font.pixelSize: 14
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "رمز عبور را وارد کنید"
                color: "#6B7280"
                font.family: "Vazirmatn"
                font.pixelSize: 11
            }
        }
    }
}
