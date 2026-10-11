// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// NimehStartMenu.qml — منوی استارت NimehOS (نسخه بازسازی‌شده)
// ============================================================
//
// این فایل منوی استارت به‌سبک ویندوز ۱۱ (۶۴۰×۷۰۰ پیکسل، پایین-مرکز صفحه)
// را بازسازی می‌کند. تمام رنگ‌ها، توکن‌های انیمیشن، پس‌زمینه شیشه‌ای و
// لایه‌ی تعامل از سینگلتون‌های ماژول NimehOS تأمین می‌شوند:
//
//   - Theme.qml        → رنگ‌ها (پالت M3، semantic، توکن‌های فاصله/شعاع)
//   - Animations.qml   → duration و easing tokens
//   - GlassPanel.qml   → پس‌زمینه آکریلیک با gradient و shadow
//   - StateLayer.qml   → لایه‌ی تعامل Material 3 با ripple و hover/press
//
// ساختار کلی:
//   ┌─────────────────────────────────────┐
//   │  🔍 جستجوی برنامه‌ها و فایل‌ها       │  ← نوار جستجو
//   ├─────────────────────────────────────┤
//   │  پین‌شده                              │
//   │  ┌──┬──┬──┬──┬──┬──┐               │
//   │  │📁│🌐│⌨│✏│⚙│🧮│  (۶ ستون)        │
//   │  ├──┼──┼──┼──┼──┼──┤               │
//   │  │📷│🎵│📧│🗺│🎥│●│                  │
//   │  └──┴──┴──┴──┴──┴──┘               │
//   ├─────────────────────────────────────┤
//   │  پیشنهادها                           │
//   │  [recent file 1]                    │
//   │  [recent file 2]                    │
//   ├─────────────────────────────────────┤
//   │  [👤 nimeh]              [⏻]        │  ← کاربر + power
//   └─────────────────────────────────────┘
//
// تفاوت‌ها با نسخه قبلی (NimehOS_final/shell/NimehStartMenu.qml):
//   - حذف کامل رنگ‌های هاردکد (تمام رنگ‌ها از Theme)
//   - حذف اعداد هاردکد انیمیشن (تمام duration/easing از Animations)
//   - استفاده از GlassPanel به‌جای Rectangle دستی برای پس‌زمینه
//   - استفاده از StateLayer به‌جای Rectangle hover/press دستی
//   - استفاده از ColumnLayout/RowLayout به‌جای Column/Row + anchors
//   - انیمیشن باز/بسته شدن با states + transitions (medium03/emphasize و medium02/decelerate)
//   - بخش «پیشنهادها» اضافه شده (placeholder فایل‌های اخیر)
//   - راست‌کلیک روی آیتم پین‌شده → Controls.Menu با Pin/Unpin/Open/Properties
//   - توضیحات فارسی سراسری و doc comment بالای فایل
//
// سیگنال‌ها:
//   closeRequested() powerRequested() lockRequested() logoutRequested()

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Io

Item {
    id: sm

    // ============================================================
    // ۱. ابعاد و رابط عمومی
    // ============================================================
    width: 640
    height: 700

    signal closeRequested()
    signal powerRequested()
    signal lockRequested()
    signal logoutRequested()

    // پرچم باز/بسته بودن منو — والد (shell.qml) این را set می‌کند.
    property bool open: false

    // پیشوند مسیر آیکون‌ها.
    readonly property string ib: "file:///home/nimeh/NimehOS/shell/icons/png/"

    // ============================================================
    // ۲. وضعیت داخلی (جستجو و همه‌ی برنامه‌ها)
    // ============================================================
    // allApps: لیست کامل برنامه‌ها از فایل‌های desktop
    property var allApps: []
    // shownApps: نتیجه‌ی جستجو (وقتی query خالی است، از pinnedGrid استفاده می‌کنیم)
    property var shownApps: []
    property string query: ""

    // لیست برنامه‌های پین‌شده (۱۲ برنامه برای گرید ۶×۲)
    readonly property var pinnedApps: [
        { n: "فایل‌ها",    i: "ic_fluent_folder_24_regular.png",     e: "dolphin" },
        { n: "مرورگر",     i: "ic_fluent_globe_24_regular.png",      e: "firefox" },
        { n: "ترمینال",    i: "ic_fluent_edit_24_regular.png",       e: "konsole" },
        { n: "ویرایشگر",   i: "ic_fluent_pen_24_regular.png",        e: "kate" },
        { n: "تنظیمات",    i: "ic_fluent_settings_24_regular.png",   e: "/home/nimeh/.local/bin/nimehos-settings" },
        { n: "ماشین‌حساب", i: "ic_fluent_calculator_24_regular.png", e: "kcalc" },
        { n: "تصویر",      i: "ic_fluent_image_24_regular.png",      e: "gwenview" },
        { n: "موسیقی",     i: "ic_fluent_music_24_regular.png",      e: "elisa" },
        { n: "پست",        i: "ic_fluent_mail_24_regular.png",       e: "thunderbird" },
        { n: "دوربین",     i: "ic_fluent_camera_24_regular.png",     e: "cheese" },
        { n: "آرشیو",      i: "ic_fluent_folder_add_24_regular.png", e: "ark" },
        { n: "سیستم",      i: "ic_fluent_settings_24_regular.png",   e: "kinfocenter" }
    ]

    // فایل‌های اخیر (placeholder — در آینده از یک سرویس فایل‌های اخیر پر شود)
    readonly property var recommendedFiles: [
        { n: "گزارش-فصلی.pdf",      d: "۲ ساعت پیش" },
        { n: "یادداشت-جلسه.md",     d: "دیروز" },
        { n: "پروژه-نهایی.qml",     d: "۳ روز پیش" }
    ]

    // ============================================================
    // ۳. انیمیشن باز/بسته شدن
    // ============================================================
    // باز شدن: fade + slide up از پایین، medium03 (۳۵۰ms)، emphasize
    // بسته شدن: fade + slide down، medium02 (۳۰۰ms)، decelerate
    states: [
        State {
            name: "open"
            when: sm.open
            PropertyChanges {
                target: sm
                opacity: 1.0
                y: 0
            }
        },
        State {
            name: "closed"
            when: !sm.open
            PropertyChanges {
                target: sm
                opacity: 0.0
                y: 40
            }
        }
    ]
    transitions: [
        Transition {
            from: "closed"; to: "open"
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    duration: Animations.medium03
                    easing.type: Animations.emphasize
                    easing.overshoot: Animations.emphasizeOvershoot
                }
                NumberAnimation {
                    property: "y"
                    duration: Animations.medium03
                    easing.type: Animations.emphasize
                    easing.overshoot: Animations.emphasizeOvershoot
                }
            }
        },
        Transition {
            from: "open"; to: "closed"
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    duration: Animations.medium02
                    easing.type: Animations.decelerate
                }
                NumberAnimation {
                    property: "y"
                    duration: Animations.medium02
                    easing.type: Animations.decelerate
                }
            }
        }
    ]

    // ============================================================
    // ۴. پس‌زمینه شیشه‌ای (GlassPanel)
    // ============================================================
    // tintOpacity=0.96 برای منو، چون نیاز به کنتراست بالا روی محتوا داریم.
    // elevation=3 برای سایه‌ی مشخص (مطابق M3 level 3 dialog).
    GlassPanel {
        id: bg
        anchors.fill: parent
        radius: Theme.radiusXl
        tintOpacity: 0.96
        blurEnabled: true
        elevation: 3
        shadowEnabled: true
    }

    // ============================================================
    // ۵. محتوای اصلی (ColumnLayout)
    // ============================================================
    ColumnLayout {
        id: rootLayout
        anchors.fill: parent
        anchors.margins: Theme.spacingLg
        spacing: Theme.spacingMd

        // ====================================================
        // ۵.۱. نوار جستجو
        // ====================================================
        Rectangle {
            id: searchBar
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            radius: Theme.radiusLg
            color: Theme.surface
            border.color: searchInput.activeFocus ? Theme.accent : Theme.border
            border.width: 1

            // تغییر رنگ حاشیه هنگام focus (با ColorAnimation)
            Behavior on border.color {
                ColorAnimation {
                    duration: Animations.colorAnim(Animations.fast02).duration
                    easing.type: Animations.smooth
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingMd
                anchors.rightMargin: Theme.spacingMd
                spacing: Theme.spacingSm

                Image {
                    Layout.preferredWidth: 18
                    Layout.preferredHeight: 18
                    source: sm.ib + "ic_fluent_search_24_regular.png"
                    sourceSize: Qt.size(18, 18)
                    opacity: 0.7
                }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    color: Theme.text
                    font.family: Theme.fontPersian
                    font.pixelSize: 13
                    clip: true
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true

                    onTextChanged: {
                        sm.query = text
                        sm.updateShown()
                    }
                    onAccepted: {
                        if (sm.shownApps.length > 0) {
                            Quickshell.execDetached([sm.shownApps[0].exec])
                            sm.closeRequested()
                        }
                    }
                    Keys.onEscapePressed: sm.closeRequested()

                    // متن placeholder فارسی
                    Text {
                        visible: !searchInput.text && !searchInput.activeFocus
                        text: "جستجوی برنامه‌ها و فایل‌ها"
                        color: Theme.textMuted
                        font.family: Theme.fontPersian
                        font.pixelSize: 13
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // کلیک روی نوار جستجو → focus به input
            MouseArea {
                anchors.fill: parent
                onPressed: mouse => {
                    searchInput.forceActiveFocus()
                    mouse.accepted = false  // بگذار TextInput هم دریافت کند
                }
            }
        }

        // ====================================================
        // ۵.۲. محتوای گرید/لیست (پین‌شده یا نتایج جستجو)
        // ====================================================
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // ---- حالت پیش‌فرض: گرید پین‌شده + پیشنهادها ----
            visible: sm.query.length === 0

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacingSm

                // هدر «پین‌شده»
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "پین‌شده"
                        color: Theme.text
                        font.family: Theme.fontPersian
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }
                    Item { Layout.fillWidth: true }
                }

                // گرید ۶ ستونه
                GridLayout {
                    id: pinnedGrid
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220
                    columns: 6
                    rowSpacing: Theme.spacingXs
                    columnSpacing: Theme.spacingXs

                    Repeater {
                        model: sm.pinnedApps
                        delegate: pinnedAppTile
                    }
                }

                // هدر «پیشنهادها»
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.spacingSm
                    Text {
                        text: "پیشنهادها"
                        color: Theme.text
                        font.family: Theme.fontPersian
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                    }
                    Item { Layout.fillWidth: true }
                }

                // لیست فایل‌های اخیر (placeholder)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Theme.spacingXs

                    Repeater {
                        model: sm.recommendedFiles
                        delegate: Rectangle {
                            id: recItem
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            radius: Theme.radiusMd
                            color: recLayer.containsMouse
                                   ? Theme.surfaceHover
                                   : "transparent"
                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.colorAnim(Animations.fast02).duration
                                    easing.type: Animations.smooth
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacingSm
                                anchors.rightMargin: Theme.spacingSm
                                spacing: Theme.spacingSm

                                Image {
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 20
                                    source: sm.ib + "ic_fluent_document_24_regular.png"
                                    sourceSize: Qt.size(20, 20)
                                    opacity: 0.7
                                }
                                Text {
                                    text: recItem.modelData.n
                                    color: Theme.text
                                    font.family: Theme.fontPersian
                                    font.pixelSize: 12
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: recItem.modelData.d
                                    color: Theme.textMuted
                                    font.family: Theme.fontPersian
                                    font.pixelSize: 11
                                }
                            }

                            StateLayer {
                                id: recLayer
                                color: Theme.text
                                rippleEnabled: true
                                onClicked: mouse => { /* باز کردن فایل در آینده */ }
                            }
                        }
                    }
                }
            }
        }

        // ====================================================
        // ۵.۳. حالت جستجو (ListView نتایج)
        // ====================================================
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: sm.query.length > 0

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacingSm

                Text {
                    Layout.fillWidth: true
                    text: "نتایج جستجو (" + Theme.toFa(sm.shownApps.length) + ")"
                    color: Theme.text
                    font.family: Theme.fontPersian
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }

                Controls.ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ListView {
                        id: resultsList
                        model: sm.shownApps
                        clip: true
                        spacing: Theme.spacingXs

                        delegate: Rectangle {
                            id: resultRow
                            required property var modelData
                            width: resultsList.width
                            height: 44
                            radius: Theme.radiusMd
                            color: resultLayer.containsMouse
                                   ? Theme.surfaceHover
                                   : "transparent"
                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.colorAnim(Animations.fast02).duration
                                    easing.type: Animations.smooth
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacingSm
                                anchors.rightMargin: Theme.spacingSm
                                spacing: Theme.spacingSm

                                Image {
                                    Layout.preferredWidth: 26
                                    Layout.preferredHeight: 26
                                    source: sm.iconFor(resultRow.modelData)
                                    sourceSize: Qt.size(26, 26)
                                }
                                Text {
                                    text: resultRow.modelData.name
                                    color: Theme.text
                                    font.family: Theme.fontPersian
                                    font.pixelSize: 13
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }

                            StateLayer {
                                id: resultLayer
                                color: Theme.text
                                rippleEnabled: true
                                onClicked: mouse => {
                                    Quickshell.execDetached([resultRow.modelData.exec])
                                    sm.closeRequested()
                                }
                            }
                        }
                    }
                }
            }
        }

        // ====================================================
        // ۵.۴. فوتر (کاربر + power)
        // ====================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            radius: Theme.radiusLg
            color: Theme.withAlpha(Theme.surface, 0.5)
            border.color: Theme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingMd
                anchors.rightMargin: Theme.spacingMd
                spacing: Theme.spacingSm

                // ---- کاربر (چپ) ----
                // Rectangle (نه Item) تا StateLayer بتواند radius را از parent بخواند.
                Rectangle {
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignVCenter
                    radius: Theme.radiusPill
                    color: "transparent"
                    border.width: 0

                    Row {
                        anchors.centerIn: parent
                        spacing: Theme.spacingSm

                        // آواتار: دایره با حاشیه accent و حرف «ن»
                        Rectangle {
                            width: 28; height: 28
                            radius: width / 2
                            color: Theme.accent
                            border.color: Theme.withAlpha(Theme.text, 0.20)
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: "ن"
                                color: Theme.textOnAccent
                                font.family: Theme.fontPersian
                                font.pixelSize: 13
                                font.weight: Font.Bold
                            }
                        }
                        Text {
                            text: "nimeh"
                            color: Theme.text
                            font.family: Theme.fontPersian
                            font.pixelSize: 13
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    StateLayer {
                        color: Theme.text
                        rippleEnabled: true
                        onClicked: mouse => sm.logoutRequested()
                    }
                }

                // فاصله‌ساز
                Item { Layout.fillWidth: true }

                // ---- دکمه قفل (راست، کنار power) ----
                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignVCenter
                    radius: Theme.radiusMd
                    color: "transparent"
                    border.width: 0

                    Image {
                        anchors.centerIn: parent
                        width: 18; height: 18
                        source: sm.ib + "ic_fluent_lock_24_regular.png"
                        sourceSize: Qt.size(18, 18)
                        opacity: lockLayer.containsMouse ? 1.0 : 0.85
                        Behavior on opacity {
                            NumberAnimation {
                                duration: Animations.fast02
                                easing.type: Animations.smooth
                            }
                        }
                    }

                    StateLayer {
                        id: lockLayer
                        color: Theme.text
                        rippleEnabled: true
                        onClicked: mouse => sm.lockRequested()
                    }
                }

                // ---- دکمه power (راست) ----
                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignVCenter
                    radius: Theme.radiusMd
                    color: "transparent"
                    border.width: 0

                    Image {
                        anchors.centerIn: parent
                        width: 18; height: 18
                        source: sm.ib + "ic_fluent_power_24_regular.png"
                        sourceSize: Qt.size(18, 18)
                        // hover → رنگ danger (قرمز)
                        opacity: powerLayer.containsMouse ? 1.0 : 0.85
                        Behavior on opacity {
                            NumberAnimation {
                                duration: Animations.fast02
                                easing.type: Animations.smooth
                            }
                        }
                    }

                    // overlay رنگی برای حالت hover (قرمز)
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: Theme.danger
                        opacity: powerLayer.containsMouse ? 0.15 : 0.0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: Animations.colorAnim(Animations.fast02).duration
                                easing.type: Animations.smooth
                            }
                        }
                        z: -1  // زیر آیکون
                    }

                    StateLayer {
                        id: powerLayer
                        color: Theme.danger
                        rippleEnabled: true
                        onClicked: mouse => sm.powerRequested()
                    }
                }
            }
        }
    }

    // ============================================================
    // ۶. delegate تایل برنامه‌ی پین‌شده (گرید)
    // ============================================================
    // هر تایل ۶۴×۶۴ آیکون + برچسب زیر، با:
    //   - scale: 1.0 → 1.06 (hover)
    //   - StateLayer برای hover/press/ripple
    //   - راست‌کلیک → Controls.Menu (Pin/Unpin/Open/Properties)
    Component {
        id: pinnedAppTile

        Item {
            id: tile
            required property var modelData
            Layout.fillWidth: true
            Layout.preferredHeight: 96

            // scale پویا بر اساس hover/press
            scale: tileLayer.pressed ? 0.92
                                    : (tileLayer.containsMouse ? 1.06 : 1.0)
            Behavior on scale {
                NumberAnimation {
                    duration: Animations.medium02
                    easing.type: Animations.emphasize
                    easing.overshoot: Animations.emphasizeOvershoot
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: Theme.spacingXs

                // مستطیل آیکون (۶۰×۶۰ با گوشه گرد)
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 60
                    radius: Theme.radiusMd
                    color: Theme.surfaceHover
                    // وقتی hovered، کمی پررنگ‌تر
                    opacity: tileLayer.containsMouse ? 1.0 : 0.5
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Animations.colorAnim(Animations.fast02).duration
                            easing.type: Animations.smooth
                        }
                    }

                    Image {
                        anchors.centerIn: parent
                        width: 30
                        height: 30
                        source: sm.ib + tile.modelData.i
                        sourceSize: Qt.size(30, 30)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                }

                // برچسب زیر آیکون
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    text: tile.modelData.n
                    color: Theme.text
                    font.family: Theme.fontPersian
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // StateLayer برای کلیک چپ و راست
            StateLayer {
                id: tileLayer
                color: Theme.text
                rippleEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        // نمایش منوی زمینه
                        contextMenu.open()
                    } else {
                        Quickshell.execDetached([tile.modelData.e])
                        sm.closeRequested()
                    }
                }
            }

            // منوی زمینه (راست‌کلیک)
            Controls.Menu {
                id: contextMenu

                Controls.MenuItem {
                    text: "باز کردن"
                    onTriggered: {
                        Quickshell.execDetached([tile.modelData.e])
                        sm.closeRequested()
                    }
                }
                Controls.MenuItem {
                    text: "برداشتن پین"
                    onTriggered: { /* TODO: مدیریت پین در آینده */ }
                }
                Controls.MenuSeparator {}
                Controls.MenuItem {
                    text: "ویژگی‌ها"
                    onTriggered: { /* TODO: نمایش ویژگی‌ها */ }
                }
            }

            // tooltip روی hover
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.top
                anchors.bottomMargin: Theme.spacingXs
                width: tileTipLabel.width + 16
                height: 24
                radius: Theme.radiusSm
                color: Theme.surfaceElevated
                border.color: Theme.border
                border.width: 1
                opacity: tileLayer.containsMouse ? 1.0 : 0.0
                visible: opacity > 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.fast02
                        easing.type: Animations.smooth
                    }
                }
                z: 100
                Text {
                    id: tileTipLabel
                    anchors.centerIn: parent
                    text: tile.modelData.n
                    color: Theme.text
                    font.family: Theme.fontPersian
                    font.pixelSize: 11
                }
            }
        }
    }

    // ============================================================
    // ۷. بارگذاری همه‌ی برنامه‌ها از فایل‌های desktop
    // ============================================================
    Process {
        id: appScan
        command: ["sh", "-c",
            "for f in /usr/share/applications/*.desktop /home/nimeh/.local/share/applications/*.desktop; do " +
            "[ -f \"$f\" ] || continue; " +
            "grep -q 'NoDisplay=true' \"$f\" && continue; " +
            "name=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2); " +
            "[ -z \"$name\" ] && continue; " +
            "exe=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2 | sed 's/ %.*//' | cut -d' ' -f1); " +
            "icon=$(grep -m1 '^Icon=' \"$f\" | cut -d= -f2); " +
            "echo \"$name|$exe|$icon\"; " +
            "done | sort -u"]
        stdout: StdioCollector {
            onStreamFinished: {
                const list = []
                this.text.trim().split("\n").forEach(l => {
                    if (!l) return
                    const p = l.split("|")
                    if (p.length >= 2 && p[0] && p[1])
                        list.push({ name: p[0], exec: p[1], icon: p[2] || "" })
                })
                sm.allApps = list
                sm.updateShown()
            }
        }
    }
    Component.onCompleted: appScan.running = true

    // ============================================================
    // ۸. توابع کمکی
    // ============================================================

    // به‌روزرسانی shownApps بر اساس query
    function updateShown() {
        if (query.length > 0) {
            const q = query.toLowerCase()
            shownApps = allApps.filter(a =>
                a.name.toLowerCase().includes(q)
            ).slice(0, 30)
        } else {
            shownApps = []
        }
    }

    // تعیین آیکون برای یک app
    function iconFor(a) {
        // اگر آیکون مطلق بود (path)، مستقیم استفاده کن
        if (a.icon && String(a.icon).startsWith("/"))
            return "file://" + a.icon
        // در غیر این صورت آیکون پیش‌فرض
        return ib + "ic_fluent_settings_24_regular.png"
    }
}
