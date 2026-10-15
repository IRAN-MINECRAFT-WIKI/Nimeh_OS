//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Controls as Controls

ShellRoot {
    id: root

    property bool startMenuVisible: false

    property string startMode: "start"
    property bool quickSettingsVisible: false
    property bool notificationCenterVisible: false
    property bool widgetsPanelVisible: false
    property bool taskViewVisible: false
    property bool powerMenuVisible: false
    property bool lockScreenVisible: false
    property bool appLauncherVisible: false
    property bool snapLayoutsVisible: false
    property bool altTabVisible: false

    // ==== پس‌زمینه و آیکون‌های دسکتاپ ====
    Wallpaper {}
    DesktopIcons {
        onContextMenuRequested: (x, y) => ctx.show(x, y, { accent: "#4CC2FF", title: "دسکتاپ", items: [{ id: "refresh", label: "بازخوانی" }, { sep: true }, { id: "newfolder", label: "پوشه‌ی جدید" }, { id: "newfile", label: "فایل متنی جدید" }, { sep: true }, { id: "display", label: "تنظیمات نمایش", sub: "Win+I" }, { id: "personalize", label: "شخصی‌سازی" }] }, "desktop")
    }

    // ==== تسک‌بار ====
    ContextOverlay {
        id: ctx
        onActivated: (id, owner) => {
            if (owner.indexOf("app:") === 0 && id === "open")
                Quickshell.execDetached([owner.substring(4)])
        }
    }

    NimehTaskbar {

        onQuickSettingsClicked: root.quickSettingsVisible = !root.quickSettingsVisible
        onAppRightClicked: (name, exec, proc, running, x, y) => ctx.show(x, y, {
            accent: "#A78BFA",
            title: name,
            fromBottom: true,
            items: [
                { id: "open",  label: "باز کردن", sub: "Enter" },
                { id: "pin",   label: "پین به تسک‌بار" },
                { sep: true },
                { id: "close", label: "بستن برنامه", sub: "Ctrl+W" }
            ]
        }, "app:" + exec)
        onStartClicked: {
            if (root.startMenuVisible && root.startMode === "start") { root.startMenuVisible = false; return }
            root.startMode = "start"
            root.startMenuVisible = true
            root.quickSettingsVisible = false
        }
        onClockClicked: {
            root.quickSettingsVisible = !root.quickSettingsVisible
            if (root.quickSettingsVisible) root.startMenuVisible = false
        }
        onNotificationsClicked: root.notificationCenterVisible = !root.notificationCenterVisible
        onWidgetsClicked: root.widgetsPanelVisible = !root.widgetsPanelVisible
        onAiClicked: Quickshell.execDetached(["nimehos-ai-assistant"])
        onSearchClicked: {
            if (root.startMenuVisible && root.startMode === "search") { root.startMenuVisible = false; return }
            root.startMode = "search"
            root.startMenuVisible = true
            root.quickSettingsVisible = false
        }
    }

    // ==== Title Bar (روی پنجره فعال) ====
    WindowTitleBar {
        id: wtb
    }

    // ==== منوی استارت ====
    PanelWindow {
        id: smw
        visible: root.startMenuVisible
        implicitWidth: 640
        implicitHeight: 700
        anchors.bottom: true
        anchors.left: true
        margins.bottom: 56
        margins.left: (screen.width - 640) / 2
        color: "transparent"
        WlrLayershell.namespace: "nimeh-startmenu"
        WlrLayershell.layer: WlrLayer.Overlay
        NimehStartMenu {
            mode: root.startMode
            open: root.startMenuVisible
            onCloseRequested: root.startMenuVisible = false
            onPowerRequested: { root.startMenuVisible = false; root.powerMenuVisible = true }
            onLockRequested: {
                root.startMenuVisible = false
                Quickshell.execDetached(["loginctl", "lock-session"])
            }
            onLogoutRequested: Hyprland.dispatch("exit")
        }
    }

    // ==== تنظیمات سریع ====
    PanelWindow {
        id: qsw
        visible: root.quickSettingsVisible
        implicitWidth: 380
        implicitHeight: 600
        anchors.bottom: true
        anchors.right: true
        margins.bottom: 56
        margins.right: 8
        color: "transparent"
        WlrLayershell.namespace: "nimeh-quicksettings"
        WlrLayershell.layer: WlrLayer.Overlay
        NimehQuickSettings {
            open: root.quickSettingsVisible
            onCloseRequested: root.quickSettingsVisible = false
            onAllSettingsRequested: {
                root.quickSettingsVisible = false
                Quickshell.execDetached(["nimehos-settings"])
            }
        }
    }

    // ==== بقیه پنل‌ها ====
    NotificationCenter  { id: ncPanel;  visible: root.notificationCenterVisible;  onCloseRequested: root.notificationCenterVisible = false }
    WidgetsPanel        { id: wpPanel;  visible: root.widgetsPanelVisible;        onCloseRequested: root.widgetsPanelVisible = false }
    TaskView            { id: tvPanel;  visible: root.taskViewVisible;            onCloseRequested: root.taskViewVisible = false }
    PowerMenu           { id: pmPanel;  visible: root.powerMenuVisible;           onCloseRequested: root.powerMenuVisible = false }
    LockScreen          { id: lockPanel }
    AppLauncher         { id: alPanel;  visible: root.appLauncherVisible;         onCloseRequested: root.appLauncherVisible = false }
    SnapLayouts         { id: snapPanel;visible: root.snapLayoutsVisible;         onCloseRequested: root.snapLayoutsVisible = false }
    AltTabPreview       { id: atPanel;  visible: root.altTabVisible;              onCloseRequested: root.altTabVisible = false }

    // ==== OSD و منوها ====
    OSD                 { id: osdPanel }
    AppContextMenu { id: appMenu }
    DesktopContextMenu  { id: cmPanel; visible: false; onCloseRequested: cmPanel.visible = false }

    // ==== توابع کمکی ====
    function notify(app, title, body, urgency) {
        ncPanel.push({
            app: app || "NimehOS", title: title || "", body: body || "",
            time: "اکنون", urgency: urgency || "normal"
        })
    }
    function showOSD(type, value, muted) { osdPanel.show(type, value, muted) }

    Component.onCompleted: {
        ncPanel.push({
            app: "NimehOS",
            title: "به NimehOS خوش آمدید",
            body: "دسکتاپ آماده است. کلید Super را برای منوی استارت فشار دهید.",
            time: "اکنون", urgency: "normal"
        })
    }

    // ==== IPC Handlers ====
    IpcHandler {
        target: "shell"

        // --- Panel toggles ---
        // Panels without show()/hide() animations: just flip the visibility
        // property; the PanelWindow binding takes care of the rest.
        function toggleStart()         { root.startMenuVisible          = !root.startMenuVisible }
        function toggleQuick()         { root.quickSettingsVisible      = !root.quickSettingsVisible }
        function toggleNotifications() { root.notificationCenterVisible = !root.notificationCenterVisible }
        function toggleWidgets()       { root.widgetsPanelVisible       = !root.widgetsPanelVisible }
        function togglePower()         { root.powerMenuVisible          = !root.powerMenuVisible }

        // FIX v4 (Bug 9): panels that expose show()/hide() must actually
        // have those functions called — otherwise the appear/disappear
        // animations never run and (for AppLauncher) the search input is
        // never focused. We use `panel.visible` as the source of truth
        // so the toggle keeps working even after the `visible: root.*`
        // binding is broken by the first show() call.
        function toggleTaskView() { tvPanel.visible   ? tvPanel.hide()   : tvPanel.show()   }
        function toggleSnap()     { snapPanel.visible ? snapPanel.hide() : snapPanel.show() }
        function toggleLauncher() { alPanel.visible   ? alPanel.hide()   : alPanel.show()   }
        function toggleAltTab()   { atPanel.visible   ? atPanel.hide()   : atPanel.show()   }

        function lockNow() {
            Quickshell.execDetached(["loginctl", "lock-session"])
        }
        function showOSD() { osdPanel.show("volume", 50, false) }
        // تابع کمکی: minimize پنجره فعال
        function minimizeActive() {
            Hyprland.dispatch("movetoworkspacesilent", "special:minimized")
        }

        // ----------------------------------------------------------
        // FIX v4 (debug report §17.6): missing IPC handlers added
        // ----------------------------------------------------------

        // Instant volume control + OSD feedback (no 800ms poller delay)
        function volUp() {
            Quickshell.execDetached(["sh","-c",
                "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"])
            osdPanel.show("volume", osdPanel.level, false)
        }
        function volDown() {
            Quickshell.execDetached(["sh","-c",
                "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-"])
            osdPanel.show("volume", osdPanel.level, false)
        }
        function volMute() {
            Quickshell.execDetached(["sh","-c",
                "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"])
            osdPanel.show("volume", osdPanel.level, true)
        }

        // Instant brightness control + OSD feedback
        function brightUp() {
            Quickshell.execDetached(["sh","-c","brightnessctl s +5%"])
            osdPanel.show("brightness", osdPanel.level, false)
        }
        function brightDown() {
            Quickshell.execDetached(["sh","-c","brightnessctl s 5%-"])
            osdPanel.show("brightness", osdPanel.level, false)
        }

        // Win+Ctrl+D: jump to a fresh empty workspace
        function newDesktop() {
            Hyprland.dispatch("workspace", "empty")
        }

        // Win+S: open the launcher (which auto-focuses its search input)
        function searchStart() {
            if (!alPanel.visible) alPanel.show()
        }

        // Snap shortcuts — apply a layout to the active window without
        // showing the snap picker UI.
        function snapLeft()  { snapPanel.applyLayout("left-half")  }
        function snapRight() { snapPanel.applyLayout("right-half") }
        function snapUp()    { snapPanel.applyLayout("focus") }
        function snapDown()  { Hyprland.dispatch("movetoworkspacesilent", "special:minimized") }
    }
}
