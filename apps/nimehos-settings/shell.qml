// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// shell.qml — پنجره‌ی اصلی اپلیکیشن تنظیمات NimehOS
// ============================================================
// پنجره‌ی ۱۱۲۰×۷۲۰ با جلوه‌ی glass، titlebar ۴۶px، sidebar ۲۷۰px
// و content area با Loader. صفحه‌ها از راست با fade اسلاید می‌شوند.
//
// الگوبرداری شده از HTML reference: glass effect، rounded r-xl (24px).
// هیچ Process/execDetached استفاده نمی‌شود — تمام داده‌ها از
// Quickshell.Services (Pipewire, UPower) خوانده می‌شوند.

import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

PanelWindow {
    id: root
    color: "transparent"
    visible: true
    WlrLayershell.namespace: "nimehos-settings"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore

    // ── تمام صفحه (لایه‌ی شفاف) ──
    anchors { top: true; bottom: true; left: true; right: true }

    // ── صفحه‌ی فعلی ──
    property string currentPage: "Home"
    property bool closing: false

    // ── ۱۲ آیتم ناوبری (مطابق HTML) ──
    readonly property var navItems: [
        { page: "Home",            icon: "🏠", label: "خانه" },
        { page: "System",          icon: "💻", label: "سیستم" },
        { page: "Bluetooth",       icon: "📱", label: "بلوتوث" },
        { page: "Network",         icon: "🌐", label: "شبکه و اینترنت" },
        { page: "Personalization", icon: "🎨", label: "شخصی‌سازی" },
        { page: "Apps",            icon: "📦", label: "برنامه‌ها" },
        { page: "Accounts",        icon: "👤", label: "حساب کاربری" },
        { page: "Time",            icon: "🕐", label: "زمان و زبان" },
        { page: "Gaming",          icon: "🎮", label: "بازی" },
        { page: "Accessibility",   icon: "♿", label: "دسترسی‌پذیری" },
        { page: "Privacy",         icon: "🔒", label: "حریم خصوصی" },
        { page: "Update",          icon: "🔄", label: "به‌روزرسانی" }
    ]

    function closeWindow() {
        if (closing) return
        closing = true
        Quickshell.exit()
    }

    // ============================================================
    // لایه‌ی background: dim + پنجره‌ی شیشه‌ای مرکزی
    // ============================================================
    Item {
        anchors.fill: parent

        // ── هاله‌ی dim پشت پنجره — کلیک روی آن می‌بندد ──
        Rectangle {
            id: dimOverlay
            anchors.fill: parent
            color: SettingsTheme.dim

            MouseArea {
                anchors.fill: parent
                onClicked: root.closeWindow()
            }
        }

        // ── پنجره‌ی شیشه‌ای مرکزی ۱۱۲۰×۷۲۰ ──
        Rectangle {
            id: glassWindow
            width: SettingsTheme.windowWidth
            height: SettingsTheme.windowHeight
            anchors.centerIn: parent
            color: SettingsTheme.bgBase
            radius: SettingsTheme.rXl
            border.width: 1
            border.color: SettingsTheme.borderHi
            clip: true

            // ظاهر شیشه‌ای — rgba(255,255,255,0.12) + gradient برای عمق
            // (blur واقعی توسط Hyprland layerrule ارائه می‌شود)
            Rectangle {
                anchors.fill: parent
                color: SettingsTheme.glassBg
                radius: parent.radius
                z: -1
            }

            // ── ورودی انیمیشن پنجره ──
            Component.onCompleted: {
                glassWindow.opacity = 0
                glassWindow.scale = 0.97
                enterAnim.start()
            }

            ParallelAnimation {
                id: enterAnim
                NumberAnimation { target: glassWindow; property: "opacity"; to: 1; duration: 220; easing.type: Easing.OutCubic }
                NumberAnimation { target: glassWindow; property: "scale"; to: 1; duration: 240; easing.type: Easing.OutCubic }
            }

            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale {
                SpringAnimation { spring: 3; damping: 0.32 }
            }

            // ============================================================
            // ۱. Titlebar (۴۶px)
            // ============================================================
            Rectangle {
                id: titlebar
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: SettingsTheme.titlebarHeight
                color: Qt.rgba(0, 0, 0, 0.18)
                radius: SettingsTheme.rXl

                // گوشه‌های پایین titlebar صاف — مستطیل کوچک زیر آن
                Rectangle {
                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                    height: SettingsTheme.rXl
                    color: parent.color
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    layoutDirection: Qt.RightToLeft

                    Text {
                        text: "⚙"
                        font.pixelSize: 16
                        color: SettingsTheme.accentSoft
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "تنظیمات — NimehOS"
                        color: SettingsTheme.text
                        font.family: SettingsTheme.fontPersian
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // ── دکمه‌ی بستن ──
                Rectangle {
                    width: 30
                    height: 30
                    radius: 8
                    anchors {
                        left: parent.left
                        leftMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                    color: closeMa.containsMouse ? SettingsTheme.red : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: closeMa.containsMouse ? "#ffffff" : SettingsTheme.textDim
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: closeMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closeWindow()
                    }
                }
            }

            // ============================================================
            // ۲. بدنه: sidebar + content area
            // ============================================================
            Item {
                id: body
                anchors {
                    top: titlebar.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                // ── سایدبار ۲۷۰px ──
                Rectangle {
                    id: sidebar
                    width: SettingsTheme.sidebarWidth
                    anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                    color: Qt.rgba(0, 0, 0, 0.14)

                    Rectangle {
                        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                        width: 1
                        color: SettingsTheme.border
                    }

                    // ── جعبه‌ی جستجو ──
                    Rectangle {
                        id: searchBox
                        anchors {
                            top: parent.top
                            topMargin: 16
                            left: parent.left
                            leftMargin: 16
                            right: parent.right
                            rightMargin: 16
                        }
                        height: 36
                        radius: SettingsTheme.rSm
                        color: SettingsTheme.inputBg
                        border.width: 1
                        border.color: searchInput.activeFocus ? SettingsTheme.accent : SettingsTheme.border

                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            layoutDirection: Qt.RightToLeft

                            Text {
                                text: "🔍"
                                font.pixelSize: 12
                                color: SettingsTheme.textMute
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Controls.TextField {
                                id: searchInput
                                width: searchBox.width - 40
                                placeholderText: "جستجوی تنظیمات…"
                                color: SettingsTheme.text
                                font.family: SettingsTheme.fontPersian
                                font.pixelSize: 12
                                background: Item {}
                                verticalAlignment: Text.AlignVCenter
                                anchors.verticalCenter: parent.verticalCenter

                                Keys.onEscapePressed: focus = false
                            }
                        }
                    }

                    // ── کارت کاربر ──
                    Rectangle {
                        id: userCard
                        anchors {
                            top: searchBox.bottom
                            topMargin: 12
                            left: parent.left
                            leftMargin: 16
                            right: parent.right
                            rightMargin: 16
                        }
                        height: 58
                        radius: SettingsTheme.rMd
                        color: SettingsTheme.cardBg
                        border.width: 1
                        border.color: SettingsTheme.border

                        Row {
                            anchors.centerIn: parent
                            spacing: 10
                            layoutDirection: Qt.RightToLeft

                            Rectangle {
                                width: 36
                                height: 36
                                radius: 18
                                color: SettingsTheme.accentDeep
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "ن"
                                    color: "#ffffff"
                                    font.family: SettingsTheme.fontPersian
                                    font.pixelSize: 15
                                    font.weight: Font.DemiBold
                                }
                            }

                            Column {
                                spacing: 2
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: "کاربر NimehOS"
                                    color: SettingsTheme.text
                                    font.family: SettingsTheme.fontPersian
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                }
                                Text {
                                    text: "حساب محلی"
                                    color: SettingsTheme.textMute
                                    font.family: SettingsTheme.fontPersian
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }

                    // ── لیست ناوبری (۱۲ آیتم) ──
                    ListView {
                        id: navList
                        anchors {
                            top: userCard.bottom
                            topMargin: 10
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                            bottomMargin: 10
                        }
                        clip: true
                        model: root.navItems
                        spacing: 2
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: Rectangle {
                            width: navList.width - 24
                            height: 38
                            x: 12
                            radius: SettingsTheme.rSm
                            color: root.currentPage === modelData.page
                                   ? Qt.rgba(0.29, 0.62, 1.0, 0.18)
                                   : (navMa.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")
                            Behavior on color { ColorAnimation { duration: 120 } }

                            // نوار accent سمت راست وقتی فعال
                            Rectangle {
                                visible: root.currentPage === modelData.page
                                width: 3
                                height: 18
                                radius: 2
                                anchors {
                                    right: parent.right
                                    rightMargin: 8
                                    verticalCenter: parent.verticalCenter
                                }
                                color: SettingsTheme.accent
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 10
                                layoutDirection: Qt.RightToLeft

                                Text {
                                    text: modelData.icon
                                    font.pixelSize: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: modelData.label
                                    color: root.currentPage === modelData.page
                                           ? SettingsTheme.text
                                           : SettingsTheme.textDim
                                    font.family: SettingsTheme.fontPersian
                                    font.pixelSize: 12
                                    anchors.verticalCenter: parent.verticalCenter
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }
                            }

                            MouseArea {
                                id: navMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.currentPage = modelData.page
                            }
                        }
                    }
                }

                // ── Content area ──
                Item {
                    id: contentArea
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: sidebar.left
                    }
                    clip: true

                    // padding: 26px 32px (top/bottom 26, left/right 32)
                    Loader {
                        id: pageLoader
                        anchors.fill: parent
                        anchors.leftMargin: 32
                        anchors.rightMargin: 32
                        anchors.topMargin: 26
                        anchors.bottomMargin: 26
                        source: `pages/${root.currentPage}.qml`

                        // انیمیشن ورود صفحه: slide از راست + fade
                        onLoaded: {
                            if (item) {
                                item.x = 36
                                item.opacity = 0
                                pageEnterAnim.start()
                            }
                        }

                        ParallelAnimation {
                            id: pageEnterAnim
                            NumberAnimation {
                                target: pageLoader.item
                                property: "x"
                                from: 36; to: 0
                                duration: 280
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: pageLoader.item
                                property: "opacity"
                                from: 0; to: 1
                                duration: 280
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }
    }
}
