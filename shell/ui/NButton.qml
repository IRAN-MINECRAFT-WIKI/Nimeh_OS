import QtQuick

Rectangle {
    id: btn
    property string text: ""
    property string icon: ""
    property bool primary: false
    property bool danger:  false
    property bool ghost:   false
    property bool small:   false
    property bool disabled: false
    signal clicked()

    implicitWidth: small ? 80 : 120
    implicitHeight: small ? 28 : 36
    radius: height / 2
    opacity: disabled ? 0.5 : 1

    color: {
        if (disabled) return Qt.rgba(1,1,1,0.04)
        if (primary)  return ma.pressed ? "#007ACC" : (ma.containsMouse ? "#00AAFF" : "#0099FF")
        if (danger)   return ma.pressed ? "#B91C1C" : (ma.containsMouse ? "#F05252" : "#EF4444")
        if (ghost)    return ma.containsMouse ? Qt.rgba(1,1,1,0.08) : "transparent"
        return ma.pressed ? Qt.rgba(1,1,1,0.16) : (ma.containsMouse ? Qt.rgba(1,1,1,0.10) : Qt.rgba(1,1,1,0.04))
    }
    border.color: ghost ? "transparent" : Qt.rgba(1,1,1,0.10)
    border.width: ghost ? 0 : 1

    Behavior on color { ColorAnimation { duration: 120 } }
    scale: ma.pressed ? 0.96 : (ma.containsMouse ? 1.03 : 1.0)
    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutBack } }

    Row {
        anchors.centerIn: parent
        spacing: 8

        Image {
            visible: btn.icon !== ""
            source: btn.icon ? "file://$HOME/NimehOS/shell/icons/png/" + btn.icon : ""
            width: 16; height: 16
            sourceSize: Qt.size(16,16)
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: btn.text
            color: btn.primary || btn.danger ? "white" : "#F0F4FF"
            font.family: "Vazirmatn"
            font.pixelSize: btn.small ? 11 : 12
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        enabled: !btn.disabled
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
