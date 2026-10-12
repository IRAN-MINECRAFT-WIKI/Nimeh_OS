import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "."

PanelWindow {
    id: diRoot
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "nimeh-desktopicons"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    signal contextMenuRequested(real x, real y)
    property var files: []
    property int selectedIndex: -1

    Process {
        id: lister
        command: ["sh","-c","ls -1 ~/Desktop 2>/dev/null | head -40"]
        stdout: StdioCollector { onStreamFinished: {
            diRoot.files = this.text.trim().split("\n").filter(f => f.length > 0)
        }}
    }
    Timer { interval: 8000; running: true; repeat: true; triggeredOnStart: true; onTriggered: lister.running = true }

    function openFile(name) {
        const path = "$HOME/Desktop/" + name
        Qt.openUrlExternally("file://" + path)
    }
    Process { id: opener }
    function openWithDolphin(path) {
        opener.command = ["dolphin", path]
        opener.running = true
    }


    MouseArea {
        anchors.fill: parent
        z: 0
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                const g = mapToItem(null, mouse.x, mouse.y)
                diRoot.contextMenuRequested(g.x, g.y)
            } else {
                diRoot.selectedIndex = -1
            }
        }
    }

    Flow {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 24
        width: Math.min(420, parent.width - 48)
        spacing: 6
        z: 1

        Repeater {
            model: diRoot.files
            delegate: Item {
                id: it
                required property string modelData
                required property int index
                width: 92
                height: 92

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: it.index === diRoot.selectedIndex
                           ? Qt.rgba(0, 120/255, 212/255, 0.30)
                           : dMa.containsMouse ? Qt.rgba(1,1,1,0.08) : "transparent"
                    border.color: it.index === diRoot.selectedIndex ? Qt.rgba(1,1,1,0.35) : "transparent"
                    border.width: 1
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    width: parent.width - 8

                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        width: 40; height: 40
                        source: {
                            const n = it.modelData
                            const base = "file://$HOME/NimehOS/shell/icons/png/"
                            if (n.endsWith(".txt")) return base + "ic_fluent_document_24_regular.png"
                            if (n.endsWith(".png") || n.endsWith(".jpg")) return base + "ic_fluent_image_24_regular.png"
                            if (n.endsWith(".sh")) return base + "ic_fluent_terminal_24_regular.png"
                            return base + "ic_fluent_folder_24_regular.png"
                        }
                        sourceSize: Qt.size(40, 40)
                        fillMode: Image.PreserveAspectFit
                    }
                    Controls.Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: it.modelData
                        color: "#F0F4FF"
                        font.family: "Vazirmatn"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }

                MouseArea {
                    id: dMa
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        diRoot.selectedIndex = it.index
                        if (mouse.button === Qt.RightButton) {
                            const g = mapToItem(null, mouse.x, mouse.y)
                            diRoot.contextMenuRequested(g.x, g.y)
                        }
                    }
                    onDoubleClicked: {
                        const n = it.modelData
                        const p = "$HOME/Desktop/" + n
                        // پوشه با دلفین، فایل با اپ پیش‌فرض
                        if (!n.includes(".")) diRoot.openWithDolphin(p)
                        else diRoot.openFile(n)
                    }
                }
            }
        }
    }
}
