// ═════════════════════════════════════════════════════════
//  WidgetsPanel — پنل ویجت‌ها، از پایین (بالای تسک‌بار) بالا می‌آید
//  کارت‌ها: آب‌وهوا، ساعت و تاریخ، منابع سیستم
//  API سازگار با shell.qml: visible (از shell)، closeRequested()
// ═════════════════════════════════════════════════════════
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: wp

    property real p: 0
    signal closeRequested()

    anchors { bottom: true; left: true }
    margins { bottom: 84; left: 16 }
    implicitWidth: 380
    implicitHeight: 560
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.namespace: "nimeh-widgets"
    WlrLayershell.layer: WlrLayer.Overlay

    onVisibleChanged: p = visible ? 1 : 0
    Behavior on p { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

    // زمان زنده
    property date now: new Date()
    Timer {
        interval: 1000; running: wp.visible; repeat: true
        onTriggered: wp.now = new Date()
    }

    component Card: Rectangle {
        default property alias content: holder.data
        Layout.fillWidth: true
        radius: 14
        color: Qt.rgba(1, 1, 1, 0.06)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.07)
        Item { id: holder; anchors.fill: parent; anchors.margins: 14 }
    }

    component Bar: RowLayout {
        property string label: ""
        property real value: 0
        property color tint: "#4CC2FF"
        Layout.fillWidth: true
        spacing: 10
        Text { text: parent.label; color: "#9CA3AF"; font.family: "Vazirmatn"; font.pixelSize: 10; Layout.preferredWidth: 34 }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            radius: 3
            color: Qt.rgba(1, 1, 1, 0.12)
            Rectangle {
                width: parent.width * parent.parent.value
                height: parent.height
                radius: 3
                color: parent.parent.tint
            }
        }
        Text { text: Math.round(parent.value * 100) + "٪"; color: "#D1D5DB"; font.family: "Vazirmatn"; font.pixelSize: 10; Layout.preferredWidth: 34; horizontalAlignment: Text.AlignRight }
    }

    Rectangle {
        id: panel
        anchors.fill: parent
        radius: 16
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.10)
        color: Qt.rgba(0.13, 0.14, 0.18, 0.96)
        clip: true

        // ورود از پایین
        transform: Translate { y: (1 - wp.p) * (panel.height + 40) }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // آب‌وهوا
            Card {
                Layout.preferredHeight: 110
                RowLayout {
                    anchors.fill: parent
                    spacing: 14
                    Text { text: "☀"; color: "#FCD34D"; font.pixelSize: 40 }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: "۲۴°"; color: "#F3F4F6"; font.family: "Inter"; font.pixelSize: 30; font.weight: Font.Light }
                        Text { text: "آفتابی"; color: "#D1D5DB"; font.family: "Vazirmatn"; font.pixelSize: 11 }
                        Text { text: "تهران"; color: "#6B7280"; font.family: "Vazirmatn"; font.pixelSize: 10 }
                    }
                }
            }

            // ساعت و تاریخ
            Card {
                Layout.preferredHeight: 92
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 4
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatTime(wp.now, "HH:mm:ss")
                        color: "#F3F4F6"
                        font.family: "Inter"
                        font.pixelSize: 30
                        font.weight: Font.Light
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(wp.now, "dddd, yyyy/MM/dd")
                        color: "#9CA3AF"
                        font.family: "Vazirmatn"
                        font.pixelSize: 11
                    }
                }
            }

            // منابع سیستم (مقادیر نمونه؛ بعداً از سرویس خوانده می‌شوند)
            Card {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12
                    Text { text: "منابع سیستم"; color: "#F3F4F6"; font.family: "Vazirmatn"; font.pixelSize: 12; font.weight: Font.DemiBold }
                    Bar { label: "CPU";  value: 0.32; tint: "#4CC2FF" }
                    Bar { label: "RAM";  value: 0.48; tint: "#22D3AE" }
                    Bar { label: "دیسک"; value: 0.65; tint: "#A78BFA" }
                    Item { Layout.fillHeight: true }
                }
            }
        }
    }

    Keys.onEscapePressed: wp.closeRequested()
}
