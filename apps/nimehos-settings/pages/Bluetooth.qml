import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 16

    Text {
        text: "بلوتوث و دستگاه‌ها"
        color: "#F0F4FF"
        font.family: "Vazirmatn"
        font.pixelSize: 24
        font.bold: true
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 120
        radius: 12
        color: Qt.rgba(1, 1, 1, 0.05)
        border.color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Text { text: "🔵"; font.pixelSize: 40 }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Text {
                    text: "بلوتوث"
                    color: "#F0F4FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 14
                    font.bold: true
                }
                Text {
                    text: "روشن • در حال جستجو..."
                    color: "#7A8598"
                    font.family: "Vazirmatn"
                    font.pixelSize: 11
                }
            }

            Rectangle {
                width: 50; height: 28; radius: 14
                color: "#0099FF"
                Rectangle {
                    width: 22; height: 22; radius: 11
                    color: "white"
                    x: 25; y: 3
                }
            }
        }
    }

    Text {
        text: "دستگاه‌های متصل"
        color: "#F0F4FF"
        font.family: "Vazirmatn"
        font.pixelSize: 14
        font.bold: true
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 80
        radius: 12
        color: Qt.rgba(1, 1, 1, 0.05)
        border.color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            Text { text: "🖱️"; font.pixelSize: 24 }
            ColumnLayout {
                Layout.fillWidth: true
                Text { text: "Logitech Mouse"; color: "#F0F4FF"; font.family: "Vazirmatn"; font.pixelSize: 12; font.bold: true }
                Text { text: "متصل"; color: "#22D3AE"; font.family: "Vazirmatn"; font.pixelSize: 10 }
            }
        }
    }
}
