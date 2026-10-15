// ═════════════════════════════════════════════════════════
//  NimehTaskbar — طبق نمونه‌ی HTML (کپسول ۵۶px، گوشه‌ی ۱۶، گرادیانت و هایلایت)
//  [Start] [جستجو] [نمای وظایف] | [برنامه‌ها] | [تنظیمات] [صدا] [باتری] [ساعت + تاریخ]
// ═════════════════════════════════════════════════════════
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: tb

    signal startClicked()
    signal searchClicked()
    signal clockClicked()
    signal notificationsClicked()
    signal widgetsClicked()
    signal taskViewClicked()
    signal quickSettingsClicked()
    signal appClicked(string exec)
    signal contextMenuRequested(int x, int y)
    signal appRightClicked(string name, string exec, string proc, bool running, int x, int y)
    signal aiClicked()

    readonly property int barH: 56

    readonly property int barRadius: 16

    anchors { bottom: true; left: true; right: true }
    margins.bottom: 14
    implicitHeight: barH + 14
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.namespace: "nimeh-taskbar"

    // برنامه‌های پین‌شده: رنگ اختصاصی هرکدام
    readonly property var pinned: [
        { n: "Terminal", e: "foot",             c: "#22D3AE" },
        { n: "Files",    e: "thunar",           c: "#A78BFA" },
        { n: "Settings", e: "nimehos-settings", c: "#F59E0B" }
    ]

    // ─── کپسول اصلی ───
    Rectangle {
        id: capsule
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        height: tb.barH
        width: row.implicitWidth + 28
        radius: tb.barRadius
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.10)
        clip: true

        // پس‌زمینه‌ی گرادیانتی شیشه
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.16, 0.17, 0.21, 0.82) }
            GradientStop { position: 1.0; color: Qt.rgba(0.11, 0.12, 0.16, 0.90) }
        }

        // هایلایت بالا (خط نور)
        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.7
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: Qt.rgba(0.30, 0.76, 1.0, 0.7) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 6

            // ── دکمه‌ی Start: لوگوی N (همان طرح نمونه‌ی HTML، بدون فایل عکس) ──
            Rectangle {
                id: startBtn
                Layout.preferredWidth: 46
                Layout.preferredHeight: 46
                radius: 12
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.12)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0.24, 0.27, 0.35, 0.95) }
                    GradientStop { position: 1.0; color: Qt.rgba(0.10, 0.11, 0.15, 0.98) }
                }
                scale: startArea.pressed ? 0.94 : (startArea.containsMouse ? 1.05 : 1.0)
                Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                // خط نور بالای دکمه
                Rectangle {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width * 0.6; height: 1
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: Qt.rgba(0.47, 0.76, 1.0, 0.8) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }

                // لوگوی N از مختصات SVG نمونه (viewBox 100)
                Canvas {
                    id: logoN
                    anchors.centerIn: parent
                    width: 26; height: 26
                    onPaint: {
                        var c = getContext("2d")
                        c.reset()
                        var k = width / 100
                        var g = c.createLinearGradient(0, 0, 0, height)
                        g.addColorStop(0, "#FFFFFF")
                        g.addColorStop(1, "#E5E7EB")
                        c.fillStyle = g
                        function rr(x, y, w, h, r) {
                            c.beginPath()
                            c.moveTo((x + r) * k, y * k)
                            c.lineTo((x + w - r) * k, y * k)
                            c.quadraticCurveTo((x + w) * k, y * k, (x + w) * k, (y + r) * k)
                            c.lineTo((x + w) * k, (y + h - r) * k)
                            c.quadraticCurveTo((x + w) * k, (y + h) * k, (x + w - r) * k, (y + h) * k)
                            c.lineTo((x + r) * k, (y + h) * k)
                            c.quadraticCurveTo(x * k, (y + h) * k, x * k, (y + h - r) * k)
                            c.lineTo(x * k, (y + r) * k)
                            c.quadraticCurveTo(x * k, y * k, (x + r) * k, y * k)
                            c.closePath()
                            c.fill()
                        }
                        rr(15, 12, 14, 76, 3)
                        rr(71, 12, 14, 76, 3)
                        c.beginPath()
                        c.moveTo(25 * k, 12 * k)
                        c.lineTo(39 * k, 12 * k)
                        c.lineTo(75 * k, 76 * k)
                        c.lineTo(75 * k, 88 * k)
                        c.lineTo(61 * k, 88 * k)
                        c.lineTo(25 * k, 24 * k)
                        c.closePath()
                        c.fill()
                        c.beginPath()
                        c.arc(28 * k, 14 * k, 3 * k, 0, Math.PI * 2)
                        c.fill()
                    }
                    Connections {
                        target: startArea
                        function onContainsMouseChanged() { logoN.requestPaint() }
                    }
                }
                // درخشش آبی زیر لوگو هنگام hover
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.width: 1
                    border.color: startArea.containsMouse ? Qt.rgba(0.30, 0.76, 1.0, 0.55) : "transparent"
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                }

                MouseArea {
                    id: startArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: tb.startClicked()
                }
            }

            // ── دکمه‌های آیکونی ──
            TbButton { glyph: "search";  onActivated: tb.searchClicked() }
            TbButton { glyph: "tasks";   onActivated: tb.taskViewClicked() }

            Rectangle {
                Layout.preferredWidth: 1; Layout.preferredHeight: 28
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.18) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // ── برنامه‌های پین‌شده ──
            Repeater {
                model: tb.pinned
                Rectangle {
                    id: appTile
                    required property var modelData
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    radius: 10
                    color: pinArea.containsMouse ? Qt.rgba(1, 1, 1, 0.09) : "transparent"
                    Behavior on color { ColorAnimation { duration: 200 } }

                    // آیکون رنگی با حرف اول (تا آیکون واقعی وصل شود)
                    Rectangle {
                        anchors.centerIn: parent
                        width: 26; height: 26; radius: 8
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: appTile.modelData.c }
                            GradientStop { position: 1.0; color: Qt.lighter(appTile.modelData.c, 1.35) }
                        }
                        scale: pinArea.containsMouse ? 1.12 : 1.0
                        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
                        Text {
                            anchors.centerIn: parent
                            text: appTile.modelData.n.charAt(0)
                            color: "#0B0D12"
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }
                    }

                    // نشان اجرا: خط گرادیانت با درخشش
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        width: pinArea.containsMouse ? 20 : 6
                        height: 3; radius: 2
                        color: appTile.modelData.c
                        Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        id: pinArea
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                // مختصات روی صفحه: پنجره‌ی تسک‌بار پایین صفحه است
                                var p = appTile.mapToItem(null, mouse.x, mouse.y)
                                // x و y نسبت به پنجره‌ی تسک‌بار؛ overlay خودش به صفحه تبدیل می‌کند
                                // مرکز آیکون و لبه‌ی بالای آن: منو دقیقاً بالای همین برنامه باز می‌شود
                                var c = appTile.mapToItem(null, appTile.width / 2, 0)
                                tb.appRightClicked(appTile.modelData.n, appTile.modelData.e, appTile.modelData.e, false, Math.round(c.x), Math.round(c.y))
                            } else {
                                tb.appClicked(appTile.modelData.e)
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1; Layout.preferredHeight: 28
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.18) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // ── ناحیه‌ی سیستم (تنظیمات سریع) ──
            Rectangle {
                id: tray
                Layout.preferredWidth: trayRow.implicitWidth + 20
                Layout.preferredHeight: 40
                radius: 10
                color: trayArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                border.width: 1
                border.color: trayArea.containsMouse ? Qt.rgba(0.30, 0.76, 1.0, 0.35) : "transparent"
                Behavior on border.color { ColorAnimation { duration: 200 } }

                Row {
                    id: trayRow
                    anchors.centerIn: parent
                    spacing: 12
                    Text { text: "⚙"; color: "#4CC2FF"; font.pixelSize: 15; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "♪"; color: "#A78BFA"; font.pixelSize: 15; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "▮"; color: "#22D3AE"; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea {
                    id: trayArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: tb.quickSettingsClicked()
                }
            }

            // ── ساعت و تاریخ (کلیک = مرکز اعلان و تقویم) ──
            Rectangle {
                id: clockBox
                Layout.preferredWidth: clockCol.implicitWidth + 20
                Layout.preferredHeight: 40
                radius: 10
                color: clockArea.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
                border.width: 1
                border.color: clockArea.containsMouse ? Qt.rgba(0.96, 0.45, 0.71, 0.35) : "transparent"
                Behavior on border.color { ColorAnimation { duration: 200 } }

                Column {
                    id: clockCol
                    anchors.centerIn: parent
                    spacing: 0
                    Text {
                        id: clockText
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#F472B6"
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        text: Qt.formatTime(new Date(), "HH:mm")
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#9CA3AF"
                        font.family: "Inter"
                        font.pixelSize: 10
                        text: Qt.formatDate(new Date(), "yyyy/MM/dd")
                    }
                }
                MouseArea {
                    id: clockArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: tb.notificationsClicked()
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm")
    }

    // ── دکمه‌ی آیکونی با بلور رنگی و جهش نرم ──
    component TbButton: Rectangle {
        id: btn
        property string glyph: ""
        signal activated()
        Layout.preferredWidth: 44
        Layout.preferredHeight: 44
        radius: 10
        color: btnArea.containsMouse ? Qt.rgba(1, 1, 1, 0.09) : "transparent"
        Behavior on color { ColorAnimation { duration: 200 } }
        y: btnArea.containsMouse ? -2 : 0
        Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        Canvas {
            id: cv
            anchors.centerIn: parent
            width: 20; height: 20
            onPaint: {
                var c = getContext("2d")
                c.reset()
                c.strokeStyle = "#E5E7EB"
                c.lineWidth = 1.7
                c.lineCap = "round"
                if (btn.glyph === "search") {
                    c.beginPath(); c.arc(8.5, 8.5, 6, 0, Math.PI * 2); c.stroke()
                    c.beginPath(); c.moveTo(13, 13); c.lineTo(18, 18); c.stroke()
                } else {
                    c.strokeRect(2.5, 2.5, 6, 6)
                    c.strokeRect(11.5, 2.5, 6, 6)
                    c.strokeRect(2.5, 11.5, 6, 6)
                    c.strokeRect(11.5, 11.5, 6, 6)
                }
            }
        }
        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: btn.activated()
        }
    }
}
