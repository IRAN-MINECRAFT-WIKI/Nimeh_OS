// ═════════════════════════════════════════════════════════
//  ColorContextMenu — منوی کلیک راست با رنگ اختصاصی (مثل نمونه‌ی HTML)
//  استفاده:
//    ColorContextMenu { id: menu; accent: "#22D3AE"; title: "تسک‌بار"
//        items: [ { id: "tm", label: "مدیر وظایف", sub: "Ctrl+Shift+Esc" },
//                 { sep: true },
//                 { id: "lock", label: "قفل کردن" } ]
//        onActivated: id => ... }
//    menu.show(x, y)
// ═════════════════════════════════════════════════════════
import QtQuick
import QtQuick.Layouts

Item {
    id: cm

    property color accent: "#4CC2FF"
    property string title: ""
    property var items: []
    property bool shown: false

    signal activated(string id)
    signal dismissed()

    width: 260
    height: panel.height

    function show(px, py) {
        x = px; y = py
        shown = true
    }
    function hide() {
        shown = false
        dismissed()
    }

    visible: opacity > 0
    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.95
    transformOrigin: Item.TopLeft
    Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    Behavior on scale   { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

    Keys.onEscapePressed: cm.hide()

    Rectangle {
        id: panel
        width: parent.width
        height: col.implicitHeight + 16
        radius: 12
        border.width: 1
        border.color: Qt.rgba(cm.accent.r, cm.accent.g, cm.accent.b, 0.35)
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.17, 0.18, 0.23, 0.95) }
            GradientStop { position: 1.0; color: Qt.rgba(0.10, 0.11, 0.15, 0.97) }
        }
        clip: true

        // هاله‌ی رنگی بالا
        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.8; height: 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: cm.accent }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Column {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            anchors.topMargin: 12
            spacing: 2

            // عنوان منو با نقطه‌ی رنگی
            Row {
                visible: cm.title !== ""
                leftPadding: 10
                spacing: 8
                bottomPadding: 6
                Rectangle {
                    width: 6; height: 6; radius: 3
                    color: cm.accent
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: cm.title
                    color: cm.accent
                    font.family: "Vazirmatn"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }
            }

            Repeater {
                model: cm.items
                Loader {
                    required property var modelData
                    width: col.width
                    sourceComponent: modelData.sep === true ? sepComp : itemComp
                    property var entry: modelData
                }
            }
        }
    }

    Component {
        id: sepComp
        Rectangle {
            width: col.width
            height: 9
            color: "transparent"
            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 20; height: 1
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.12) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }
    }

    Component {
        id: itemComp
        Rectangle {
            id: row
            width: col.width
            height: 34
            radius: 7
            color: rowArea.containsMouse ? Qt.rgba(cm.accent.r, cm.accent.g, cm.accent.b, 0.16) : "transparent"
            Behavior on color { ColorAnimation { duration: 140 } }

            // نوار رنگی کنار آیتم هنگام hover
            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 3
                height: rowArea.containsMouse ? 16 : 0
                radius: 2
                color: cm.accent
                Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: row.parent.entry ? row.parent.entry.label : ""
                color: rowArea.containsMouse ? "#FFFFFF" : "#E5E7EB"
                font.family: "Vazirmatn"
                font.pixelSize: 12
            }
            Text {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: row.parent.entry && row.parent.entry.sub ? row.parent.entry.sub : ""
                color: rowArea.containsMouse ? cm.accent : "#6B7280"
                font.family: "Consolas"
                font.pixelSize: 10
            }
            MouseArea {
                id: rowArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    cm.activated(row.parent.entry.id)
                    cm.hide()
                }
            }
        }
    }
}
