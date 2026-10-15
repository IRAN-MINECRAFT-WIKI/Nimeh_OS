#!/bin/bash
export QT_QUICK_BACKEND=software
export QT_QPA_PLATFORM=wayland
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
exec quickshell -p "$(dirname "$0")" "$@"
