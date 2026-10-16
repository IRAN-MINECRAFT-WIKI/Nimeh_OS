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
//
// آیکون‌ها با Canvas کشیده می‌شوند (بدون emoji). خروج از پنجره
// با Qt.quit() انجام می‌شود (Quickshell.exit در v0.3.0 پایدار نیست).

import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Wayland

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

    // ── نام کاربر واقعی از env (با fallback) ──
    readonly property string userName: {
        const u = Quickshell.env("USER") || Quickshell.env("LOGNAME") || ""
        return u.length > 0 ? u : "کاربر NimehOS"
    }

    // ── ۱۲ آیتم ناوبری (بدون emoji — آیکون‌ها با Canvas کشیده می‌شوند) ──
    readonly property var navItems: [
        { page: "Home",            kind: "home",           label: "خانه" },
        { page: "System",          kind: "system",         label: "سیستم" },
        { page: "Bluetooth",       kind: "bluetooth",      label: "بلوتوث" },
        { page: "Network",         kind: "network",        label: "شبکه و اینترنت" },
        { page: "Personalization", kind: "personalization",label: "شخصی‌سازی" },
        { page: "Apps",            kind: "apps",           label: "برنامه‌ها" },
        { page: "Accounts",        kind: "accounts",       label: "حساب کاربری" },
        { page: "Time",            kind: "time",           label: "زمان و زبان" },
        { page: "Gaming",          kind: "gaming",         label: "بازی" },
        { page: "Accessibility",   kind: "accessibility",  label: "دسترسی‌پذیری" },
        { page: "Privacy",         kind: "privacy",        label: "حریم خصوصی" },
        { page: "Update",          kind: "update",         label: "به‌روزرسانی" }
    ]

    function closeWindow() {
        if (closing) return
        closing = true
        // Quickshell.exit() در v0.3.0 ممکن است نباشد — Qt.quit() پایدار است.
        Qt.quit()
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

                    // آیکون چرخ‌دنده — Canvas (نه emoji)
                    Canvas {
                        width: 16
                        height: 16
                        anchors.verticalCenter: parent.verticalCenter
                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.reset()
                            ctx.strokeStyle = SettingsTheme.accentSoft
                            ctx.lineWidth = 1.4
                            ctx.beginPath()
                            ctx.arc(8, 8, 3.5, 0, 2 * Math.PI)
                            ctx.stroke()
                            // دندانه‌های ساده
                            for (let i = 0; i < 8; i++) {
                                const a = (i / 8) * 2 * Math.PI
                                ctx.beginPath()
                                ctx.moveTo(8 + Math.cos(a) * 4.5, 8 + Math.sin(a) * 4.5)
                                ctx.lineTo(8 + Math.cos(a) * 7,   8 + Math.sin(a) * 7)
                                ctx.stroke()
                            }
                        }
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

                    // ضربدر — خطوط هندسی (نه glyph)
                    Canvas {
                        anchors.centerIn: parent
                        width: 12
                        height: 12
                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.reset()
                            ctx.strokeStyle = closeMa.containsMouse ? "#ffffff" : SettingsTheme.textDim
                            ctx.lineWidth = 1.6
                            ctx.lineCap = "round"
                            ctx.beginPath()
                            ctx.moveTo(2, 2); ctx.lineTo(10, 10)
                            ctx.moveTo(10, 2); ctx.lineTo(2, 10)
                            ctx.stroke()
                        }
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

                            // ذره‌بین — Canvas (نه emoji)
                            Canvas {
                                width: 14
                                height: 14
                                anchors.verticalCenter: parent.verticalCenter
                                onPaint: {
                                    const ctx = getContext("2d")
                                    ctx.reset()
                                    ctx.strokeStyle = SettingsTheme.textMute
                                    ctx.lineWidth = 1.4
                                    ctx.beginPath()
                                    ctx.arc(6, 6, 4, 0, 2 * Math.PI)
                                    ctx.stroke()
                                    ctx.beginPath()
                                    ctx.moveTo(9, 9)
                                    ctx.lineTo(13, 13)
                                    ctx.stroke()
                                }
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
                                    text: root.userName.length > 0
                                          ? root.userName.charAt(0).toUpperCase()
                                          : "ن"
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
                                    text: root.userName
                                    color: SettingsTheme.text
                                    font.family: SettingsTheme.fontPersian
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                    width: 180
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

                            // نوار accent سمت راست (start در RTL) وقتی فعال
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

                                // آیکون کشیده‌شده با Canvas (نه emoji)
                                Canvas {
                                    width: 22
                                    height: 22
                                    anchors.verticalCenter: parent.verticalCenter
                                    onPaint: {
                                        const ctx = getContext("2d")
                                        ctx.reset()
                                        const active = root.currentPage === modelData.page
                                        ctx.strokeStyle = active ? SettingsTheme.text : SettingsTheme.textDim
                                        ctx.fillStyle = active ? SettingsTheme.text : SettingsTheme.textDim
                                        ctx.lineWidth = 1.5
                                        ctx.lineCap = "round"
                                        ctx.lineJoin = "round"
                                        const k = modelData.kind
                                        if (k === "home") {
                                            ctx.beginPath()
                                            ctx.moveTo(3, 11); ctx.lineTo(11, 4); ctx.lineTo(19, 11)
                                            ctx.stroke()
                                            ctx.strokeRect(6, 10, 10, 9)
                                            ctx.fillRect(10, 14, 3, 5)
                                        } else if (k === "system") {
                                            ctx.strokeRect(3, 4, 16, 11)
                                            ctx.beginPath()
                                            ctx.moveTo(8, 19); ctx.lineTo(14, 19)
                                            ctx.moveTo(11, 15); ctx.lineTo(11, 19)
                                            ctx.stroke()
                                        } else if (k === "bluetooth") {
                                            ctx.beginPath()
                                            ctx.moveTo(8, 5); ctx.lineTo(14, 11); ctx.lineTo(8, 17); ctx.lineTo(8, 5); ctx.lineTo(14, 17)
                                            ctx.stroke()
                                        } else if (k === "network") {
                                            ctx.beginPath()
                                            ctx.arc(11, 11, 7, 0, 2 * Math.PI)
                                            ctx.stroke()
                                            ctx.beginPath()
                                            ctx.moveTo(4, 11); ctx.lineTo(18, 11)
                                            ctx.moveTo(11, 4); ctx.lineTo(11, 18)
                                            ctx.stroke()
                                        } else if (k === "personalization") {
                                            ctx.beginPath()
                                            ctx.arc(11, 11, 7, 0, 2 * Math.PI)
                                            ctx.stroke()
                                            ctx.beginPath(); ctx.arc(8, 8, 1.4, 0, 2 * Math.PI); ctx.fill()
                                            ctx.beginPath(); ctx.arc(14, 8, 1.4, 0, 2 * Math.PI); ctx.fill()
                                            ctx.beginPath(); ctx.arc(11, 14, 1.4, 0, 2 * Math.PI); ctx.fill()
                                        } else if (k === "apps") {
                                            ctx.strokeRect(4, 4, 6, 6)
                                            ctx.strokeRect(12, 4, 6, 6)
                                            ctx.strokeRect(4, 12, 6, 6)
                                            ctx.strokeRect(12, 12, 6, 6)
                                        } else if (k === "accounts") {
                                            ctx.beginPath()
                                            ctx.arc(11, 7, 3, 0, 2 * Math.PI)
                                            ctx.stroke()
                                            ctx.beginPath()
                                            ctx.arc(11, 18, 6, Math.PI, 2 * Math.PI)
                                            ctx.stroke()
                                        } else if (k === "time") {
                                            ctx.beginPath()
                                            ctx.arc(11, 11, 7, 0, 2 * Math.PI)
                                            ctx.stroke()
                                            ctx.beginPath()
                                            ctx.moveTo(11, 11); ctx.lineTo(11, 6)
                                            ctx.moveTo(11, 11); ctx.lineTo(15, 11)
                                            ctx.stroke()
                                        } else if (k === "gaming") {
                                            ctx.beginPath()
                                            ctx.moveTo(4, 9); ctx.lineTo(18, 9); ctx.lineTo(17, 17); ctx.lineTo(5, 17); ctx.closePath()
                                            ctx.stroke()
                                            ctx.beginPath(); ctx.arc(8, 13, 1.2, 0, 2 * Math.PI); ctx.fill()
                                            ctx.beginPath(); ctx.arc(14, 13, 1.2, 0, 2 * Math.PI); ctx.fill()
                                        } else if (k === "accessibility") {
                                            ctx.beginPath(); ctx.arc(11, 5, 1.8, 0, 2 * Math.PI); ctx.fill()
                                            ctx.beginPath()
                                            ctx.moveTo(4, 9); ctx.lineTo(18, 9)
                                            ctx.moveTo(11, 9); ctx.lineTo(11, 16)
                                            ctx.moveTo(7, 20); ctx.lineTo(11, 16); ctx.lineTo(15, 20)
                                            ctx.stroke()
                                        } else if (k === "privacy") {
                                            ctx.beginPath()
                                            ctx.moveTo(11, 3); ctx.lineTo(19, 6); ctx.lineTo(19, 12)
                                            ctx.quadraticCurveTo(19, 18, 11, 21)
                                            ctx.quadraticCurveTo(3, 18, 3, 12)
                                            ctx.lineTo(3, 6); ctx.closePath()
                                            ctx.stroke()
                                        } else if (k === "update") {
                                            ctx.beginPath()
                                            ctx.arc(11, 11, 6, -Math.PI / 2, Math.PI * 1.3)
                                            ctx.stroke()
                                            ctx.beginPath()
                                            ctx.moveTo(11, 3); ctx.lineTo(15, 5); ctx.lineTo(13, 8); ctx.closePath()
                                            ctx.fill()
                                        }
                                    }
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

                        // انیمیشن ورود صفحه: slide از راست + fade (۳۰۰ms)
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
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: pageLoader.item
                                property: "opacity"
                                from: 0; to: 1
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }

                        // اتصال سیگنال navigateRequested صفحه‌ها به ناوبری اصلی
                        // ignoreUnknownSignals: true — صفحاتی که این سیگنال را
                        // ندارند (مثلاً System.qml) بی‌صدا نادیده گرفته می‌شوند.
                        Connections {
                            target: pageLoader.item
                            ignoreUnknownSignals: true
                            function onNavigateRequested(page) {
                                root.currentPage = page
                            }
                        }
                    }
                }
            }
        }
    }
}
