import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: page
    property date now: new Date()
    property string timezone: ""
    property bool format24h: true

    Timer { interval: 1000; running: true; repeat: true; onTriggered: page.now = new Date() }
    Process {
        id: tzCheck
        command: ["sh", "-c", "timedatectl 2>/dev/null | grep 'Time zone' | awk '{print $3}' || echo 'unknown'"]
        stdout: StdioCollector { onStreamFinished: page.timezone = this.text.trim() }
    }
    Component.onCompleted: tzCheck.running = true

    function jalali(gy, gm, gd) {
        const g = [0,31,59,90,120,151,181,212,243,273,304,334]
        let jy = gy <= 1600 ? 0 : 979; gy -= gy <= 1600 ? 621 : 1600
        const g2 = gm > 2 ? gy + 1 : gy
        let d = 365*gy + Math.floor((g2+3)/4) - Math.floor((g2+99)/100) + Math.floor((g2+399)/400) - 80 + gd + g[gm-1]
        jy += 33*Math.floor(d/12053); d %= 12053
        jy += 4*Math.floor(d/1461); d %= 1461
        if (d > 365) { jy += Math.floor((d-1)/365); d = (d-1)%365 }
        const jm = d < 186 ? 1+Math.floor(d/31) : 7+Math.floor((d-186)/30)
        const jd = 1 + (d < 186 ? d%31 : (d-186)%30)
        const months = ["فروردین","اردیبهشت","خرداد","تیر","مرداد","شهریور","مهر","آبان","آذر","دی","بهمن","اسفند"]
        return jy + " " + months[jm-1] + " " + jd
    }
    function toFa(s) { return String(s).replace(/[0-9]/g, d => "۰۱۲۳۴۵۶۷۸۹"[+d]) }

    Column {
        anchors.fill: parent; spacing: 12
        Text { text: "زمان و زبان"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 20; weight: Font.Bold } }

        Rectangle {
            width: parent.width; height: 100; radius: 8; color: "#2A2A2A"; border { width: 1; color: "#333333" }
            Column {
                anchors { fill: parent; margins: 16 }; spacing: 6
                Text { text: "🕐 ساعت فعلی"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 13; weight: Font.Medium } }
                Text { text: toFa(Qt.formatTime(page.now, page.format24h ? "HH:mm:ss" : "h:mm:ss AP")); color: "#4CC2FF"; font { family: "Inter"; pixelSize: 24 } }
                Text { text: toFa(jalali(page.now.getFullYear(), page.now.getMonth()+1, page.now.getDate())); color: "#888888"; font { family: "Vazirmatn"; pixelSize: 12 } }
            }
        }

        Rectangle {
            width: parent.width; height: 60; radius: 8; color: "#2A2A2A"; border { width: 1; color: "#333333" }
            Row {
                anchors { fill: parent; margins: 16 }; spacing: 12
                Text { text: "منطقه‌ی زمانی"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 13; weight: Font.Medium }; anchors.verticalCenter: parent.verticalCenter }
                Text { text: page.timezone || "..."; color: "#4CC2FF"; font { family: "Inter"; pixelSize: 12 }; anchors.verticalCenter: parent.verticalCenter }
            }
        }

        Rectangle {
            width: parent.width; height: 60; radius: 8; color: "#2A2A2A"; border { width: 1; color: "#333333" }
            Row {
                anchors { fill: parent; margins: 16 }; spacing: 12
                Text { text: "فرمت ۲۴ ساعته"; color: "#FFFFFF"; font { family: "Vazirmatn"; pixelSize: 13; weight: Font.Medium }; anchors.verticalCenter: parent.verticalCenter }
                Item { width: parent.width - 200; height: parent.height }
                Rectangle {
                    width: 40; height: 20; radius: 10; anchors.verticalCenter: parent.verticalCenter
                    color: page.format24h ? "#0078D4" : "#444444"
                    Rectangle { x: page.format24h ? 22 : 2; y: 2; width: 16; height: 16; radius: 8; color: "#FFFFFF"; Behavior on x { NumberAnimation { duration: 150 } } }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: page.format24h = !page.format24h }
                }
            }
        }
    }
}
