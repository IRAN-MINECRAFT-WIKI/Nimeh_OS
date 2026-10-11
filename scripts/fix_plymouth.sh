#!/bin/bash
# ============================================================
# fix_plymouth.sh — رفع مشکل Plymouth boot animation
# اجرا روی VM: bash ~/NimehOS/scripts/fix_plymouth.sh
# ============================================================
set -e

echo "===================================================="
echo "  رفع مشکل Plymouth NimehOS"
echo "===================================================="

# ۱. چک کردن theme نصب‌شده
echo ""
echo "۱. بررسی theme فعلی Plymouth..."
CURRENT_THEME=$(plymouth-set-default-theme 2>/dev/null || echo "none")
echo "  theme فعلی: $CURRENT_THEME"

if [ "$CURRENT_THEME" != "nimehos" ]; then
    echo "  ❌ theme روی nimehos تنظیم نیست"
    echo "  تنظیم theme..."
    if [ -d /usr/share/plymouth/themes/nimehos ]; then
        sudo plymouth-set-default-theme -R nimehos
        echo "  ✓ theme تنظیم شد"
    else
        echo "  ❌ پوشه theme وجود ندارد: /usr/share/plymouth/themes/nimehos"
        echo "  ابتدا theme رو نصب کن"
        exit 1
    fi
else
    echo "  ✓ theme درست تنظیم شده"
fi

# ۲. چک کردن GRUB_CMDLINE_LINUX_DEFAULT
echo ""
echo "۲. بررسی GRUB_CMDLINE_LINUX_DEFAULT..."
if grep -q "quiet splash" /etc/default/grub; then
    echo "  ✓ quiet splash در GRUB هست"
else
    echo "  ❌ quiet splash نیست — اضافه می‌کنم..."
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 quiet splash"/' /etc/default/grub
    echo "  ✓ اضافه شد"
fi

# ۳. بررسی vmwgfx در initramfs modules
echo ""
echo "۳. بررسی vmwgfx در initramfs..."
if grep -q "^vmwgfx" /etc/initramfs-tools/modules 2>/dev/null; then
    echo "  ✓ vmwgfx در modules هست"
else
    echo "  ❌ vmwgfx نیست — اضافه می‌کنم..."
    echo "vmwgfx" | sudo tee -a /etc/initramfs-tools/modules > /dev/null
    echo "  drm" | sudo tee -a /etc/initramfs-tools/modules > /dev/null
    echo "  ✓ اضافه شد"
fi

# ۴. بررسی init-top script
echo ""
echo "۴. بررسی init-top script..."
INIT_TOP=/etc/initramfs-tools/scripts/init-top/plymouth
if [ -f "$INIT_TOP" ]; then
    echo "  ✓ script وجود داره"
    if [ ! -x "$INIT_TOP" ]; then
        sudo chmod +x "$INIT_TOP"
        echo "  ✓ executable شد"
    fi
else
    echo "  ❌ script نیست — ایجاد..."
    sudo tee "$INIT_TOP" > /dev/null << 'EOF'
#!/bin/sh
PREREQ=""
prereqs()
{
   echo "$PREREQ"
}
case $1 in
prereqs)
   prereqs
   exit 0
   ;;
esac
. /scripts/functions
/bin/plymouth --show-splash
EOF
    sudo chmod +x "$INIT_TOP"
    echo "  ✓ ساخته شد"
fi

# ۵. آپدیت initramfs
echo ""
echo "۵. آپدیت initramfs..."
echo "  (این ممکنه ۱-۲ دقیقه طول بکشه)"
sudo update-initramfs -u -k all
echo "  ✓ initramfs آپدیت شد"

# ۶. آپدیت GRUB
echo ""
echo "۶. آپدیت GRUB..."
if [ -f /boot/grub/grub.cfg ] || [ -d /boot/grub ]; then
    sudo update-grub 2>/dev/null && echo "  ✓ GRUB آپدیت شد" || echo "  ⚠ GRUB نداریم (شاید systemd-boot)"
else
    echo "  ⚠ GRUB نصب نیست — از این مرحله بگذر"
fi

# ۷. تست Plymouth
echo ""
echo "۷. تست Plymouth..."
echo "  تست در TTY (ممکنه صفحه سیاه بشه — Ctrl+Alt+F1 برای برگشت)"
echo ""
echo "  برای تست دستی:"
echo "    sudo plymouthd --no-daemon --debug --tty=/dev/tty7"
echo "    sudo plymouth --show-splash"
echo "    sudo plymouth --quit"
echo ""

# ۸. چک کردن فایل‌های theme
echo "۸. بررسی فایل‌های theme..."
THEME_DIR=/usr/share/plymouth/themes/nimehos
if [ -d "$THEME_DIR" ]; then
    echo "  فایل‌های theme:"
    ls -la "$THEME_DIR" | head -20
else
    echo "  ❌ پوشه theme نیست!"
fi

echo ""
echo "===================================================="
echo "  ✓ Plymouth fix کامل شد"
echo "===================================================="
echo ""
echo "حالا سیستم رو ری‌استارت کن:"
echo "  sudo reboot"
echo ""
echo "اگه بعد از ری‌استارت انیمیشن نشون داده نشد:"
echo "  ۱. چک کن GRUB menu ظاهر می‌شه (اگه ظاهر شد، splash کار نکرده)"
echo "  ۲. در حین بوت، دکمه Esc رو بزن تا لاگ‌ها ببینید"
echo "  ۳. بعد از بوت، چک کن: dmesg | grep -i plymouth"
echo ""
