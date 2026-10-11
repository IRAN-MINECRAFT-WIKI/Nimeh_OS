import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 16

    Text {
        text: "حریم خصوصی و امنیت"
        color: "#F0F4FF"
        font.family: "Vazirmatn"
        font.pixelSize: 24
        font.bold: true
    }

    Repeater {
        model: [
            { name: "دوربین", status: "مجاز", icon: "📷" },
            { name: "میکروفن", status: "مجاز", icon: "🎤" },
            { name: "موقعیت مکانی", status: "غیرفعال", icon: "📍" },
            { name: "اطلاعات تماس", status: "مجاز", icon: "📞" }
        ]

        delegate: Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            radius: 10
            color: Qt.rgba(1, 1, 1, 0.04)
            border.color: Qt.rgba(1, 1, 1, 0.06)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Text { text: modelData.icon; font.pixelSize: 22 }
                Text {
                    text: modelData.name
                    color: "#F0F4FF"
                    font.family: "Vazirmatn"
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }
                Text {
                    text: modelData.status
                    color: modelData.status === "مجاز" ? "#22D3AE" : "#7A8598"
                    font.family: "Vazirmatn"
                    font.pixelSize: 11
                }
            }
        }
    }
}
