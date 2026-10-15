#!/bin/bash
set -e
INSTALLER_DIR="$(cd "$(dirname "$0")/.." && pwd)/apps/nimehos-installer"

echo "=== نصب NimehOS Installer ==="

# ۱. نصب پیش‌نیازها
echo "۱. نصب PySide6..."
if ! python3 -c "import PySide6" 2>/dev/null; then
    pip3 install --user PySide6 2>/dev/null || sudo apt install -y python3-pyside6 2>/dev/null || echo "⚠ PySide6 نصب نشد — با pip install PySide6 نصب کنید"
fi

# ۲. لینک باینری
echo "۲. ساخت لینک..."
sudo ln -sf "$INSTALLER_DIR/launch.sh" /usr/local/bin/nimehos-installer 2>/dev/null || \
    ln -sf "$INSTALLER_DIR/launch.sh" ~/.local/bin/nimehos-installer 2>/dev/null

# ۳. desktop entry
echo "۳. نصب desktop entry..."
mkdir -p ~/.local/share/applications
cp "$INSTALLER_DIR/nimehos-installer.desktop" ~/.local/share/applications/

# ۴. MIME associations
echo "۴. تنظیم MIME..."
xdg-mime default nimehos-installer.desktop application/vnd.flatpak 2>/dev/null || true
xdg-mime default nimehos-installer.desktop application/x-appimage 2>/dev/null || true
xdg-mime default nimehos-installer.desktop application/vnd.debian.binary-package 2>/dev/null || true
xdg-mime default nimehos-installer.desktop application/x-rpm 2>/dev/null || true

# ۵. update desktop database
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

echo ""
echo "✅ نصب کامل شد!"
echo "حالا می‌تونی روی هر فایل .flatpak/.AppImage/.deb/.rpm دابل‌کلیک کنی."
