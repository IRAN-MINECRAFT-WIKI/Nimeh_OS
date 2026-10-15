import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: page
    property bool wifiOn: false
    property bool btOn: false
    property string ssid: ""

    Process {
        id: netCheck
        command: ["sh", "-c", "rfkill list wifi 2>/dev/null | grep -q 'blocked: no' && echo WIFI_ON || echo WIFI_OFF; nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2 || echo ''; bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo BT_ON || echo BT_OFF"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n")
                page.wifiOn = lines[0] === "WIFI_ON"
                page.ssid = lines[1] || ""
                page.btOn = lines[2] === "BT_ON"
            }
        }
    }
    Component.onCompleted: netCheck.running = true

    Column {
        anchors.fill: parent
        spacing: 12

        Text { text: "شبکه و اینترنت"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 20; weight: Font.Bold } }

        // WiFi
        Rectangle {
            width: parent.width; height: 80; radius: 8; color: "#2A2A2A"; border { width: 1; color: "#333333" }
            Row {
                anchors { fill: parent; margins: 16 }
                spacing: 12
                Column {
                    spacing: 4
                    Text { text: "📶 وای‌فای"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 13; weight: Font.Medium } }
                    Text { text: page.wifiOn ? (page.ssid ? "متصل به: " + page.ssid : "روشن — متصل نیست") : "خاموش"; color: "#888888"; font { family: "Vazirmatn"; pixelSize: 11 } }
                }
                Item { width: parent.width - 200; height: parent.height }
                Rectangle {
                    width: 40; height: 20; radius: 10; anchors.verticalCenter: parent.verticalCenter
                    color: page.wifiOn ? "#0078D4" : "#444444"
                    Rectangle { x: page.wifiOn ? 22 : 2; y: 2; width: 16; height: 16; radius: 8; color: "#FFFFFF"; Behavior on x { NumberAnimation { duration: 150 } } }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { page.wifiOn = !page.wifiOn; Quickshell.execDetached(["sh", "-c", "nmcli radio wifi " + (page.wifiOn ? "on" : "off")]) } }
                }
            }
        }

        // Bluetooth
        Rectangle {
            width: parent.width; height: 80; radius: 8; color: "#2A2A2A"; border { width: 1; color: "#333333" }
            Row {
                anchors { fill: parent; margins: 16 }
                spacing: 12
                Column {
                    spacing: 4
                    Text { text: "🔵 بلوتوث"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 13; weight: Font.Medium } }
                    Text { text: page.btOn ? "روشن" : "خاموش"; color: "#888888"; font { family: "Vazirmatn"; pixelSize: 11 } }
                }
                Item { width: parent.width - 200; height: parent.height }
                Rectangle {
                    width: 40; height: 20; radius: 10; anchors.verticalCenter: parent.verticalCenter
                    color: page.btOn ? "#0078D4" : "#444444"
                    Rectangle { x: page.btOn ? 22 : 2; y: 2; width: 16; height: 16; radius: 8; color: "#FFFFFF"; Behavior on x { NumberAnimation { duration: 150 } } }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { page.btOn = !page.btOn; Quickshell.execDetached(["sh", "-c", "bluetoothctl power " + (page.btOn ? "on" : "off")]) } }
                }
            }
        }

        // Airplane mode
        Rectangle {
            width: parent.width; height: 60; radius: 8; color: "#2A2A2A"; border { width: 1; color: "#333333" }
            Row {
                anchors { fill: parent; margins: 16 }
                spacing: 12
                Text { text: "✈ حالت پرواز"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 13; weight: Font.Medium }; anchors.verticalCenter: parent.verticalCenter }
                Item { width: parent.width - 200; height: parent.height }
                Rectangle {
                    width: 40; height: 20; radius: 10; anchors.verticalCenter: parent.verticalCenter
                    color: (!page.wifiOn && !page.btOn) ? "#F59E0B" : "#444444"
                    Rectangle { x: (!page.wifiOn && !page.btOn) ? 22 : 2; y: 2; width: 16; height: 16; radius: 8; color: "#FFFFFF"; Behavior on x { NumberAnimation { duration: 150 } } }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { page.wifiOn = false; page.btOn = false; Quickshell.execDetached(["sh", "-c", "nmcli radio wifi off; bluetoothctl power off; rfkill block all"]) } }
                }
            }
        }
    }
}
