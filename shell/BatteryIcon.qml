import QtQuick

// ============================================================
// BatteryIcon — آیکون باتری کشیده‌شده با QML (بدون نیاز به PNG)
// level: 0-9 (0=خالی، 9=پر)
// ============================================================

Item {
    id: batIcon
    width: 16
    height: 16
    property int level: 8
    property bool charging: false

    // رنگ بر اساس سطح
    property color iconColor: {
        if (level <= 1) return "#EF4444"    // قرمز برای بحرانی
        if (level === 2) return "#F59E0B"   // نارنجی برای پایین
        if (level >= 9) return "#22D3AE"    // سبز برای پر
        return "#F0F4FF"                     // سفید برای معمولی
    }

    // ===== بدنه باتری =====
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 3
        height: parent.height * 0.6
        radius: 2
        color: "transparent"
        border.color: batIcon.iconColor
        border.width: 1.2
    }

    // ===== دندانه باتری (سمت راست) =====
    Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: parent.height * 0.3
        radius: 1
        color: batIcon.iconColor
    }

    // ===== پرشدگی باتری =====
    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        width: (parent.width - 7) * (batIcon.level / 10)
        height: parent.height * 0.4
        radius: 1
        color: batIcon.iconColor
        visible: batIcon.level > 0

        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    // ===== آیکون شارژ (صاعقه) =====
    Text {
        anchors.centerIn: parent
        text: "⚡"
        color: "#22D3AE"
        font.pixelSize: 10
        font.family: "Vazirmatn"
        visible: batIcon.charging
    }
}
