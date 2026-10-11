import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Layouts

// ============================================================
// WidgetsPanel — Side panel with weather, calendar, big clock
// Feature C: Widgets Panel (left side)
// ============================================================

PanelWindow {
    id: wpRoot
    anchors.top: true
    anchors.left: true
    anchors.bottom: true
    implicitWidth: 360
    color: "transparent"
    WlrLayershell.namespace: "nimeh-widgets"
    WlrLayershell.layer: WlrLayer.Overlay

    signal closeRequested()

    function show() {
        visible = true
        slideIn.start()
    }
    function hide() {
        slideOut.start()
        hideTimer.start()
    }

    Rectangle {
        id: panel
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.bottomMargin: 56
        anchors.leftMargin: 8
        radius: 16
        color: Qt.rgba(12/255,12/255,16/255,0.96)
        border.color: Qt.rgba(1,1,1,0.08)
        border.width: 1
        x: wpRoot.visible ? 0 : -wpRoot.width

        Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

        Controls.ScrollView {
            anchors.fill: parent
            anchors.margins: 14
            clip: true

            Column {
                width: parent.width
                spacing: 14

                // ====== Big Digital Clock ======
                Rectangle {
                    width: parent.width
                    height: 180
                    radius: 14
                    color: Qt.rgba(28/255,28/255,30/255,0.6)
                    border.color: Qt.rgba(1,1,1,0.06)
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            id: bigClock2
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: {
                                const d = new Date()
                                return Theme.toFa(String(d.getHours()).padStart(2,"0")) + ":" +
                                       Theme.toFa(String(d.getMinutes()).padStart(2,"0")) + ":" +
                                       Theme.toFa(String(d.getSeconds()).padStart(2,"0"))
                            }
                            color: "#F0F4FF"
                            font.family: "Inter"
                            font.pixelSize: 56
                            font.weight: Font.Light

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.0; duration: 1000 }
                                NumberAnimation { to: 0.75; duration: 1000 }
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: {
                                const d = new Date()
                                const j = Theme.jalali(d)
                                return Theme.jalaliWeekdays[d.getDay()] + "، " +
                                       Theme.toFa(j.day) + " " +
                                       Theme.jalaliMonths[j.month-1] + " " +
                                       Theme.toFa(j.year)
                            }
                            color: "#7A8598"
                            font.family: "Vazirmatn"
                            font.pixelSize: 13
                        }
                    }
                }

                // ====== Weather Widget ======
                Rectangle {
                    width: parent.width
                    height: 140
                    radius: 14
                    color: Qt.rgba(28/255,28/255,30/255,0.6)
                    border.color: Qt.rgba(1,1,1,0.06)
                    border.width: 1

                    Row {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16

                        // Weather icon (sun)
                        Item {
                            width: 64
                            height: 64
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                anchors.centerIn: parent
                                width: 48
                                height: 48
                                radius: 24
                                color: "#F59E0B"
                                opacity: 0.9

                                SequentialAnimation on scale {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 1.05; duration: 2000; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 1.0; duration: 2000; easing.type: Easing.InOutSine }
                                }
                            }

                            // Sun rays
                            Repeater {
                                model: 8
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 2
                                    height: 12
                                    color: "#F59E0B"
                                    opacity: 0.7
                                    transformOrigin: Item.Center
                                    rotation: index * 45
                                    y: -28 + (index % 2) * 2
                                }
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Text {
                                text: "۲۴°"
                                color: "#F0F4FF"
                                font.family: "Inter"
                                font.pixelSize: 32
                                font.weight: Font.Light
                            }
                            Text {
                                text: "آفتابی"
                                color: "#7A8598"
                                font.family: "Vazirmatn"
                                font.pixelSize: 12
                            }
                            Text {
                                text: "تهران"
                                color: "#525C6E"
                                font.family: "Vazirmatn"
                                font.pixelSize: 11
                            }
                        }
                    }
                }

                // ====== Calendar Mini ======
                Rectangle {
                    width: parent.width
                    height: 280
                    radius: 14
                    color: Qt.rgba(28/255,28/255,30/255,0.6)
                    border.color: Qt.rgba(1,1,1,0.06)
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        Text {
                            text: {
                                const d = new Date()
                                const j = Theme.jalali(d)
                                return Theme.jalaliMonths[j.month-1] + " " + Theme.toFa(j.year)
                            }
                            color: "#F0F4FF"
                            font.family: "Vazirmatn"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                        }

                        Grid {
                            width: parent.width
                            columns: 7
                            spacing: 2

                            Repeater {
                                model: ["ش","ی","د","س","چ","پ","ج"]
                                delegate: Text {
                                    width: (parent.width - 12) / 7
                                    horizontalAlignment: Text.AlignHCenter
                                    text: modelData
                                    color: "#7A8598"
                                    font.family: "Vazirmatn"
                                    font.pixelSize: 11
                                }
                            }
                        }

                        Grid {
                            width: parent.width
                            columns: 7
                            spacing: 2

                            Repeater {
                                model: 42
                                delegate: Rectangle {
                                    width: (parent.width - 12) / 7
                                    height: 28
                                    radius: 6
                                    color: {
                                        const d = new Date()
                                        const j = Theme.jalali(d)
                                        const dayNum = index - 4 + 1
                                        return dayNum === j.day ? "#0099FF" : "transparent"
                                    }
                                    property int dayNum: index - 4 + 1
                                    property bool valid: dayNum > 0 && dayNum <= 31

                                    Text {
                                        anchors.centerIn: parent
                                        text: valid ? Theme.toFa(dayNum) : ""
                                        color: {
                                            const d = new Date()
                                            const j = Theme.jalali(d)
                                            return dayNum === j.day ? "white" : "#C4CAD6"
                                        }
                                        font.family: "Vazirmatn"
                                        font.pixelSize: 11
                                    }
                                }
                            }
                        }
                    }
                }

                // ====== System Stats ======
                Rectangle {
                    width: parent.width
                    height: 120
                    radius: 14
                    color: Qt.rgba(28/255,28/255,30/255,0.6)
                    border.color: Qt.rgba(1,1,1,0.06)
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 8

                        Text {
                            text: "وضعیت سیستم"
                            color: "#F0F4FF"
                            font.family: "Vazirmatn"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        // CPU bar
                        Row {
                            width: parent.width
                            spacing: 8
                            Text { text: "CPU"; color: "#7A8598"; font.family: "Vazirmatn"; font.pixelSize: 10; width: 50 }
                            Rectangle {
                                width: parent.width - 90
                                height: 6
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 3
                                color: Qt.rgba(1,1,1,0.08)
                                Rectangle {
                                    width: parent.width * 0.32
                                    height: parent.height
                                    radius: 3
                                    color: "#0099FF"
                                }
                            }
                            Text { text: "۳۲٪"; color: "#F0F4FF"; font.family: "Vazirmatn"; font.pixelSize: 10 }
                        }

                        // RAM bar
                        Row {
                            width: parent.width
                            spacing: 8
                            Text { text: "RAM"; color: "#7A8598"; font.family: "Vazirmatn"; font.pixelSize: 10; width: 50 }
                            Rectangle {
                                width: parent.width - 90
                                height: 6
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 3
                                color: Qt.rgba(1,1,1,0.08)
                                Rectangle {
                                    width: parent.width * 0.48
                                    height: parent.height
                                    radius: 3
                                    color: "#22D3AE"
                                }
                            }
                            Text { text: "۴۸٪"; color: "#F0F4FF"; font.family: "Vazirmatn"; font.pixelSize: 10 }
                        }

                        // Disk bar
                        Row {
                            width: parent.width
                            spacing: 8
                            Text { text: "دیسک"; color: "#7A8598"; font.family: "Vazirmatn"; font.pixelSize: 10; width: 50 }
                            Rectangle {
                                width: parent.width - 90
                                height: 6
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 3
                                color: Qt.rgba(1,1,1,0.08)
                                Rectangle {
                                    width: parent.width * 0.65
                                    height: parent.height
                                    radius: 3
                                    color: "#A78BFA"
                                }
                            }
                            Text { text: "۶۵٪"; color: "#F0F4FF"; font.family: "Vazirmatn"; font.pixelSize: 10 }
                        }
                    }
                }
            }
        }
    }

    // Live clock update
    Timer {
        interval: 1000
        running: wpRoot.visible
        repeat: true
        onTriggered: {
            const d = new Date()
            bigClock2.text = Theme.toFa(String(d.getHours()).padStart(2,"0")) + ":" +
                            Theme.toFa(String(d.getMinutes()).padStart(2,"0")) + ":" +
                            Theme.toFa(String(d.getSeconds()).padStart(2,"0"))
        }
    }

    NumberAnimation { id: slideIn; target: panel; property: "x"; to: 0; duration: 250; easing.type: Easing.OutCubic }
    NumberAnimation { id: slideOut; target: panel; property: "x"; to: -wpRoot.width; duration: 250; easing.type: Easing.InCubic }
    Timer { id: hideTimer; interval: 250; onTriggered: wpRoot.visible = false }


    // FIX v4: close on outside click
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: wpRoot.closeRequested()
    }
}
