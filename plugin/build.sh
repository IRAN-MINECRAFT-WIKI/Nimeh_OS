#!/bin/bash
# NimehOS C++ plugin — build & install script.
# Builds the Qt6 QML plugin (BlobRect, BlobGroup, ImageAnalyser) and
# installs it to the system QML import path so `import NimehOS` works.

set -e

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PLUGIN_DIR/build"
BACKUP_DIR="$HOME/NimehOS/backups/plugin-$(date +%Y%m%d-%H%M%S)"
LOG_DIR="/tmp"

echo "=== NimehOS C++ Plugin Build ==="
echo "Plugin dir: $PLUGIN_DIR"
echo "Build dir:  $BUILD_DIR"
echo ""

# ---------------------------------------------------------------------------
# Step 1 — Backup current sources
# ---------------------------------------------------------------------------
echo "1. Backing up current sources to $BACKUP_DIR ..."
mkdir -p "$BACKUP_DIR"
cp -r "$PLUGIN_DIR/src" "$BACKUP_DIR/" 2>/dev/null || true
cp -r "$PLUGIN_DIR/qml" "$BACKUP_DIR/" 2>/dev/null || true
cp "$PLUGIN_DIR/CMakeLists.txt" "$BACKUP_DIR/" 2>/dev/null || true
echo "   done."
echo ""

# ---------------------------------------------------------------------------
# Step 2 — Locate Qt6
# ---------------------------------------------------------------------------
echo "2. Locating Qt6 ..."
if command -v pkg-config >/dev/null 2>&1; then
    QT6_DIR=$(pkg-config --variable=prefix Qt6Quick 2>/dev/null || true)
fi
if [ -z "$QT6_DIR" ]; then
    # Fall back to common install locations.
    for candidate in /usr /usr/lib/qt6 /opt/qt6 /usr/local; do
        if [ -d "$candidate/lib/cmake/Qt6Quick" ] || [ -d "$candidate/lib/qt6/cmake/Qt6Quick" ]; then
            QT6_DIR="$candidate"
            break
        fi
    done
fi
if [ -z "$QT6_DIR" ]; then
    QT6_DIR="/usr"
fi
echo "   Qt6 prefix: $QT6_DIR"
echo ""

# ---------------------------------------------------------------------------
# Step 3 — Configure (cmake)
# ---------------------------------------------------------------------------
echo "3. Configuring ..."
cmake -B "$BUILD_DIR" -S "$PLUGIN_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="$QT6_DIR" \
    -DCMAKE_INSTALL_PREFIX="/usr" 2>&1 | tee "$LOG_DIR/nimehos-cmake.log"

if [ "${PIPESTATUS[0]}" != "0" ]; then
    echo "❌ CMAKE CONFIGURE FAILED!"
    echo "See $LOG_DIR/nimehos-cmake.log"
    exit 1
fi
echo ""

# ---------------------------------------------------------------------------
# Step 4 — Build
# ---------------------------------------------------------------------------
echo "4. Building ..."
NPROC=$(nproc 2>/dev/null || echo 4)
cmake --build "$BUILD_DIR" --parallel "$NPROC" 2>&1 | tee "$LOG_DIR/nimehos-build.log"

if grep -qiE "(^|[^a-z])error([^a-z]|$)|failed|undefined reference" "$LOG_DIR/nimehos-build.log"; then
    echo ""
    echo "❌ BUILD FAILED! Last 40 lines:"
    tail -40 "$LOG_DIR/nimehos-build.log"
    exit 1
fi
echo ""
echo "✅ Build successful!"
echo ""

# ---------------------------------------------------------------------------
# Step 5 — Install (needs sudo for /usr)
# ---------------------------------------------------------------------------
echo "5. Installing (sudo required for /usr/lib/qt6/qml) ..."
if [ -w /usr/lib/qt6/qml ] || [ -w /usr/lib/qt6 ]; then
    cmake --install "$BUILD_DIR" 2>&1 | tee "$LOG_DIR/nimehos-install.log"
else
    sudo cmake --install "$BUILD_DIR" 2>&1 | tee "$LOG_DIR/nimehos-install.log"
fi
echo ""

# ---------------------------------------------------------------------------
# Step 6 — Verify
# ---------------------------------------------------------------------------
echo "6. Verifying installation ..."
QML_DIR=""
for candidate in /usr/lib/qt6/qml /usr/lib/qt6/qml /usr/local/lib/qt6/qml; do
    if [ -d "$candidate/NimehOS" ]; then
        QML_DIR="$candidate"
        break
    fi
done

if [ -n "$QML_DIR" ]; then
    echo "✅ Plugin installed at: $QML_DIR/NimehOS"
    ls -la "$QML_DIR/NimehOS/"
else
    echo "⚠ Plugin directory not found in standard locations. Searching ..."
    find /usr /opt -name "NimehOS" -type d 2>/dev/null || true
    echo ""
    echo "If nothing is found, the install destination may differ on your distro."
    echo "Set -DCMAKE_INSTALL_LIBDIR=lib/qt6/qml explicitly when configuring."
fi
echo ""

# ---------------------------------------------------------------------------
# Step 7 — Quick QML sanity check (only if qml is available)
# ---------------------------------------------------------------------------
if command -v qml >/dev/null 2>&1 || command -v qml6 >/dev/null 2>&1; then
    QML_BIN=$(command -v qml6 || command -v qml)
    echo "7. QML import test (via $QML_BIN) ..."
    cat > "$LOG_DIR/nimehos-test.qml" <<'EOF'
import QtQuick
import NimehOS

Item {
    width: 200; height: 200
    BlobRect { width: 100; height: 100; color: "blue"; radius: 20 }
    BlobGroup { color: "red" }
    ImageAnalyser { id: ia }
}
EOF
    if $QML_BIN "$LOG_DIR/nimehos-test.qml" --apptype widget 2>&1 | tee "$LOG_DIR/nimehos-qml-test.log" | grep -qi "error\|could not find\|is not installed"; then
        echo "⚠ QML test reported an error — see $LOG_DIR/nimehos-qml-test.log"
    else
        echo "✅ QML import test passed."
    fi
    echo ""
fi

echo "=== Build complete ==="
echo ""
echo "To use in QML:"
echo "    import NimehOS"
echo "    BlobRect { color: 'blue'; radius: 20 }"
echo "    BlobGroup { BlobRect { } BlobRect { } }"
echo "    ImageAnalyser { source: '/path/to/wallpaper.jpg'; onDominantColourChanged: print(dominantColour) }"
