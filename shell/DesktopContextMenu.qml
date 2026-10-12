import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Layouts

// ============================================================
// DesktopContextMenu — Right-click on desktop
// Feature H: Desktop Context Menu
// ============================================================

PanelWindow {
    anchors { top: true; bottom: true; left: true; right: true }
    id: cmRoot
    color: "transparent"
    WlrLayershell.namespace: "nimeh-contextmenu"
    WlrLayershell.layer: WlrLayer.Overlay

    property real menuX: 0
    property real menuY: 0

    signal closeRequested()

                function show(x, y) {
        const menuW = 250
        const menuH = Math.min(450, contentCol ? contentCol.height + 16 : 400)
        const scrW = cmRoot.screen ? cmRoot.screen.width : 1920
        const scrH = cmRoot.screen ? cmRoot.screen.height : 1080
        const taskbarH = 48
        const margin = 8
        menuX = Math.max(margin, Math.min(x, scrW - menuW - margin))
        menuY = Math.max(margin, Math.min(y, scrH - taskbarH - menuH - margin))
        visible = true
        appear.start()
    }
    function hide() {
        disappear.start()
        hideTimer.start()
    }

    // Click outside → close (left) یا reposition (right)
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                cmRoot.hide()
            } else {
                // right-click بیرون → منو رو به موقعیت جدید ببر
                cmRoot.show(mouse.x, mouse.y)
            }
        }
    }

    Rectangle {
        id: menu
        x: cmRoot.menuX
        y: cmRoot.menuY
        width: 250
        height: contentCol.height + 16
        radius: 12
        color: Qt.rgba(20/255,20/255,24/255,0.97)
        border.color: Qt.rgba(1,1,1,0.08)
        border.width: 1

        Column {
            id: contentCol
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 8
            spacing: 0

            // Section: View
            MenuSection { label: "نمایش" }
            MenuItem { icon: "ic_fluent_arrow_clockwise_24_regular.png"; text: "بازخوانی"; onClicked: { Quickshell.execDetached(["hyprctl","dispatch","forcenorender",""]); cmRoot.hide() } }
            MenuItem { icon: "ic_fluent_arrow_sort_24_regular.png"; text: "مرتب‌سازی بر اساس"; hasSubmenu: true; onClicked: cmRoot.hide() }
            MenuSeparator {}

            // Section: New
            MenuSection { label: "جدید" }
            MenuItem { icon: "ic_fluent_folder_add_24_regular.png"; text: "پوشه جدید"; onClicked: { Quickshell.execDetached(["sh","-c","mkdir -p /home/nimeh/Desktop/'New Folder'"]); cmRoot.hide() } }
            MenuItem { icon: "ic_fluent_document_add_24_regular.png"; text: "فایل متنی"; onClicked: { Quickshell.execDetached(["sh","-c","touch /home/nimeh/Desktop/newfile.txt"]); cmRoot.hide() } }
            MenuItem { icon: "ic_fluent_document_24_regular.png"; text: "سند جدید"; hasSubmenu: true; onClicked: cmRoot.hide() }
            MenuSeparator {}

            // Section: Display
            MenuSection { label: "نمایش و شخصی‌سازی" }
            MenuItem { icon: "ic_fluent_tv_24_regular.png"; text: "تنظیمات نمایش"; onClicked: { Quickshell.execDetached(["nimehos-settings","display"]); cmRoot.hide() } }
            MenuItem { icon: "ic_fluent_color_24_regular.png"; text: "شخصی‌سازی"; onClicked: { Quickshell.execDetached(["nimehos-settings","personalize"]); cmRoot.hide() } }
            MenuItem { icon: "ic_fluent_image_24_regular.png"; text: "تغییر پس‌زمینه"; onClicked: { Quickshell.execDetached(["nimehos-settings","wallpaper"]); cmRoot.hide() } }
            MenuSeparator {}

            // Section: System
            MenuSection { label: "سیستم" }
            MenuItem { icon: "ic_fluent_settings_24_regular.png"; text: "تنظیمات NimehOS"; onClicked: { Quickshell.execDetached(["/home/nimeh/.local/bin/nimehos-settings"]); cmRoot.hide() } }
            MenuItem { icon: "ic_fluent_terminal_24_regular.png"; text: "باز کردن ترمینال"; onClicked: { Quickshell.execDetached(["konsole"]); cmRoot.hide() } }
        }
    }

    component MenuItem : Rectangle {
        width: parent.width
        height: 36
        radius: 6
        color: hoverArea.containsMouse ? Qt.rgba(1,1,1,0.06) : "transparent"
        Behavior on color { ColorAnimation { duration: 100 } }

        property string icon: ""
        property string text: ""
        property bool hasSubmenu: false
        signal clicked()

        Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 10

            Image {
                source: parent.parent.icon ?
                    "file:///home/nimeh/NimehOS/shell/icons/png/" + parent.parent.icon : ""
                width: 16; height: 16
                sourceSize: Qt.size(16,16)
                anchors.verticalCenter: parent.verticalCenter
                visible: parent.parent.icon
                opacity: 0.8
            }

            Text {
                text: parent.parent.text
                color: "#F0F4FF"
                font.family: "Vazirmatn"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }

            Item { width: 1; height: 1; Layout.fillWidth: true }

            Text {
                text: parent.parent.hasSubmenu ? "›" : ""
                color: "#7A8598"
                font.family: "Vazirmatn"
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
                visible: parent.parent.hasSubmenu
            }
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component MenuSection : Text {
        width: parent.width
        height: 24
        verticalAlignment: Text.AlignVCenter
        leftPadding: 12
        text: label
        color: "#525C6E"
        font.family: "Vazirmatn"
        font.pixelSize: 10
        font.weight: Font.DemiBold
        property string label: ""
    }

    component MenuSeparator : Rectangle {
        width: parent.width
        height: 1
        color: Qt.rgba(1,1,1,0.06)
    }

    NumberAnimation { id: appear; target: menu; property: "opacity"; from: 0; to: 1; duration: 150 }
    NumberAnimation { id: appear2; target: menu; property: "scale"; from: 0.94; to: 1; duration: 150; easing.type: Easing.OutBack }
    NumberAnimation { id: disappear; target: menu; property: "opacity"; to: 0; duration: 100 }
    Timer { id: hideTimer; interval: 100; onTriggered: cmRoot.visible = false }
}
