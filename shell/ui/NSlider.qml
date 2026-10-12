import QtQuick

Item {
    id: root
    property real value: 50
    property real minValue: 0
    property real maxValue: 100
    property string icon: ""
    signal moved(real v)

    implicitWidth: 240
    implicitHeight: 32

    Row {
        anchors.fill: parent
        spacing: 10

        Image {
            visible: root.icon !== ""
            source: root.icon ? "file://$HOME/NimehOS/shell/icons/png/" + root.icon : ""
            width: 18; height: 18
            sourceSize: Qt.size(18,18)
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.8
        }

        Rectangle {
            id: track
            width: parent.width - (root.icon !== "" ? 28 : 0)
            height: 6
            radius: 3
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.rgba(1,1,1,0.10)

            Rectangle {
                width: parent.width * ((root.value - root.minValue) / (root.maxValue - root.minValue))
                height: parent.height
                radius: 3
                color: "#0099FF"
                Behavior on width { NumberAnimation { duration: 80 } }

                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: -7
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14; height: 14; radius: 7
                    color: "white"
                    border.color: Qt.rgba(0,0,0,0.2)
                    border.width: 1
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: (m) => updateVal(m.x)
                onPositionChanged: (m) => { if (pressed) updateVal(m.x) }
                function updateVal(x) {
                    const p = Math.max(0, Math.min(1, x / track.width))
                    root.value = root.minValue + p * (root.maxValue - root.minValue)
                    root.moved(root.value)
                }
            }
        }
    }
}
