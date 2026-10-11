import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// ============================================================
// AltTabPreview — 3D card flip window switcher
// Feature J: Alt+Tab Preview
// ============================================================

PanelWindow {
    id: atRoot
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    WlrLayershell.namespace: "nimeh-alttab"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property int selectedIndex: 0
    property var windows: []

    signal closeRequested()

    function show() {
        windows = Hyprland.windows.toArray()
        if (windows.length === 0) return
        visible = true
        selectedIndex = 0
        appear.start()
    }
    function hide() {
        disappear.start()
        hideTimer.start()
    }
    function next() {
        selectedIndex = (selectedIndex + 1) % windows.length
    }
    function prev() {
        selectedIndex = (selectedIndex - 1 + windows.length) % windows.length
    }
    function activate() {
        if (windows[selectedIndex]) {
            Hyprland.dispatch("focuswindow", "address:" + windows[selectedIndex].address)
        }
        hide()
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0,0,0,0.55)
        opacity: 0
        id: backdrop

        MouseArea {
            anchors.fill: parent
            onClicked: atRoot.hide()
        }
    }

    Item {
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: 280
        opacity: 0
        id: cardRow

        // Card flow
        ListView {
            id: lv
            anchors.fill: parent
            orientation: ListView.Horizontal
            model: atRoot.windows
            spacing: 16
            clip: true

            preferredHighlightBegin: width / 2 - 100
            preferredHighlightEnd: width / 2 + 100
            highlightRangeMode: ListView.StrictlyEnforceRange
            currentIndex: atRoot.selectedIndex

            delegate: Item {
                width: 240
                height: 200
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: Qt.rgba(28/255,28/255,30/255,0.92)
                    border.color: index === atRoot.selectedIndex ? "#0099FF" : Qt.rgba(1,1,1,0.06)
                    border.width: index === atRoot.selectedIndex ? 2 : 1

                    scale: index === atRoot.selectedIndex ? 1.0 : 0.82
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                    transform: Rotation {
                        origin.x: width / 2
                        origin.y: height / 2
                        axis { x: 0; y: 1; z: 0 }
                        angle: index < atRoot.selectedIndex ? -25 : (index > atRoot.selectedIndex ? 25 : 0)
                    }

                    // Title bar
                    Rectangle {
                        id: tbar
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 30
                        radius: 14
                        color: Qt.rgba(1,1,1,0.04)

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 1
                            color: Qt.rgba(1,1,1,0.06)
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: 6
                            Rectangle { width: 8; height: 8; radius: 4; color: "#EF4444" }
                            Rectangle { width: 8; height: 8; radius: 4; color: "#F59E0B" }
                            Rectangle { width: 8; height: 8; radius: 4; color: "#22D3AE" }
                        }
                    }

                    // Live preview
                    Image {
                        anchors.top: tbar.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 1
                        source: "image://hyprland/window/" + modelData.id
                        fillMode: Image.PreserveAspectCrop
                        cache: false
                    }

                    // App name
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 8
                        text: modelData.title
                        color: "#F0F4FF"
                        font.family: "Vazirmatn"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignBottom
                    }
                }
            }
        }
    }

    // Hint text
    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80
        anchors.horizontalCenter: parent.horizontalCenter
        text: "← → برای جابه‌جایی  |  Enter برای انتخاب  |  Esc برای بستن"
        color: "#7A8598"
        font.family: "Vazirmatn"
        font.pixelSize: 11
        opacity: 0
        id: hintText
    }

    Item {
        focus: true
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Tab || event.key === Qt.Key_Right) {
                atRoot.next()
                event.accepted = true
            } else if (event.key === Qt.Key_Backtab || event.key === Qt.Key_Left) {
                atRoot.prev()
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                atRoot.activate()
                event.accepted = true
            } else if (event.key === Qt.Key_Escape) {
                atRoot.hide()
                event.accepted = true
            }
        }
    }

    ParallelAnimation {
        id: appear
        NumberAnimation { target: backdrop; property: "opacity"; to: 1; duration: 200 }
        NumberAnimation { target: cardRow; property: "opacity"; to: 1; duration: 250 }
        NumberAnimation { target: hintText; property: "opacity"; to: 1; duration: 300 }
        NumberAnimation { target: cardRow; property: "scale"; from: 0.95; to: 1; duration: 250; easing.type: Easing.OutBack }
    }
    ParallelAnimation {
        id: disappear
        NumberAnimation { target: backdrop; property: "opacity"; to: 0; duration: 150 }
        NumberAnimation { target: cardRow; property: "opacity"; to: 0; duration: 150 }
        NumberAnimation { target: hintText; property: "opacity"; to: 0; duration: 150 }
    }
    Timer { id: hideTimer; interval: 150; onTriggered: atRoot.visible = false }
}
