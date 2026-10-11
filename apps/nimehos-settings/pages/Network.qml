import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 16

    Text {
        text: "شبکه و اینترنت"
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

            Text { text: "🌐"; font.pixelSize: 40 }

            ColumnLayout {
                Layout.fillWidth: true
                Text {
                    text: "WiFi"
                    color: "#F0F4FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 14
                    font.bold: true
                }
                Text {
                    text: "متصل به NimehOS-Net"
                    color: "#22D3AE"
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
        text: "شبکه‌های موجود"
        color: "#F0F4FF"
        font.family: "Vazirmatn"
        font.pixelSize: 14
        font.bold: true
    }

    Repeater {
        model: [
            { name: "NimehOS-Net", signal: "قوی", connected: true },
            { name: "Home-5G", signal: "متوسط", connected: false },
            { name: "Guest", signal: "ضعیف", connected: false }
        ]

        delegate: Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            radius: 10
            color: Qt.rgba(1, 1, 1, 0.04)
            border.color: Qt.rgba(1, 1, 1, 0.06)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Text { text: "📶"; font.pixelSize: 20 }
                ColumnLayout {
                    Layout.fillWidth: true
                    Text {
                        text: modelData.name
                        color: "#F0F4FF"
                        font.family: "Vazirmatn"
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: modelData.signal
                        color: "#7A8598"
                        font.family: "Vazirmatn"
                        font.pixelSize: 10
                    }
                }
                Text {
                    visible: modelData.connected
                    text: "✓ متصل"
                    color: "#22D3AE"
                    font.family: "Vazirmatn"
                    font.pixelSize: 11
                }
            }
        }
    }
}
