import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: ctxRoot
    color: "transparent"
    visible: false
    WlrLayershell.namespace: "nimeh-appmenu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    property int menuX: 8
    property string appName: ""
    property string appExec: ""
    property string appProc: ""
    property bool isRunning: false
    property bool isClosing: false

    function show(name, exec, proc, running, x) {
        isClosing = false
        appName = name
        appExec = exec
        appProc = proc
        isRunning = running

        const scrW = ctxRoot.screen ? ctxRoot.screen.width : 1920
        menuX = Math.max(8, Math.min(x, scrW - 268))
        visible = true

        // انیمیشن باز: از پایین
        menu.opacity = 0
        menu.yOffset = 20
        openAnim.start()
    }

    function hide() {
        if (isClosing) return
        isClosing = true
        closeAnim.start()
    }

    // Backdrop
    MouseArea {
        anchors.fill: parent
        onClicked: ctxRoot.hide()
    }

    Rectangle {
        id: menu
        x: ctxRoot.menuX
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60 + menu.yOffset
        width: 260
        height: menuCol.height + 16
        radius: 10
        color: Qt.rgba(28/255, 28/255, 32/255, 0.98)
        border.color: Qt.rgba(1, 1, 1, 0.10)
        border.width: 1
        opacity: 0
        property real yOffset: 20

        MouseArea { anchors.fill: parent; onClicked: {} }

        Column {
            id: menuCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            spacing: 0

            Rectangle {
                width: parent.width
                height: 34
                color: "transparent"
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: ctxRoot.appName
                    color: "#0099FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 11
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width - 20
                }
            }

            Rectangle { width: parent.width; height: 1; color: Qt.rgba(1,1,1,0.06) }

            MenuItem {
                label: "پنجره جدید"
                icon: "✚"
                onClicked: {
                    if (ctxRoot.appExec && ctxRoot.appExec !== "")
                        Quickshell.execDetached([ctxRoot.appExec])
                    ctxRoot.hide()
                }
            }

            MenuItem {
                visible: ctxRoot.isRunning && ctxRoot.appProc !== "" && ctxRoot.appProc !== "quickshell"
                label: "بستن همه پنجره‌های " + ctxRoot.appName
                icon: "✕"
                danger: true
                onClicked: {
                    if (ctxRoot.appProc && ctxRoot.appProc !== "quickshell" && ctxRoot.appProc.length > 0)
                        Quickshell.execDetached(["sh","-c",
                            "pkill -x '" + ctxRoot.appProc + "' 2>/dev/null || true"])
                    ctxRoot.hide()
                }
            }

            Rectangle { width: parent.width; height: 1; color: Qt.rgba(1,1,1,0.06) }

            MenuItem {
                label: "نمایش محل فایل"
                icon: "📁"
                visible: ctxRoot.appExec !== ""
                onClicked: {
                    if (ctxRoot.appExec)
                        Quickshell.execDetached(["sh","-c",
                            "dolphin $(dirname $(which '" + ctxRoot.appExec + "' 2>/dev/null) 2>/dev/null) 2>/dev/null || true"])
                    ctxRoot.hide()
                }
            }

            MenuItem {
                label: "مشخصات"
                icon: "ℹ"
                onClicked: ctxRoot.hide()
            }

            Rectangle { width: parent.width; height: 1; color: Qt.rgba(1,1,1,0.06) }

            MenuItem {
                label: "لغو"
                icon: "✕"
                onClicked: ctxRoot.hide()
            }
        }
    }

    ParallelAnimation {
        id: openAnim
        NumberAnimation { target: menu; property: "opacity"; to: 1; duration: 180; easing.type: Easing.OutCubic }
        NumberAnimation { target: menu; property: "yOffset"; to: 0; duration: 220; easing.type: Easing.OutBack }
    }

    SequentialAnimation {
        id: closeAnim
        ParallelAnimation {
            NumberAnimation { target: menu; property: "opacity"; to: 0; duration: 150 }
            NumberAnimation { target: menu; property: "yOffset"; to: 20; duration: 180; easing.type: Easing.InCubic }
        }
        ScriptAction { script: ctxRoot.visible = false }
    }

    Shortcut {
        sequences: ["Escape"]
        onActivated: ctxRoot.hide()
    }

    component MenuItem : Rectangle {
        width: parent.width
        height: 34
        radius: 6
        color: ma.containsMouse ? Qt.rgba(1,1,1,0.06) : "transparent"
        Behavior on color { ColorAnimation { duration: 100 } }

        property string icon: ""
        property string label: ""
        property bool danger: false
        signal clicked()

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
            Text {
                text: parent.parent.icon
                color: parent.parent.danger ? "#EF4444" : "#F0F4FF"
                font.pixelSize: 13
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: parent.parent.label
                color: parent.parent.danger ? "#EF4444" : "#F0F4FF"
                font.family: "Vazirmatn"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                width: parent.width - 30
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
