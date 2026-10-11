import QtQuick
import QtQuick.Layouts

ColumnLayout {
    spacing: 16

    Text {
        text: "برنامه‌ها"
        color: "#F0F4FF"
        font.family: "Vazirmatn"
        font.pixelSize: 24
        font.bold: true
    }

    Text {
        text: "برنامه‌های نصب‌شده"
        color: "#F0F4FF"
        font.family: "Vazirmatn"
        font.pixelSize: 14
        font.bold: true
    }

    Repeater {
        model: [
            { name: "Files", desc: "مدیر فایل", icon: "📁" },
            { name: "Terminal", desc: "ترمینال", icon: "⌨️" },
            { name: "Editor", desc: "ویرایشگر متن", icon: "📝" },
            { name: "Browser", desc: "مرورگر وب", icon: "🌐" },
            { name: "Settings", desc: "تنظیمات", icon: "⚙️" }
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

                Text { text: modelData.icon; font.pixelSize: 24 }

                ColumnLayout {
                    Layout.fillWidth: true
                    Text {
                        text: modelData.name
                        color: "#F0F4FF"
                        font.family: "Vazirmatn"
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Text {
                        text: modelData.desc
                        color: "#7A8598"
                        font.family: "Vazirmatn"
                        font.pixelSize: 10
                    }
                }

                Rectangle {
                    width: 70; height: 28; radius: 14
                    color: Qt.rgba(1, 1, 1, 0.06)
                    border.color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "حذف"
                        color: "#EF4444"
                        font.family: "Vazirmatn"
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
