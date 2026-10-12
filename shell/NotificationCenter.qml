import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland

// ============================================================
// NotificationCenter — Toast + Full panel with calendar
// FIX: حذف anchors از داخل Row → استفاده از RowLayout
// ============================================================

PanelWindow {
    id: ncRoot
    anchors.top: true
    anchors.right: true
    implicitWidth: 380
    implicitHeight: 600
    color: "transparent"
    WlrLayershell.namespace: "nimeh-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    property bool panelOpen: visible
    property var notifications: []

    signal closeRequested()

    function show() {
        // FIX: panelOpen now tracks `visible` so it is always in sync
        // whether we are shown via show() or via the shell.qml
        // `visible: root.notificationCenterVisible` binding.
        visible = true
        slideIn.from = ncRoot.width
        slideIn.to = 0
        slideIn.start()
    }
    function hide() {
        slideOut.from = 0
        slideOut.to = ncRoot.width
        slideOut.start()
        hideTimer.start()
    }
    function push(n) {
        notifications.unshift(n)
        if (notifications.length > 50) notifications.pop()
        ncRoot.notifications = notifications.slice()
        toastModel.append(n)
        toastTimer.restart()
    }
    function clearAll() {
        notifications = []
        toastModel.clear()
    }

    // ----- Toast area (top-right, temporary) -----
    Column {
        id: toastColumn
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.rightMargin: 8
        spacing: 8
        width: 360
        z: 100

        Repeater {
            id: toastRepeater
            model: ListModel { id: toastModel }

            delegate: Rectangle {
                width: 360
                height: contentCol.height + 24
                radius: 12
                color: Qt.rgba(20/255, 20/255, 24/255, 0.96)
                border.color: Qt.rgba(1,1,1,0.10)
                border.width: 1
                opacity: 0
                scale: 0.92

                Component.onCompleted: {
                    fadeIn.start()
                    autoDismiss.start()
                }

                SequentialAnimation { id: fadeIn
                    ParallelAnimation {
                        NumberAnimation { target: parent; property: "opacity"; to: 1; duration: 200; easing.type: Easing.OutCubic }
                        NumberAnimation { target: parent; property: "scale"; to: 1; duration: 200; easing.type: Easing.OutBack }
                    }
                }
                Timer { id: autoDismiss; interval: 4500; onTriggered: fadeOut.start() }
                SequentialAnimation { id: fadeOut
                    ParallelAnimation {
                        NumberAnimation { target: parent; property: "opacity"; to: 0; duration: 200 }
                        NumberAnimation { target: parent; property: "scale"; to: 0.92; duration: 200 }
                    }
                    ScriptAction { script: toastModel.remove(model.index) }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: "transparent"
                    border.color: model.urgency === "critical" ? "#EF4444" :
                                  model.urgency === "normal"  ? "#0099FF" : "transparent"
                    border.width: 1
                    opacity: 0.4
                }

                Column {
                    id: contentCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    anchors.top: parent.top
                    anchors.topMargin: 12
                    spacing: 4

                    // FIX: RowLayout به جای Row + anchors
                    RowLayout {
                        width: parent.width
                        spacing: 8

                        Text {
                            text: model.app || "NimehOS"
                            color: "#0099FF"
                            font.family: "Vazirmatn"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            Layout.alignment: Qt.AlignLeft
                        }
                        Item { Layout.fillWidth: true; height: 1 }
                        Text {
                            text: model.time || "اکنون"
                            color: "#7A8598"
                            font.family: "Vazirmatn"
                            font.pixelSize: 10
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                    Text {
                        width: parent.width
                        text: model.title
                        color: "#F0F4FF"
                        font.family: "Vazirmatn"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        width: parent.width
                        text: model.body
                        color: "#C4CAD6"
                        font.family: "Vazirmatn"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        fadeOut.start()
                    }
                }
            }
        }

        Timer {
            id: toastTimer
            interval: 100
        }
    }

    // ----- Full notification panel (when toggled) -----
    Rectangle {
        id: fullPanel
        anchors.fill: parent
        radius: 16
        color: Qt.rgba(12/255, 12/255, 16/255, 0.97)
        border.color: Qt.rgba(1,1,1,0.08)
        border.width: 1
        visible: ncRoot.panelOpen
        opacity: ncRoot.panelOpen ? 1 : 0
        x: ncRoot.panelOpen ? 0 : ncRoot.width

        Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            // Header — FIX: RowLayout
            RowLayout {
                width: parent.width
                spacing: 8

                Text {
                    text: "اعلان‌ها"
                    color: "#F0F4FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                }
                Item { Layout.fillWidth: true; height: 1 }
                Rectangle {
                    width: clearBtn.width + 20
                    height: 32
                    radius: 16
                    color: clearMa.containsMouse ? Qt.rgba(1,1,1,0.10) : Qt.rgba(1,1,1,0.04)
                    border.color: Qt.rgba(1,1,1,0.08)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text {
                        id: clearBtn
                        anchors.centerIn: parent
                        text: "پاک کردن همه"
                        color: "#F0F4FF"
                        font.family: "Vazirmatn"
                        font.pixelSize: 11
                    }
                    MouseArea {
                        id: clearMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ncRoot.clearAll()
                    }
                }
            }

            // Calendar
            Rectangle {
                width: parent.width
                height: 280
                radius: 12
                color: Qt.rgba(28/255, 28/255, 30/255, 0.8)
                border.color: Qt.rgba(1,1,1,0.06)
                border.width: 1

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // Month header — FIX: RowLayout
                    RowLayout {
                        width: parent.width
                        Text {
                            id: monthLabel
                            text: {
                                const d = new Date()
                                const j = Theme.jalali(d.getFullYear(), d.getMonth()+1, d.getDate())
                                return Theme.jalaliMonths[j.month-1] + " " + Theme.toFa(j.year)
                            }
                            color: "#F0F4FF"
                            font.family: "Vazirmatn"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                        }
                        Item { Layout.fillWidth: true; height: 1 }
                        Text {
                            text: "‹ ›"
                            color: "#7A8598"
                            font.family: "Vazirmatn"
                            font.pixelSize: 14
                        }
                    }

                    // Weekday header
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

                    // Days grid
                    Grid {
                        width: parent.width
                        height: parent.height - 80
                        columns: 7
                        spacing: 2

                        Repeater {
                            model: 42
                            delegate: Rectangle {
                                width: (parent.width - 12) / 7
                                height: (parent.height - 10) / 6
                                radius: 6
                                color: {
                                    const d = new Date()
                                    const j = Theme.jalali(d.getFullYear(), d.getMonth()+1, d.getDate())
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
                                        const j = Theme.jalali(d.getFullYear(), d.getMonth()+1, d.getDate())
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

            // Notifications list
            Controls.ScrollView {
                width: parent.width
                height: parent.height - 360
                clip: true

                ListView {
                    id: notifList
                    model: ncRoot.notifications
                    spacing: 8

                    delegate: Rectangle {
                        width: notifList.width
                        height: 72
                        radius: 10
                        color: Qt.rgba(28/255, 28/255, 30/255, 0.8)
                        border.color: Qt.rgba(1,1,1,0.06)
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 4

                            // FIX: RowLayout
                            RowLayout {
                                width: parent.width
                                spacing: 8
                                Text {
                                    text: modelData.app || ""
                                    color: "#0099FF"
                                    font.family: "Vazirmatn"
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                }
                                Item { Layout.fillWidth: true; height: 1 }
                                Text {
                                    text: modelData.time || ""
                                    color: "#7A8598"
                                    font.family: "Vazirmatn"
                                    font.pixelSize: 10
                                }
                            }
                            Text {
                                width: parent.width
                                text: modelData.title
                                color: "#F0F4FF"
                                font.family: "Vazirmatn"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                            }
                            Text {
                                width: parent.width
                                text: modelData.body
                                color: "#C4CAD6"
                                font.family: "Vazirmatn"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }

    NumberAnimation { id: slideIn; target: fullPanel; property: "x"; duration: 250; easing.type: Easing.OutCubic }
    NumberAnimation { id: slideOut; target: fullPanel; property: "x"; duration: 250; easing.type: Easing.InCubic }
    Timer { id: hideTimer; interval: 250; onTriggered: ncRoot.visible = false }
}
