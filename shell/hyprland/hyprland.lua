-- ═════════════════════════════════════════════════════════
--  NimehOS — Hyprland Config (Lua) — Windows 11 style
--  همه‌ی پنجره‌ها شناور، تسک‌بار شناور، blur برای پنل‌ها
-- ═════════════════════════════════════════════════════════

-- ---------- اجرای خودکار ----------
exec_once("env QT_QUICK_BACKEND=software quickshell -p $HOME/NimehOS/shell")
exec_once("dbus-update-activation-environment --wayland --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
exec_once("systemctl --user start pipewire pipewire-pulse wireplumber")
exec_once("wl-paste --watch cliphist store")

-- ---------- مانیتور ----------
monitor("", "preferred", "auto", 1)

-- ---------- متغیرهای محیطی ----------
env("XCURSOR_SIZE", "24")
env("QT_QPA_PLATFORM", "wayland")
env("QT_QPA_PLATFORMTHEME", "qt6ct")
env("XDG_CURRENT_DESKTOP", "Hyprland")
env("XDG_SESSION_TYPE", "wayland")
env("MOZ_ENABLE_WAYLAND", "1")

-- ---------- ورودی ----------
input({
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

cursor({
    no_hardware_cursors = true,
    enable_hyprcursor = true
})

-- ---------- عمومی ----------
general({
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
decoration({
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
animations({
    enabled = true
})

-- Bezier curves
animation("windows", 1, 3, "winEase", "slide")
animation("windowsIn", 1, 3, "winBack", "slide")
animation("windowsOut", 1, 3, "winEase", "slide")
animation("windowsMove", 1, 3, "winEase", "slide")
animation("fade", 1, 3, "default")
animation("border", 1, 3, "default")
animation("layers", 1, 3, "default", "fade")
animation("workspaces", 1, 3, "winEase", "slide")

bezier("winEase", "0.16, 1, 0.3, 1")
bezier("winBack", "0.34, 1.4, 0.64, 1")

-- ---------- متفرقه ----------
misc({
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
    focus_on_activate = true,
    animate_manual_resizes = true,
    animate_mouse_windowdragging = true
})

gestures({})

dwindle({
    preserve_split = true
})

-- ═════════════════════════════════════════════════════════
-- قانون پنجره — همه شناور، وسط صفحه
-- ═════════════════════════════════════════════════════════
windowrule("float on", "class:.*")
windowrule("center on", "class:.*")

-- برنامه‌های خاص — اندازه اولیه
windowrule("size 760 500", "class:^(thunar|dolphin|nautilus)$")
windowrule("size 800 540", "class:^nimehos-settings$")
windowrule("size 340 500", "class:^(nimeh-calc|galculator|org.kde.kcalc)$")
windowrule("size 600 450", "class:^(nimeh-notepad|kate|gedit)$")
windowrule("size 700 420", "class:^(foot|kitty|konsole|alacritty)$")

-- دیالوگ‌ها
windowrule("float on", "title:^(Open File|Save File|Open Folder)$")
windowrule("center on", "title:^(Open File|Save File|Open Folder)$")

-- pavucontrol
windowrule("float on", "class:^pavucontrol$")
windowrule("center on", "class:^pavucontrol$")
windowrule("size 700 500", "class:^pavucontrol$")

-- nm-connection-editor
windowrule("float on", "class:^nm-connection-editor$")
windowrule("center on", "class:^nm-connection-editor$")

-- wofi
windowrule("float on", "class:^wofi$")
windowrule("center on", "class:^wofi$")

-- ═════════════════════════════════════════════════════════
-- Blur برای پنل‌های NimehOS
-- ═════════════════════════════════════════════════════════
layerrule("blur on", "namespace:nimeh-taskbar")
layerrule("blur on", "namespace:nimeh-startmenu")
layerrule("blur on", "namespace:nimeh-quicksettings")
layerrule("blur on", "namespace:nimeh-notifications")
layerrule("blur on", "namespace:nimeh-widgets")
layerrule("blur on", "namespace:nimeh-powermenu")
layerrule("blur on", "namespace:nimeh-lockscreen")
layerrule("blur on", "namespace:nimeh-applauncher")
layerrule("blur on", "namespace:nimeh-snap")
layerrule("blur on", "namespace:nimeh-alttab")
layerrule("blur on", "namespace:nimeh-taskview")

-- ═════════════════════════════════════════════════════════
-- کلیدها
-- ═════════════════════════════════════════════════════════
local SUPER = "SUPER"

-- برنامه‌ها
bind(SUPER, "Return", "exec", "foot")
bind(SUPER, "E", "exec", "thunar")
bind(SUPER, "I", "exec", "nimehos-settings")
bind(SUPER, "R", "exec", "quickshell ipc call shell/toggleLauncher")

-- پنجره
bind(SUPER, "Q", "killactive")
bind("ALT", "F4", "killactive")
bind(SUPER, "M", "movetoworkspacesilent", "special:minimized")
bind(SUPER, "F", "fullscreen", "1")
bind(SUPER, "SHIFT", "F", "fullscreen", "0")
bind(SUPER, "V", "togglefloating")

-- پنل‌های NimehOS (IPC)
bind(SUPER, "super_l", "exec", "quickshell ipc call shell/toggleStart")
bind(SUPER, "A", "exec", "quickshell ipc call shell/toggleQuick")
bind(SUPER, "N", "exec", "quickshell ipc call shell/toggleNotifications")
bind(SUPER, "W", "exec", "quickshell ipc call shell/toggleWidgets")
bind(SUPER, "Tab", "exec", "quickshell ipc call shell/toggleTaskView")
bind(SUPER, "Z", "exec", "quickshell ipc call shell/toggleSnap")
bind(SUPER, "X", "exec", "quickshell ipc call shell/togglePower")
bind(SUPER, "L", "exec", "loginctl lock-session")
bind(SUPER, "B", "exec", "loginctl lock-session")
bind(SUPER, "D", "exec", "quickshell ipc call shell/toggleLauncher")

-- Alt+Tab
bind("ALT", "Tab", "exec", "quickshell ipc call shell/toggleAltTab")
bind("ALT", "SHIFT", "Tab", "exec", "quickshell ipc call shell/toggleAltTab")

-- جابه‌جایی پنجره (snap به لبه)
bind(SUPER, "Left", "movewindow", "l")
bind(SUPER, "Right", "movewindow", "r")
bind(SUPER, "Up", "movewindow", "u")
bind(SUPER, "Down", "movewindow", "d")

-- فوکوس
bind(SUPER, "CTRL", "Left", "movefocus", "l")
bind(SUPER, "CTRL", "Right", "movefocus", "r")
bind(SUPER, "CTRL", "Up", "movefocus", "u")
bind(SUPER, "CTRL", "Down", "movefocus", "d")

-- ماوس
bindm(SUPER, "mouse:272", "movewindow")
bindm(SUPER, "mouse:273", "resizewindow")

-- ورک‌اسپیس
bind(SUPER, "1", "workspace", "1")
bind(SUPER, "2", "workspace", "2")
bind(SUPER, "3", "workspace", "3")
bind(SUPER, "4", "workspace", "4")
bind(SUPER, "5", "workspace", "5")
bind(SUPER, "SHIFT", "1", "movetoworkspacesilent", "1")
bind(SUPER, "SHIFT", "2", "movetoworkspacesilent", "2")
bind(SUPER, "SHIFT", "3", "movetoworkspacesilent", "3")
bind(SUPER, "CTRL", "Tab", "workspace", "+1")
bind(SUPER, "CTRL", "SHIFT", "Tab", "workspace", "-1")

-- اسکرین‌شات
bind("", "Print", "exec", "grim /tmp/nimeh-screen.png")
bind("SHIFT", "Print", "exec", "sh -c 'grim -g \"$(slurp)\" /tmp/nimeh-region.png'")

-- صدا و روشنایی
bindl("", "XF86AudioMute", "exec", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
bindl("", "XF86AudioRaiseVolume", "exec", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")
bindl("", "XF86AudioLowerVolume", "exec", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-")
bindl("", "XF86MonBrightnessUp", "exec", "brightnessctl s +5%")
bindl("", "XF86MonBrightnessDown", "exec", "brightnessctl s 5%-")
