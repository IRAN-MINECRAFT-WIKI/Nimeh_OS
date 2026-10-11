#!/usr/bin/env python3
# ============================================================
# generate_all_icons.py — Fluent-style icon set for NimehOS
# ============================================================
#
# Generates every `ic_fluent_*_24_regular.png` icon referenced
# by the NimehOS shell QML files.  Each icon is a 24x24 PNG with
# a transparent background and white (#F0F4FF) line strokes drawn
# in a simple, modern, Fluent-like style.
#
# Rendering pipeline: every icon is composed on a 96x96 (4x
# supersampled) RGBA canvas, then LANCZOS-downsampled to 24x24
# for clean, anti-aliased curves.
#
# Usage:
#     python3 generate_all_icons.py
#
# Output:
#     ../shell/icons/png/*.png
# ============================================================

import os
from PIL import Image, ImageDraw

# ---- Configuration ---------------------------------------------------

OUT_DIR = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    "..", "shell", "icons", "png",
)
OUT_DIR = os.path.normpath(OUT_DIR)

SS = 4              # supersample factor
S = 24 * SS         # canvas size (96x96)
FINAL = 24          # output size

ICON_COLOR = (240, 244, 255, 255)   # #F0F4FF fully opaque
W = 6 * 1           # base line width (in supersampled px) -> ~1.5px final
W_THIN = 5          # thinner line variant
W_BOLD = 7          # bolder line variant

# ---- Helpers ---------------------------------------------------------


def new_canvas():
    """Return a fresh transparent RGBA canvas + draw context."""
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    return img, d


def save(img, name):
    """Downsample SSx and write the final 24x24 PNG."""
    final = img.resize((FINAL, FINAL), Image.LANCZOS)
    path = os.path.join(OUT_DIR, name)
    final.save(path, "PNG")
    return path


# ---- Primitive drawing helpers ---------------------------------------


def line(d, p1, p2, width=W):
    d.line([p1, p2], fill=ICON_COLOR, width=width)
    # Round the line caps with small ellipses for a Fluent look.
    r = width // 2
    for pt in (p1, p2):
        d.ellipse([pt[0] - r, pt[1] - r, pt[0] + r, pt[1] + r],
                  fill=ICON_COLOR)


def polyline(d, points, width=W, closed=False):
    for i in range(len(points) - 1):
        line(d, points[i], points[i + 1], width=width)
    if closed:
        line(d, points[-1], points[0], width=width)


def circle(d, cx, cy, r, outline=True, fill=False, width=W):
    bbox = [cx - r, cy - r, cx + r, cy + r]
    if fill:
        d.ellipse(bbox, fill=ICON_COLOR)
    if outline:
        d.ellipse(bbox, outline=ICON_COLOR, width=width)


def arc(d, cx, cy, r, start, end, width=W):
    bbox = [cx - r, cy - r, cx + r, cy + r]
    d.arc(bbox, start=start, end=end, fill=ICON_COLOR, width=width)


def rrect(d, x0, y0, x1, y1, r, outline=True, fill=False, width=W):
    bbox = [x0, y0, x1, y1]
    if fill:
        d.rounded_rectangle(bbox, radius=r, fill=ICON_COLOR)
    if outline:
        d.rounded_rectangle(bbox, radius=r, outline=ICON_COLOR, width=width)


def polygon(d, points, outline=True, fill=False, width=W):
    if fill:
        d.polygon(points, fill=ICON_COLOR)
    if outline:
        d.line(points + [points[0]], fill=ICON_COLOR, width=width, joint="curve")


def dot(d, cx, cy, r):
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=ICON_COLOR)


# ---- Icon definitions ------------------------------------------------
# Each function takes a draw context `d` and draws on the 96x96 canvas.
# Coordinate space: 0..96 (96 = canvas edge).  Padding ~14px is left
# around icons so they don't touch the tile edges (Fluent convention).


def ic_search(d):
    # Magnifying glass: circle top-left + handle bottom-right
    cx, cy, r = 36, 36, 22
    circle(d, cx, cy, r, outline=True, fill=False, width=W)
    # Handle
    line(d, (52, 52), (78, 78), width=W_BOLD)


def ic_folder(d):
    # Folder: tab + body
    # Body
    rrect(d, 16, 30, 80, 76, r=8, outline=True, fill=False, width=W)
    # Tab top
    points = [(16, 38), (16, 26), (40, 26), (48, 34), (80, 34)]
    polyline(d, points, width=W)
    # Close the top-left corner
    line(d, (16, 38), (16, 26), width=W)


def ic_folder_add(d):
    ic_folder(d)
    # Plus badge bottom-right
    cx, cy = 70, 64
    line(d, (cx - 10, cy), (cx + 10, cy), width=W_BOLD)
    line(d, (cx, cy - 10), (cx, cy + 10), width=W_BOLD)


def ic_settings(d):
    # Gear: outer ring of teeth + inner circle
    cx, cy = 48, 48
    r_out = 32
    r_in = 22
    r_hub = 10
    # 8 teeth as short radial bars
    import math
    for i in range(8):
        a = i * (math.pi / 4)
        x1 = cx + r_in * math.cos(a)
        y1 = cy + r_in * math.sin(a)
        x2 = cx + r_out * math.cos(a)
        y2 = cy + r_out * math.sin(a)
        line(d, (x1, y1), (x2, y2), width=W)
    circle(d, cx, cy, r_hub, outline=True, fill=False, width=W)


def ic_edit(d):
    # Pencil diagonal (tip bottom-left, eraser top-right)
    # Pencil body as a thick diagonal line
    line(d, (24, 72), (66, 30), width=W_BOLD)
    # Tip (triangle at bottom-left)
    polygon(d, [(24, 72), (32, 64), (16, 80)], outline=True, fill=True, width=W)
    # Top eraser cap
    line(d, (60, 24), (72, 36), width=W_BOLD)


def ic_pen(d):
    # Fountain pen: diagonal pen + nib
    line(d, (28, 68), (66, 30), width=W_BOLD)
    # Nib triangle bottom-left
    polygon(d, [(28, 68), (36, 60), (20, 76)], outline=True, fill=True, width=W)
    # Top cap
    line(d, (60, 24), (72, 36), width=W_BOLD)
    # Center ink slit
    line(d, (30, 66), (44, 52), width=W_THIN)


def ic_globe(d):
    # Sphere with meridians + equator
    cx, cy, r = 48, 48, 32
    circle(d, cx, cy, r, outline=True, fill=False, width=W)
    # Equator (horizontal ellipse seen edge-on -> straight line)
    line(d, (cx - r, cy), (cx + r, cy), width=W)
    # Central meridian (vertical)
    line(d, (cx, cy - r), (cx, cy + r), width=W)
    # Two side meridian arcs (ellipses)
    d.ellipse([cx - 18, cy - r, cx + 18, cy + r], outline=ICON_COLOR, width=W_THIN)


def ic_wifi(d, level):
    # Concentric arcs: level 1 (smallest) up to level 4 (largest)
    cx, cy = 48, 70
    dot(d, cx, cy, 5)
    radii = [18, 30, 42]
    # Map level -> number of arcs
    # level 1 -> 1 arc (innermost), level 2 -> 2 arcs, level 3 -> 3 arcs, level 4 -> 3 arcs (full)
    n_arcs = {1: 1, 2: 2, 3: 3, 4: 3}[level]
    for i in range(n_arcs):
        r = radii[i]
        if level == 4 and i == 2:
            # full strength: brightest arc
            arc(d, cx, cy, r, 200, 340, width=W_BOLD)
        else:
            arc(d, cx, cy, r, 205, 335, width=W)


def ic_wifi_off(d):
    ic_wifi(d, 3)
    # Diagonal slash through it
    line(d, (16, 16), (80, 80), width=W_BOLD)


def ic_speaker(d, level):
    # Speaker body + waves. level 0 = no waves, 1 = 1 wave, 2 = 2 waves
    # Speaker cone (trapezoid on the left)
    polygon(d, [(20, 38), (38, 38), (54, 22), (54, 74), (38, 58), (20, 58)],
            outline=True, fill=False, width=W)
    # Waves
    for i in range(level):
        r = 12 + i * 12
        arc(d, 56, 48, r, 305, 55, width=W)


def ic_speaker_off(d):
    ic_speaker(d, 0)
    # X to the right
    line(d, (60, 34), (82, 62), width=W_BOLD)
    line(d, (82, 34), (60, 62), width=W_BOLD)


def ic_lock(d):
    # Padlock: body rect + arc shackle
    rrect(d, 26, 44, 70, 80, r=8, outline=True, fill=False, width=W)
    # Shackle arc
    arc(d, 48, 44, 18, 180, 360, width=W)
    # Keyhole dot
    dot(d, 48, 58, 4)
    line(d, (48, 58), (48, 68), width=W_THIN)


def ic_power(d):
    # Power: vertical line + open arc
    line(d, (48, 18), (48, 50), width=W_BOLD)
    arc(d, 48, 48, 26, 45, 135, width=W_BOLD)


def ic_arrow_clockwise(d):
    # Circular arrow (refresh)
    arc(d, 48, 48, 28, 30, 320, width=W_BOLD)
    # Arrowhead at top-right
    polygon(d, [(74, 22), (84, 30), (70, 34)],
            outline=False, fill=True, width=W)


def ic_sign_out(d):
    # Door/box on left + arrow pointing right
    rrect(d, 18, 24, 56, 72, r=6, outline=True, fill=False, width=W)
    # Door handle
    dot(d, 32, 48, 3)
    # Arrow
    line(d, (50, 48), (82, 48), width=W_BOLD)
    polygon(d, [(82, 48), (72, 40), (72, 56)],
            outline=False, fill=True, width=W)


def ic_weather_moon(d):
    # Crescent: big circle minus offset circle (we approximate with a chord)
    # Use a thick arc on left side
    arc(d, 50, 48, 30, 130, 230, width=W_BOLD)
    # Round the ends
    import math
    a1 = math.radians(130)
    a2 = math.radians(230)
    p1 = (50 + 30 * math.cos(a1), 48 + 30 * math.sin(a1))
    p2 = (50 + 30 * math.cos(a2), 48 + 30 * math.sin(a2))
    dot(d, int(p1[0]), int(p1[1]), W_BOLD // 2)
    dot(d, int(p2[0]), int(p2[1]), W_BOLD // 2)


def ic_pause(d):
    # Two vertical bars
    rrect(d, 30, 22, 42, 74, r=3, outline=False, fill=True)
    rrect(d, 54, 22, 66, 74, r=3, outline=False, fill=True)


def ic_play(d):
    # Triangle pointing right
    polygon(d, [(34, 22), (34, 74), (74, 48)],
            outline=False, fill=True)


def ic_previous(d):
    # Triangle pointing left + bar on left
    rrect(d, 22, 22, 30, 74, r=2, outline=False, fill=True)
    polygon(d, [(72, 22), (72, 74), (34, 48)],
            outline=False, fill=True)


def ic_next(d):
    # Triangle pointing right + bar on right
    rrect(d, 66, 22, 74, 74, r=2, outline=False, fill=True)
    polygon(d, [(22, 22), (22, 74), (62, 48)],
            outline=False, fill=True)


def ic_brightness_high(d):
    # Sun: center circle + 8 rays
    circle(d, 48, 48, 16, outline=True, fill=False, width=W)
    import math
    for i in range(8):
        a = i * (math.pi / 4)
        x1 = 48 + 22 * math.cos(a)
        y1 = 48 + 22 * math.sin(a)
        x2 = 48 + 32 * math.cos(a)
        y2 = 48 + 32 * math.sin(a)
        line(d, (x1, y1), (x2, y2), width=W_BOLD)


def ic_brightness_low(d):
    # Sun: smaller center circle + 4 rays (corners only)
    circle(d, 48, 48, 14, outline=True, fill=False, width=W)
    import math
    for i in range(4):
        a = i * (math.pi / 2) + math.pi / 4
        x1 = 48 + 20 * math.cos(a)
        y1 = 48 + 20 * math.sin(a)
        x2 = 48 + 30 * math.cos(a)
        y2 = 48 + 30 * math.sin(a)
        line(d, (x1, y1), (x2, y2), width=W_BOLD)


def ic_document_add(d):
    # Document with folded corner + plus
    points = [(26, 16), (60, 16), (74, 30), (74, 80), (26, 80)]
    polyline(d, points + [(26, 16)], width=W, closed=True)
    # Folded corner
    line(d, (60, 16), (60, 30), width=W)
    line(d, (60, 30), (74, 30), width=W)
    # Plus
    cx, cy = 50, 60
    line(d, (cx - 10, cy), (cx + 10, cy), width=W_BOLD)
    line(d, (cx, cy - 10), (cx, cy + 10), width=W_BOLD)


def ic_document(d):
    # Plain document with folded corner + text lines
    points = [(26, 16), (60, 16), (74, 30), (74, 80), (26, 80)]
    polyline(d, points + [(26, 16)], width=W, closed=True)
    line(d, (60, 16), (60, 30), width=W)
    line(d, (60, 30), (74, 30), width=W)
    # Text lines
    for y in (44, 54, 64):
        line(d, (34, y), (66, y), width=W_THIN)


def ic_arrow_sort(d):
    # Up/down arrow pair
    # Up arrow
    line(d, (38, 70), (38, 26), width=W)
    polygon(d, [(38, 18), (30, 30), (46, 30)], outline=False, fill=True)
    # Down arrow
    line(d, (58, 26), (58, 70), width=W)
    polygon(d, [(58, 78), (50, 66), (66, 66)], outline=False, fill=True)


def ic_tv(d):
    # TV: body rectangle + antenna + screen
    # Antenna
    line(d, (32, 18), (44, 32), width=W)
    line(d, (64, 18), (52, 32), width=W)
    # Body
    rrect(d, 16, 30, 80, 76, r=6, outline=True, fill=False, width=W)
    # Screen inset
    rrect(d, 24, 38, 72, 64, r=4, outline=True, fill=False, width=W_THIN)
    # Stand
    line(d, (38, 84), (58, 84), width=W_BOLD)


def ic_color(d):
    # Color palette: outline with dots
    # Palette outline: rounded blob
    rrect(d, 18, 22, 78, 78, r=22, outline=True, fill=False, width=W)
    # Thumb hole
    circle(d, 64, 64, 8, outline=True, fill=False, width=W_THIN)
    # Paint dots
    for cx, cy in [(34, 40), (48, 34), (62, 40), (38, 54)]:
        dot(d, cx, cy, 4)


def ic_image(d):
    # Picture frame + mountain + sun
    rrect(d, 16, 24, 80, 72, r=6, outline=True, fill=False, width=W)
    # Sun
    circle(d, 34, 40, 5, outline=False, fill=True)
    # Mountains
    polygon(d, [(20, 64), (38, 44), (52, 60), (62, 48), (76, 64)],
            outline=True, fill=False, width=W)


def ic_terminal(d):
    # Terminal window: rounded rect + prompt
    rrect(d, 16, 22, 80, 74, r=6, outline=True, fill=False, width=W)
    # Title bar dots
    dot(d, 26, 32, 2)
    dot(d, 34, 32, 2)
    # Prompt ">_"
    line(d, (28, 50), (38, 58), width=W_BOLD)
    line(d, (38, 58), (28, 66), width=W_BOLD)
    line(d, (44, 58), (66, 58), width=W_BOLD)


def ic_calculator(d):
    # Calculator body + grid of buttons
    rrect(d, 24, 16, 72, 80, r=8, outline=True, fill=False, width=W)
    # Screen
    rrect(d, 32, 24, 64, 38, r=3, outline=True, fill=False, width=W_THIN)
    # Buttons grid (3x3 dots)
    for r in range(3):
        for c in range(3):
            cx = 38 + c * 14
            cy = 50 + r * 12
            dot(d, cx, cy, 2)


def ic_music(d):
    # Music note: stem + flag + bottom dot
    # Stem
    line(d, (56, 20), (56, 70), width=W_BOLD)
    # Flag
    line(d, (56, 20), (74, 28), width=W_BOLD)
    # Note head (oval tilted)
    d.ellipse([36, 60, 60, 80], fill=ICON_COLOR)


def ic_mail(d):
    # Envelope: rectangle + flap
    rrect(d, 16, 28, 80, 68, r=6, outline=True, fill=False, width=W)
    # Flap (two lines from top corners to center)
    line(d, (16, 32), (48, 52), width=W)
    line(d, (80, 32), (48, 52), width=W)


def ic_map(d):
    # Map: folded paper with a pin
    # Folds
    points = [(20, 28), (40, 22), (56, 28), (76, 22), (76, 68),
              (56, 74), (40, 68), (20, 74)]
    polyline(d, points + [(20, 28)], width=W, closed=True)
    # Inner fold lines
    line(d, (40, 22), (40, 68), width=W_THIN)
    line(d, (56, 28), (56, 74), width=W_THIN)
    # Pin
    circle(d, 48, 42, 6, outline=True, fill=False, width=W_THIN)
    line(d, (48, 48), (48, 60), width=W_THIN)


def ic_camera(d):
    # Camera body + lens
    rrect(d, 14, 32, 82, 74, r=8, outline=True, fill=False, width=W)
    # Viewfinder bump
    rrect(d, 34, 24, 58, 34, r=3, outline=True, fill=False, width=W)
    # Lens
    circle(d, 48, 54, 14, outline=True, fill=False, width=W)
    circle(d, 48, 54, 6, outline=False, fill=True)
    # Flash dot
    dot(d, 72, 42, 3)


def ic_record(d):
    # Filled circle (record dot)
    circle(d, 48, 48, 22, outline=False, fill=True)


def ic_chevron_right(d):
    polygon(d, [(40, 22), (60, 48), (40, 74)],
            outline=False, fill=False, width=W)
    polyline(d, [(40, 22), (60, 48), (40, 74)], width=W_BOLD)


def ic_chevron_left(d):
    polyline(d, [(56, 22), (36, 48), (56, 74)], width=W_BOLD)


def ic_chevron_down(d):
    polyline(d, [(22, 40), (48, 60), (74, 40)], width=W_BOLD)


def ic_chevron_up(d):
    polyline(d, [(22, 56), (48, 36), (74, 56)], width=W_BOLD)


def ic_more(d):
    # Three horizontal dots
    for cx in (30, 48, 66):
        dot(d, cx, 48, 5)


def ic_close(d):
    # X
    line(d, (24, 24), (72, 72), width=W_BOLD)
    line(d, (72, 24), (24, 72), width=W_BOLD)


def ic_checkmark(d):
    # Check mark
    polyline(d, [(20, 50), (40, 70), (76, 28)], width=W_BOLD)


def ic_warning(d):
    # Triangle with exclamation
    polygon(d, [(48, 18), (80, 78), (16, 78)], outline=True, fill=False, width=W)
    # Exclamation
    line(d, (48, 38), (48, 60), width=W_BOLD)
    dot(d, 48, 70, 3)


def ic_error(d):
    # Circle with X
    circle(d, 48, 48, 30, outline=True, fill=False, width=W)
    line(d, (34, 34), (62, 62), width=W_BOLD)
    line(d, (62, 34), (34, 62), width=W_BOLD)


def ic_info(d):
    # Circle with i
    circle(d, 48, 48, 30, outline=True, fill=False, width=W)
    # dot
    dot(d, 48, 32, 4)
    # stem
    line(d, (48, 44), (48, 66), width=W_BOLD)


def ic_star(d):
    # 5-point star outline
    import math
    pts = []
    for i in range(10):
        a = -math.pi / 2 + i * math.pi / 5
        r = 30 if i % 2 == 0 else 13
        pts.append((48 + r * math.cos(a), 48 + r * math.sin(a)))
    polyline(d, pts + [pts[0]], width=W, closed=True)


def ic_heart(d):
    # Heart outline
    # Two arcs + bottom triangle
    circle(d, 34, 38, 14, outline=True, fill=False, width=W)
    circle(d, 62, 38, 14, outline=True, fill=False, width=W)
    # Bottom V
    polyline(d, [(22, 46), (48, 76), (74, 46)], width=W)
    # Cover the inner arcs so the top lobes connect cleanly
    line(d, (24, 38), (48, 50), width=W)
    line(d, (72, 38), (48, 50), width=W)


def ic_share(d):
    # Three nodes connected (share / network)
    # Central node
    circle(d, 48, 48, 7, outline=True, fill=False, width=W)
    # Top node
    circle(d, 48, 22, 7, outline=True, fill=False, width=W)
    # Bottom-right node
    circle(d, 70, 66, 7, outline=True, fill=False, width=W)
    # Connectors
    line(d, (48, 41), (48, 29), width=W_THIN)
    line(d, (54, 52), (66, 62), width=W_THIN)


def ic_delete(d):
    # Trash can: body + lid + handle
    # Lid
    rrect(d, 26, 26, 70, 32, r=2, outline=True, fill=False, width=W)
    # Handle
    line(d, (40, 26), (40, 22), width=W)
    line(d, (56, 22), (56, 26), width=W)
    line(d, (40, 22), (56, 22), width=W)
    # Body
    polyline(d, [(30, 32), (34, 78), (62, 78), (66, 32)], width=W, closed=True)
    # Vertical lines inside
    line(d, (42, 38), (42, 72), width=W_THIN)
    line(d, (54, 38), (54, 72), width=W_THIN)


def ic_copy(d):
    # Two overlapping rectangles (back one offset)
    rrect(d, 30, 16, 70, 56, r=6, outline=True, fill=False, width=W)
    rrect(d, 16, 40, 56, 80, r=6, outline=True, fill=False, width=W)


def ic_cut(d):
    # Scissors: two circles + crossing blades
    circle(d, 28, 64, 9, outline=True, fill=False, width=W)
    circle(d, 28, 32, 9, outline=True, fill=False, width=W)
    # Blades crossing
    line(d, (35, 58), (74, 24), width=W)
    line(d, (35, 38), (74, 72), width=W)
    line(d, (35, 38), (50, 50), width=W_THIN)
    line(d, (35, 58), (50, 50), width=W_THIN)


def ic_paste(d):
    # Clipboard: back rect + clip at top
    rrect(d, 22, 22, 74, 80, r=6, outline=True, fill=False, width=W)
    # Clip
    rrect(d, 38, 14, 58, 30, r=4, outline=True, fill=False, width=W)
    # Lines on the paper
    for y in (42, 52, 62, 70):
        line(d, (32, y), (64, y), width=W_THIN)


# ---- Icon registry ---------------------------------------------------

REGISTRY = {
    "ic_fluent_search_24_regular.png":           ic_search,
    "ic_fluent_folder_24_regular.png":           ic_folder,
    "ic_fluent_folder_add_24_regular.png":       ic_folder_add,
    "ic_fluent_settings_24_regular.png":         ic_settings,
    "ic_fluent_edit_24_regular.png":             ic_edit,
    "ic_fluent_pen_24_regular.png":              ic_pen,
    "ic_fluent_globe_24_regular.png":            ic_globe,
    "ic_fluent_wifi_1_24_regular.png":           lambda d: ic_wifi(d, 1),
    "ic_fluent_wifi_2_24_regular.png":           lambda d: ic_wifi(d, 2),
    "ic_fluent_wifi_3_24_regular.png":           lambda d: ic_wifi(d, 3),
    "ic_fluent_wifi_4_24_regular.png":           lambda d: ic_wifi(d, 4),
    "ic_fluent_wifi_off_24_regular.png":         ic_wifi_off,
    "ic_fluent_speaker_0_24_regular.png":        lambda d: ic_speaker(d, 0),
    "ic_fluent_speaker_1_24_regular.png":        lambda d: ic_speaker(d, 1),
    "ic_fluent_speaker_2_24_regular.png":        lambda d: ic_speaker(d, 2),
    "ic_fluent_speaker_off_24_regular.png":      ic_speaker_off,
    "ic_fluent_lock_24_regular.png":             ic_lock,
    "ic_fluent_power_24_regular.png":            ic_power,
    "ic_fluent_arrow_clockwise_24_regular.png":  ic_arrow_clockwise,
    "ic_fluent_sign_out_24_regular.png":         ic_sign_out,
    "ic_fluent_weather_moon_24_regular.png":     ic_weather_moon,
    "ic_fluent_pause_24_regular.png":            ic_pause,
    "ic_fluent_play_24_regular.png":             ic_play,
    "ic_fluent_previous_24_regular.png":         ic_previous,
    "ic_fluent_next_24_regular.png":             ic_next,
    "ic_fluent_brightness_high_24_regular.png":  ic_brightness_high,
    "ic_fluent_brightness_low_24_regular.png":   ic_brightness_low,
    "ic_fluent_document_add_24_regular.png":     ic_document_add,
    "ic_fluent_document_24_regular.png":         ic_document,
    "ic_fluent_arrow_sort_24_regular.png":       ic_arrow_sort,
    "ic_fluent_tv_24_regular.png":               ic_tv,
    "ic_fluent_color_24_regular.png":            ic_color,
    "ic_fluent_image_24_regular.png":            ic_image,
    "ic_fluent_terminal_24_regular.png":         ic_terminal,
    "ic_fluent_calculator_24_regular.png":       ic_calculator,
    "ic_fluent_music_24_regular.png":            ic_music,
    "ic_fluent_mail_24_regular.png":             ic_mail,
    "ic_fluent_map_24_regular.png":              ic_map,
    "ic_fluent_camera_24_regular.png":           ic_camera,
    "ic_fluent_record_24_regular.png":           ic_record,
    "ic_fluent_chevron_right_24_regular.png":    ic_chevron_right,
    "ic_fluent_chevron_left_24_regular.png":     ic_chevron_left,
    "ic_fluent_chevron_down_24_regular.png":     ic_chevron_down,
    "ic_fluent_chevron_up_24_regular.png":       ic_chevron_up,
    "ic_fluent_more_24_regular.png":             ic_more,
    "ic_fluent_close_24_regular.png":            ic_close,
    "ic_fluent_checkmark_24_regular.png":        ic_checkmark,
    "ic_fluent_warning_24_regular.png":          ic_warning,
    "ic_fluent_error_24_regular.png":            ic_error,
    "ic_fluent_info_24_regular.png":             ic_info,
    "ic_fluent_star_24_regular.png":             ic_star,
    "ic_fluent_heart_24_regular.png":            ic_heart,
    "ic_fluent_share_24_regular.png":            ic_share,
    "ic_fluent_delete_24_regular.png":           ic_delete,
    "ic_fluent_copy_24_regular.png":             ic_copy,
    "ic_fluent_cut_24_regular.png":              ic_cut,
    "ic_fluent_paste_24_regular.png":            ic_paste,
}


# ---- Main ------------------------------------------------------------


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    print(f"Output dir: {OUT_DIR}")
    print(f"Generating {len(REGISTRY)} icons at {FINAL}x{FINAL} "
          f"(supersampled {S}x{S})...\n")
    count = 0
    for name, fn in sorted(REGISTRY.items()):
        img, d = new_canvas()
        fn(d)
        path = save(img, name)
        count += 1
        print(f"  [{count:02d}/{len(REGISTRY)}] {name}")
    print(f"\nDone. {count} icons written to {OUT_DIR}")


if __name__ == "__main__":
    main()
