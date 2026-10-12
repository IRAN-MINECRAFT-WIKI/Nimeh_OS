#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  NimehOS — build_cpp_on_vm.sh
#  این اسکریپت روی VM اجرا می‌شه و پلاگین C++ رو build می‌کنه.
#  توسط deploy.py (FINAL v5) — step_build_cpp فراخوانی می‌شه.
# ═══════════════════════════════════════════════════════════════
set -e

echo "═══════════════════════════════════════════════════════════"
echo "  NimehOS — Build C++ Plugin on VM"
echo "═══════════════════════════════════════════════════════════"

# مسیر پلاگین
PLUGIN_DIR="$HOME/NimehOS/NimehOS_plugin"
if [ ! -d "$PLUGIN_DIR" ]; then
    echo "ERROR: پوشه پلاگین پیدا نشد: $PLUGIN_DIR" >&2
    echo "       ابتدا deploy.py deploy و build-cpp رو از ویندوز اجرا کنید." >&2
    exit 1
fi

echo "→ ورود به پوشه پلاگین: $PLUGIN_DIR"
cd "$PLUGIN_DIR"

# بررسی وجود build.sh
if [ ! -f "build.sh" ]; then
    echo "ERROR: build.sh داخل پوشه پلاگین پیدا نشد." >&2
    ls -la
    exit 1
fi

# بررسی cmake و g++
echo "→ بررسی ابزارهای build..."
if ! command -v cmake >/dev/null 2>&1; then
    echo "ERROR: cmake نصب نیست. install_deps.sh رو اجرا کنید." >&2
    exit 1
fi
if ! command -v g++ >/dev/null 2>&1; then
    echo "ERROR: g++ نصب نیست. install_deps.sh رو اجرا کنید." >&2
    exit 1
fi
echo "  ✓ cmake: $(cmake --version | head -1)"
echo "  ✓ g++:   $(g++ --version | head -1)"

# اجرای build
echo "→ اجرای build.sh..."
chmod +x build.sh
bash build.sh

# بررسی موفقیت
if [ $? -eq 0 ]; then
    echo "═══════════════════════════════════════════════════════════"
    echo "  ✓ Build پلاگین با موفقیت انجام شد"
    echo "═══════════════════════════════════════════════════════════"
else
    echo "═══════════════════════════════════════════════════════════"
    echo "  ✗ Build شکست خورد"
    echo "═══════════════════════════════════════════════════════════"
    exit 1
fi

# بررسی نصب qmldir و کتابخانه
echo "→ بررسی نصب پلاگین..."
if [ -d "build" ]; then
    echo "  محتویات build/:"
    ls -la build/ 2>/dev/null | head -20
fi

# جستجوی فایل .so یا qmldir نصب‌شده
echo "→ بررسی مسیرهای نصب Qt..."
QT_QML_DIR="/usr/lib/qt6/qml"
if [ -d "$QT_QML_DIR" ]; then
    echo "  مسیر QML: $QT_QML_DIR"
    find "$QT_QML_DIR" -name "*NimehOS*" -o -name "*nimehos*" 2>/dev/null | head -10
fi

echo ""
echo "✓ build_cpp_on_vm.sh تمام شد"
