// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Theme.qml — مرکز رنگ و طراحی NimehOS
// ============================================================
//
// این فایل یک Singleton است که تمام منابع رنگ، فونت، توکن‌های فاصله/شعاع/زمان،
// و توابع کمکی (تاریخ شمسی، ارقام فارسی، ترکیب رنگ، acrylic/glass) را در خود
// نگه می‌دارد. تمام اجزای دیگر NimehOS باید به این سینگلتون ارجاع دهند و از
// رنگ‌های هاردکد شده استفاده نکنند.
//
// الگوبرداری شده از:
//
//   - به‌جای ImageAnalyser C++، رنگ accent بر اساس ساعت روز محاسبه می‌شود.
//   - پشتیبانی کامل از فارسی (تبدیل ارقام، تاریخ شمسی) اضافه شده.
//   - توکن‌های فاصله/شعاع/زمان طبق spec خود NimehOS تنظیم شده.
//
// نحوه استفاده:
//   import NimehOS
//   Rectangle { color: Theme.surface; radius: Theme.radiusMd }
//   Text { text: Theme.toFa(Time.hour); color: Theme.text }

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    // ============================================================
    // ۱. حالت تم (روشن/تیره)
    // ============================================================

    // حالت پیش‌فرض تیره است؛ با تغییر این پراپرتی کل UI واکنش‌گرا به‌روز می‌شود.
    property bool dark: true
    // light معکوس dark است برای راحتی در عبارات شرطی.
    readonly property bool light: !dark

    // ============================================================
    // ۲. فونت‌ها
    // ============================================================

    // فونت لاتین: Inter (مدرن، خوانا، متن‌باز، مناسب UI).
    readonly property string fontLatin: "Inter"
    // فونت فارسی/عربی: Vazirmatn (پشتیبانی کامل از حروف چسبان، ارقام فارسی).
    readonly property string fontPersian: "Vazirmatn"
    // فونت monospace برای کد و اعداد فنی: JetBrains Mono.
    readonly property string fontMono: "JetBrains Mono"
    // فونت پیش‌فرض UI (لاتین)؛ برای متن فارسی از fontPersian استفاده شود.
    readonly property string fontDefault: fontLatin

    // ============================================================
    // ۳. توکن‌های فاصله (Spacing Tokens)
    // ============================================================

    // مقادیر بر اساس spec NimehOS:
    //   xs=4, sm=8, md=12, lg=16, xl=24, xxl=32
    readonly property real spacingXs: 4
    readonly property real spacingSm: 8
    readonly property real spacingMd: 12
    readonly property real spacingLg: 16
    readonly property real spacingXl: 24
    readonly property real spacingXxl: 32

    // ============================================================
    // ۴. توکن‌های شعاع (Radius Tokens)
    // ============================================================

    //   sm=6, md=10, lg=14, xl=20, pill=9999
    readonly property real radiusSm: 6
    readonly property real radiusMd: 10
    readonly property real radiusLg: 14
    readonly property real radiusXl: 20
    readonly property real radiusPill: 9999

    // ============================================================
    // ۵. توکن‌های زمان (Timing Tokens) — واحد ms
    // ============================================================

    //   fast=120, normal=220, slow=350, glacial=600
    // (برای Animations.qml duration tokens جداگانه تعریف شده.)
    readonly property int timingFast: 120
    readonly property int timingNormal: 220
    readonly property int timingSlow: 350
    readonly property int timingGlacial: 600

    // ============================================================
    // ۶. استخراج accent پویا (بر اساس ساعت روز)
    // ============================================================
    //
    // چون ImageAnalyser از C++ در دسترس نیست، رنگ accent را بر اساس ساعت روز
    // محاسبه می‌کنیم. این رویکرد مشابه Material You است ولی منبع، ساعت به‌جای
    // wallpaper است. نقاط کلیدی:
    //   - شب (00–05): ایندیگو عمیق (~240°)
    //   - پیش‌ازطلوع (05–07): بنفش (~280°)
    //   - طلوع (07–11): نارنجی/صورتی گرم (~20°)
    //   - صبح (11–14): آبی فیروزه‌ای (~200°)
    //   - بعدازظهر (14–17): آبی روشن (~215°)
    //   - غروب (17–20): کهربایی (~30°)
    //   - شب اول (20–24): ارغوانی (~320°)
    // میان هر دو keyframe با smoothstep در فضای HSL میان‌یابی می‌شود.

    // ساعت روز به‌صورت اعشاری (14.5 = ۱۴:۳۰). هر دقیقه به‌روز می‌شود.
    property real accentHour: 0.0

    // تابع میان‌یابی hue به‌صورت کوتاه‌ترین مسیر در چرخه ۰..۳۶۰.
    function _lerpHue(h1: real, h2: real, t: real): real {
        let d = h2 - h1
        if (Math.abs(d) > 180) {
            if (d > 0) d -= 360
            else d += 360
        }
        return (h1 + d * t + 360) % 360
    }

    // تابع اصلی: ساخت رنگ accent از ساعت.
    function _accentFromHour(hour: real): color {
        const keys = [
            [0,  240, 0.65, 0.45],   // شب: ایندیگو عمیق
            [5,  280, 0.55, 0.50],   // پیش‌ازطلوع: بنفش
            [7,  20,  0.80, 0.62],   // طلوع: نارنجی گرم
            [11, 200, 0.75, 0.55],   // صبح: فیروزه‌ای
            [14, 215, 0.78, 0.58],   // بعدازظهر: آبی روشن
            [18, 30,  0.85, 0.55],   // غروب: کهربایی
            [20, 320, 0.70, 0.55],   // شب اول: ارغوانی
            [24, 240, 0.65, 0.45]    // بازگشت به شب
        ]
        for (let i = 0; i < keys.length - 1; i++) {
            if (hour >= keys[i][0] && hour <= keys[i + 1][0]) {
                const t = (hour - keys[i][0]) / (keys[i + 1][0] - keys[i][0])
                // smoothstep برای انتقال نرم‌تر
                const s = t * t * (3 - 2 * t)
                const h = root._lerpHue(keys[i][1], keys[i + 1][1], s)
                const sat = keys[i][2] + (keys[i + 1][2] - keys[i][2]) * s
                const lt = keys[i][3] + (keys[i + 1][3] - keys[i][3]) * s
                return Qt.hsla(h / 360.0, sat, lt, 1.0)
            }
        }
        return Qt.hsla(240 / 360.0, 0.65, 0.45, 1.0)
    }

    // تایمر به‌روزرسانی هر ۶۰ ثانیه (و در زمان لود).
    // به‌صورت پراپرتی Timer تعریف شده تا از هشدار "default property" برای
    // QtObject جلوگیری شود (QtObject default property برای children ندارد).
    property Timer _accentTimer: Timer {
        interval: 60000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            const now = new Date()
            root.accentHour = now.getHours() + now.getMinutes() / 60.0
        }
    }

    // ============================================================
    // ۷. رنگ‌های Accent و واریانس‌های آن
    // ============================================================
    //
    // accent      — رنگ اصلی روز
    // accentDeep  — تیره‌تر و اشباع‌تر (حالت hovered/pressed)
    // accentGlow  — روشن‌تر با شفافیت (برای افکت glow)
    // accentMuted — اشباع کاهش‌یافته (برای پس‌زمینه‌های ملایم)

    readonly property color accent: root._accentFromHour(root.accentHour)
    readonly property color accentDeep: Qt.hsla(
        accent.hslHue,
        Math.min(1.0, accent.hslSaturation + 0.15),
        Math.max(0.0, accent.hslLightness - 0.18),
        1.0
    )
    readonly property color accentGlow: Qt.hsla(
        accent.hslHue,
        accent.hslSaturation,
        Math.min(1.0, accent.hslLightness + 0.15),
        0.45
    )
    readonly property color accentMuted: Qt.hsla(
        accent.hslHue,
        accent.hslSaturation * 0.45,
        accent.hslLightness,
        1.0
    )
    // رنگ متن روی accent — روشن اگر accent تیره، تیره اگر accent روشن.
    readonly property color textOnAccent: accent.hslLightness < 0.55
        ? Qt.rgba(1, 1, 1, 1)
        : Qt.rgba(0.10, 0.10, 0.12, 1)

    // ============================================================
    // ۸. پالت Material 3 (۸۰+ رنگ)
    // ============================================================
    //
    // دو ست برای dark/light. مقادیر dark از spec NimehOS، و light بر اساس
    // معکوس‌سازی ذهنی پالت M3 تنظیم شده. تمام component‌ها باید از این
    // پراپرتی‌ها استفاده کنند، نه از هگز هاردکد.

    // --- Primary family ---
    readonly property color m3primary: dark ? accent : Qt.hsla(accent.hslHue, accent.hslSaturation * 0.85, 0.40, 1.0)
    readonly property color m3onPrimary: dark ? Qt.rgba(0.10, 0.10, 0.14, 1) : Qt.rgba(1, 1, 1, 1)
    readonly property color m3primaryContainer: dark ? Qt.hsla(accent.hslHue, accent.hslSaturation * 0.7, 0.22, 1.0)
                                                    : Qt.hsla(accent.hslHue, accent.hslSaturation * 0.7, 0.88, 1.0)
    readonly property color m3onPrimaryContainer: dark ? Qt.hsla(accent.hslHue, accent.hslSaturation * 0.6, 0.90, 1.0)
                                                       : Qt.hsla(accent.hslHue, accent.hslSaturation * 0.6, 0.12, 1.0)
    readonly property color m3inversePrimary: Qt.hsla(accent.hslHue, accent.hslSaturation, dark ? 0.40 : 0.85, 1.0)
    readonly property color m3primaryFixed: Qt.hsla(accent.hslHue, accent.hslSaturation * 0.75, 0.90, 1.0)
    readonly property color m3primaryFixedDim: Qt.hsla(accent.hslHue, accent.hslSaturation * 0.75, 0.80, 1.0)
    readonly property color m3onPrimaryFixed: Qt.rgba(0.10, 0.10, 0.14, 1)
    readonly property color m3onPrimaryFixedVariant: Qt.hsla(accent.hslHue, accent.hslSaturation * 0.6, 0.25, 1.0)
    readonly property color m3primary_paletteKeyColor: Qt.hsla(accent.hslHue, accent.hslSaturation * 0.7, 0.50, 1.0)

    // --- Secondary family ---
    readonly property color m3secondary: Qt.hsla(accent.hslHue, accent.hslSaturation * 0.35, dark ? 0.78 : 0.40, 1.0)
    readonly property color m3onSecondary: dark ? Qt.rgba(0.12, 0.12, 0.16, 1) : Qt.rgba(1, 1, 1, 1)
    readonly property color m3secondaryContainer: dark ? Qt.hsla(accent.hslHue, accent.hslSaturation * 0.3, 0.22, 1.0)
                                                       : Qt.hsla(accent.hslHue, accent.hslSaturation * 0.3, 0.88, 1.0)
    readonly property color m3onSecondaryContainer: dark ? Qt.hsla(accent.hslHue, accent.hslSaturation * 0.25, 0.90, 1.0)
                                                         : Qt.hsla(accent.hslHue, accent.hslSaturation * 0.25, 0.15, 1.0)
    readonly property color m3secondaryFixed: Qt.hsla(accent.hslHue, accent.hslSaturation * 0.4, 0.90, 1.0)
    readonly property color m3secondaryFixedDim: Qt.hsla(accent.hslHue, accent.hslSaturation * 0.4, 0.80, 1.0)
    readonly property color m3onSecondaryFixed: Qt.rgba(0.10, 0.10, 0.14, 1)
    readonly property color m3onSecondaryFixedVariant: Qt.hsla(accent.hslHue, accent.hslSaturation * 0.25, 0.25, 1.0)
    readonly property color m3secondary_paletteKeyColor: Qt.hsla(accent.hslHue, accent.hslSaturation * 0.35, 0.50, 1.0)

    // --- Tertiary family ---
    readonly property color m3tertiary: Qt.hsla((accent.hslHue + 0.33) % 1.0, accent.hslSaturation * 0.55, dark ? 0.75 : 0.42, 1.0)
    readonly property color m3onTertiary: dark ? Qt.rgba(0.12, 0.10, 0.14, 1) : Qt.rgba(1, 1, 1, 1)
    readonly property color m3tertiaryContainer: dark ? Qt.hsla((accent.hslHue + 0.33) % 1.0, accent.hslSaturation * 0.4, 0.22, 1.0)
                                                      : Qt.hsla((accent.hslHue + 0.33) % 1.0, accent.hslSaturation * 0.4, 0.88, 1.0)
    readonly property color m3onTertiaryContainer: dark ? Qt.hsla((accent.hslHue + 0.33) % 1.0, accent.hslSaturation * 0.35, 0.90, 1.0)
                                                        : Qt.hsla((accent.hslHue + 0.33) % 1.0, accent.hslSaturation * 0.35, 0.15, 1.0)
    readonly property color m3tertiaryFixed: Qt.hsla((accent.hslHue + 0.33) % 1.0, accent.hslSaturation * 0.5, 0.90, 1.0)
    readonly property color m3tertiaryFixedDim: Qt.hsla((accent.hslHue + 0.33) % 1.0, accent.hslSaturation * 0.5, 0.80, 1.0)
    readonly property color m3onTertiaryFixed: Qt.rgba(0.10, 0.10, 0.14, 1)
    readonly property color m3onTertiaryFixedVariant: Qt.hsla((accent.hslHue + 0.33) % 1.0, accent.hslSaturation * 0.35, 0.25, 1.0)
    readonly property color m3tertiary_paletteKeyColor: Qt.hsla((accent.hslHue + 0.33) % 1.0, accent.hslSaturation * 0.55, 0.50, 1.0)

    // --- Error family ---
    readonly property color m3error: dark ? "#EF4444" : "#BA1A1A"
    readonly property color m3onError: dark ? Qt.rgba(1, 1, 1, 1) : Qt.rgba(1, 1, 1, 1)
    readonly property color m3errorContainer: dark ? "#7A1A1A" : "#FFDAD6"
    readonly property color m3onErrorContainer: dark ? "#FFDAD6" : "#410002"

    // --- Success family ---
    readonly property color m3success: dark ? "#22D3AE" : "#1B7A5C"
    readonly property color m3onSuccess: dark ? Qt.rgba(0, 0, 0, 1) : Qt.rgba(1, 1, 1, 1)
    readonly property color m3successContainer: dark ? "#0F4A3A" : "#A5EED7"
    readonly property color m3onSuccessContainer: dark ? "#A5EED7" : "#002114"

    // --- Neutral / Surface family ---
    readonly property color m3background: dark ? "#0A0A0C" : "#FBFBFD"
    readonly property color m3onBackground: dark ? "#F0F4FF" : "#1A1B1F"
    readonly property color m3surface: dark ? "#1C1C1E" : "#FFFFFF"
    readonly property color m3surfaceDim: dark ? "#080809" : "#DAD9DD"
    readonly property color m3surfaceBright: dark ? "#343438" : "#FFFFFF"
    readonly property color m3surfaceContainerLowest: dark ? "#050507" : "#FFFFFF"
    readonly property color m3surfaceContainerLow: dark ? "#121215" : "#F2F0F4"
    readonly property color m3surfaceContainer: dark ? "#1C1C1E" : "#ECEEF1"
    readonly property color m3surfaceContainerHigh: dark ? "#26262A" : "#E6E7EB"
    readonly property color m3surfaceContainerHighest: dark ? "#313135" : "#E0E1E5"
    readonly property color m3onSurface: dark ? "#F0F4FF" : "#1A1B1F"
    readonly property color m3surfaceVariant: dark ? "#45464F" : "#E2E2EC"
    readonly property color m3onSurfaceVariant: dark ? "#C6C6D0" : "#45464F"
    readonly property color m3inverseSurface: dark ? "#F0F4FF" : "#2F3036"
    readonly property color m3inverseOnSurface: dark ? "#2F3036" : "#F0F4FF"
    readonly property color m3surfaceTint: m3primary

    // --- Outline / Shadow / Scrim ---
    readonly property color m3outline: dark ? "#8B8B95" : "#76767F"
    readonly property color m3outlineVariant: dark ? "#3F3F44" : "#C6C6D0"
    readonly property color m3shadow: "#000000"
    readonly property color m3scrim: "#000000"
    readonly property color m3neutral_paletteKeyColor: dark ? "#7A7A7E" : "#767680"
    readonly property color m3neutral_variant_paletteKeyColor: dark ? "#837387" : "#807586"

    // --- Terminal colors (16) ---
    readonly property color term0:  dark ? "#353434" : "#000000"
    readonly property color term1:  dark ? "#ff4c8a" : "#cc0000"
    readonly property color term2:  dark ? "#22D3AE" : "#4e9a06"
    readonly property color term3:  dark ? "#F59E0B" : "#c4a000"
    readonly property color term4:  dark ? "#0099FF" : "#3465a4"
    readonly property color term5:  dark ? "#c084fc" : "#75507b"
    readonly property color term6:  dark ? "#06b6d4" : "#06989a"
    readonly property color term7:  dark ? "#eed1d2" : "#d3d7cf"
    readonly property color term8:  dark ? "#b39e9e" : "#555753"
    readonly property color term9:  dark ? "#ff80a3" : "#ef2929"
    readonly property color term10: dark ? "#5DE2A1" : "#8ae234"
    readonly property color term11: dark ? "#FFD580" : "#fce94f"
    readonly property color term12: dark ? "#dcbc93" : "#729fcf"
    readonly property color term13: dark ? "#f9a8c2" : "#ad7fa8"
    readonly property color term14: dark ? "#ffd1c0" : "#34e2e2"
    readonly property color term15: dark ? "#ffffff" : "#eeeeec"

    // ============================================================
    // ۹. رنگ‌های Semantic (میان‌برهای NimehOS)
    // ============================================================
    //
    // این پراپرتی‌ها alias ای به پالت M3 هستند تا کد خواناتر باشد.
    // مثلاً Theme.success به‌جای Theme.m3success.

    // --- Semantic states ---
    readonly property color success: m3success
    readonly property color warning: dark ? "#F59E0B" : "#B45309"
    readonly property color danger:  m3error
    readonly property color info:    dark ? "#0099FF" : "#0066CC"

    // --- Background / Surface shortcuts ---
    readonly property color bg:             m3background
    readonly property color bgDeep:         m3surfaceContainerLowest
    readonly property color surface:        m3surface
    readonly property color surfaceGlass:   dark ? Qt.rgba(0.110, 0.110, 0.118, 0.94)   // rgba(28,28,30,0.94)
                                                 : Qt.rgba(1.0, 1.0, 1.0, 0.94)
    readonly property color surfaceElevated: dark ? Qt.rgba(0.157, 0.157, 0.180, 0.96)  // rgba(40,40,46,0.96)
                                                  : Qt.rgba(0.98, 0.98, 1.0, 0.96)
    readonly property color surfaceHover:   dark ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.04)

    // --- Text ---
    readonly property color text:       m3onBackground
    readonly property color textMuted:  dark ? "#7A8598" : "#5C6370"
    readonly property color textSubtle: dark ? "#4A5568" : "#9CA3AF"

    // --- Borders ---
    readonly property color border:        dark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.08)
    readonly property color borderStrong:  dark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.16)
    readonly property color borderHover:   dark ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(0, 0, 0, 0.20)

    // ============================================================
    // ۱۰. تابع tPalette() — پالت با transparency اعمال شده
    // ============================================================
    //
    // این برای اجزایی که روی backdrop blur قرار می‌گیرند (drawers, panels) است.
    //
    // نحوه استفاده:
    //   color: Theme.tPalette(Theme.surface, 0.7)  // surface با 70% شفافیت
    //
    // پارامتر alpha در بازه [0, 1] است.

    function tPalette(baseColor: color, alpha: real): color {
        const a = Math.max(0, Math.min(1, alpha))
        return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, a)
    }

    function layer(c: color, layerIndex: int, alpha: real): color {
        if (layerIndex === 0) return tPalette(c, alpha)
        // برای لایه‌های بالاتر، روشنایی را تنظیم کن تا کنتراست حفظ شود.
        const lum = root.getLuminance(c)
        const offset = (dark ? 1 : -1) * 0.08 * layerIndex * (1 - alpha)
        const scale = (lum + offset) / Math.max(0.01, lum)
        return Qt.rgba(
            Math.max(0, Math.min(1, c.r * scale)),
            Math.max(0, Math.min(1, c.g * scale)),
            Math.max(0, Math.min(1, c.b * scale)),
            alpha
        )
    }

    // ============================================================
    // ۱۱. توابع کمکی رنگ
    // ============================================================

    // luminance درخشان طبق فرمول BT.601 (با ریشه برای درک بهتر).
    function getLuminance(c: color): real {
        if (c.r === 0 && c.g === 0 && c.b === 0) return 0
        return Math.sqrt(0.299 * (c.r ** 2) + 0.587 * (c.g ** 2) + 0.114 * (c.b ** 2))
    }

    // glassRect: رنگ شیشه‌ای با شفافیت داده شده برای پشت panel‌ها.
    function glassRect(opacity: real): color {
        const a = Math.max(0, Math.min(1, opacity))
        return dark ? Qt.rgba(0.110, 0.110, 0.118, a)
                    : Qt.rgba(1.0, 1.0, 1.0, a)
    }

    // withAlpha: اعمال آلفای مشخص روی هر رنگ.
    function withAlpha(c: color, alpha: real): color {
        return Qt.rgba(c.r, c.g, c.b, Math.max(0, Math.min(1, alpha)))
    }

    // mix: میان‌یابی خطی دو رنگ (t=0 → c1, t=1 → c2).
    function mix(c1: color, c2: color, t: real): color {
        const s = Math.max(0, Math.min(1, t))
        return Qt.rgba(
            c1.r + (c2.r - c1.r) * s,
            c1.g + (c2.g - c1.g) * s,
            c1.b + (c2.b - c1.b) * s,
            c1.a + (c2.a - c1.a) * s
        )
    }

    // lighten: افزایش روشنایی HSL.
    function lighten(c: color, amount: real): color {
        return Qt.hsla(
            c.hslHue,
            c.hslSaturation,
            Math.min(1, c.hslLightness + amount),
            c.a
        )
    }

    // darken: کاهش روشنایی HSL.
    function darken(c: color, amount: real): color {
        return Qt.hsla(
            c.hslHue,
            c.hslSaturation,
            Math.max(0, c.hslLightness - amount),
            c.a
        )
    }

    // alterColour: تنظیم رنگ بر اساس luminance و شدت transparency
    function alterColour(c: color, alpha: real, layerIdx: int): color {
        const lum = root.getLuminance(c)
        const offset = (dark ? 1 : -1) * 0.12 * layerIdx * (1 - alpha)
        const scale = (lum + offset) / Math.max(0.01, lum)
        return Qt.rgba(
            Math.max(0, Math.min(1, c.r * scale)),
            Math.max(0, Math.min(1, c.g * scale)),
            Math.max(0, Math.min(1, c.b * scale)),
            alpha
        )
    }

    // on: رنگ متن مناسب روی c (تیره/روشن طبق lightness).
    function on(c: color): color {
        if (c.hslLightness < 0.5)
            return Qt.hsla(c.hslHue, c.hslSaturation, 0.95, 1)
        return Qt.hsla(c.hslHue, c.hslSaturation, 0.10, 1)
    }

    // ============================================================
    // ۱۲. توابع فارسی (ارقام و تاریخ شمسی)
    // ============================================================

    // آرایه ارقام فارسی برای تبدیل سریع.
    readonly property var faDigits: ["۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹"]

    // نام ماه‌های شمسی.
    readonly property var jalaliMonths: [
        "فروردین", "اردیبهشت", "خرداد", "تیر", "مرداد", "شهریور",
        "مهر", "آبان", "آذر", "دی", "بهمن", "اسفند"
    ]

    // نام روزهای هفته (شنبه تا جمعه).
    readonly property var jalaliWeekdays: [
        "شنبه", "یکشنبه", "دوشنبه", "سه‌شنبه",
        "چهارشنبه", "پنجشنبه", "جمعه"
    ]

    // toFa: تبدیل عدد/رشته به ارقام فارسی.
    // مثال: toFa(1399) → "۱۳۹۹"
    // مثال: toFa("14:30") → "۱۴:۳۰"
    function toFa(input: var): string {
        return String(input).replace(/[0-9]/g, d => root.faDigits[parseInt(d, 10)])
    }

    // jalaliConvert: تبدیل میلادی (gy, gm, gd) به شمسی (jy, jm, jd).
    // الگوریتم: JDN-based، دقت تست‌شده برای سال‌های ۱۳۴۲ تا ۱۴۱۰ شمسی.
    function _gregorianToJalali(gy: int, gm: int, gd: int): var {
        const g_d_m = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
        let jy
        if (gy > 1600) {
            jy = 979
            gy -= 1600
        } else {
            jy = 0
            gy -= 621
        }
        const gy2 = (gm > 2) ? (gy + 1) : gy
        let days = (365 * gy)
              + Math.floor((gy2 + 3) / 4)
              - Math.floor((gy2 + 99) / 100)
              + Math.floor((gy2 + 399) / 400)
              - 80
              + gd
              + g_d_m[gm - 1]
        jy += 33 * Math.floor(days / 12053)
        days %= 12053
        jy += 4 * Math.floor(days / 1461)
        days %= 1461
        if (days > 365) {
            jy += Math.floor((days - 1) / 365)
            days = (days - 1) % 365
        }
        const jm = (days < 186) ? 1 + Math.floor(days / 31) : 7 + Math.floor((days - 186) / 30)
        const jd = 1 + ((days < 186) ? (days % 31) : ((days - 186) % 30))
        return [jy, jm, jd]
    }

    // jalali: تبدیل تاریخ میلادی فعلی (یا دلخواه) به شمسی.
    // ورودی اختیاری: Date object. اگر داده نشود، تاریخ جاری استفاده می‌شود.
    // خروجی: شیء { year, month, day, monthName, monthIndex (0..11), weekdayIndex (0..6, شنبه=0), weekdayName, formatted }
    function jalali(date: var): var {
        const d = date || new Date()
        const [jy, jm, jd] = root._gregorianToJalali(d.getFullYear(), d.getMonth() + 1, d.getDate())
        // در JS getDay: یکشنبه=0، شنبه=6. ما می‌خواهیم شنبه=0، جمعه=6.
        const jsDay = d.getDay()
        const shanbeIndex = (jsDay + 1) % 7
        return {
            year: jy,
            month: jm,
            monthIndex: jm - 1,
            day: jd,
            monthName: root.jalaliMonths[jm - 1],
            weekdayIndex: shanbeIndex,
            weekdayName: root.jalaliWeekdays[shanbeIndex],
            formatted: `${root.toFa(jy)} ${root.jalaliMonths[jm - 1]} ${root.toFa(jd)}`
        }
    }

    // jalaliShort: رشته کوتاه "YYYY/MM/DD" با ارقام فارسی.
    function jalaliShort(date: var): string {
        const j = root.jalali(date)
        const mm = j.month < 10 ? `0${j.month}` : `${j.month}`
        const dd = j.day < 10 ? `0${j.day}` : `${j.day}`
        return root.toFa(`${j.year}/${mm}/${dd}`)
    }

    // ============================================================
    // ۱۳. مقداردهی اولیه
    // ============================================================

    // ============================================================
    // ۸. توکن‌های شیشه (Glass Tokens)
    // ============================================================
    // منبع: جدول شفافیت‌های انتخابی NimehOS
    // مقادیر Qt.rgba بین ۰ تا ۱ (مثلاً 32/255 ≈ ۰.۱۲۵).

    // --- Solid (بدون شفافیت) ---
    readonly property color glassSolidFill:   "#202020"
    readonly property color glassSolidBorder: "#2D2D2D"

    // --- Acrylic (Windows 11) ---
    readonly property color glassAcrylic1Fill:   Qt.rgba(32/255, 32/255, 32/255, 0.70)
    readonly property color glassAcrylic1Border: Qt.rgba(1, 1, 1, 0.08)
    readonly property int   glassAcrylic1Blur:   20
    readonly property real  glassAcrylic1Sat:    0.25   // 150% CSS → (1.5-1)*0.5

    readonly property color glassAcrylic2Fill:   Qt.rgba(32/255, 32/255, 32/255, 0.55)
    readonly property color glassAcrylic2Border: Qt.rgba(1, 1, 1, 0.12)
    readonly property int   glassAcrylic2Blur:   30
    readonly property real  glassAcrylic2Sat:    0.35   // 170% CSS

    readonly property color glassAcrylic3Fill:   Qt.rgba(32/255, 32/255, 32/255, 0.40)
    readonly property color glassAcrylic3Border: Qt.rgba(1, 1, 1, 0.18)
    readonly property int   glassAcrylic3Blur:   40
    readonly property real  glassAcrylic3Sat:    0.50   // 200% CSS

    // --- Frosted (iOS / visionOS) ---
    readonly property color glassFrosted1Fill:   Qt.rgba(1, 1, 1, 0.08)
    readonly property color glassFrosted1Border: Qt.rgba(1, 1, 1, 0.15)
    readonly property int   glassFrosted1Blur:   15

    readonly property color glassFrosted2Fill:   Qt.rgba(1, 1, 1, 0.12)
    readonly property color glassFrosted2Border: Qt.rgba(1, 1, 1, 0.22)
    readonly property int   glassFrosted2Blur:   25

    readonly property color glassFrosted3Fill:   Qt.rgba(1, 1, 1, 0.15)
    readonly property color glassFrosted3Border: Qt.rgba(1, 1, 1, 0.30)
    readonly property int   glassFrosted3Blur:   35
    readonly property real  glassFrosted3Sat:    0.25   // 150% CSS

    readonly property color glassFrosted4Fill:         Qt.rgba(1, 1, 1, 0.20)
    readonly property color glassFrosted4Border:       Qt.rgba(1, 1, 1, 0.35)
    readonly property int   glassFrosted4Blur:         45
    readonly property real  glassFrosted4Sat:          0.40   // 180% CSS
    readonly property int   glassFrosted4BorderWidth:  2

    // --- Liquid Glass (تعریف فقط، پیاده‌سازی بعداً) ---
    readonly property int  glassLiquid1Blur: 20
    readonly property real glassLiquid1Sat:  0.30   // 160% CSS
    readonly property int  glassLiquid4Blur: 50
    readonly property real glassLiquid4Sat:  0.60   // 220% CSS

    // رنگ‌های استاپ‌های گرادیانت Liquid 1 (برای استفاده در Gradient داخل QML)
    readonly property color glassLiquid1Stop0: Qt.rgba(1, 1, 1, 0.12)
    readonly property color glassLiquid1Stop1: Qt.rgba(1, 1, 1, 0.04)
    readonly property color glassLiquid1Stop2: Qt.rgba(0, 120/255, 212/255, 0.12)

    // --- Radius ---
    readonly property int glassRadiusPanel: 12
    readonly property int glassRadiusWindow: 8

    Component.onCompleted: {
        const now = new Date()
        root.accentHour = now.getHours() + now.getMinutes() / 60.0
    }
}
