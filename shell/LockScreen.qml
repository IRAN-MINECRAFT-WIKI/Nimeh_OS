import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Controls as Controls
import QtQuick.Layouts

// ============================================================
// LockScreen — Overlay روی hyprlock
// • hyprlock قفل واقعی رو انجام می‌ده (PAM authentication)
// • این QML فقط لایه بصری هست (ساعت بزرگ + آواتار)
// • وقتی hyprlock اجرا می‌شه، این هم visible می‌شه
// ============================================================

PanelWindow {
    id: lockRoot
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    visible: false
    WlrLayershell.namespace: "nimeh-lockscreen-overlay"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None  // hyprlock کیبورد رو می‌گیره

    signal closeRequested()

    // نشان دادن وقتی hyprlock اجرا می‌شه
    Process {
        id: lockCheck
        command: ["sh","-c","pgrep -x hyprlock > /dev/null && echo LOCKED || echo UNLOCKED"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = this.text.trim()
                if (t === "LOCKED") {
                    if (!lockRoot.visible) {
                        lockRoot.visible = true
                        appearAnim.start()
                    }
                } else {
                    if (lockRoot.visible) {
                        lockRoot.visible = false
                    }
                }
            }
        }
    }
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: lockCheck.running = true
    }

    // ----- پس‌زمینه تیره -----
    Rectangle {
        anchors.fill: parent
        color: "#050507"

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#1A1330" }
                GradientStop { position: 0.5; color: "#0A0A0C" }
                GradientStop { position: 1.0; color: "#0A0A0C" }
            }
        }

        // Glow blobs
        Rectangle {
            width: parent.width * 0.6
            height: parent.width * 0.6
            x: parent.width * 0.2
            y: parent.height * 0.1
            radius: width / 2
            color: "#6366F1"
            opacity: 0.15
        }
        Rectangle {
            width: parent.width * 0.4
            height: parent.width * 0.4
            x: parent.width * 0.6
            y: parent.height * 0.5
            radius: width / 2
            color: "#0099FF"
            opacity: 0.10
        }
    }

    // ----- ساعت بزرگ -----
    Column {
        id: clockCol
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.15
        spacing: 12

        Text {
            id: bigClock
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                const d = new Date()
                return Theme.toFa(String(d.getHours()).padStart(2,"0")) + ":" +
                       Theme.toFa(String(d.getMinutes()).padStart(2,"0"))
            }
            color: "#F0F4FF"
            font.family: "Inter"
            font.pixelSize: 120
            font.weight: Font.Light

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation { to: 1.0; duration: 1500 }
                NumberAnimation { to: 0.85; duration: 1500 }
            }
        }

        Text {
            id: bigDate
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                const d = new Date()
                const j = Theme.jalali(d.getFullYear(), d.getMonth()+1, d.getDate())
                return Theme.jalaliWeekdays[d.getDay()] + "، " +
                       Theme.toFa(j.day) + " " +
                       Theme.jalaliMonths[j.month-1] + " " +
                       Theme.toFa(j.year)
            }
            color: "#7A8598"
            font.family: "Vazirmatn"
            font.pixelSize: 18
        }
    }

    Timer {
        interval: 1000
        running: lockRoot.visible
        repeat: true
        onTriggered: {
            const d = new Date()
            bigClock.text = Theme.toFa(String(d.getHours()).padStart(2,"0")) + ":" +
                            Theme.toFa(String(d.getMinutes()).padStart(2,"0"))
        }
    }

    // ----- آواتار -----
    Column {
        id: loginCol
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.20
        spacing: 16

        Rectangle {
            id: avatar
            width: 110
            height: 110
            radius: 55
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#1C1C1E"
            border.color: "#0099FF"
            border.width: 2

            Text {
                anchors.centerIn: parent
                text: "ن"
                color: "#F0F4FF"
                font.family: "Vazirmatn"
                font.pixelSize: 56
                font.weight: Font.Light
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: 8
                width: 18
                height: 18
                radius: 9
                color: "#22D3AE"
                border.color: "#0A0A0C"
                border.width: 3
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "nimeh"
            color: "#F0F4FF"
            font.family: "Vazirmatn"
            font.pixelSize: 16
            font.weight: Font.DemiBold
        }

        // راهنما — رمز رو در hyprlock وارد کن
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "رمز خود را وارد کرده و Enter بزنید"
            color: "#7A8598"
            font.family: "Vazirmatn"
            font.pixelSize: 12
        }
    }

    // ----- دکمه‌های پایین -----
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
        spacing: 16

        Rectangle {
            width: 44; height: 44; radius: 22
            color: powerMa.containsMouse ? Qt.rgba(1,1,1,0.10) : Qt.rgba(1,1,1,0.04)
            Behavior on color { ColorAnimation { duration: 150 } }
            Image {
                anchors.centerIn: parent
                source: "file://$HOME/NimehOS/shell/icons/png/ic_fluent_power_24_regular.png"
                width: 20; height: 20
                sourceSize: Qt.size(20,20)
                opacity: 0.8
            }
            MouseArea {
                id: powerMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["shutdown","-h","now"])
            }
        }

        Rectangle {
            width: 44; height: 44; radius: 22
            color: restartMa.containsMouse ? Qt.rgba(1,1,1,0.10) : Qt.rgba(1,1,1,0.04)
            Behavior on color { ColorAnimation { duration: 150 } }
            Image {
                anchors.centerIn: parent
                source: "file://$HOME/NimehOS/shell/icons/png/ic_fluent_arrow_clockwise_24_regular.png"
                width: 20; height: 20
                sourceSize: Qt.size(20,20)
                opacity: 0.8
            }
            MouseArea {
                id: restartMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["reboot"])
            }
        }
    }

    ParallelAnimation {
        id: appearAnim
        NumberAnimation { target: clockCol; property: "opacity"; from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic }
        NumberAnimation { target: loginCol; property: "opacity"; from: 0; to: 1; duration: 400; easing.type: Easing.OutCubic }
    }
}
