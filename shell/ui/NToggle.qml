import QtQuick

Item {
    id: root
    property bool checked: false
    property string label: ""
    signal toggled()

    implicitWidth: 200
    implicitHeight: 36

    Row {
        anchors.fill: parent
        spacing: 12

        Rectangle {
            id: track
            width: 44
            height: 24
            radius: 12
            anchors.verticalCenter: parent.verticalCenter
            color: root.checked ? "#0099FF" : Qt.rgba(1,1,1,0.10)
            Behavior on color { ColorAnimation { duration: 180 } }

            Rectangle {
                width: 18; height: 18; radius: 9
                color: "white"
                y: 3
                x: root.checked ? parent.width - width - 3 : 3
                Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
            }
        }

        Text {
            text: root.label
            color: "#F0F4FF"
            font.family: "Vazirmatn"
            font.pixelSize: 13
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: { root.checked = !root.checked; root.toggled() }
    }
}
