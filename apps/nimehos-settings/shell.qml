import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

PanelWindow {
    id: root
    color: "transparent"
    visible: true
    WlrLayershell.namespace: "nimehos-settings"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore

    anchors { top: true; bottom: true; left: true; right: true }

    property string currentPage: "System"
    property bool closing: false

    function closeWindow() {
        if (closing) return
        closing = true
        Quickshell.exit()
    }

    // ─── پس‌زمینه ───
    Rectangle {
        anchors.fill: parent
        color: "#202020"

        // ─── نوار بالا ───
        Rectangle {
            id: topBar
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 48
            color: "#2A2A2A"
            border { bottom { width: 1; color: "#333333" } }

            Row {
                anchors.centerIn: parent
                spacing: 12
                Text {
                    text: "⚙ تنظیمات NimehOS"
                    color: "#FFFFFF"
                    font { family: "Vazirmatn"; pixelSize: 14; weight: Font.Medium }
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: 32; height: 32; radius: 6
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 12 }
                color: closeMa.containsMouse ? "#C42B1C" : "transparent"
                Text { anchors.centerIn: parent; text: "✕"; color: "#FFFFFF"; font.pixelSize: 12 }
                MouseArea { id: closeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.closeWindow() }
            }
        }

        // ─── سایدبار ───
        Rectangle {
            id: sidebar
            anchors { top: topBar.bottom; bottom: parent.bottom; left: parent.left }
            width: 240
            color: "#252525"

            ListView {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2
                model: [
                    { page: "System", icon: "🖥", label: "سیستم" },
                    { page: "Personalization", icon: "🎨", label: "شخصی‌سازی" },
                    { page: "Network", icon: "🌐", label: "شبکه و اینترنت" },
                    { page: "Bluetooth", icon: "🔵", label: "بلوتوث" },
                    { page: "Apps", icon: "📦", label: "برنامه‌ها" },
                    { page: "Accounts", icon: "👤", label: "حساب کاربری" },
                    { page: "Time", icon: "🕐", label: "زمان و زبان" },
                    { page: "Privacy", icon: "🔒", label: "حریم خصوصی" },
                    { page: "Update", icon: "🔄", label: "به‌روزرسانی" }
                ]
                delegate: Rectangle {
                    width: ListView.view.width
                    height: 40
                    radius: 6
                    color: root.currentPage === modelData.page ? Qt.rgba(0, 0.47, 0.83, 0.25) : (navMa.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent")
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        spacing: 10
                        Text { text: modelData.icon; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
                        Text {
                            text: modelData.label
                            color: root.currentPage === modelData.page ? "#4CC2FF" : "#CCCCCC"
                            font { family: "Vazirmatn"; pixelSize: 12 }
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea { id: navMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.currentPage = modelData.page }
                }
            }
        }

        // ─── محتوای اصلی ───
        Rectangle {
            anchors { top: topBar.bottom; bottom: parent.bottom; left: sidebar.right; right: parent.right }
            color: "#202020"
            clip: true

            Loader {
                anchors.fill: parent
                anchors.margins: 24
                source: `pages/${root.currentPage}.qml`
            }
        }
    }
}
