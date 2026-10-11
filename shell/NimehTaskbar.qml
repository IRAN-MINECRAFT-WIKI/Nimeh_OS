// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// NimehTaskbar.qml — نوار وظیفه NimehOS (نسخه بازسازی‌شده)
// ============================================================
//
// این فایل نوار وظیفه‌ی پایین صفحه NimehOS را با الگوی ویندوز ۱۱ بازسازی
// می‌کند. تمام رنگ‌ها، توکن‌های انیمیشن، پس‌زمینه شیشه‌ای و لایه‌ی تعامل
// از سینگلتون‌های ماژول NimehOS تأمین می‌شوند:
//
//   - Theme.qml        → رنگ‌ها (پالت M3، semantic، توکن‌های فاصله/شعاع)
//   - Animations.qml   → duration و easing tokens
//   - GlassPanel.qml   → پس‌زمینه آکریلیک با gradient و shadow
//   - StateLayer.qml   → لایه‌ی تعامل Material 3 با ripple و hover/press
//
// ساختار کلی (۴۸ پیکسل ارتفاع، تمام عرض پایین صفحه):
//   [N Logo] [Search] [Apps پین‌شده مرکزی] | [AI] [WS] [WiFi] [Vol] [Bat] [Clock] [Notif]
//
// تفاوت‌ها با نسخه قبلی (NimehOS_final/shell/NimehTaskbar.qml):
//   - حذف کامل رنگ‌های هاردکد (تمام رنگ‌ها از Theme)
//   - حذف اعداد هاردکد انیمیشن (تمام duration/easing از Animations)
//   - استفاده از GlassPanel به‌جای Rectangle دستی برای پس‌زمینه
//   - استفاده از StateLayer به‌جای Rectangle hover/press دستی روی همه‌ی آیتم‌ها
//   - استفاده از RowLayout به‌جای Row + anchors (طبق قاعده NimehOS)
//   - توضیحات فارسی سراسری و doc comment بالای فایل
//   - AI Orb و Workspace به‌صورت اینلاین با breathing animation پیاده‌سازی شده‌اند
//
// سیگنال‌ها (هم‌خانواده با نسخه قبلی + wifiClicked/volumeClicked):
//   startClicked() clockClicked() notificationsClicked() widgetsClicked()
//   aiClicked() searchClicked() wifiClicked() volumeClicked()
//   appRightClicked(string name, string exec, string proc, bool running, int x, int y)

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: tb

    // ============================================================
    // ۱. پیکربندی PanelWindow
    // ============================================================
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 48
    color: "transparent"
    WlrLayershell.namespace: "nimeh-taskbar"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: 48

    // ============================================================
    // ۲. سیگنال‌ها (رابط عمومی)
    // ============================================================
    signal startClicked()
    signal clockClicked()
    signal notificationsClicked()
    signal widgetsClicked()
    signal aiClicked()
    signal searchClicked()
    signal wifiClicked()
    signal volumeClicked()
    signal appRightClicked(string name, string exec, string proc, bool running, int x, int y)

    // ============================================================
    // ۳. پراپرتی‌های عمومی
    // ============================================================
    // پیشوند مسیر آیکون‌ها.
    readonly property string ib: "file:///home/nimeh/NimehOS/shell/icons/png/"
    // لیست برنامه‌های پین‌شده در نوار وظیفه.
    // n=name(فارسی)، i=icon file، e=exec، p=proc برای تشخیص اجرا
    readonly property var pinnedApps: [
        { n: "فایل‌ها",   i: "ic_fluent_folder_24_regular.png",   e: "dolphin",   p: "dolphin" },
        { n: "تنظیمات",  i: "ic_fluent_settings_24_regular.png",  e: "/home/nimeh/.local/bin/nimehos-settings", p: "quickshell" },
        { n: "ترمینال",  i: "ic_fluent_edit_24_regular.png",      e: "konsole",   p: "konsole" },
        { n: "مرورگر",   i: "ic_fluent_globe_24_regular.png",     e: "firefox",   p: "firefox" },
        { n: "ویرایشگر", i: "ic_fluent_pen_24_regular.png",       e: "kate",      p: "kate" }
    ]

    // ============================================================
    // ۴. پس‌زمینه شیشه‌ای (GlassPanel)
    // ============================================================
    // radius=0 چون taskbar تمام عرض را می‌گیرد و گوشه‌های گرد نمی‌خواهیم.
    // tintOpacity=0.85 تا blur زیر آن (توسط Hyprland) همچنان دیده شود.
    // elevation=1 برای سایه ملایم (سایه به سمت پایین می‌رود که برای
    // taskbar پایین صفحه مناسب است).
    GlassPanel {
        id: bg
        anchors.fill: parent
        radius: 0
        tintOpacity: 0.85
        blurEnabled: true
        elevation: 1
        shadowEnabled: false  // taskbar پایین صفحه است، سایه نیاز نیست

        // خط جداکننده‌ی نازک در بالا — یک gradient افقی نرم
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Theme.withAlpha(Theme.text, 0.00) }
                GradientStop { position: 0.5; color: Theme.withAlpha(Theme.text, 0.10) }
                GradientStop { position: 1.0; color: Theme.withAlpha(Theme.text, 0.00) }
            }
        }
    }

    // ============================================================
    // ۵. محتوای اصلی (RowLayout)
    // ============================================================
    // از RowLayout استفاده می‌کنیم تا Layout.fillWidth برای فاصله‌گذاری
    // مرکزی کار کند. در RowLayout، فرزندان نباید از anchors استفاده کنند.
    RowLayout {
        id: content
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingSm
        anchors.rightMargin: Theme.spacingSm
        spacing: Theme.spacingSm

        // ====================================================
        // ۵.۱. لوگوی N (دکمه استارت)
        // ====================================================
        Item {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            Layout.alignment: Qt.AlignVCenter

            Image {
                anchors.centerIn: parent
                width: 34
                height: 34
                source: tb.ib + "nlogo.png"
                fillMode: Image.PreserveAspectFit
                smooth: true

                // تأکید هنگام hover
                scale: logoLayer.containsMouse ? 1.08 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: Animations.medium02
                        easing.type: Animations.emphasize
                        easing.overshoot: Animations.emphasizeOvershoot
                    }
                }
            }

            StateLayer {
                id: logoLayer
                color: Theme.accent
                rippleEnabled: true
                onClicked: mouse => tb.startClicked()
            }
        }

        // ====================================================
        // ۵.۲. جعبه جستجو
        // ====================================================
        Item {
            Layout.preferredWidth: 200
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                id: searchBox
                anchors.fill: parent
                radius: Theme.radiusPill  // به‌سبک Windows 11، کاملاً گرد
                color: Theme.withAlpha(Theme.text, searchLayer.containsMouse ? 0.10 : 0.06)
                border.color: searchLayer.containsMouse ? Theme.withAlpha(Theme.accent, 0.5) : Theme.border
                border.width: 1

                Behavior on color {
                    ColorAnimation {
                        duration: Animations.colorAnim(Animations.fast02).duration
                        easing.type: Animations.smooth
                    }
                }
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
                        Layout.preferredWidth: 14
                        Layout.preferredHeight: 14
                        source: tb.ib + "ic_fluent_search_24_regular.png"
                        sourceSize: Qt.size(14, 14)
                        opacity: 0.7
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "جستجو"
                        color: Theme.textMuted
                        font.family: Theme.fontPersian
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignLeft
                    }
                }
            }

            StateLayer {
                id: searchLayer
                color: Theme.text
                rippleEnabled: false  // روی input تپ‌دل‌خواه نزنیم
                onClicked: mouse => tb.searchClicked()
                cursorShape: Qt.PointingHandCursor
            }
        }

        // ====================================================
        // ۵.۳. فاصله‌ساز چپ (push pinned apps to center)
        // ====================================================
        Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }

        // ====================================================
        // ۵.۴. برنامه‌های پین‌شده (مرکز)
        // ====================================================
        // از Row استفاده می‌کنیم چون مجموعه ثابت است و فرزندان مستقیماً
        // در آن قرار می‌گیرند (نه با anchors).
        Row {
            Layout.alignment: Qt.AlignVCenter
            spacing: Theme.spacingXs

            Repeater {
                model: tb.pinnedApps
                delegate: pinnedAppDelegate
            }
        }

        // ====================================================
        // ۵.۵. فاصله‌ساز راست
        // ====================================================
        Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }

        // ====================================================
        // ۵.۶. AI Orb (با breathing animation)
        // ====================================================
        Item {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                id: aiOrb
                anchors.centerIn: parent
                width: 28
                height: 28
                radius: width / 2  // دایره کامل
                // گرادیال شعاعی برای حس سه‌بعدی orb
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Theme.accentGlow }
                    GradientStop { position: 1.0; color: Theme.accentDeep }
                }
                border.color: Theme.withAlpha(Theme.text, 0.15)
                border.width: 1

                // breathing: scale 1.0 ↔ 1.08 بینهایت
                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: 1.0; to: 1.08
                        duration: Animations.slow01
                        easing.type: Animations.smooth
                    }
                    NumberAnimation {
                        from: 1.08; to: 1.0
                        duration: Animations.slow01
                        easing.type: Animations.smooth
                    }
                }
            }

            StateLayer {
                color: Theme.text
                rippleEnabled: true
                onClicked: mouse => tb.aiClicked()
            }
        }

        // ====================================================
        // ۵.۷. اندیکاتور Workspace (۴ نقطه)
        // ====================================================
        Item {
            Layout.preferredWidth: 56
            Layout.preferredHeight: 36
            Layout.alignment: Qt.AlignVCenter

            // نقطه فعال (با حرکت بین آن‌ها با x)
            Row {
                anchors.centerIn: parent
                spacing: Theme.spacingSm

                Repeater {
                    model: 4
                    delegate: Rectangle {
                        required property int index
                        width: 8
                        height: 8
                        radius: width / 2
                        // فعال = accent، غیرفعال = outline
                        color: index === wsLayer._activeWs ? Theme.accent
                                                        : Theme.m3outlineVariant
                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.colorAnim(Animations.fast02).duration
                                easing.type: Animations.smooth
                            }
                        }
                        // نقطه فعال کمی بزرگ‌تر
                        scale: index === wsLayer._activeWs ? 1.15 : 1.0
                        Behavior on scale {
                            NumberAnimation {
                                duration: Animations.medium02
                                easing.type: Animations.emphasize
                                easing.overshoot: Animations.emphasizeOvershoot
                            }
                        }
                    }
                }
            }

            // MouseArea سفارشی (نه StateLayer) چون می‌خواهیم wheel و click
            // را جداگانه هندل کنیم و StateLayer برای این کار طراحی نشده.
            MouseArea {
                id: wsLayer
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton
                // اندیس workspace فعال (placeholder: ۰)
                property int _activeWs: 0
                onClicked: mouse => tb.widgetsClicked()
                onWheel: wheel => {
                    // scroll بین workspaceها (محلی)
                    if (wheel.angleDelta.y > 0)
                        _activeWs = Math.max(0, _activeWs - 1)
                    else
                        _activeWs = Math.min(3, _activeWs + 1)
                }
            }
        }

        // ====================================================
        // ۵.۸. آیکون WiFi
        // ====================================================
        Item {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignVCenter

            Image {
                anchors.centerIn: parent
                width: 16
                height: 16
                source: tb.ib + "ic_fluent_wifi_1_24_regular.png"
                sourceSize: Qt.size(16, 16)
                opacity: wifiLayer.containsMouse ? 1.0 : 0.85
                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.fast02
                        easing.type: Animations.smooth
                    }
                }
            }

            StateLayer {
                id: wifiLayer
                color: Theme.text
                rippleEnabled: true
                onClicked: mouse => tb.wifiClicked()
            }
        }

        // ====================================================
        // ۵.۹. آیکون Volume (با toggle و wheel)
        // ====================================================
        Item {
            id: volItem
            Layout.preferredWidth: 32
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignVCenter
            property bool muted: false

            Image {
                anchors.centerIn: parent
                width: 16
                height: 16
                source: tb.ib + (volItem.muted
                                 ? "ic_fluent_speaker_off_24_regular.png"
                                 : "ic_fluent_speaker_2_24_regular.png")
                sourceSize: Qt.size(16, 16)
                opacity: volLayer.containsMouse ? 1.0 : 0.85
                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.fast02
                        easing.type: Animations.smooth
                    }
                }
            }

            StateLayer {
                id: volLayer
                color: Theme.text
                rippleEnabled: true
                onClicked: mouse => {
                    volToggleProcess.running = true
                    tb.volumeClicked()
                }
                // scroll → تغییر صدا (محلی)
                onWheel: wheel => {
                    const step = (wheel.angleDelta.y > 0 ? 0.05 : -0.05)
                    volScrollProcess.command = ["sh", "-c",
                        "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (step > 0 ? "5%+" : "5%-")]
                    volScrollProcess.running = true
                }
            }

            // Process: toggle mute
            Process {
                id: volToggleProcess
                command: ["sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"]
                onRunningChanged: if (!running) volCheckProcess.running = true
            }
            // Process: read current state
            Process {
                id: volCheckProcess
                command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null"]
                stdout: StdioCollector {
                    onStreamFinished: volItem.muted = (this.text.indexOf("MUTED") !== -1)
                }
            }
            // Process: scroll change (command پویا)
            Process {
                id: volScrollProcess
                command: ["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"]
            }
            // به‌روزرسانی دوره‌ای وضعیت mute
            Timer {
                interval: 5000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: volCheckProcess.running = true
            }
        }

        // ====================================================
        // ۵.۱۰. باتری (با BatteryIcon)
        // ====================================================
        Item {
            id: batItem
            Layout.preferredWidth: 44
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignVCenter
            property int level: 8
            property bool charging: false
            property int percent: 80

            Row {
                anchors.centerIn: parent
                spacing: 3

                // کامپوننت BatteryIcon فرض می‌شود از مسیر shell قابل دسترس باشد.
                BatteryIcon {
                    level: batItem.level
                    charging: batItem.charging
                }

                Text {
                    text: Theme.toFa(batItem.percent) + "٪"
                    color: Theme.text
                    font.family: Theme.fontPersian
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            StateLayer {
                color: Theme.text
                rippleEnabled: true
                onClicked: mouse => { /* نمایش جزئیات باتری در آینده */ }
            }

            // Process: درصد باتری
            Process {
                id: batPercentProc
                command: ["sh", "-c",
                    "upower -i $(upower -e | grep -m1 BAT) 2>/dev/null | " +
                    "grep -oE '[0-9]+%' | head -1 | tr -d '%'"]
                stdout: StdioCollector {
                    onStreamFinished: {
                        const v = parseInt(this.text.trim(), 10)
                        if (!isNaN(v)) {
                            batItem.percent = v
                            batItem.level = Math.max(0, Math.min(9, Math.floor(v / 10)))
                        }
                    }
                }
            }
            // Process: وضعیت شارژ
            Process {
                id: batChargeProc
                command: ["sh", "-c",
                    "upower -i $(upower -e | grep -m1 BAT) 2>/dev/null | " +
                    "grep -q 'state.*charging' && echo YES || echo NO"]
                stdout: StdioCollector {
                    onStreamFinished: batItem.charging = (this.text.trim() === "YES")
                }
            }
            Timer {
                interval: 30000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    batPercentProc.running = true
                    batChargeProc.running = true
                }
            }
        }

        // ====================================================
        // ۵.۱۱. ساعت + تاریخ شمسی
        // ====================================================
        Item {
            id: clockItem
            Layout.preferredWidth: clockCol.width + 20
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignVCenter

            function refresh() {
                const now = new Date()
                const hh = String(now.getHours()).padStart(2, "0")
                const mm = String(now.getMinutes()).padStart(2, "0")
                timeLabel.text = Theme.toFa(hh + ":" + mm)
                const j = Theme.jalali(now)
                dateLabel.text = Theme.toFa(j.year) + "/" +
                                 Theme.toFa(String(j.month).padStart(2, "0")) + "/" +
                                 Theme.toFa(String(j.day).padStart(2, "0"))
            }
            Component.onCompleted: clockItem.refresh()
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clockItem.refresh()
            }

            Column {
                id: clockCol
                anchors.centerIn: parent
                spacing: -2
                Text {
                    id: timeLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.text
                    font.family: Theme.fontLatin
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }
                Text {
                    id: dateLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.textMuted
                    font.family: Theme.fontPersian
                    font.pixelSize: 10
                }
            }

            StateLayer {
                color: Theme.text
                rippleEnabled: true
                onClicked: mouse => tb.clockClicked()
            }
        }

        // ====================================================
        // ۵.۱۲. نشان اعلان‌ها (نوار عمودی نازک)
        // ====================================================
        Item {
            Layout.preferredWidth: 6
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: notifLayer.containsMouse
                       ? Theme.withAlpha(Theme.text, 0.18)
                       : Theme.withAlpha(Theme.text, 0.06)
                Behavior on color {
                    ColorAnimation {
                        duration: Animations.colorAnim(Animations.fast02).duration
                        easing.type: Animations.smooth
                    }
                }
            }

            StateLayer {
                id: notifLayer
                color: Theme.text
                rippleEnabled: false  // نوار باریک است؛ ripple خوب دیده نمی‌شود
                onClicked: mouse => tb.notificationsClicked()
            }
        }
    }

    // ============================================================
    // ۶. کامپوننت delegate برنامه‌ی پین‌شده
    // ============================================================
    // هر آیتم ۴۰×۴۰ با:
    //   - StateLayer برای hover/press/ripple
    //   - Image ۲۴×۲۴ در مرکز
    //   - نشان اجرا (۱۸×۳) در پایین
    //   - tooltip در بالا (fade in/out)
    //   - scale: 1.0 (عادی) → 1.1 (hover) → 0.92 (press)
    // از الگوی سنتی Component (نه inline component) برای بیشترین سازگاری.
    Component {
        id: pinnedAppDelegate
        Item {
            id: appItem
            required property var modelData
            width: 40
            height: 40
            property bool running: false

        // مقیاس پویا بر اساس hover/press
        scale: appLayer.pressed ? 0.92
                              : (appLayer.containsMouse ? 1.10 : 1.0)
        Behavior on scale {
            NumberAnimation {
                duration: Animations.medium02
                easing.type: Animations.emphasize
                easing.overshoot: Animations.emphasizeOvershoot
            }
        }

        // آیکون برنامه
        Image {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -2
            width: 24
            height: 24
            source: tb.ib + appItem.modelData.i
            sourceSize: Qt.size(24, 24)
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        // نشان «در حال اجرا» — نوار ۱۸×۳ accent در پایین
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3
            width: appItem.running ? 18 : 0
            height: 3
            radius: 1.5
            color: Theme.accent
            Behavior on width {
                NumberAnimation {
                    duration: Animations.medium02
                    easing.type: Animations.bouncy
                    easing.overshoot: Animations.bouncyOvershoot
                }
            }
        }

        // Tooltip بالا (fade in/out)
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.top
            anchors.bottomMargin: Theme.spacingSm
            width: tipLabel.width + 16
            height: 24
            radius: Theme.radiusSm
            color: Theme.surfaceElevated
            border.color: Theme.border
            border.width: 1
            opacity: appLayer.containsMouse ? 1.0 : 0.0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Animations.fast02
                    easing.type: Animations.smooth
                }
            }
            Text {
                id: tipLabel
                anchors.centerIn: parent
                text: appItem.modelData.n
                color: Theme.text
                font.family: Theme.fontPersian
                font.pixelSize: 11
            }
        }

        // StateLayer — کلیک چپ اجرا، راست منوی زمینه
        StateLayer {
            id: appLayer
            color: Theme.text
            rippleEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    const g = appLayer.mapToItem(null, mouse.x, mouse.y)
                    tb.appRightClicked(appItem.modelData.n,
                                       appItem.modelData.e,
                                       appItem.modelData.p,
                                       appItem.running,
                                       g.x, g.y)
                } else {
                    Quickshell.execDetached([appItem.modelData.e])
                    runningHintTimer.start()
                }
            }
        }

        // تشخیص اجرا (pgrep دوره‌ای)
        Process {
            id: runCheck
            command: {
                const p = appItem.modelData.p
                if (p && p.indexOf("/") !== -1) {
                    return ["sh", "-c",
                        "pgrep -f '" + p + "' | grep -v pgrep | head -1"]
                }
                return ["sh", "-c", "pgrep -x '" + p + "' 2>/dev/null | head -1"]
            }
            running: true
            stdout: StdioCollector {
                onStreamFinished: appItem.running = (this.text.trim().length > 0)
            }
        }
        Timer {
            interval: 2000
            running: true
            repeat: true
            onTriggered: runCheck.running = true
        }
        // بعد از launch، موقتاً running=true می‌کنیم تا سریع نشان داده شود
        Timer {
            id: runningHintTimer
            interval: 800
            onTriggered: runCheck.running = true
        }
        }
    }
}
