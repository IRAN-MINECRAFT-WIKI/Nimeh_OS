#!/usr/bin/env python3
"""
Generate battery icon PNG files (0-9 levels) in Fluent design style for NimehOS.

Icons generated (24x24 transparent PNG, supersampled for smooth anti-aliasing):

    ic_fluent_battery_0_24_regular.png  (empty / critical - red outline, no fill)
    ic_fluent_battery_1_24_regular.png  (10%  - red    fill #EF4444)
    ic_fluent_battery_2_24_regular.png  (20%  - orange fill #F59E0B)
    ic_fluent_battery_3_24_regular.png  (30%  - white  fill #F0F4FF)
    ic_fluent_battery_4_24_regular.png  (40%  - white  fill #F0F4FF)
    ic_fluent_battery_5_24_regular.png  (50%  - white  fill #F0F4FF)
    ic_fluent_battery_6_24_regular.png  (60%  - white  fill #F0F4FF)
    ic_fluent_battery_7_24_regular.png  (70%  - white  fill #F0F4FF)
    ic_fluent_battery_8_24_regular.png  (80%  - white  fill #F0F4FF)
    ic_fluent_battery_9_24_regular.png  (90%+ - green  fill #22D3AE, "full")

Design:
    - Battery body: rounded rectangle, outline only (Fluent style).
    - Battery nub: small rounded rectangle on the right side.
    - Fill level: solid rounded rectangle inside the body, proportional to
      the level (level N -> N/10 of the inner width).
    - Outline is white (#F0F4FF) for levels 1-9 and red (#EF4444) for level 0
      to signal the "empty / critical" state.

Output directory:
    <project_root>/shell/icons/png/
"""

from __future__ import annotations

import os
import sys

try:
    from PIL import Image, ImageDraw
except ImportError as exc:  # pragma: no cover - helpful runtime hint
    sys.stderr.write(
        "Pillow is required. Install it with:  pip install Pillow\n"
    )
    raise

# --------------------------------------------------------------------------- #
# Configuration
# --------------------------------------------------------------------------- #

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)          # .../NimehOS_fix
OUTPUT_DIR = os.path.join(PROJECT_ROOT, "shell", "icons", "png")

# Canvas settings -- we render at 4x and downsample with LANCZOS for clean,
# anti-aliased edges (Fluent-style icons look best with smooth curves).
FINAL_SIZE = 24                 # final icon size in pixels
SCALE = 4                       # supersample factor
CANVAS = FINAL_SIZE * SCALE     # working canvas = 96x96

# Color palette (R, G, B, A)
WHITE      = (240, 244, 255, 255)   # #F0F4FF - default outline + mid-level fill
RED        = (239,  68,  68, 255)   # #EF4444 - critical (level 0/1)
ORANGE     = (245, 158,  11, 255)   # #F59E0B - low (level 2)
GREEN      = ( 34, 211, 174, 255)   # #22D3AE - full (level 9)
TRANSPARENT = (0, 0, 0, 0)

# Battery geometry, expressed in the supersampled (96x96) coordinate space.
#
#   +--------------------------------------+
#   |        battery body (outline)        |)  <- nub
#   |  +-----+                             |
#   |  |fill |                             |
#   |  +-----+                             |
#   +--------------------------------------+
#
BODY_BOX        = (8, 28, 78, 68)        # x0, y0, x1, y1
BODY_RADIUS     = 8
OUTLINE_WIDTH   = 4                       # 1px at final size

# Battery nub (small rounded rect on the right side of the body)
NUB_BOX         = (80, 38, 86, 58)
NUB_RADIUS      = 2

# Inner fill area.  Inset from BODY_BOX by OUTLINE_WIDTH so the fill sits
# cleanly inside the body outline and never overlaps the stroke.
FILL_PAD        = OUTLINE_WIDTH + 1       # 5px padding at 4x = ~1.25px final
FILL_BOX        = (
    BODY_BOX[0] + FILL_PAD,
    BODY_BOX[1] + FILL_PAD,
    BODY_BOX[2] - FILL_PAD,
    BODY_BOX[3] - FILL_PAD,
)
FILL_INNER_W    = FILL_BOX[2] - FILL_BOX[0]   # total horizontal travel for fill
FILL_RADIUS     = 2                       # slight rounding on the fill's edges

# Per-level configuration: (fill_color, outline_color)
#   - fill_color = None  -> no fill (level 0 = empty / critical)
#   - outline_color is also used for the nub so the icon stays consistent.
#
# Level 0  : red outline only, no fill            -> empty / critical
# Level 1  : red fill,    white outline           -> ~10%
# Level 2  : orange fill, white outline           -> ~20%
# Level 3-8: white fill,  white outline           -> 30%..80%
# Level 9  : green fill,  white outline           -> 90%+ (full)
LEVEL_CONFIG = {
    0: (None,     RED),
    1: (RED,      WHITE),
    2: (ORANGE,   WHITE),
    3: (WHITE,    WHITE),
    4: (WHITE,    WHITE),
    5: (WHITE,    WHITE),
    6: (WHITE,    WHITE),
    7: (WHITE,    WHITE),
    8: (WHITE,    WHITE),
    9: (GREEN,    WHITE),
}


# --------------------------------------------------------------------------- #
# Drawing
# --------------------------------------------------------------------------- #
def draw_battery(level: int) -> Image.Image:
    """Render a single battery icon (24x24 RGBA) for the given level (0-9)."""
    if level not in LEVEL_CONFIG:
        raise ValueError(f"Unsupported battery level: {level!r}")

    fill_color, outline_color = LEVEL_CONFIG[level]

    # Work on a high-resolution canvas, then downsample for anti-aliasing.
    img = Image.new("RGBA", (CANVAS, CANVAS), TRANSPARENT)
    draw = ImageDraw.Draw(img)

    # 1. Battery nub (small rounded rect on the right) --------------------- #
    draw.rounded_rectangle(
        NUB_BOX,
        radius=NUB_RADIUS,
        fill=outline_color,
    )

    # 2. Fill bar (solid rounded rect, proportional to level) -------------- #
    #    Drawn BEFORE the outline so any overflow is cleanly masked by the
    #    body stroke drawn in step 3.
    if fill_color is not None and level > 0:
        fraction = level / 10.0                       # 1 -> 10%, 9 -> 90%
        fill_w = int(round(FILL_INNER_W * fraction))
        fill_w = max(fill_w, SCALE)                   # >= 1px at final size
        fill_box = (
            FILL_BOX[0],
            FILL_BOX[1],
            FILL_BOX[0] + fill_w,
            FILL_BOX[3],
        )
        draw.rounded_rectangle(
            fill_box,
            radius=FILL_RADIUS,
            fill=fill_color,
        )

    # 3. Battery body outline (rounded rect, stroke only) ------------------ #
    draw.rounded_rectangle(
        BODY_BOX,
        radius=BODY_RADIUS,
        outline=outline_color,
        width=OUTLINE_WIDTH,
    )

    # 4. Downsample to 24x24 with LANCZOS for smooth anti-aliased edges ---- #
    img = img.resize((FINAL_SIZE, FINAL_SIZE), Image.LANCZOS)
    return img


# --------------------------------------------------------------------------- #
# Entry point
# --------------------------------------------------------------------------- #
def main() -> int:
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print(f"Output directory : {OUTPUT_DIR}")
    print(f"Canvas           : {CANVAS}x{CANVAS} (supersampled -> {FINAL_SIZE}x{FINAL_SIZE})")
    print(f"Generating {len(LEVEL_CONFIG)} battery icons ...\n")

    generated = []
    for level in sorted(LEVEL_CONFIG):
        img = draw_battery(level)
        filename = f"ic_fluent_battery_{level}_24_regular.png"
        out_path = os.path.join(OUTPUT_DIR, filename)
        img.save(out_path, format="PNG")
        size_bytes = os.path.getsize(out_path)
        generated.append((filename, size_bytes))
        print(f"  [OK]  {filename:42s}  {size_bytes:>5} bytes")

    print(f"\nTotal icons generated: {len(generated)}")
    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
