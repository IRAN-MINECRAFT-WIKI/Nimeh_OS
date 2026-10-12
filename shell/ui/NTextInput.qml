import QtQuick

Rectangle {
    id: input
    property string placeholder: ""
    property alias text: ti.text
    property bool password: false
    property string icon: ""

    implicitWidth: 240
    implicitHeight: 36
    radius: 8
    color: Qt.rgba(28/255,28/255,30/255,0.7)
    border.color: ti.activeFocus ? "#0099FF" : Qt.rgba(1,1,1,0.08)
    border.width: 1
    Behavior on border.color { ColorAnimation { duration: 180 } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8

        Image {
            visible: input.icon !== ""
            source: input.icon ? "file:///home/nimeh/NimehOS/shell/icons/png/" + input.icon : ""
            width: 16; height: 16
            sourceSize: Qt.size(16,16)
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.65
        }

        TextInput {
            id: ti
            width: parent.width - 30
            anchors.verticalCenter: parent.verticalCenter
            color: "#F0F4FF"
            font.family: "Vazirmatn"
            font.pixelSize: 13
            selectByMouse: true
            clip: true
            echoMode: input.password ? TextInput.Password : TextInput.Normal
            verticalAlignment: TextInput.AlignVCenter

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: !ti.text && !ti.activeFocus
                text: input.placeholder
                color: "#7A8598"
                font.family: "Vazirmatn"
                font.pixelSize: 13
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        onClicked: ti.forceActiveFocus()
    }
}
