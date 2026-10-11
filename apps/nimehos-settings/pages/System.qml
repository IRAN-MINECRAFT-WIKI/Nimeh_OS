import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 16

    Text {
        text: "سیستم"
        color: "#F0F4FF"
        font.family: "Vazirmatn"
        font.pixelSize: 24
        font.bold: true
    }

    // Card: مشخصات
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 180
        radius: 12
        color: Qt.rgba(1, 1, 1, 0.05)
        border.color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Text {
                text: "مشخصات دستگاه"
                color: "#F0F4FF"
                font.family: "Vazirmatn"
                font.pixelSize: 14
                font.bold: true
            }

            GridLayout {
                columns: 2
                columnSpacing: 40
                rowSpacing: 8

                Text { text: "نام:"; color: "#7A8598"; font.family: "Vazirmatn"; font.pixelSize: 12 }
                Text { text: "NimehOS-Dev"; color: "#F0F4FF"; font.family: "Vazirmatn"; font.pixelSize: 12 }
                Text { text: "سیستم:"; color: "#7A8598"; font.family: "Vazirmatn"; font.pixelSize: 12 }
                Text { text: "NimehOS 1.0"; color: "#F0F4FF"; font.family: "Vazirmatn"; font.pixelSize: 12 }
                Text { text: "معماری:"; color: "#7A8598"; font.family: "Vazirmatn"; font.pixelSize: 12 }
                Text { text: "x86_64"; color: "#F0F4FF"; font.family: "Vazirmatn"; font.pixelSize: 12 }
                Text { text: "حافظه:"; color: "#7A8598"; font.family: "Vazirmatn"; font.pixelSize: 12 }
                Text { text: "4 GB RAM"; color: "#F0F4FF"; font.family: "Vazirmatn"; font.pixelSize: 12 }
            }
        }
    }

    // Card: نمایش
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 120
        radius: 12
        color: Qt.rgba(1, 1, 1, 0.05)
        border.color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Text {
                text: "نمایش"
                color: "#F0F4FF"
                font.family: "Vazirmatn"
                font.pixelSize: 14
                font.bold: true
            }

            RowLayout {
                spacing: 12
                Text { text: "روشنایی"; color: "#7A8598"; font.family: "Vazirmatn"; font.pixelSize: 12; Layout.preferredWidth: 80 }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 6
                    radius: 3
                    color: Qt.rgba(1, 1, 1, 0.08)
                    Rectangle {
                        width: parent.width * 0.8
                        height: parent.height
                        radius: 3
                        color: "#0099FF"
                    }
                }
            }
        }
    }
}
