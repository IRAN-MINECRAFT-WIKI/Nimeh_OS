import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Layouts

// ============================================================
// AppLauncher — wofi-style launcher with Super key
// Feature K: App Launcher (Spotlight-style)
// ============================================================

PanelWindow {
    id: alRoot
    anchors.top: true
    anchors.left: true
    anchors.right: true
    margins.top: 120
    implicitWidth: 640
    implicitHeight: 500
    color: "transparent"
    WlrLayershell.namespace: "nimeh-applauncher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    signal closeRequested()
    signal launched(string exec)

    property var apps: []
    property var filteredApps: []

    function show() {
        visible = true
        searchInput.text = ""
        searchInput.forceActiveFocus()
        appear.start()
        loadApps()
    }
    function hide() {
        disappear.start()
        hideTimer.start()
    }

    function loadApps() {
        apps = []
        appLoader.running = true
    }

    Process {
        id: appLoader
        command: ["sh","-c",
          "for f in /usr/share/applications/*.desktop $HOME/.local/share/applications/*.desktop; do " +
          "name=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2); " +
          "exec=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2 | cut -d' ' -f1); " +
          "icon=$(grep -m1 '^Icon=' \"$f\" | cut -d= -f2); " +
          "nd=$(grep -m1 '^NoDisplay=true' \"$f\"); " +
          "[ -n \"$name\" ] && [ -z \"$nd\" ] && [ -n \"$exec\" ] && echo \"$name|$exec|$icon\"; " +
          "done | head -80"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parsed = []
                const lines = this.text.trim().split("\n")
                lines.forEach(l => {
                    if (!l) return
                    const pr = l.split("|")
                    if (pr.length >= 2) parsed.push({ name: pr[0], exec: pr[1], icon: pr[2] || "", nodisplay: false })
                })
                alRoot.apps = parsed
                alRoot.filteredApps = parsed
            }
        }
    }

    function filter(text) {
        if (!text) {
            filteredApps = apps.slice(0, 30)
            return
        }
        const t = text.toLowerCase()
        filteredApps = apps.filter(a =>
            a.name.toLowerCase().includes(t) ||
            (a.exec && a.exec.toLowerCase().includes(t))
        ).slice(0, 30)
    }

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: Qt.rgba(14/255,14/255,18/255,0.96)
        border.color: Qt.rgba(1,1,1,0.08)
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // Search bar
            Rectangle {
                width: parent.width
                height: 48
                radius: 12
                color: Qt.rgba(28/255,28/255,30/255,0.7)
                border.color: searchInput.activeFocus ? "#0099FF" : Qt.rgba(1,1,1,0.06)
                border.width: 1
                Behavior on border.color { ColorAnimation { duration: 180 } }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Image {
                        source: "file://$HOME/NimehOS/shell/icons/png/ic_fluent_search_24_regular.png"
                        width: 18; height: 18
                        sourceSize: Qt.size(18,18)
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: 0.6
                    }

                    TextInput {
                        id: searchInput
                        width: parent.width - 100
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#F0F4FF"
                        font.family: "Vazirmatn"
                        font.pixelSize: 14
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        clip: true
                        onTextChanged: alRoot.filter(text)
                        Keys.onEscapePressed: alRoot.hide()
                        Keys.onDownPressed: appList.incrementCurrentIndex()
                        Keys.onUpPressed: appList.decrementCurrentIndex()
                        Keys.onReturnPressed: {
                            if (appList.currentItem) {
                                launchApp(appList.currentItem.appData)
                            }
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !searchInput.text && !searchInput.activeFocus
                            text: "جستجوی برنامه..."
                            color: "#7A8598"
                            font.family: "Vazirmatn"
                            font.pixelSize: 13
                        }
                    }

                    Item { width: 1; height: 1; Layout.fillWidth: true }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Esc"
                        color: "#525C6E"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
                    }
                }
            }

            // Results list
            Controls.ScrollView {
                width: parent.width
                height: parent.height - 62
                clip: true

                ListView {
                    id: appList
                    model: alRoot.filteredApps
                    spacing: 2
                    clip: true

                    delegate: Rectangle {
                        property var appData: modelData
                        width: appList.width
                        height: 48
                        radius: 8
                        color: ListView.isCurrentItem ?
                               Qt.rgba(0,153/255,1,0.18) :
                               (itemMa.containsMouse ? Qt.rgba(1,1,1,0.06) : "transparent")
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            // App icon placeholder
                            Rectangle {
                                width: 32; height: 32
                                radius: 8
                                anchors.verticalCenter: parent.verticalCenter
                                color: Qt.rgba(1,1,1,0.06)
                                Image {
                                    anchors.centerIn: parent
                                    width: 22; height: 22
                                    source: modelData.icon ?
                                        "image://icons/" + modelData.icon : ""
                                    sourceSize: Qt.size(22,22)
                                    fillMode: Image.PreserveAspectFit
                                }
                                // Fallback letter
                                Text {
                                    anchors.centerIn: parent
                                    visible: !modelData.icon
                                    text: modelData.name ? modelData.name.charAt(0) : "?"
                                    color: "#F0F4FF"
                                    font.family: "Vazirmatn"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                Text {
                                    text: modelData.name
                                    color: "#F0F4FF"
                                    font.family: "Vazirmatn"
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    text: modelData.exec || ""
                                    color: "#7A8598"
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 10
                                }
                            }
                        }

                        MouseArea {
                            id: itemMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: launchApp(modelData)
                        }
                    }
                }
            }
        }
    }

    function launchApp(app) {
        if (!app || !app.exec) return
        Quickshell.execDetached([app.exec])
        launched(app.exec)
        alRoot.hide()
    }

    ParallelAnimation {
        id: appear
        NumberAnimation { target: alRoot; property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
        NumberAnimation { target: alRoot; property: "scale"; from: 0.95; to: 1; duration: 180; easing.type: Easing.OutBack }
    }
    ParallelAnimation {
        id: disappear
        NumberAnimation { target: alRoot; property: "opacity"; to: 0; duration: 150 }
        NumberAnimation { target: alRoot; property: "scale"; to: 0.95; duration: 150 }
    }
    Timer { id: hideTimer; interval: 150; onTriggered: alRoot.visible = false }
}
