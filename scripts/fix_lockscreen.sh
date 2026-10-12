#!/bin/bash
# ============================================================
# fix_lockscreen.sh — نصب و تنظیم hyprlock برای LockScreen واقعی
# اجرا روی VM: bash ~/NimehOS/scripts/fix_lockscreen.sh
# ============================================================
set -e

echo "===================================================="
echo "  نصب و تنظیم hyprlock برای LockScreen"
echo "===================================================="

# ۱. چک کردن نصب بودن hyprlock
echo ""
echo "۱. بررسی hyprlock..."
if command -v hyprlock &>/dev/null; then
    echo "  ✓ hyprlock نصبه: $(hyprlock --version 2>&1 | head -1)"
else
    echo "  ❌ hyprlock نصب نیست — نصب..."
    sudo apt update
    sudo apt install -y hyprlock
    if ! command -v hyprlock &>/dev/null; then
        echo "  ⚠ نصب از apt نشد، تلاش با AUR/build..."
        echo "  (در Debian باید از source build بشه)"
        echo ""
        echo "  برای نصب از source:"
        echo "    sudo apt install -y build-essential cmake libpam0g-dev libegl-dev libwayland-dev libglslang-dev libgbm-dev libdbus-1-dev libgles2-dev libpixman-1-dev libseat-dev libxkbcommon-dev libinput-dev libudev-dev"
        echo "    git clone https://github.com/hyprwm/hyprlock.git"
        echo "    cd hyprlock && cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -S . -B ./build"
        echo "    cmake --build ./build --config Release -j\$(nproc)"
        echo "    sudo cmake --install ./build"
        exit 1
    fi
fi

# ۲. ایجاد کانفیگ hyprlock
echo ""
echo "۲. ساخت کانفیگ hyprlock..."
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hyprlock.conf << 'HYPRLOCK_EOF'
# ============================================================
# hyprlock — Lock Screen کانفیگ
# ============================================================

general {
    disable_loading_bar = false
    grace = 0
    hide_cursor = false
    no_fade_in = false
    no_fade_out = false
}

background {
    monitor =
    path = screenshot
    blur_size = 5
    blur_passes = 2
    color = rgba(10, 10, 12, 0.85)
}

# ساعت بزرگ
label {
    monitor =
    text = cmd[update:1000] echo "$(date +%H:%M)"
    color = rgba(240, 244, 255, 1.0)
    font_size = 120
    font_family = Inter
    position = 0, 200
    halign = center
    valign = center
}

# تاریخ شمسی
label {
    monitor =
    text = cmd[update:60000] echo "$(/usr/local/bin/jdate.sh 2>/dev/null || date +%A)"
    color = rgba(122, 133, 152, 1.0)
    font_size = 18
    font_family = Vazirmatn
    position = 0, 100
    halign = center
    valign = center
}

# آواتار کاربر
label {
    monitor =
    text = nimeh
    color = rgba(240, 244, 255, 1.0)
    font_size = 16
    font_family = Vazirmatn
    position = 0, -100
    halign = center
    valign = center
}

# فیلد رمز
input-field {
    monitor =
    size = 320, 44
    outline_thickness = 1
    dots_size = 0.3
    dots_spacing = 0.3
    inner_color = rgba(28, 28, 30, 0.85)
    outer_color = rgba(0, 153, 255, 0.6)
    font_color = rgba(240, 244, 255, 1.0)
    fade_on_empty = true
    placeholder_text = <i>رمز خود را وارد کنید</i>
    hide_input = false
    position = 0, -200
    halign = center
    valign = center
}

# راهنما
label {
    monitor =
    text = Enter برای ورود
    color = rgba(82, 92, 110, 1.0)
    font_size = 11
    font_family = Vazirmatn
    position = 0, -260
    halign = center
    valign = center
}
HYPRLOCK_EOF
echo "  ✓ کانفیگ ساخته شد: ~/.config/hypr/hyprlock.conf"

# ۳. اسکریپت کمکی jdate.sh
echo ""
echo "۳. ساخت اسکریپت تاریخ شمسی..."
sudo tee /usr/local/bin/jdate.sh > /dev/null << 'JDATE_EOF'
#!/bin/bash
# تاریخ شمسی
python3 -c "
import datetime
def jalali(gy, gm, gd):
    g_d_m = [0,31,59,90,120,151,181,212,243,273,304,334]
    gy2 = gy - 1600
    gm2 = gm - 1
    gd2 = gd - 1
    g_day_no = 365*gy2 + (gy2+3)//4 - (gy2+99)//100 + (gy2+399)//400 + g_d_m[gm2] + gd2
    g_day_no -= 79
    jy = 979 + 33*(g_day_no//12053)
    g_day_no %= 12053
    jy += 4*(g_day_no//1461)
    g_day_no %= 1461
    if g_day_no >= 365:
        g_day_no -= 1
        jy += g_day_no//365
        g_day_no %= 365
    if g_day_no < 186:
        jm = 1 + g_day_no//31
        jd = 1 + g_day_no%31
    else:
        jm = 7 + (g_day_no-186)//30
        jd = 1 + (g_day_no-186)%30
    weekdays = ['دوشنبه','سه‌شنبه','چهارشنبه','پنجشنبه','جمعه','شنبه','یکشنبه']
    months = ['فروردین','اردیبهشت','خرداد','تیر','مرداد','شهریور','مهر','آبان','آذر','دی','بهمن','اسفند']
    import datetime as dt
    today = dt.date.today()
    wd = weekdays[today.weekday()]
    return f'{wd}، {jd} {months[jm-1]} {jy}'
today = datetime.date.today()
print(jalali(today.year, today.month, today.day))
"
JDATE_EOF
sudo chmod +x /usr/local/bin/jdate.sh
echo "  ✓ اسکریپت ساخته شد"

# ۴. تست
echo ""
echo "۴. تست hyprlock..."
echo "  برای تست:"
echo "    hyprlock &"
echo "  (برای خروج: رمز رو وارد کن یا Ctrl+Alt+F2 → pkill hyprlock)"
echo ""

# ۵. چک PAM
echo "۵. بررسی PAM..."
if [ -f /etc/pam.d/hyprlock ]; then
    echo "  ✓ فایل PAM هست"
else
    echo "  ❌ فایل PAM نیست — ایجاد..."
    sudo tee /etc/pam.d/hyprlock > /dev/null << 'PAM_EOF'
#
# PAM configuration for hyprlock
#
auth include common-auth
account include common-account
password include common-password
session include common-session
PAM_EOF
    echo "  ✓ ساخته شد"
fi

echo ""
echo "===================================================="
echo "  ✓ hyprlock آماده است"
echo "===================================================="
echo ""
echo "حالا وقتی کلید Win+L رو می‌زنی، hyprlock اجرا می‌شه."
echo ""
echo "نکته: کانفیگ Hyprland برای Win+L باید این باشه:"
echo "  bind = \$super, L, exec, hyprlock"
echo ""
echo "این کانفیگ رو در hyprland.conf قرار دادیم."
echo ""
