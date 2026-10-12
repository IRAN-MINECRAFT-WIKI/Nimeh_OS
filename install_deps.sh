#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  NimehOS — install_deps.sh
#  نصب وابستگی‌های build برای پلاگین C++ NimehOS روی VM.
#  این اسکریپت روی VM اجرا می‌شه (با sudo).
#  توسط deploy.py (FINAL v5) — step_build_cpp فراخوانی می‌شه.
# ═══════════════════════════════════════════════════════════════
set -e

echo "═══════════════════════════════════════════════════════════"
echo "  NimehOS — نصب وابستگی‌های build پلاگین C++"
echo "═══════════════════════════════════════════════════════════"

# رمز sudo از stdin خونده می‌شه
SUDO_PWD="habib9170"

echo "→ به‌روزرسانی apt..."
echo "$SUDO_PWD" | sudo -S apt-get update -y

echo "→ نصب بسته‌های build-essential..."
echo "$SUDO_PWD" | sudo -S apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    g++ \
    pkg-config

echo "→ نصب بسته‌های Qt6..."
echo "$SUDO_PWD" | sudo -S apt-get install -y \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-shadertools \
    qt6-base-private-dev \
    qt6-declarative-private-dev

echo "→ نصب ابزارهای کمکی..."
echo "$SUDO_PWD" | sudo -S apt-get install -y \
    hyprland \
    hyprlock \
    grim \
    slurp \
    qt6-declarative-dev-tools \
    wayland-protocols \
    libwayland-dev \
    libgl1-mesa-dev \
    libegl-dev

echo "═══════════════════════════════════════════════════════════"
echo "  ✓ نصب وابستگی‌ها کامل شد"
echo "═══════════════════════════════════════════════════════════"

# بررسی نسخه‌های کلیدی
echo ""
echo "→ بررسی نسخه‌های نصب‌شده:"
echo "  cmake:     $(cmake --version 2>/dev/null | head -1 || echo 'نصب نشد')"
echo "  g++:       $(g++ --version 2>/dev/null | head -1 || echo 'نصب نشد')"
echo "  qmake6:    $(qmake6 --version 2>/dev/null | head -2 | tail -1 || echo 'نصب نشد')"
echo "  hyprland:  $(hyprland --version 2>/dev/null | head -1 || echo 'نصب نشد')"
echo "  grim:      $(grim --version 2>/dev/null || echo 'نصب نشد')"

echo ""
echo "✓ install_deps.sh تمام شد"
