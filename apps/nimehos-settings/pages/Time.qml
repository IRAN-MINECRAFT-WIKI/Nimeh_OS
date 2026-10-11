import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 16

    Text {
        text: "زمان و زبان"
        color: "#F0F4FF"
        font.family: "Vazirmatn"
        font.pixelSize: 24
        font.bold: true
    }

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
                text: "تاریخ و ساعت"
                color: "#F0F4FF"
                font.family: "Vazirmatn"
                font.pixelSize: 14
                font.bold: true
            }

            GridLayout {
                columns: 2
                columnSpacing: 40
                rowSpacing: 8

                Text { text: "منطقه زمانی:"; color: "#7A8598"; font.family: "Vazirmatn"; font.pixelSize: 12 }
                Text { text: "Asia/Tehran (UTC+3:30)"; color: "#F0F4FF"; font.family: "Vazirmatn"; font.pixelSize: 12 }
                Text { text: "زبان:"; color: "#7A8598"; font.family: "Vazirmatn"; font.pixelSize: 12 }
                Text { text: "فارسی"; color: "#F0F4FF"; font.family: "Vazirmatn"; font.pixelSize: 12 }
                Text { text: "تقویم:"; color: "#7A8598"; font.family: "Vazirmatn"; font.pixelSize: 12 }
                Text { text: "شمسی"; color: "#F0F4FF"; font.family: "Vazirmatn"; font.pixelSize: 12 }
            }
        }
    }
}
