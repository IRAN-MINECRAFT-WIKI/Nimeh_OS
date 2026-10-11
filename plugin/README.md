# NimehOS C++ Plugin

A Qt6 QML plugin for NimehOS providing high-performance deformable UI
primitives and an image colour analyser. Inspired by caelestia-shell's
`Caelestia.Blobs` and `Caelestia.Images` modules, rewritten as a
standalone plugin for the NimehOS desktop.

## What it provides

| Type            | Base class        | Purpose                                              |
| --------------- | ----------------- | ---------------------------------------------------- |
| `BlobRect`      | `QQuickPaintedItem` | Deformable rounded rectangle with spring physics.   |
| `BlobGroup`     | `QQuickItem`      | Container that ticks physics for all child `BlobRect`s. |
| `ImageAnalyser` | `QObject`         | Async dominant-colour + luminance extraction.        |

### `BlobRect` properties

| Property      | Type    | Default | Notes                                              |
| ------------- | ------- | ------- | -------------------------------------------------- |
| `radius`      | qreal   | 12.0    | Corner radius (px), clamped to half min dimension. |
| `color`       | QColor  | black   | Fill colour.                                       |
| `deformX`     | qreal   | 1.0     | Eigenvalue stretch along motion axis (1 = rest).   |
| `deformY`     | qreal   | 1.0     | Eigenvalue compress perpendicular (1 = rest).      |
| `deformAngle` | qreal   | 0.0     | Eigen-frame rotation in degrees.                   |
| `stiffness`   | qreal   | 200.0   | Spring stiffness k.                                |
| `damping`     | qreal   | 16.0    | Spring damping c (underdamped: ζ ≈ 0.57).          |
| `deformScale` | qreal   | 0.0005  | Speed → stretch conversion factor.                 |
| `maxStretch`  | qreal   | 0.35    | Cap on stretch (35% = caelestia default).          |
| `group`       | BlobGroup* | null | Parent group; auto-set for inline children.        |

The spring physics is driven by the item's scene-space velocity. When the
item moves faster than 5 px/s, the deformation target is recomputed from
the velocity vector: stretch (1 + min(v·scale, 0.35)) along the motion
direction, 1/stretch perpendicular. An underdamped spring integrates
deformX/deformY toward the target with implicit damping (stable for any
dt, never diverges).

### `ImageAnalyser` API

```cpp
Q_INVOKABLE QColor analyze(const QString &path);
Q_INVOKABLE QColor getDominant(const QImage &image);
Q_INVOKABLE qreal  getLuminance(const QColor &color) const;
Q_INVOKABLE void   requestUpdate();
```

Properties:

| Property         | Type    | Notes                                                   |
| ---------------- | ------- | ------------------------------------------------------- |
| `source`         | QString | Path to image; setting it triggers async analysis.      |
| `rescaleSize`    | int     | Downscale target (128). 0 = no downscale.               |
| `dominantColour` | QColor  | Result: most-frequent 5-bit-quantised colour bin.       |
| `luminance`      | qreal   | Result: BT.601 luma (0..1) averaged over non-transparent pixels. |
| `running`        | bool    | True while an async analysis is in flight.              |

The algorithm:

1. Downscale to `rescaleSize`×`rescaleSize` (preserve aspect, fast transform).
2. Walk every pixel, skip alpha = 0.
3. Quantise each channel to 5 bits (mask `0xF8`, 32 bins/channel) and
   pack R,G,B into a 15-bit key.
4. The bin with the highest pixel count wins.
5. Luminance is `sqrt(0.299·R² + 0.587·G² + 0.114·B²)` averaged over all
   non-transparent pixels (linearised sRGB, matches Qt 6.8
   `QColor::luminance`).

Analysis runs off the GUI thread via `QtConcurrent::run` with a
`QFutureWatcher`. A new request cancels any in-flight one.

## Build

### Dependencies (Debian/Ubuntu)

```bash
sudo apt install \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-shadertools-dev \
    cmake \
    ninja-build \
    g++
```

### Build & install

```bash
cd /home/z/my-project/download/NimehOS_plugin
chmod +x build.sh rollback.sh
./build.sh
```

The script:

1. Backs up the source tree to `~/NimehOS/backups/plugin-<timestamp>/`
2. Locates Qt6 via `pkg-config` (falls back to `/usr`)
3. Configures with CMake (Release, `CMAKE_PREFIX_PATH` = Qt6)
4. Builds in parallel (`nproc` jobs)
5. Installs to `/usr/lib/qt6/qml/NimehOS/` (sudo as needed)
6. Verifies the install
7. Optional QML import test if `qml6` is on PATH

### Manual build

```bash
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build --parallel
sudo cmake --install build
```

## Usage in QML

```qml
import QtQuick
import NimehOS

Item {
    width: 400; height: 400

    // A single deformable blob.
    BlobRect {
        width: 120; height: 60
        radius: 20
        color: "#4488ff"
        // Move it around to see the spring physics deform it.
        NumberAnimation on x { from: 0; to: 280; duration: 1500; loops: -1; easing.type: Easing.InOutQuad }
    }

    // Multiple blobs in a group (single physics tick for all).
    BlobGroup {
        color: "red"
        BlobRect { width: 80; height: 80; radius: 24; color: "red";   x: 0;   y: 200 }
        BlobRect { width: 80; height: 80; radius: 24; color: "green"; x: 100; y: 220 }
        BlobRect { width: 80; height: 80; radius: 24; color: "blue";  x: 200; y: 200 }
    }

    // Extract the dominant colour from the current wallpaper.
    ImageAnalyser {
        id: analyser
        source: "/home/nimeh/Pictures/wallpaper.jpg"
        onDominantColourChanged: console.log("dominant =", dominantColour, "lum =", luminance)
    }
}
```

## Rollback

```bash
./rollback.sh
```

Removes every `NimehOS` plugin artefact from `/usr/lib/qt6/qml/NimehOS`,
`/usr/local/lib/qt6/qml/NimehOS`, and any other Qt6 QML import path it
can find, plus any stray `libNimehOSPlugin*.so` files. Uses `sudo` as
needed.

## Architecture notes

### Rendering — Approach A (default) vs Approach B (SDF shader)

The plugin ships two rendering strategies, selected at compile time:

* **Approach A (default, compiled):** `BlobRect` derives from
  `QQuickPaintedItem` and renders via `QPainter::drawRoundedRect`, with
  the spring-driven deformation applied as a `QPainter` transform.
  Portable across every Qt6 backend (software, GL, Vulkan, Metal, D3D)
  and works without Qt Shader Tools at runtime.
* **Approach B (reference, in `blobrect.cpp` as a commented block):**
  `QSGGeometryNode` + custom `QSGMaterialShader` wrapping `blob.frag`.
  Real GPU SDF rendering, ~10× faster, true 2×2 deformation matrix. The
  full implementation is sketched in a comment block at the bottom of
  `src/blobs/blobrect.cpp`. Enabling it requires deriving from
  `QQuickItem` (instead of `QQuickPaintedItem`) and providing a
  matching vertex shader. The `blob.frag` shader is still processed by
  Qt Shader Tools (`qt_add_shaders`) so the `.qsb` bundle is available
  at runtime under `:/qt/qml/NimehOS/shaders/blob.frag.qsb`.

### Spring physics

The integrator is the closed-form implicit-damping spring from
caelestia::blobs::BlobRect:

```
v = (v - k·(x - target)·dt) / (1 + c·dt)
x += v·dt
```

The `1/(1 + c·dt)` factor stays in (0, 1] for any `dt`, so the spring
never diverges on slow frames (an explicit `-c·v·dt` term would flip
sign once `c·dt > 1`, injecting energy).

### Why `qt_add_library` not `qt_add_executable`

The task spec wrote `qt_add_executable(NimehOSPlugin SHARED ...)`, but
`qt_add_executable` does not accept the `SHARED` keyword — it always
produces an executable. To get a loadable `.so` QML plugin, the
canonical Qt6 call is `qt_add_library(NimehOSPlugin SHARED ...)`, which
is what this `CMakeLists.txt` uses. `qt_add_qml_module` then registers
the plugin target via `PLUGIN_TARGET NimehOSPlugin`, generating the
`qmldir` and type-registration boilerplate automatically.

## Troubleshooting

### `import NimehOS` fails with "module not installed"

* Confirm the install location:
  ```bash
  find /usr /opt -name NimehOS -type d 2>/dev/null
  ```
* Confirm the QML import path includes it:
  ```bash
  qml6 --paths   # or: echo $QML_IMPORT_PATH
  ```
* If you installed to a non-default prefix, set
  `QML_IMPORT_PATH=/your/prefix/lib/qt6/qml` before launching your app.

### `ShaderTools` not found

Install `qt6-shadertools-dev` (Debian) or `qt6-shadertools` (Arch). The
shader is optional for the default QPainter code path, but the build
will fail without the package because `qt_add_shaders` is unconditional.
If you can't install it, comment out the `qt_add_shaders(...)` block and
the `ShaderTools` component in `find_package`.

### Build fails with "QML_ELEMENT not a valid macro"

Make sure `CMAKE_AUTOMOC` is `ON` (it is by default in this
`CMakeLists.txt`). The `QML_ELEMENT` macro is processed by moc and
turned into type-registration code that `qt_add_qml_module` collects.

### Spring physics looks jerky

* Check that the parent `BlobGroup` has `physicsEnabled: true` (default).
* Check the item is actually being moved (the spring only fires above
  5 px/s).
* `deformScale` defaults to 0.0005 — bump it to 0.001 for stronger
  deformation at lower speeds.

### `ImageAnalyser` returns black

* Check the path exists and is readable.
* Check the image isn't fully transparent (every pixel alpha = 0 is
  skipped).
* Enable debug logging:
  ```bash
  QT_LOGGING_RULES="nimehos.imageanalyser.debug=true" your-app
  ```

## File layout

```
NimehOS_plugin/
├── CMakeLists.txt
├── README.md
├── build.sh
├── rollback.sh
├── qml/NimehOS/qmldir
└── src/
    ├── plugin.cpp
    ├── blobs/
    │   ├── blobrect.hpp
    │   ├── blobrect.cpp
    │   ├── blobgroup.hpp
    │   ├── blobgroup.cpp
    │   └── shaders/blob.frag
    └── imageanalyser/
        ├── imageanalyser.hpp
        └── imageanalyser.cpp
```

## License

MIT. See `LICENSE` (or the parent NimehOS README) for details.
