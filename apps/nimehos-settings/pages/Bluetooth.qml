import QtQuick
import Quickshell
import Quickshell.Io

Item {
    Column {
        anchors.fill: parent
        spacing: 12
        Text { text: "Bluetooth"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 20; weight: Font.Bold } }
        Rectangle {
            width: parent.width; height: 60; radius: 8; color: "#2A2A2A"; border { width: 1; color: "#333333" }
            Text { anchors.centerIn: parent; text: "این صفحه در حال توسعه است"; color: "#666666"; font { family: "Vazirmatn"; pixelSize: 12 } }
        }
    }
}
