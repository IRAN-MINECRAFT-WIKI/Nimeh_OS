// ═════════════════════════════════════════════════════════
//  NimehStartMenu — منوی Start و جستجو در یک پنجره
//  mode = "start"  → پین‌شده‌ها + پیشنهادها + پروفایل
//  mode = "search" → کادر جستجو فعال + نتایج برنامه‌ها
//  API: open, mode, closeRequested, powerRequested, lockRequested,
//       logoutRequested, allSettingsRequested
// ═════════════════════════════════════════════════════════
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: sm

    property bool open: false
    property string mode: "start"
    property string query: ""
    property var allApps: []
    readonly property var resultApps: {
        const q = query.trim().toLowerCase()
        if (q === "") return allApps.slice(0, 40)
        return allApps.filter(a => a.name.toLowerCase().indexOf(q) !== -1).slice(0, 40)
    }
    readonly property var pinnedApps: allApps.slice(0, 12)
    readonly property var recentApps: allApps.slice(12, 16)
    readonly property string userName: Quickshell.env("USER") || "user"

    signal closeRequested()
    signal powerRequested()
    signal lockRequested()
    signal logoutRequested()
    signal allSettingsRequested()

    width: 640
    height: 640

    onModeChanged: {
        query = ""
        searchInput.text = ""
        if (mode === "search") searchInput.forceActiveFocus()
    }
    onOpenChanged: {
        if (open && mode === "search") searchInput.forceActiveFocus()
        if (!open && mode === "power") mode = "start"
    }

    // ─── بدنه ───
    Rectangle {
        anchors.fill: parent
        radius: 16
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.12)
        clip: true
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.17, 0.18, 0.23, 0.94) }
            GradientStop { position: 1.0; color: Qt.rgba(0.10, 0.11, 0.15, 0.96) }
        }
        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.6; height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: Qt.rgba(0.30, 0.76, 1.0, 0.8) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 14

            // ── کادر جستجو (همیشه بالا) ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                radius: 12
                color: Qt.rgba(0, 0, 0, 0.30)
                border.width: 1
                border.color: searchInput.activeFocus ? Qt.rgba(0.30, 0.76, 1.0, 0.7) : Qt.rgba(1, 1, 1, 0.08)
                Behavior on border.color { ColorAnimation { duration: 180 } }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10
                    Text { text: "⌕"; color: "#4CC2FF"; font.pixelSize: 18 }
                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        color: "#F3F4F6"
                        font.family: "Vazirmatn"
                        font.pixelSize: 13
                        selectByMouse: true
                        onTextChanged: {
                            sm.query = text
                            if (text !== "" && sm.mode !== "search") sm.mode = "search"
                        }
                        Keys.onEscapePressed: sm.closeRequested()
                        Keys.onReturnPressed: {
                            if (sm.resultApps.length > 0) {
                                Quickshell.execDetached([sm.resultApps[0].exec])
                                sm.closeRequested()
                            }
                        }
                        Text {
                            visible: searchInput.text === ""
                            text: "جستجو در برنامه‌ها، فایل‌ها و تنظیمات..."
                            color: "#6B7280"
                            font: searchInput.font
                        }
                    }
                }
            }

            // ── حالت Start ──
            ColumnLayout {
                visible: sm.mode === "start"
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "پین‌شده"; color: "#F3F4F6"; font.family: "Vazirmatn"; font.pixelSize: 13; font.weight: Font.DemiBold }
                    Item { Layout.fillWidth: true }
                    Text { text: "همه برنامه‌ها ›"; color: "#4CC2FF"; font.family: "Vazirmatn"; font.pixelSize: 11 }
                }
                GridLayout {
                    Layout.fillWidth: true
                    columns: 6
                    rowSpacing: 6
                    columnSpacing: 6
                    Repeater {
                        model: sm.pinnedApps
                        AppTile {
                            required property var modelData
                            required property int index
                            app: modelData
                            tint: index
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "پیشنهادها"; color: "#F3F4F6"; font.family: "Vazirmatn"; font.pixelSize: 13; font.weight: Font.DemiBold }
                }
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 6
                    columnSpacing: 6
                    Repeater {
                        model: sm.recentApps
                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 46
                            radius: 10
                            color: rHover.containsMouse ? Qt.rgba(0.30, 0.76, 1.0, 0.12) : Qt.rgba(0, 0, 0, 0.15)
                            Behavior on color { ColorAnimation { duration: 140 } }
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 14
                                anchors.verticalCenter: parent.verticalCenter
                                text: parent.modelData.name
                                color: "#E5E7EB"
                                font.family: "Vazirmatn"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                width: parent.width - 28
                            }
                            MouseArea {
                                id: rHover
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: { Quickshell.execDetached([parent.modelData.exec]); sm.closeRequested() }
                            }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }

            // ── حالت Search ──
            ListView {
                visible: sm.mode === "search"
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                model: sm.resultApps
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: 46
                    radius: 10
                    color: sHover.containsMouse || index === 0 ? Qt.rgba(0.30, 0.76, 1.0, 0.14) : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 12
                        Rectangle {
                            Layout.preferredWidth: 26; Layout.preferredHeight: 26; radius: 7
                            color: ["#22D3AE", "#A78BFA", "#F59E0B", "#4CC2FF", "#F472B6", "#81C784"][index % 6]
                            Text { anchors.centerIn: parent; text: modelData.name.charAt(0); color: "#0B0D12"; font.pixelSize: 12; font.weight: Font.Bold }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            color: "#F3F4F6"
                            font.family: "Vazirmatn"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                        Text { text: "Enter"; color: "#6B7280"; font.family: "Inter"; font.pixelSize: 9; visible: index === 0 }
                    }
                    MouseArea {
                        id: sHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: { Quickshell.execDetached([modelData.exec]); sm.closeRequested() }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    visible: sm.resultApps.length === 0
                    text: "نتیجه‌ای پیدا نشد"
                    color: "#6B7280"
                    font.family: "Vazirmatn"
                    font.pixelSize: 12
                }
            }

            // ── حالت Power (داخل همان منوی Start) ──
            ColumnLayout {
                visible: sm.mode === "power"
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Rectangle {
                        width: 30; height: 30; radius: 8
                        color: backArea.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
                        Text { anchors.centerIn: parent; text: "‹"; color: "#E5E7EB"; font.pixelSize: 18 }
                        MouseArea { id: backArea; anchors.fill: parent; hoverEnabled: true; onClicked: sm.mode = "start" }
                    }
                    Text { text: "خاموش کردن"; color: "#F3F4F6"; font.family: "Vazirmatn"; font.pixelSize: 13; font.weight: Font.DemiBold }
                    Item { Layout.fillWidth: true }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 10
                    columnSpacing: 10
                    Repeater {
                        model: [
                            { label: "خواب",      glyph: "☾", cmd: ["systemctl", "suspend"],   danger: false },
                            { label: "هیبرنیت",   glyph: "⧗", cmd: ["systemctl", "hibernate"], danger: false },
                            { label: "قفل",       glyph: "⊡", cmd: ["loginctl", "lock-session"], danger: false },
                            { label: "خروج",      glyph: "⇥", cmd: ["hyprctl", "dispatch", "exit"], danger: false },
                            { label: "ری‌استارت", glyph: "↻", cmd: ["systemctl", "reboot"],    danger: true },
                            { label: "خاموش",     glyph: "⏻", cmd: ["systemctl", "poweroff"],  danger: true }
                        ]
                        Rectangle {
                            id: pBtn
                            required property var modelData
                            property bool armed: false
                            Layout.fillWidth: true
                            Layout.preferredHeight: 62
                            radius: 12
                            color: pArea.containsMouse
                                   ? (modelData.danger ? Qt.rgba(0.94, 0.27, 0.27, 0.16) : Qt.rgba(0.30, 0.76, 1.0, 0.12))
                                   : Qt.rgba(1, 1, 1, 0.06)
                            border.width: 1
                            border.color: armed ? "#EF4444" : Qt.rgba(1, 1, 1, 0.06)
                            Behavior on color { ColorAnimation { duration: 140 } }
                            Row {
                                anchors.centerIn: parent
                                spacing: 10
                                Text { text: pBtn.modelData.glyph; color: pBtn.modelData.danger ? "#FCA5A5" : "#E5E7EB"; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
                                Text {
                                    text: pBtn.armed ? "مطمئنی؟ دوباره بزن" : pBtn.modelData.label
                                    color: pBtn.armed ? "#FCA5A5" : "#E5E7EB"
                                    font.family: "Vazirmatn"
                                    font.pixelSize: 11
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                            MouseArea {
                                id: pArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    // کارهای خطرناک (ری‌استارت و خاموش) با دو کلیک انجام می‌شوند
                                    if (pBtn.modelData.danger && !pBtn.armed) { pBtn.armed = true; armReset.restart(); return }
                                    Quickshell.execDetached(pBtn.modelData.cmd)
                                    sm.closeRequested()
                                }
                            }
                            Timer {
                                id: armReset
                                interval: 3000
                                onTriggered: pBtn.armed = false
                            }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }

            // ── پروفایل و خاموش کردن ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(1, 1, 1, 0.08)
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Rectangle {
                    width: 38; height: 38; radius: 19
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#0078D4" }
                        GradientStop { position: 1.0; color: "#4CC2FF" }
                    }
                    Text { anchors.centerIn: parent; text: sm.userName.charAt(0).toUpperCase(); color: "white"; font.pixelSize: 14; font.weight: Font.Bold }
                }
                Column {
                    Text { text: sm.userName; color: "#F3F4F6"; font.family: "Inter"; font.pixelSize: 13; font.weight: Font.Medium }
                    Text { text: "کاربر"; color: "#6B7280"; font.family: "Vazirmatn"; font.pixelSize: 10 }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 38; height: 38; radius: 10
                    color: pwrArea.containsMouse ? Qt.rgba(0.94, 0.27, 0.27, 0.18) : "transparent"
                    border.width: 1
                    border.color: pwrArea.containsMouse ? Qt.rgba(0.94, 0.27, 0.27, 0.45) : "transparent"
                    Behavior on color { ColorAnimation { duration: 160 } }
                    Text { anchors.centerIn: parent; text: "⏻"; color: pwrArea.containsMouse ? "#FCA5A5" : "#E5E7EB"; font.pixelSize: 17 }
                    MouseArea { id: pwrArea; anchors.fill: parent; hoverEnabled: true; onClicked: sm.mode = "power" }
                }
            }
        }
    }

    // ─── انیمیشن باز و بسته ───
    visible: opacity > 0
    opacity: open ? 1 : 0
    scale: open ? 1 : 0.96
    transformOrigin: Item.Bottom
    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on scale   { NumberAnimation { duration: 240; easing.type: Easing.OutBack } }

    Keys.onEscapePressed: sm.closeRequested()

    // ─── کاشی برنامه (حالت Start) ───
    component AppTile: Rectangle {
        id: tile
        property var app: ({ name: "", exec: "" })
        property int tint: 0
        Layout.fillWidth: true
        Layout.preferredHeight: 84
        radius: 12
        color: tArea.containsMouse ? Qt.rgba(0.30, 0.76, 1.0, 0.12) : "transparent"
        Behavior on color { ColorAnimation { duration: 160 } }
        y: tArea.containsMouse ? -2 : 0
        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Column {
            anchors.centerIn: parent
            spacing: 8
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 36; height: 36; radius: 10
                gradient: Gradient {
                    GradientStop { position: 0.0; color: ["#22D3AE", "#A78BFA", "#F59E0B", "#4CC2FF", "#F472B6", "#81C784"][tile.tint % 6] }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.15) }
                }
                Text { anchors.centerIn: parent; text: tile.app.name.charAt(0); color: "#0B0D12"; font.family: "Inter"; font.pixelSize: 16; font.weight: Font.Bold }
            }
            Text {
                width: 84
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: tile.app.name
                color: "#E5E7EB"
                font.family: "Vazirmatn"
                font.pixelSize: 11
            }
        }
        MouseArea {
            id: tArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: { Quickshell.execDetached([tile.app.exec]); sm.closeRequested() }
        }
    }

    // ─── لیست برنامه‌ها (اسکن .desktop) ───
    Process {
        id: appScan
        command: ["sh", "-c",
            "for f in /usr/share/applications/*.desktop $HOME/.local/share/applications/*.desktop; do " +
            "[ -f \"$f\" ] || continue; " +
            "grep -q 'NoDisplay=true' \"$f\" && continue; " +
            "name=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2); " +
            "[ -z \"$name\" ] && continue; " +
            "exe=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2 | sed 's/ %.*//'); " +
            "echo \"$name|$exe\"; done | sort -u"]
        stdout: StdioCollector {
            onStreamFinished: {
                const list = []
                this.text.trim().split("\n").forEach(l => {
                    const p = l.split("|")
                    if (p.length >= 2 && p[0] && p[1]) list.push({ name: p[0], exec: p[1] })
                })
                sm.allApps = list
            }
        }
    }
    Component.onCompleted: appScan.running = true
}
