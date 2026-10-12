import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Layouts

// ============================================================
// PowerMenu — Shutdown / Restart / Sleep / Lock / Logout
// Feature F: Power Menu with confirmation
// ============================================================

PanelWindow {
    id: pmRoot
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    WlrLayershell.namespace: "nimeh-powermenu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    signal closeRequested()

    function show() {
        visible = true
        appear.start()
    }
    function hide() {
        disappear.start()
        hideTimer.start()
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0,0,0,0.65)
        opacity: 0
        id: dim
        MouseArea {
            anchors.fill: parent
            onClicked: pmRoot.hide()
        }
    }

    Rectangle {
        id: dialog
        anchors.centerIn: parent
        width: 440
        height: 420
        radius: 18
        color: Qt.rgba(18/255,18/255,22/255,0.97)
        border.color: Qt.rgba(1,1,1,0.08)
        border.width: 1
        opacity: 0
        scale: 0.94

        Column {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            // Header
            Text {
                text: "منوی خاموش"
                color: "#F0F4FF"
                font.family: "Vazirmatn"
                font.pixelSize: 18
                font.weight: Font.Bold
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Confirmation text
            Text {
                id: confirmText
                text: "لطفاً انتخاب کنید:"
                color: "#7A8598"
                font.family: "Vazirmatn"
                font.pixelSize: 12
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !pendingAction.visible
            }

            // Pending action confirmation
            Rectangle {
                id: pendingAction
                width: parent.width
                height: 56
                radius: 10
                color: Qt.rgba(239/255,68/255,68/255,0.10)
                border.color: "#EF4444"
                border.width: 1
                            // FIX: default to hidden - only shown after user picks an action
                            visible: false
                            property string action: ""

                Text {
                    id: pendingText
                    anchors.centerIn: parent
                    text: "مطمئنی؟"
                    color: "#EF4444"
                    font.family: "Vazirmatn"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }

                Row {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: -36
                    spacing: 8

                    Rectangle {
                        width: 80; height: 28; radius: 14
                        color: confirmYesMa.containsMouse ? "#EF4444" : Qt.rgba(239/255,68/255,68/255,0.18)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Text {
                            anchors.centerIn: parent
                            text: "بله، اجرا کن"
                            color: "#F0F4FF"
                            font.family: "Vazirmatn"
                            font.pixelSize: 11
                        }
                        MouseArea {
                            id: confirmYesMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: executeAction(pendingAction.action)
                        }
                    }
                    Rectangle {
                        width: 60; height: 28; radius: 14
                        color: confirmNoMa.containsMouse ? Qt.rgba(1,1,1,0.10) : Qt.rgba(1,1,1,0.04)
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Text {
                            anchors.centerIn: parent
                            text: "لغو"
                            color: "#F0F4FF"
                            font.family: "Vazirmatn"
                            font.pixelSize: 11
                        }
                        MouseArea {
                            id: confirmNoMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                pendingAction.visible = false
                                confirmText.visible = true
                            }
                        }
                    }
                }
            }

            // Action grid
            Grid {
                width: parent.width
                columns: 2
                spacing: 12
                visible: !pendingAction.visible

                Repeater {
                    model: [
                        { label: "خاموش کردن", icon: "ic_fluent_power_24_regular.png",     action: "shutdown", color: "#EF4444" },
                        { label: "ری‌استارت",   icon: "ic_fluent_arrow_clockwise_24_regular.png", action: "reboot",   color: "#F59E0B" },
                        { label: "خواب",         icon: "ic_fluent_weather_moon_24_regular.png",    action: "suspend",  color: "#6366F1" },
                        { label: "قفل",          icon: "ic_fluent_lock_24_regular.png",            action: "lock",     color: "#0099FF" },
                        { label: "خروج",         icon: "ic_fluent_sign_out_24_regular.png",        action: "logout",   color: "#A78BFA" },
                        { label: "هیبرنیت",      icon: "ic_fluent_weather_moon_24_regular.png",    action: "hibernate",color: "#22D3AE" }
                    ]

                    delegate: Rectangle {
                        width: (parent.width - 12) / 2
                        height: 90
                        radius: 12
                        color: cardMa.containsMouse ? Qt.rgba(1,1,1,0.08) : Qt.rgba(28/255,28/255,30/255,0.6)
                        border.color: cardMa.containsMouse ? modelData.color : Qt.rgba(1,1,1,0.06)
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        scale: cardMa.containsMouse ? 1.02 : 1.0
                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 8

                            Image {
                                anchors.horizontalCenter: parent.horizontalCenter
                                source: "file:///home/nimeh/NimehOS/shell/icons/png/" + modelData.icon
                                width: 28; height: 28
                                sourceSize: Qt.size(28,28)
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.label
                                color: "#F0F4FF"
                                font.family: "Vazirmatn"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                            }
                        }

                        MouseArea {
                            id: cardMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                pendingAction.action = modelData.action
                                pendingText.text = "مطمئنی «" + modelData.label + "»؟"
                                pendingAction.visible = true
                                confirmText.visible = false
                            }
                        }
                    }
                }
            }

            // Cancel
            Rectangle {
                width: parent.width
                height: 38
                radius: 19
                color: cancelMa.containsMouse ? Qt.rgba(1,1,1,0.10) : Qt.rgba(1,1,1,0.04)
                border.color: Qt.rgba(1,1,1,0.08)
                border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }
                visible: !pendingAction.visible

                Text {
                    anchors.centerIn: parent
                    text: "لغو"
                    color: "#F0F4FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 12
                }
                MouseArea {
                    id: cancelMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: pmRoot.hide()
                }
            }
        }
    }

    function executeAction(action) {
        let cmd
        switch(action) {
            case "shutdown":  cmd = ["shutdown","-h","now"]; break
            case "reboot":    cmd = ["reboot"]; break
            case "suspend":   cmd = ["systemctl","suspend"]; break
            case "hibernate": cmd = ["systemctl","hibernate"]; break
            case "lock":      cmd = ["loginctl","lock-session"]; break
            case "logout":    cmd = ["hyprctl","dispatch","exit"]; break
        }
        if (cmd) Quickshell.execDetached(cmd)
        pmRoot.hide()
    }

    ParallelAnimation {
        id: appear
        NumberAnimation { target: dim; property: "opacity"; to: 1; duration: 200 }
        NumberAnimation { target: dialog; property: "opacity"; to: 1; duration: 250 }
        NumberAnimation { target: dialog; property: "scale"; to: 1; duration: 250; easing.type: Easing.OutBack }
    }
    ParallelAnimation {
        id: disappear
        NumberAnimation { target: dim; property: "opacity"; to: 0; duration: 200 }
        NumberAnimation { target: dialog; property: "opacity"; to: 0; duration: 200 }
        NumberAnimation { target: dialog; property: "scale"; to: 0.94; duration: 200 }
    }
    Timer { id: hideTimer; interval: 200; onTriggered: pmRoot.visible = false }
}
