#!/bin/bash
# NimehOS Installer launcher
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export QT_QUICK_BACKEND=software
exec python3 "$SCRIPT_DIR/main.py" "$@"
