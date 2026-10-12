import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root
    color: "transparent"
    visible: true
    WlrLayershell.namespace: "nimehos-settings"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    property string currentPage: "System"
    property bool closing: false

    function closeWindow() {
        if (closing) return
        closing = true
        closeAnim.start()
    }

    // ═══ Backdrop (تیره) ═══
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.4)
        opacity: 0

        // کلیک روی backdrop → بستن
        MouseArea {
            anchors.fill: parent
            onClicked: root.closeWindow()
        }
    }

    // ═══ Main Window ═══
    Rectangle {
        id: mainWindow
        anchors.centerIn: parent
        width: Math.min(1100, parent.width - 80)
        height: Math.min(720, parent.height - 80)
        radius: 14
        color: Qt.rgba(28/255, 28/255, 32/255, 0.98)
        border.color: Qt.rgba(1, 1, 1, 0.12)
        border.width: 1

        // انیمیشن باز: از پایین به بالا
        opacity: 0
        scale: 0.92
        y: 80

        Component.onCompleted: openAnim.start()

        // ⚠️ کلیک روی پنجره → backdrop نبسته
        MouseArea {
            anchors.fill: parent
            // swallow — جلوگیری از رسیدن به backdrop
        }

        ParallelAnimation {
            id: openAnim
            NumberAnimation { target: backdrop; property: "opacity"; to: 1; duration: 200 }
            NumberAnimation { target: mainWindow; property: "opacity"; to: 1; duration: 250; easing.type: Easing.OutCubic }
            NumberAnimation { target: mainWindow; property: "scale"; to: 1; duration: 350; easing.type: Easing.OutBack }
            NumberAnimation { target: mainWindow; property: "y"; to: 0; duration: 350; easing.type: Easing.OutCubic }
        }

        // ⚠️ انیمیشن بستن: بره پایین
        SequentialAnimation {
            id: closeAnim
            ParallelAnimation {
                NumberAnimation { target: backdrop; property: "opacity"; to: 0; duration: 250; easing.type: Easing.InCubic }
                NumberAnimation { target: mainWindow; property: "opacity"; to: 0; duration: 200 }
                NumberAnimation { target: mainWindow; property: "scale"; to: 0.94; duration: 250; easing.type: Easing.InCubic }
                NumberAnimation { target: mainWindow; property: "y"; to: 80; duration: 280; easing.type: Easing.InCubic }
            }
            ScriptAction { script: killProc.running = true }
        }

        Process {
            id: killProc
            command: ["sh","-c","pkill -f 'quickshell.*nimehos-settings' 2>/dev/null || true"]
        }

        // ═══ Title Bar ═══
        Rectangle {
            id: titleBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 40
            radius: 14
            color: Qt.rgba(20/255, 20/255, 24/255, 0.6)

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Qt.rgba(1, 1, 1, 0.08)
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Rectangle {
                    width: 20; height: 20; radius: 5
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#0099FF" }
                        GradientStop { position: 1.0; color: "#6366F1" }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "N"
                        color: "white"
                        font.family: "Inter"
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                Text {
                    text: "تنظیمات"
                    color: "#F0F4FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 12
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // دکمه‌ها
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: 46; height: titleBar.height
                    color: minMa.containsMouse ? Qt.rgba(1,1,1,0.10) : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text {
                        anchors.centerIn: parent
                        text: "─"
                        color: "#F0F4FF"
                        font.pixelSize: 12
                    }
                    MouseArea {
                        id: minMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Rectangle {
                    width: 46; height: titleBar.height
                    color: maxMa.containsMouse ? Qt.rgba(1,1,1,0.10) : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text {
                        anchors.centerIn: parent
                        text: "▢"
                        color: "#F0F4FF"
                        font.pixelSize: 14
                    }
                    MouseArea {
                        id: maxMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Rectangle {
                    width: 46; height: titleBar.height
                    color: closeMa.containsMouse ? "#EF4444" : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: "#F0F4FF"
                        font.pixelSize: 12
                    }
                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closeWindow()
                    }
                }
            }
        }

        // ═══ Body ═══
        RowLayout {
            anchors.top: titleBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 0

            // Sidebar
            Rectangle {
                Layout.preferredWidth: 260
                Layout.fillHeight: true
                color: Qt.rgba(16/255, 16/255, 20/255, 0.5)

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1
                    color: Qt.rgba(1, 1, 1, 0.06)
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        radius: 10
                        color: Qt.rgba(1, 1, 1, 0.04)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: 20
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#0099FF" }
                                    GradientStop { position: 1.0; color: "#A78BFA" }
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: "ن"
                                    color: "white"
                                    font.family: "Vazirmatn"
                                    font.pixelSize: 18
                                    font.bold: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                Text {
                                    text: "nimeh"
                                    color: "#F0F4FF"
                                    font.family: "Vazirmatn"
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Text {
                                    text: "NimehOS-dev"
                                    color: "#7A8598"
                                    font.family: "Vazirmatn"
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        radius: 8
                        color: Qt.rgba(1, 1, 1, 0.04)
                        border.color: Qt.rgba(1, 1, 1, 0.08)
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 6
                            Text { text: "🔍"; font.pixelSize: 11; opacity: 0.6 }
                            Text {
                                text: "جستجو..."
                                color: "#7A8598"
                                font.family: "Vazirmatn"
                                font.pixelSize: 11
                                Layout.fillWidth: true
                            }
                        }
                    }

                    Item { Layout.preferredHeight: 4 }

                    Repeater {
                        model: [
                            { id: "System",          icon: "💻", title: "سیستم" },
                            { id: "Bluetooth",       icon: "🔵", title: "بلوتوث" },
                            { id: "Network",         icon: "🌐", title: "شبکه" },
                            { id: "Personalization", icon: "🎨", title: "شخصی‌سازی" },
                            { id: "Apps",            icon: "📱", title: "برنامه‌ها" },
                            { id: "Accounts",        icon: "👤", title: "حساب‌ها" },
                            { id: "Time",            icon: "🕐", title: "زمان و زبان" },
                            { id: "Privacy",         icon: "🔒", title: "حریم خصوصی" },
                            { id: "Update",          icon: "🛠", title: "به‌روزرسانی" }
                        ]

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            radius: 8
                            color: root.currentPage === modelData.id
                                   ? Qt.rgba(0, 153/255, 1, 0.20)
                                   : (itemMa.containsMouse ? Qt.rgba(1,1,1,0.06) : "transparent")
                            Behavior on color { ColorAnimation { duration: 120 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10
                                Text { text: modelData.icon; font.pixelSize: 14 }
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.title
                                    color: "#F0F4FF"
                                    font.family: "Vazirmatn"
                                    font.pixelSize: 12
                                }
                            }

                            MouseArea {
                                id: itemMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.currentPage = modelData.id
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // Content
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"

                Loader {
                    anchors.fill: parent
                    anchors.margins: 28
                    source: "pages/" + root.currentPage + ".qml"
                }
            }
        }
    }

    Shortcut {
        sequences: ["Escape"]
        onActivated: root.closeWindow()
    }
}
