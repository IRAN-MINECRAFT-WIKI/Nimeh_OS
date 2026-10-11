import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: qs
    anchors.fill: parent

    signal closeRequested()
    signal allSettingsRequested()

    readonly property string ib: "file:///home/nimeh/NimehOS/shell/icons/png/"

    property bool wifiOn: false
    property bool bluetoothOn: false
    property bool airplaneOn: false
    property bool nightLightOn: false
    property bool dndOn: false
    property int brightness: 80
    property int volume: 50

    // چک واقعی وضعیت WiFi و Bluetooth
    Process {
        id: wifiCheck
        command: ["sh","-c","rfkill list wifi 2>/dev/null | grep -q 'blocked: no' && echo on || echo off"]
        stdout: StdioCollector { onStreamFinished: qs.wifiOn = this.text.trim() === "on" }
    }
    Process {
        id: btCheck
        command: ["sh","-c","rfkill list bluetooth 2>/dev/null | grep -q 'blocked: no' && echo on || echo off"]
        stdout: StdioCollector { onStreamFinished: qs.bluetoothOn = this.text.trim() === "on" }
    }
    Timer {
        interval: 3000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { wifiCheck.running = true; btCheck.running = true }
    }

    Timer {
        id: stateRefresh
        interval: 800
        onTriggered: { wifiCheck.running = true; btCheck.running = true }
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: Qt.rgba(14/255,14/255,18/255,0.96)
        border.color: Qt.rgba(1,1,1,0.08)
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            // Toggles grid
            Grid {
                width: parent.width
                columns: 2
                spacing: 8

                // Wifi
                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 56
                    radius: 10
                    color: qs.wifiOn ? Qt.rgba(0,153/255,1,0.18) : Qt.rgba(28/255,28/255,30/255,0.6)
                    border.color: qs.wifiOn ? "#0099FF" : Qt.rgba(1,1,1,0.06)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 10
                        Image {
                            source: qs.ib + "ic_fluent_wifi_1_24_regular.png"
                            width: 18; height: 18
                            sourceSize: Qt.size(18,18)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "وای‌فای"
                            color: "#F0F4FF"
                            font.family: "Vazirmatn"
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const newState = !qs.wifiOn
                            qs.wifiOn = newState
                            Quickshell.execDetached(["sh","-c",
                                newState ? "nmcli radio wifi on 2>/dev/null || rfkill unblock wifi"
                                         : "nmcli radio wifi off 2>/dev/null || rfkill block wifi"])
                            stateRefresh.start()
                        }
                    }
                }

                // Bluetooth
                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 56
                    radius: 10
                    color: qs.bluetoothOn ? Qt.rgba(0,153/255,1,0.18) : Qt.rgba(28/255,28/255,30/255,0.6)
                    border.color: qs.bluetoothOn ? "#0099FF" : Qt.rgba(1,1,1,0.06)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 10
                        Text {
                            text: "🔵"
                            color: "#F0F4FF"
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "بلوتوث"
                            color: "#F0F4FF"
                            font.family: "Vazirmatn"
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const newState = !qs.bluetoothOn
                            qs.bluetoothOn = newState
                            Quickshell.execDetached(["sh","-c",
                                newState ? "bluetoothctl power on 2>/dev/null || rfkill unblock bluetooth"
                                         : "bluetoothctl power off 2>/dev/null || rfkill block bluetooth"])
                            stateRefresh.start()
                        }
                    }
                }

                // Airplane
                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 56
                    radius: 10
                    color: qs.airplaneOn ? Qt.rgba(245/255,158/255,11/255,0.18) : Qt.rgba(28/255,28/255,30/255,0.6)
                    border.color: qs.airplaneOn ? "#F59E0B" : Qt.rgba(1,1,1,0.06)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 10
                        Text {
                            text: "✈"
                            color: "#F0F4FF"
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "هواپیما"
                            color: "#F0F4FF"
                            font.family: "Vazirmatn"
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const newState = !qs.airplaneOn
                            qs.airplaneOn = newState
                            // FIX: Airplane mode now actually controls radios.
                            // When ON: block all radios and sync the wifi/bluetooth
                            // toggles so the UI stays consistent.
                            // When OFF: unblock everything and re-enable wifi/wwan.
                            if (newState) {
                                Quickshell.execDetached(["sh","-c",
                                    "nmcli radio wifi off; nmcli radio wwan off; rfkill block all"])
                                qs.wifiOn = false
                                qs.bluetoothOn = false
                            } else {
                                Quickshell.execDetached(["sh","-c",
                                    "rfkill unblock all; nmcli radio wifi on; nmcli radio wwan on"])
                            }
                            stateRefresh.start()
                        }
                    }
                }

                // Night light
                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 56
                    radius: 10
                    color: qs.nightLightOn ? Qt.rgba(245/255,158/255,11/255,0.18) : Qt.rgba(28/255,28/255,30/255,0.6)
                    border.color: qs.nightLightOn ? "#F59E0B" : Qt.rgba(1,1,1,0.06)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 10
                        Text {
                            text: "🌙"
                            color: "#F0F4FF"
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "نور شب"
                            color: "#F0F4FF"
                            font.family: "Vazirmatn"
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const newState = !qs.nightLightOn
                            qs.nightLightOn = newState
                            // FIX: Night Light now actually drives wlsunset.
                            // ON  -> start wlsunset with a warm 3500K night temperature.
                            // OFF -> kill any running wlsunset so the screen returns to normal.
                            Quickshell.execDetached(["sh","-c",
                                newState
                                  ? "pkill wlsunset 2>/dev/null; (wlsunset -t 3500 -T 6500 >/dev/null 2>&1 &)"
                                  : "pkill wlsunset 2>/dev/null"])
                        }
                    }
                }

                // Do Not Disturb
                Rectangle {
                    width: (parent.width - 8) / 2
                    height: 56
                    radius: 10
                    color: qs.dndOn ? Qt.rgba(167/255,139/255,250/255,0.18) : Qt.rgba(28/255,28/255,30/255,0.6)
                    border.color: qs.dndOn ? "#A78BFA" : Qt.rgba(1,1,1,0.06)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 10
                        Text {
                            text: "🔕"
                            color: "#F0F4FF"
                            font.pixelSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "مزاحم نشو"
                            color: "#F0F4FF"
                            font.family: "Vazirmatn"
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const newState = !qs.dndOn
                            qs.dndOn = newState
                            // FIX: DND now actually pauses the notification daemon.
                            // Supports dunstctl (primary) and makoctl (fallback).
                            const arg = newState ? "true" : "false"
                            Quickshell.execDetached(["sh","-c",
                                "command -v dunstctl >/dev/null 2>&1 && dunstctl set-paused " + arg +
                                " || (command -v makoctl >/dev/null 2>&1 && makoctl set-paused " + arg + ") || true"])
                        }
                    }
                }
            }

            // Sliders
            Rectangle {
                width: parent.width
                height: 80
                radius: 10
                color: Qt.rgba(28/255,28/255,30/255,0.6)
                border.color: Qt.rgba(1,1,1,0.06)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // Brightness
                    Row {
                        width: parent.width
                        spacing: 10
                        Image {
                            source: qs.ib + "ic_fluent_brightness_high_24_regular.png"
                            width: 16; height: 16
                            sourceSize: Qt.size(16,16)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Rectangle {
                            width: parent.width - 30
                            height: 6
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 3
                            color: Qt.rgba(1,1,1,0.08)
                            Rectangle {
                                width: parent.width * (qs.brightness / 100)
                                height: parent.height
                                radius: 3
                                color: "#F59E0B"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    qs.brightness = Math.round((mouse.x / parent.width) * 100)
                                    Quickshell.execDetached(["sh","-c","brightnessctl s " + qs.brightness + "%"])
                                }
                            }
                        }
                    }

                    // Volume
                    Row {
                        width: parent.width
                        spacing: 10
                        Image {
                            source: qs.ib + "ic_fluent_speaker_2_24_regular.png"
                            width: 16; height: 16
                            sourceSize: Qt.size(16,16)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Rectangle {
                            width: parent.width - 30
                            height: 6
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 3
                            color: Qt.rgba(1,1,1,0.08)
                            Rectangle {
                                width: parent.width * (qs.volume / 100)
                                height: parent.height
                                radius: 3
                                color: "#0099FF"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    qs.volume = Math.round((mouse.x / parent.width) * 100)
                                    Quickshell.execDetached(["sh","-c","wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (qs.volume/100)])
                                }
                            }
                        }
                    }
                }
            }

            // Media controls
            MediaControls {
                width: parent.width
            }

            // Battery info
            Rectangle {
                width: parent.width
                height: 50
                radius: 10
                color: Qt.rgba(28/255,28/255,30/255,0.6)
                border.color: Qt.rgba(1,1,1,0.06)
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Image {
                        source: qs.ib + "ic_fluent_battery_8_24_regular.png"
                        width: 18; height: 18
                        sourceSize: Qt.size(18,18)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            text: "۸۵٪"
                            color: "#F0F4FF"
                            font.family: "Vazirmatn"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: "۳ ساعت و ۲۰ دقیقه باقی‌مانده"
                            color: "#7A8598"
                            font.family: "Vazirmatn"
                            font.pixelSize: 10
                        }
                    }
                    Item { width: 1; height: 1; Layout.fillWidth: true }
                    Text {
                        text: "⚡ برق متصل"
                        color: "#22D3AE"
                        font.family: "Vazirmatn"
                        font.pixelSize: 11
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // All settings button
            Rectangle {
                width: parent.width
                height: 38
                radius: 19
                color: allMa.containsMouse ? Qt.rgba(0,153/255,1,0.18) : Qt.rgba(1,1,1,0.04)
                border.color: Qt.rgba(1,1,1,0.08)
                border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "همه تنظیمات"
                    color: "#F0F4FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 12
                }

                MouseArea {
                    id: allMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: qs.allSettingsRequested()
                }
            }
        }
    }

    // Close on outside click
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: qs.closeRequested()
    }
}
