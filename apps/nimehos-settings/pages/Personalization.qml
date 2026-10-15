import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: page
    property bool darkTheme: true
    property string accentColor: "#0078D4"

    Column {
        anchors.fill: parent
        spacing: 12

        Text { text: "شخصی‌سازی"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 20; weight: Font.Bold } }

        // ── تم دارک/لایت ──
        Rectangle {
            width: parent.width; height: 70; radius: 8; color: "#2A2A2A"; border { width: 1; color: "#333333" }
            Row {
                anchors { fill: parent; margins: 16 }
                spacing: 12
                Text { text: "🎨 تم"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 13; weight: Font.Medium }; anchors.verticalCenter: parent.verticalCenter }
                Item { width: parent.width - 120; height: parent.height; anchors.verticalCenter: parent.verticalCenter
                    Row {
                        anchors.centerIn: parent; spacing: 8
                        Repeater {
                            model: [{ name: "تیره", val: true }, { name: "روشن", val: false }]
                            delegate: Rectangle {
                                width: 80; height: 32; radius: 6
                                color: page.darkTheme === modelData.val ? Qt.rgba(0, 0.47, 0.83, 0.3) : "#333333"
                                border.width: page.darkTheme === modelData.val ? 1 : 0
                                border.color: "#0078D4"
                                Text { anchors.centerIn: parent; text: modelData.name; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 11 } }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: page.darkTheme = modelData.val }
                            }
                        }
                    }
                }
            }
        }

        // ── رنگ accent ──
        Rectangle {
            width: parent.width; height: 100; radius: 8; color: "#2A2A2A"; border { width: 1; color: "#333333" }
            Column {
                anchors { fill: parent; margins: 16 }
                spacing: 10
                Text { text: "رنگ اصلی"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 13; weight: Font.Medium } }
                Row {
                    spacing: 10
                    Repeater {
                        model: ["#0078D4", "#8B5CF6", "#22D3AE", "#F59E0B", "#EF4444", "#EC4899"]
                        delegate: Rectangle {
                            width: 36; height: 36; radius: 18
                            color: modelData
                            border.width: page.accentColor === modelData ? 3 : 0
                            border.color: "#FFFFFF"
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: page.accentColor = modelData }
                        }
                    }
                }
            }
        }

        // ── والپیپر ──
        Rectangle {
            width: parent.width; height: 140; radius: 8; color: "#2A2A2A"; border { width: 1; color: "#333333" }
            Column {
                anchors { fill: parent; margins: 16 }
                spacing: 10
                Text { text: "🖼 پس‌زمینه"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 13; weight: Font.Medium } }
                Row {
                    spacing: 10
                    Repeater {
                        model: [
                            { c1: "#0A0E27", c2: "#1A1F3A", name: "شب" },
                            { c1: "#1A1330", c2: "#0A0A0C", name: "غروب" },
                            { c1: "#0A0A0C", c2: "#151820", name: "تیره" },
                            { c1: "#1E1E2E", c2: "#181825", name: "بنفش" }
                        ]
                        delegate: Rectangle {
                            width: 80; height: 50; radius: 6
                            gradient: Gradient {
                                GradientStop { position: 0; color: modelData.c1 }
                                GradientStop { position: 1; color: modelData.c2 }
                            }
                            border.width: 1; border.color: "#444444"
                            Text { anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottomMargin: 4; text: modelData.name; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 9 } }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor }
                        }
                    }
                }
            }
        }
    }
}
