import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

Item {
    id: page

    // ── صدا (Pipewire) ──
    readonly property var audioSink: Pipewire.defaultAudioSink
    readonly property real volume: audioSink?.audio?.volume ?? 0
    readonly property bool muted: audioSink?.audio?.muted ?? false

    // ── باتری (UPower) ──
    readonly property bool hasBattery: UPower.displayDevice !== null
    readonly property int batteryPercent: hasBattery ? Math.round(UPower.displayDevice.percentage * 100) : -1
    readonly property bool charging: hasBattery ? (UPower.displayDevice.state === 1) : false

    // ── اطلاعات سیستم ──
    property string kernelVersion: ""
    property string cpuInfo: ""
    property string ramInfo: ""
    property string diskInfo: ""

    Process {
        id: sysInfo
        command: ["sh", "-c", "echo \"$(uname -r)|$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)|$(free -h | awk '/^Mem:/{print $2}')|$(df -h / | awk 'NR==2{print $2\"/\"$4\" ($5 used)\"}')\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = page.sysInfo?.text?.trim()?.split("|") || []
                if (parts.length >= 4) {
                    page.kernelVersion = parts[0]
                    page.cpuInfo = parts[1]
                    page.ramInfo = parts[2]
                    page.diskInfo = parts[3]
                }
            }
        }
    }
    Component.onCompleted: sysInfo.running = true

    // ── روشنایی ──
    property int brightness: 80
    Process {
        id: brightRead
        command: ["sh", "-c", "brightnessctl info 2>/dev/null | grep -o '[0-9]*%' | head -1 | tr -d '%' || echo 80"]
        stdout: StdioCollector { onStreamFinished: { const v = parseInt(this.text.trim()); if (!isNaN(v)) page.brightness = v } }
    }
    function setBrightness(v) {
        brightness = v
        Quickshell.execDetached(["sh", "-c", `brightnessctl s ${v}%`])
    }

    ScrollView {
        anchors.fill: parent
        clip: true
        Column {
            width: parent.width
            spacing: 12

            // ── عنوان ──
            Text { text: "سیستم"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 20; weight: Font.Bold } }

            // ── کارت صدا ──
            Rectangle {
                width: parent.width; height: 80; radius: 8
                color: "#2A2A2A"; border { width: 1; color: "#333333" }
                Column {
                    anchors { fill: parent; margins: 16 }
                    spacing: 8
                    Text { text: "🔊 صدا"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 13; weight: Font.Medium } }
                    Row {
                        width: parent.width; spacing: 12
                        Text { text: muted ? "بی‌صدا" : Math.round(volume * 100) + "٪"; color: "#4CC2FF"; font.pixelSize: 12; width: 50 }
                        Rectangle {
                            width: parent.width - 62; height: 4; radius: 2; color: "#333333"; anchors.verticalCenter: parent.verticalCenter
                            Rectangle { width: parent.width * (muted ? 0 : volume); height: parent.height; radius: 2; color: "#0078D4" }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { const v = Math.max(0, Math.min(1, mouse.x / parent.width)); if (audioSink) audioSink.audio.volume = v }
                            }
                        }
                    }
                }
            }

            // ── کارت روشنایی ──
            Rectangle {
                width: parent.width; height: 80; radius: 8
                color: "#2A2A2A"; border { width: 1; color: "#333333" }
                Column {
                    anchors { fill: parent; margins: 16 }
                    spacing: 8
                    Text { text: "☀ روشنایی"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 13; weight: Font.Medium } }
                    Row {
                        width: parent.width; spacing: 12
                        Text { text: brightness + "٪"; color: "#4CC2FF"; font.pixelSize: 12; width: 50 }
                        Rectangle {
                            width: parent.width - 62; height: 4; radius: 2; color: "#333333"; anchors.verticalCenter: parent.verticalCenter
                            Rectangle { width: parent.width * (brightness / 100); height: parent.height; radius: 2; color: "#0078D4" }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: { const v = Math.round(Math.max(0, Math.min(100, mouse.x / parent.width * 100))); page.setBrightness(v) }
                            }
                        }
                    }
                }
            }

            // ── کارت باتری ──
            Rectangle {
                width: parent.width; height: hasBattery ? 80 : 56; radius: 8
                color: "#2A2A2A"; border { width: 1; color: "#333333" }
                Column {
                    anchors { fill: parent; margins: 16 }
                    spacing: 8
                    Text { text: "🔋 باتری"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 13; weight: Font.Medium } }
                    Text {
                        text: hasBattery ? (batteryPercent + "٪" + (charging ? " — در حال شارژ" : " — روی باتری")) : "باتری موجود نیست (دسکتاپ/VM)"
                        color: hasBattery ? (charging ? "#22D3AE" : "#FFD700") : "#666666"
                        font { family: "Vazirmatn"; pixelSize: 12 }
                    }
                }
            }

            // ── کارت اطلاعات سیستم ──
            Rectangle {
                width: parent.width; height: 180; radius: 8
                color: "#2A2A2A"; border { width: 1; color: "#333333" }
                Column {
                    anchors { fill: parent; margins: 16 }
                    spacing: 6
                    Text { text: "💻 درباره‌ی سیستم"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 13; weight: Font.Medium } }
                    InfoRow { label: "سیستم‌عامل"; value: "NimehOS (Debian Trixie)" }
                    InfoRow { label: "کرنل"; value: kernelVersion || "در حال بارگذاری..." }
                    InfoRow { label: "پردازنده"; value: cpuInfo || "..." }
                    InfoRow { label: "حافظه RAM"; value: ramInfo ? ramInfo + " کل" : "..." }
                    InfoRow { label: "دیسک"; value: diskInfo || "..." }
                }
            }
        }
    }

    component InfoRow: Row {
        width: parent.width; spacing: 8
        Text { text: label + ":"; color: "#888888"; font { family: "Vazirmatn"; pixelSize: 11 }; width: 100 }
        Text { text: value; color: "#CCCCCC"; font { family: "Vazirmatn"; pixelSize: 11 }; wrapMode: Text.WordWrap; width: parent.width - 108 }
    }
}
