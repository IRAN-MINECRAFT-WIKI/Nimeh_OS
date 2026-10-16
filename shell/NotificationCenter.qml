// ═════════════════════════════════════════════════════════
//  NotificationCenter — مرکز اعلان و تقویم با انیمیشن ورود
//  side = "right"  → از لبه‌ی راست صفحه بیرون می‌آید (پیش‌فرض)
//  side = "bottom" → از لبه‌ی پایین (بالای تسک‌بار) بالا می‌آید
//  visible را shell کنترل می‌کند؛ با نمایش، انیمیشن ورود اجرا می‌شود.
// ═════════════════════════════════════════════════════════
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications  // سرویس اعلان داخلی Quickshell

PanelWindow {
    id: nc

    property string side: "right"
    property real p: 0   // ۰ = بیرون، ۱ = داخل
    signal closeRequested()

    anchors {
        top: side === "right"
        bottom: true
        right: true
    }
    margins {
        top: side === "right" ? 8 : 0
        bottom: side === "right" ? 8 : 84
        right: side === "right" ? 8 : 16
    }
    implicitWidth: side === "right" ? 380 : 420
    implicitHeight: side === "right" ? 0 : 560
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.namespace: "nimeh-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    onVisibleChanged: p = visible ? 1 : 0

    Behavior on p { NumberAnimation { duration: 320; easing.type: Easing.OutCubic } }

    Rectangle {
        id: panel
        anchors.fill: parent
        radius: 16
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.10)
        color: Qt.rgba(0.13, 0.14, 0.18, 0.96)
        clip: true

        // جهت ورود
        transform: Translate {
            x: nc.side === "right" ? (1 - nc.p) * (panel.width + 24) : 0
            y: nc.side === "bottom" ? (1 - nc.p) * (panel.height + 40) : 0
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // سرتیتر
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "اعلان‌ها"
                    color: "#F3F4F6"
                    font.family: "Vazirmatn"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }
                Item { Layout.fillWidth: true }

                // کلید «مزاحم نشو» (DND) — وضعیت از Notifications.dnd خوانده می‌شود
                Text {
                    text: nc.dnd ? "× مزاحم نشو: روشن" : "♪ مزاحم نشو: خاموش"
                    color: nc.dnd ? "#F59E0B" : "#4CC2FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 11
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        // تغییر وضعیت DND در سرویس Notifications
                        onClicked: nc.dnd = !nc.dnd
                    }
                }

                Text {
                    text: "پاک کردن همه"
                    color: "#4CC2FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 11
                    MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: nc.clearAll() }
                }
            }

            // فهرست اعلان‌های واقعی — منبع داده‌ی Notifications.tray
            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: nc.side === "bottom"
                Layout.preferredHeight: nc.side === "right" ? 260 : 0
                clip: true
                spacing: 8
                model: nc.notifications
                delegate: Rectangle {
                    // هر آیتم یک شیء Notification از Quickshell است
                    required property var modelData
                    width: list.width
                    height: 68
                    radius: 12
                    // رنگ زمینه بر اساس urgency: critical → قرمز روشن‌تر
                    color: nHover.containsMouse ? Qt.rgba(1, 1, 1, 0.10)
                          : (modelData.urgency === "critical" ? Qt.rgba(0.8, 0.2, 0.2, 0.18)
                          : Qt.rgba(1, 1, 1, 0.06))
                    Behavior on color { ColorAnimation { duration: 140 } }
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 8
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#0078D4" }
                                GradientStop { position: 1.0; color: "#4CC2FF" }
                            }
                            // حرف اول نام برنامه به‌عنوان آواتار موقت
                            Text { anchors.centerIn: parent; text: (modelData.appName || "?").charAt(0); color: "white"; font.pixelSize: 13; font.weight: Font.Bold }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { Layout.fillWidth: true; text: modelData.summary; color: "#F3F4F6"; font.family: "Vazirmatn"; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                            Text { Layout.fillWidth: true; text: modelData.body; color: "#9CA3AF"; font.family: "Vazirmatn"; font.pixelSize: 10; elide: Text.ElideRight }
                        }
                        // modelData.time یک شیء Date است — با Qt.formatTime به رشته تبدیل می‌شود
                        Text { text: modelData.time ? Qt.formatTime(modelData.time, "hh:mm") : ""; color: "#6B7280"; font.family: "Vazirmatn"; font.pixelSize: 9; Layout.alignment: Qt.AlignTop }
                    }
                    MouseArea {
                        id: nHover
                        anchors.fill: parent
                        hoverEnabled: true
                        // بستن اعلان از طریق API داخلی Notification
                        onClicked: modelData.close()
                    }
                }

                // پیام خالی‌بودن وقتی هیچ اعلانی وجود ندارد
                Text {
                    anchors.centerIn: parent
                    visible: list.count === 0
                    text: "اعلانی وجود ندارد"
                    color: "#6B7280"
                    font.family: "Vazirmatn"
                    font.pixelSize: 11
                }
            }

            // تقویم
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(1, 1, 1, 0.08)
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: nc.side === "right"
                Layout.preferredHeight: nc.side === "bottom" ? 300 : 0
                radius: 12
                color: Qt.rgba(0, 0, 0, 0.18)
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "مهر ۱۴۰۵"; color: "#F3F4F6"; font.family: "Vazirmatn"; font.pixelSize: 12; font.weight: Font.DemiBold }
                        Item { Layout.fillWidth: true }
                        Text { text: "‹  ›"; color: "#4CC2FF"; font.pixelSize: 12 }
                    }
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 7
                        rowSpacing: 4
                        columnSpacing: 4
                        Repeater {
                            model: ["ش", "ی", "د", "س", "چ", "پ", "ج"]
                            Text { Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter; text: modelData; color: "#6B7280"; font.family: "Vazirmatn"; font.pixelSize: 9 }
                        }
                        Repeater {
                            model: 35
                            Rectangle {
                                readonly property int day: index - 6
                                Layout.fillWidth: true
                                Layout.preferredHeight: 26
                                radius: 6
                                color: day === 20 ? "#0078D4" : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: parent.day > 0 && parent.day <= 31 ? parent.day : ""
                                    color: parent.day === 20 ? "#FFFFFF" : "#D1D5DB"
                                    font.family: "Vazirmatn"
                                    font.pixelSize: 10
                                    font.weight: parent.day === 20 ? Font.Bold : Font.Normal
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ==== منبع داده‌ی اعلان‌ها: سرویس داخلی Quickshell ====
    // notifications → لیست زنده‌ی اعلان‌های دریافت‌شده از D-Bus
    // dnd           → وضعیت «مزاحم نشو» (خواندنی/نوشتنی)
    // منبع داده: NotificationServer داخلی Quickshell
    // اعلان‌ها از D-Bus (org.freedesktop.Notifications) دریافت می‌شن
    property var notifications: []
    property bool dnd: false

    NotificationServer {
        id: notifServer
        actionsSupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notif => {
            notif.tracked = true
            const item = {
                appName: notif.appName || "",
                summary: notif.summary || "",
                body: notif.body || "",
                time: new Date(),
                urgency: notif.urgency || 1,
                _notif: notif
            }
            nc.notifications = [item].concat(nc.notifications)
        }
    }

    function clearAll() {
        for (const n of nc.notifications) {
            if (n._notif) n._notif.close()
        }
        nc.notifications = []
    }

    Keys.onEscapePressed: nc.closeRequested()
}
