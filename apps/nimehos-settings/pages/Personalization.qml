import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 16

    Text {
        text: "شخصی‌سازی"
        color: "#F0F4FF"
        font.family: "Vazirmatn"
        font.pixelSize: 24
        font.bold: true
    }

    // پس‌زمینه
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 200
        radius: 12
        color: Qt.rgba(1, 1, 1, 0.05)
        border.color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Text {
                text: "پس‌زمینه"
                color: "#F0F4FF"
                font.family: "Vazirmatn"
                font.pixelSize: 14
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                radius: 8
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#0A0A0C" }
                    GradientStop { position: 1.0; color: "#151820" }
                }
                border.color: Qt.rgba(1, 1, 1, 0.10)
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Aurora Gradient"
                    color: "#F0F4FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 12
                }
            }
        }
    }

    // رنگ اصلی
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 140
        radius: 12
        color: Qt.rgba(1, 1, 1, 0.05)
        border.color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            Text {
                text: "رنگ اصلی"
                color: "#F0F4FF"
                font.family: "Vazirmatn"
                font.pixelSize: 14
                font.bold: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: ["#0099FF", "#A78BFA", "#22D3AE", "#EF4444", "#F59E0B", "#EC4899", "#6366F1", "#F472B6"]
                    delegate: Rectangle {
                        width: 40; height: 40; radius: 20
                        color: modelData
                        border.color: colorMa.containsMouse ? "white" : Qt.rgba(1,1,1,0.15)
                        border.width: 2
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        scale: colorMa.containsMouse ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                        MouseArea {
                            id: colorMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }
    }
}
