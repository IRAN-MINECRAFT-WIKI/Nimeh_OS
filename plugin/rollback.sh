#!/bin/bash
# NimehOS C++ plugin — rollback / uninstall script.
# Removes the installed NimehOS QML plugin from every common install
# location so `import NimehOS` no longer resolves. Does NOT touch the
# source tree under /home/z/my-project/download/NimehOS_plugin/.

set +e

echo "=== Rolling back NimehOS plugin ==="

# Common install locations on Debian / Arch / Fedora.
SEARCH_DIRS=(
    /usr/lib/qt6/qml/NimehOS
    /usr/local/lib/qt6/qml/NimehOS
    /usr/lib64/qt6/qml/NimehOS
    /opt/qt6/qml/NimehOS
)

NEEDS_SUDO=0
for d in "${SEARCH_DIRS[@]}"; do
    if [ -e "$d" ]; then
        parent=$(dirname "$d")
        if [ ! -w "$parent" ]; then
            NEEDS_SUDO=1
        fi
    fi
done

SUDO=""
if [ "$NEEDS_SUDO" = "1" ]; then
    SUDO="sudo"
fi

removed=0
for d in "${SEARCH_DIRS[@]}"; do
    if [ -e "$d" ] || [ -L "$d" ]; then
        echo "  removing $d"
        $SUDO rm -rf "$d"
        removed=$((removed + 1))
    fi
done

# Catch any stragglers (e.g. plugins installed under a distro-specific libdir).
echo "  searching for stragglers ..."
while IFS= read -r f; do
    if [ -n "$f" ] && [ -e "$f" ]; then
        echo "  removing stray: $f"
        $SUDO rm -rf "$f"
        removed=$((removed + 1))
    fi
done < <(find /usr /opt -path '*qml/NimehOS*' -print 2>/dev/null)

# Also remove the backing library (might be named libNimehOSPlugin.so).
while IFS= read -r f; do
    if [ -n "$f" ] && [ -e "$f" ]; then
        echo "  removing stray lib: $f"
        $SUDO rm -f "$f"
        removed=$((removed + 1))
    fi
done < <(find /usr /opt -name 'libNimehOSPlugin*' -print 2>/dev/null)

echo ""
if [ "$removed" = "0" ]; then
    echo "ℹ Nothing to remove — no NimehOS plugin was installed."
else
    echo "✅ Removed $removed file(s)/dir(s)."
fi
echo ""
echo "Run ./build.sh to rebuild and reinstall."
