import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 16

    Text {
        text: "حساب‌های کاربری"
        color: "#F0F4FF"
        font.family: "Vazirmatn"
        font.pixelSize: 24
        font.bold: true
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 160
        radius: 12
        color: Qt.rgba(1, 1, 1, 0.05)
        border.color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            Rectangle {
                width: 80; height: 80; radius: 40
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#0099FF" }
                    GradientStop { position: 1.0; color: "#A78BFA" }
                }
                Text {
                    anchors.centerIn: parent
                    text: "ن"
                    color: "white"
                    font.family: "Vazirmatn"
                    font.pixelSize: 36
                    font.bold: true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "nimeh"
                    color: "#F0F4FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 18
                    font.bold: true
                }
                Text {
                    text: "Administrator"
                    color: "#0099FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 11
                }
                Text {
                    text: "nimeh@NimehOS-dev"
                    color: "#7A8598"
                    font.family: "Vazirmatn"
                    font.pixelSize: 11
                }
            }
        }
    }
}
