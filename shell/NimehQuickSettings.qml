// ═════════════════════════════════════════════════════════
//  NimehQuickSettings — تنظیمات سریع با اجزای مشابه ویندوز ۱۱
//  اجزا (از بالا به پایین):
//    ۱. کارت پخش‌کننده‌ی رسانه (برنامه، عنوان، کنترل‌ها)
//    ۲. شبکه‌ی کاشی‌ها (وای‌فای، بلوتوث، جلوه‌ها، پرواز، صرفه‌جویی، ...)
//    ۳. اسلایدرهای روشنایی و صدا
//    ۴. نوار پایین: وضعیت باتری و دکمه‌ی تنظیمات
//  API سازگار با shell.qml: open، closeRequested، allSettingsRequested
// ═════════════════════════════════════════════════════════
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire  // سرویس صدا (Pipewire) برای خواندن/نوشتن volume و mute
import Quickshell.Services.UPower    // سرویس باتری (UPower) برای خواندن درصد و وضعیت شارژ

Item {
    id: qs

    property bool open: false
    property bool playing: true
    property string mediaApp: "Microsoft Edge"
    property string mediaTitle: "کلاس شروع مهر ریاضی"
    property string mediaArtist: "biomaze"

    property bool wifi: true
    property bool bluetooth: true
    property bool airplane: false
    property bool nightLight: false
    property bool energySaver: false
    property bool liveCaptions: false
    property bool hotspot: false
    property bool effects: false

    property real brightness: 0.45

    // ── صدا: از Pipewire.defaultAudioSink خوانده می‌شود (به‌جای مقدار ثابت ۰.۵۵) ──
    readonly property var audioSink: Pipewire.defaultAudioSink
    readonly property real volume: audioSink?.audio?.volume ?? 0
    readonly property bool muted: audioSink?.audio?.muted ?? false

    // ── باتری: از UPower.displayDevice خوانده می‌شود (به‌جای مقدار ثابت ۹۹) ──
    readonly property bool hasBattery: UPower.displayDevice !== null
    readonly property int batteryPercent: hasBattery ? Math.round(UPower.displayDevice.percentage * 100) : -1

    signal closeRequested()
    signal allSettingsRequested()

    width: 364
    height: panel.implicitHeight

    anchors.right: parent ? parent.right : undefined
    anchors.bottom: parent ? parent.bottom : undefined
    anchors.bottomMargin: 24

    visible: opacity > 0
    opacity: open ? 1 : 0
    scale: open ? 1 : 0.96
    transformOrigin: Item.Bottom
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on scale   { NumberAnimation { duration: 240; easing.type: Easing.OutBack } }

    // ── کاشی: دکمه‌ی روشن/خاموش با فلش اختیاری برای زیرمنو ──
    component Tile: Rectangle {
        id: tile
        property string label: ""
        property string glyph: ""
        property bool on: false
        property bool hasMenu: false
        signal toggled()
        signal menuRequested()
        Layout.fillWidth: true
        Layout.preferredHeight: 72
        radius: 14
        color: tile.on ? Qt.rgba(0.0, 0.47, 0.83, 0.92) : Qt.rgba(1, 1, 1, 0.08)
        Behavior on color { ColorAnimation { duration: 160 } }

        Column {
            anchors.centerIn: parent
            width: parent.width - 16
            spacing: 6
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: tile.glyph
                color: "#FFFFFF"
                font.pixelSize: 17
            }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: tile.label
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                color: "#E5E7EB"
                font.family: "Vazirmatn"
                font.pixelSize: 10
                lineHeight: 1.1
            }
        }
        Text {
            visible: tile.hasMenu
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.top: parent.top
            anchors.topMargin: 6
            text: "›"
            color: "#9CA3AF"
            font.pixelSize: 14
            MouseArea { anchors.fill: parent; anchors.margins: -8; onClicked: tile.menuRequested() }
        }
        MouseArea {
            anchors.fill: parent
            anchors.rightMargin: tile.hasMenu ? 20 : 0
            onClicked: tile.toggled()
        }
    }

    // ── اسلایدر ──
    component Slider: RowLayout {
        id: sl
        property string glyph: ""
        property real value: 0.5
        property bool showMenu: false
        spacing: 12
        Layout.fillWidth: true
        Text { text: sl.glyph; color: "#E5E7EB"; font.pixelSize: 14; Layout.preferredWidth: 18 }
        Rectangle {
            id: track
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            radius: 3
            color: Qt.rgba(1, 1, 1, 0.22)
            Rectangle {
                width: parent.width * sl.value
                height: parent.height
                radius: 3
                color: "#4CC2FF"
            }
            Rectangle {
                x: track.width * sl.value - 9
                y: -6
                width: 18; height: 18; radius: 9
                color: "#F3F4F6"
            }
            MouseArea {
                anchors.fill: parent
                anchors.margins: -10
                onPressed: mouse => sl.value = Math.max(0, Math.min(1, (mouse.x - 10) / track.width))
                onPositionChanged: mouse => { if (pressed) sl.value = Math.max(0, Math.min(1, (mouse.x - 10) / track.width)) }
            }
        }
        Text {
            visible: sl.showMenu
            text: "›"
            color: "#9CA3AF"
            font.pixelSize: 16
            Layout.preferredWidth: 14
        }
    }

    Rectangle {
        id: panel
        width: parent.width
        implicitHeight: col.implicitHeight + 36
        radius: 16
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.10)
        color: Qt.rgba(0.13, 0.14, 0.18, 0.96)
        clip: true

        ColumnLayout {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 14

            // ── ۱. کارت رسانه ──
            Rectangle {
                visible: qs.mediaTitle !== ""
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                radius: 12
                color: Qt.rgba(1, 1, 1, 0.06)
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Rectangle { width: 16; height: 16; radius: 4; color: "#22D3AE" }
                        Text {
                            text: qs.mediaApp
                            color: "#D1D5DB"
                            font.family: "Inter"
                            font.pixelSize: 11
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Rectangle {
                            Layout.preferredWidth: 42
                            Layout.preferredHeight: 42
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.12)
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                Layout.fillWidth: true
                                text: qs.mediaTitle
                                color: "#F3F4F6"
                                font.family: "Vazirmatn"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: qs.mediaArtist
                                color: "#9CA3AF"
                                font.family: "Inter"
                                font.pixelSize: 10
                                elide: Text.ElideRight
                            }
                        }
                    }
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 26
                        Text { text: "⏮"; color: "#E5E7EB"; font.pixelSize: 16 }
                        Text {
                            text: qs.playing ? "⏸" : "▶"
                            color: "#FFFFFF"
                            font.pixelSize: 20
                            MouseArea { anchors.fill: parent; anchors.margins: -8; onClicked: qs.playing = !qs.playing }
                        }
                        Text { text: "⏭"; color: "#E5E7EB"; font.pixelSize: 16 }
                    }
                }
            }

            // ── ۲. شبکه‌ی کاشی‌ها ──
            GridLayout {
                Layout.fillWidth: true
                columns: 3
                rowSpacing: 10
                columnSpacing: 10
                Tile { label: "وای‌فای";        glyph: "⌁";  on: qs.wifi;        hasMenu: true; onToggled: qs.wifi = !qs.wifi }
                Tile { label: "بلوتوث";         glyph: "ᛒ";  on: qs.bluetooth;   hasMenu: true; onToggled: qs.bluetooth = !qs.bluetooth }
                Tile { label: "جلوه‌ها";         glyph: "✦";  on: qs.effects;     hasMenu: true; onToggled: qs.effects = !qs.effects }
                Tile { label: "حالت پرواز";     glyph: "✈";  on: qs.airplane;    onToggled: qs.airplane = !qs.airplane }
                Tile { label: "صرفه‌جویی انرژی"; glyph: "⚡"; on: qs.energySaver;  onToggled: qs.energySaver = !qs.energySaver }
                Tile { label: "دسترسی‌پذیری";   glyph: "⚲";  on: false;          hasMenu: true; onToggled: {} }
                Tile { label: "زیرنویس زنده";   glyph: "▭";  on: qs.liveCaptions; onToggled: qs.liveCaptions = !qs.liveCaptions }
                Tile { label: "روشنایی شب";     glyph: "☾";  on: qs.nightLight;  onToggled: qs.nightLight = !qs.nightLight }
                Tile { label: "اتصال موبایل";   glyph: "⊚";  on: qs.hotspot;     onToggled: qs.hotspot = !qs.hotspot }
            }

            // ── ۳. اسلایدرها ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(1, 1, 1, 0.08)
            }
            Slider { glyph: "☼"; value: qs.brightness; onValueChanged: qs.brightness = value }
            // اسلایدر صدا مستقیماً audioSink.audio.volume را در Pipewire تنظیم می‌کند
            Slider {
                glyph: qs.muted ? "🔇" : "♪"
                value: qs.muted ? 0 : qs.volume
                showMenu: true
                onValueChanged: { if (qs.audioSink) qs.audioSink.audio.volume = value }
            }

            // ── ۴. نوار پایین: باتری و تنظیمات ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(1, 1, 1, 0.08)
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                // نمایش باتری: اگر باتری یافت نشد (batteryPercent < 0) «نامشخص» نشان بده
                Text {
                    text: qs.batteryPercent < 0 ? "▮ نامشخص" : ("▮ " + qs.batteryPercent + "٪")
                    color: "#D1D5DB"
                    font.family: "Vazirmatn"
                    font.pixelSize: 11
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "⚙"
                    color: "#E5E7EB"
                    font.pixelSize: 16
                    MouseArea { anchors.fill: parent; anchors.margins: -8; onClicked: qs.allSettingsRequested() }
                }
            }
        }
    }

    Keys.onEscapePressed: qs.closeRequested()
}
