import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 16

    Text {
        text: "به‌روزرسانی NimehOS"
        color: "#F0F4FF"
        font.family: "Vazirmatn"
        font.pixelSize: 24
        font.bold: true
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 160
        radius: 12
        color: Qt.rgba(34/255, 211/255, 174/255, 0.08)
        border.color: Qt.rgba(34/255, 211/255, 174/255, 0.3)
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            Text { text: "✓"; color: "#22D3AE"; font.pixelSize: 48 }
            Text {
                text: "سیستم به‌روز است"
                color: "#F0F4FF"
                font.family: "Vazirmatn"
                font.pixelSize: 16
                font.bold: true
            }
            Text {
                text: "آخرین بررسی: امروز ۱۰:۳۰"
                color: "#7A8598"
                font.family: "Vazirmatn"
                font.pixelSize: 11
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        radius: 22
        color: "#0099FF"

        Text {
            anchors.centerIn: parent
            text: "بررسی به‌روزرسانی"
            color: "white"
            font.family: "Vazirmatn"
            font.pixelSize: 12
            font.bold: true
        }
    }
}
