# NimehOS v5 — Complete Package

## 📦 Contents

```
NimehOS/
├── deploy.py              # Main deploy script (run this!)
├── install_deps.sh        # Install build deps on VM
├── build_cpp_on_vm.sh     # Build C++ plugin on VM
├── shell/                 # All QML files (fixed + rebuilt)
│   ├── shell.qml
│   ├── Theme.qml          # M3 singleton
│   ├── Animations.qml     # Animation tokens singleton
│   ├── GlassPanel.qml     # Acrylic panel
│   ├── StateLayer.qml     # M3 interaction
│   ├── BlobRect.qml       # QML blob (fallback)
│   ├── BlobGroup.qml
│   ├── NimehTaskbar.qml   # Rebuilt with Theme+Animations
│   ├── NimehStartMenu.qml # Rebuilt with Theme+Animations
│   ├── ... (27 QML files)
│   ├── hyprland/hyprland.conf
│   ├── icons/png/ (67 icons)
│   └── ui/ (4 components)
├── scripts/               # fix_plymouth.sh, fix_lockscreen.sh, etc.
├── bin/                   # float-daemon, etc.
├── apps/                  # nimehos-settings
└── plugin/                # C++ plugin (BlobRect SDF + ImageAnalyser)
    ├── CMakeLists.txt
    ├── build.sh
    ├── rollback.sh
    ├── src/
    │   ├── plugin.cpp
    │   ├── blobs/ (blobrect, blobgroup, shader)
    │   └── imageanalyser/
    └── qml/NimehOS/qmldir
```

## 🚀 Quick Start

```cmd
cd D:\NimehOS\NimehOS
python deploy.py all
```

## 📋 Commands

| Command | Description |
|---------|-------------|
| `snapshot` | Take VirtualBox snapshot |
| `deploy` | Deploy QML + scripts only |
| `build-cpp` | Build and install C++ plugin on VM |
| `configure` | Configure hyprland + hyprlock |
| `restart` | Restart quickshell |
| `shot` | Take screenshot |
| `logs` | Show quickshell logs |
| `list` | List files to deploy |
| `help` | Show help |
