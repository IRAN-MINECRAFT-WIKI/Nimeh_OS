-- ═════════════════════════════════════════════════════════
--  NimehOS — Hyprland Config (Lua) — Windows 11 style
--  تمام پنجره‌ها شناور، تسک‌بار شناور، blur برای پنل‌ها
-- ═════════════════════════════════════════════════════════

local api = require("hypr.api")

-- ---------- اجرای خودکار ----------
api.exec_once("env QT_QUICK_BACKEND=software quickshell -p $HOME/NimehOS/shell")
api.exec_once("dbus-update-activation-environment --wayland --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
api.exec_once("systemctl --user start pipewire pipewire-pulse wireplumber")
api.exec_once("wl-paste --watch cliphist store")

-- ---------- مانیتور ----------
api.monitor("", "preferred", "auto", 1)

-- ---------- متغیرهای محیطی ----------
api.env("XCURSOR_SIZE", "24")
api.env("QT_QPA_PLATFORM", "wayland")
api.env("QT_QPA_PLATFORMTHEME", "qt6ct")
api.env("XDG_CURRENT_DESKTOP", "Hyprland")
api.env("XDG_SESSION_TYPE", "wayland")
api.env("MOZ_ENABLE_WAYLAND", "1")

-- ---------- ورودی ----------
api.input({
    kb_layout = "us,ir",
    kb_options = "grp:alt_shift_toggle",
    follow_mouse = 1,
    touchpad = {
        natural_scroll = true,
        tap_to_click = true
    },
    sensitivity = 0,
    accel_profile = "flat"
})

api.cursor({
    no_hardware_cursors = true,
    enable_hyprcursor = true
})

-- ---------- عمومی ----------
api.general({
    gaps_in = 4,
    gaps_out = 8,
    border_size = 0,
    col = {
        active_border = "rgba(0078D4FF)",
        inactive_border = "rgba(2D2D2DFF)"
    },
    layout = "dwindle",
    resize_on_border = true
})

-- ---------- تزئینات ----------
api.decoration({
    rounding = 8,
    active_opacity = 1.0,
    inactive_opacity = 0.95,
    fullscreen_opacity = 1.0,
    shadow = {
        enabled = true,
        range = 24,
        render_power = 3,
        color = "rgba(00000066)",
        offset = "0 8"
    },
    blur = {
        enabled = true,
        size = 8,
        passes = 2,
        new_optimizations = true,
        ignore_opacity = true,
        xray = true
    }
})

-- ---------- انیمیشن‌ها ----------
api.animations({ enabled = true })

api.bezier("winEase", "0.16, 1, 0.3, 1")
api.bezier("winBack", "0.34, 1.4, 0.64, 1")

api.animation("windows", 1, 3, "winEase", "slide")
api.animation("windowsIn", 1, 3, "winBack", "slide")
api.animation("windowsOut", 1, 3, "winEase", "slide")
api.animation("windowsMove", 1, 3, "winEase", "slide")
api.animation("fade", 1, 3, "default")
api.animation("border", 1, 3, "default")
api.animation("layers", 1, 3, "default", "fade")
api.animation("workspaces", 1, 3, "winEase", "slide")

-- ---------- متفرقه ----------
api.misc({
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
    focus_on_activate = true,
    animate_manual_resizes = true,
    animate_mouse_windowdragging = true
})

api.gestures({})
api.dwindle({ preserve_split = true })

-- ═════════════════════════════════════════════════════════
-- قانون پنجره — همه شناور، وسط صفحه
-- ═════════════════════════════════════════════════════════
api.windowrule("float on", "class:.*")
api.windowrule("center on", "class:.*")

-- برنامه‌های خاص — اندازه اولیه
api.windowrule("size 760 500", "class:^(thunar|dolphin|nautilus)$")
api.windowrule("size 800 540", "class:^nimehos-settings$")
api.windowrule("size 340 500", "class:^(nimeh-calc|galculator|org.kde.kcalc)$")
api.windowrule("size 600 450", "class:^(nimeh-notepad|kate|gedit)$")
api.windowrule("size 700 420", "class:^(foot|kitty|konsole|alacritty)$")

-- دیالوگ‌ها
api.windowrule("float on", "title:^(Open File|Save File|Open Folder)$")
api.windowrule("center on", "title:^(Open File|Save File|Open Folder)$")

-- pavucontrol, nm-connection-editor, wofi
api.windowrule("float on", "class:^pavucontrol$")
api.windowrule("center on", "class:^pavucontrol$")
api.windowrule("size 700 500", "class:^pavucontrol$")
api.windowrule("float on", "class:^nm-connection-editor$")
api.windowrule("center on", "class:^nm-connection-editor$")
api.windowrule("float on", "class:^wofi$")
api.windowrule("center on", "class:^wofi$")

-- ═════════════════════════════════════════════════════════
-- Blur برای پنل‌های NimehOS
-- ═════════════════════════════════════════════════════════
api.layerrule("blur on", "namespace:nimeh-taskbar")
api.layerrule("blur on", "namespace:nimeh-startmenu")
api.layerrule("blur on", "namespace:nimeh-quicksettings")
api.layerrule("blur on", "namespace:nimeh-notifications")
api.layerrule("blur on", "namespace:nimeh-widgets")
api.layerrule("blur on", "namespace:nimeh-powermenu")
api.layerrule("blur on", "namespace:nimeh-lockscreen")
api.layerrule("blur on", "namespace:nimeh-applauncher")
api.layerrule("blur on", "namespace:nimeh-snap")
api.layerrule("blur on", "namespace:nimeh-alttab")
api.layerrule("blur on", "namespace:nimeh-taskview")

-- ═════════════════════════════════════════════════════════
-- کلیدها
-- ═════════════════════════════════════════════════════════
local SUPER = "SUPER"

-- برنامه‌ها
api.bind(SUPER, "Return", "exec", "foot")
api.bind(SUPER, "E", "exec", "thunar")
api.bind(SUPER, "I", "exec", "nimehos-settings")
api.bind(SUPER, "R", "exec", "quickshell ipc call shell/toggleLauncher")

-- پنجره
api.bind(SUPER, "Q", "killactive")
api.bind("ALT", "F4", "killactive")
api.bind(SUPER, "M", "movetoworkspacesilent", "special:minimized")
api.bind(SUPER, "F", "fullscreen", "1")
api.bind(SUPER, "SHIFT", "F", "fullscreen", "0")
api.bind(SUPER, "V", "togglefloating")

-- پنل‌های NimehOS (IPC)
api.bind(SUPER, "super_l", "exec", "quickshell ipc call shell/toggleStart")
api.bind(SUPER, "A", "exec", "quickshell ipc call shell/toggleQuick")
api.bind(SUPER, "N", "exec", "quickshell ipc call shell/toggleNotifications")
api.bind(SUPER, "W", "exec", "quickshell ipc call shell/toggleWidgets")
api.bind(SUPER, "Tab", "exec", "quickshell ipc call shell/toggleTaskView")
api.bind(SUPER, "Z", "exec", "quickshell ipc call shell/toggleSnap")
api.bind(SUPER, "X", "exec", "quickshell ipc call shell/togglePower")
api.bind(SUPER, "L", "exec", "loginctl lock-session")
api.bind(SUPER, "B", "exec", "loginctl lock-session")
api.bind(SUPER, "D", "exec", "quickshell ipc call shell/toggleLauncher")

-- Alt+Tab
api.bind("ALT", "Tab", "exec", "quickshell ipc call shell/toggleAltTab")
api.bind("ALT", "SHIFT", "Tab", "exec", "quickshell ipc call shell/toggleAltTab")

-- جابه‌جایی پنجره (snap به لبه)
api.bind(SUPER, "Left", "movewindow", "l")
api.bind(SUPER, "Right", "movewindow", "r")
api.bind(SUPER, "Up", "movewindow", "u")
api.bind(SUPER, "Down", "movewindow", "d")

-- فوکوس
api.bind(SUPER, "CTRL", "Left", "movefocus", "l")
api.bind(SUPER, "CTRL", "Right", "movefocus", "r")
api.bind(SUPER, "CTRL", "Up", "movefocus", "u")
api.bind(SUPER, "CTRL", "Down", "movefocus", "d")

-- ماوس
api.bindm(SUPER, "mouse:272", "movewindow")
api.bindm(SUPER, "mouse:273", "resizewindow")

-- ورک‌اسپیس
api.bind(SUPER, "1", "workspace", "1")
api.bind(SUPER, "2", "workspace", "2")
api.bind(SUPER, "3", "workspace", "3")
api.bind(SUPER, "4", "workspace", "4")
api.bind(SUPER, "5", "workspace", "5")
api.bind(SUPER, "SHIFT", "1", "movetoworkspacesilent", "1")
api.bind(SUPER, "SHIFT", "2", "movetoworkspacesilent", "2")
api.bind(SUPER, "SHIFT", "3", "movetoworkspacesilent", "3")
api.bind(SUPER, "CTRL", "Tab", "workspace", "+1")
api.bind(SUPER, "CTRL", "SHIFT", "Tab", "workspace", "-1")

-- اسکرین‌شات
api.bind("", "Print", "exec", "grim /tmp/nimeh-screen.png")
api.bind("SHIFT", "Print", "exec", "sh -c 'grim -g \"$(slurp)\" /tmp/nimeh-region.png'")

-- صدا و روشنایی
api.bindl("", "XF86AudioMute", "exec", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
api.bindl("", "XF86AudioRaiseVolume", "exec", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")
api.bindl("", "XF86AudioLowerVolume", "exec", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-")
api.bindl("", "XF86MonBrightnessUp", "exec", "brightnessctl s +5%")
api.bindl("", "XF86MonBrightnessDown", "exec", "brightnessctl s 5%-")
