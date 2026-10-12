// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// Animations.qml — مرکز توکن‌های انیمیشن NimehOS
// ============================================================
//
// این فایل یک Singleton است که تمام منحنی‌های easing، مدت‌زمان‌ها،
// و الگوهای استاندارد انیمیشن را در خود نگه می‌دارد. تمام Behavior،
// Transition، NumberAnimation و ColorAnimation در NimehOS باید از این
// توکن‌ها استفاده کنند تا حرکت کل سیستم یکدست و هماهنگ باشد.
//
// الگوبرداری شده از:
//
//   - به‌جای QList<qreal> bezier (که نیاز به C++ دارد)، از QEasingCurve.Type
//     استاندارد QML استفاده می‌کنیم تا ۱۰۰٪ QML-only بماند.
//   - OutBack با overshoot متفاوت (emphasize=1.4, spring=1.2, bouncy=2.0)
//     با پراپرتی‌های جداگانه ارائه می‌شود.
//
// نحوه استفاده:
//   import NimehOS
//   Rectangle {
//       Behavior on scale {
//           NumberAnimation {
//               duration: Animations.medium02
//               easing.type: Animations.emphasize
//               easing.overshoot: Animations.emphasizeOvershoot
//           }
//       }
//   }

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    // ============================================================
    // ۱. توکن‌های مدت زمان (Duration Tokens) — واحد ms
    // ============================================================
    //
    // این مقادیر طبق spec NimehOS تنظیم شده‌اند. هر زمانی که به duration
    // نیاز دارید، از این پراپرتی‌ها استفاده کنید، نه از عدد هاردکد.

    readonly property int instant: 0       // بدون انیمیشن (تغییر فوری)
    readonly property int fast01: 100      // ریز-تعامل‌ها (state layer press)
    readonly property int fast02: 200      // تعامل سریع (color fade کوتاه)
    readonly property int medium01: 250    // تعامل متوسط سریع (hover lift)
    readonly property int medium02: 300    // پیش‌فرض برای اکثر تغییرات
    readonly property int medium03: 350    // باز شدن popup
    readonly property int medium04: 400    // drawer open/close
    readonly property int slow01: 500      // تغییرات بزرگ (panel swap)
    readonly property int slow02: 700      // lock screen انتقال‌ها
    readonly property int slow03: 1000     // splash / boot / startup

    // ============================================================
    // ۲. توکن‌های Easing — به‌صورت QEasingCurve.Type (int)
    // ============================================================
    //
    // هر پراپرتی یک int است که می‌توان آن را مستقیماً به `easing.type` در
    // NumberAnimation/ColorAnimation/PropertyAnimation اختصاص داد.
    //
    // برای OutBack variantها (emphasize/spring/bouncy)، مقدار overshhoot
    // جداگانه ارائه شده و باید به `easing.overshoot` اختصاص داده شود.

    // standard: OutCubic — حرکت استاندارد و خوانا (برای اکثر تعامل‌ها)
    readonly property int standard: Easing.OutCubic

    // emphasize: OutBack با overshoot 1.4 — برای تاکید با برگشت جزئی
    // (تغییرات حالت مهم، باز شدن popup)
    readonly property int emphasize: Easing.OutBack
    readonly property real emphasizeOvershoot: 1.4

    // decelerate: OutQuint — کاهش سرعت شدید در انتها (ورود محتوا)
    readonly property int decelerate: Easing.OutQuint

    // accelerate: InCubic — شروع ملایم و افزایش سرعت (خروج محتوا)
    readonly property int accelerate: Easing.InCubic

    // sharp: InOutCubic — ورود و خروج قرینه (تغییرات قرینه)
    readonly property int sharp: Easing.InOutCubic

    // spring: OutBack با overshoot 1.2 — حس فنری نرم (انتقال‌های ملایم)
    readonly property int spring: Easing.OutBack
    readonly property real springOvershoot: 1.2

    // bouncy: OutBack با overshoot 2.0 — حس بازیافتی قوی (game-like)
    readonly property int bouncy: Easing.OutBack
    readonly property real bouncyOvershoot: 2.0

    // smooth: InOutSine — نرم و sin-like (تغییرات رنگ)
    readonly property int smooth: Easing.InOutSine

    // gentle: InOutQuad — ملایم (انتقال‌های آرام)
    readonly property int gentle: Easing.InOutQuad

    // quick: OutQuart — توقف سریع در انتها (بسته شدن)
    readonly property int quick: Easing.OutQuart

    // lazy: InOutQuart — آرام و قرینه (long fade)
    readonly property int lazy: Easing.InOutQuart

    // snap: OutExpo — چسبیدن ناگهانی به هدف (state layer press)
    readonly property int snap: Easing.OutExpo

    // ============================================================
    // ۳. توابع کمکی
    // ============================================================

    // behavior: ساخت کانفیگ Behavior برای استفاده در Behavior blocks.
    // خروجی: شیء JS با target, property, duration, easing که در تعریف Behavior استفاده می‌شود.
    //
    // مثال:
    //   property var animCfg: Animations.behavior(myItem, "scale", 200, Animations.emphasize)
    //   Behavior on scale {
    //       NumberAnimation {
    //           duration: animCfg.duration
    //           easing.type: animCfg.easing
    //       }
    //   }
    function behavior(target: var, prop: string, duration: int, easing: int): var {
        return {
            target: target,
            property: prop,
            duration: duration != null ? duration : root.medium02,
            easing: easing != null ? easing : root.standard
        }
    }

    // colorAnim: کانفیگ ColorAnimation با easing smooth (پیش‌فرض برای تغییرات رنگ).
    // مدت پیش‌فرض medium02 = 300ms است.
    function colorAnim(duration: int): var {
        return {
            duration: duration != null ? duration : root.medium02,
            easingType: root.smooth
        }
    }

    // numberAnim: کانفیگ NumberAnimation با easing اختیاری.
    function numberAnim(duration: int, easing: int): var {
        return {
            duration: duration != null ? duration : root.medium02,
            easingType: easing != null ? easing : root.standard
        }
    }

    // scaleHover: محاسبه scale بر اساس hover بودن.
    // normalScale پیش‌فرض = 1.0، hoverScale پیش‌فرض = 1.05.
    function scaleHover(hovered: bool, normalScale: real, hoverScale: real): real {
        const ns = normalScale != null ? normalScale : 1.0
        const hs = hoverScale != null ? hoverScale : 1.05
        return hovered ? hs : ns
    }

    // opacityHover: محاسبه opacity بر اساس hover بودن.
    // وقتی hovered: 1.0، در غیر این‌صورت: 0.6.
    function opacityHover(hovered: bool): real {
        return hovered ? 1.0 : 0.6
    }

    // applyEasing: اعمال easing و overshoot به یک animation object.
    // برای OutBack variantها، overshoot را هم تنظیم می‌کند.
    // نمونه استفاده:
    //   Component.onCompleted: Animations.applyEasing(myNumAnim, "emphasize")
    function applyEasing(anim: var, name: string): void {
        if (anim == null || anim.easing == null) return
        switch (name) {
        case "standard":
            anim.easing.type = root.standard
            break
        case "emphasize":
            anim.easing.type = root.emphasize
            anim.easing.overshoot = root.emphasizeOvershoot
            break
        case "decelerate":
            anim.easing.type = root.decelerate
            break
        case "accelerate":
            anim.easing.type = root.accelerate
            break
        case "sharp":
            anim.easing.type = root.sharp
            break
        case "spring":
            anim.easing.type = root.spring
            anim.easing.overshoot = root.springOvershoot
            break
        case "bouncy":
            anim.easing.type = root.bouncy
            anim.easing.overshoot = root.bouncyOvershoot
            break
        case "smooth":
            anim.easing.type = root.smooth
            break
        case "gentle":
            anim.easing.type = root.gentle
            break
        case "quick":
            anim.easing.type = root.quick
            break
        case "lazy":
            anim.easing.type = root.lazy
            break
        case "snap":
            anim.easing.type = root.snap
            break
        default:
            anim.easing.type = root.standard
        }
    }

    // ============================================================
    // ۴. الگوهای استاندارد انیمیشن (Preset Blocks)
    // ============================================================
    //
    // هر preset یک شیء JS است با فیلدهای duration, easingType, overshoot,
    // from, to که در NumberAnimation/ColorAnimation/PropertyAnimation استفاده
    // می‌شود. این الگوها برای یکدست‌سازی حرکت کل سیستم طراحی شده‌اند.
    //
    // الگوی استفاده:
    //   Behavior on scale {
    //       NumberAnimation {
    //           duration: Animations.hoverLift.duration
    //           easing.type: Animations.hoverLift.easingType
    //           easing.overshoot: Animations.hoverLift.overshoot
    //       }
    //   }

    // HoverLift: برای آیکون‌ها — scale با تأکید هنگام hover
    readonly property var hoverLift: ({
        duration: root.fast02,
        easingType: root.emphasize,
        overshoot: root.emphasizeOvershoot
    })

    // ClickPress: برای دکمه‌ها — scale کاهشی سریع هنگام کلیک
    readonly property var clickPress: ({
        duration: root.instant,
        easingType: root.snap,
        overshoot: 0.0
    })

    // FadeIn: باز شدن پنل — opacity از 0 به 1 با smooth
    readonly property var fadeIn: ({
        duration: root.medium02,
        easingType: root.smooth,
        from: 0.0,
        to: 1.0
    })

    // FadeOut: بسته شدن پنل — opacity از 1 به 0 با quick
    readonly property var fadeOut: ({
        duration: root.fast02,
        easingType: root.quick,
        from: 1.0,
        to: 0.0
    })

    // SlideIn: ورود پنل از یک جهت — emphasize با overshoot
    // direction: "left"|"right"|"up"|"down" (در کد کاربر اعمال می‌شود)
    readonly property var slideIn: ({
        duration: root.medium04,
        easingType: root.emphasize,
        overshoot: root.emphasizeOvershoot
    })

    // SlideOut: خروج پنل به یک جهت — quick
    readonly property var slideOut: ({
        duration: root.medium02,
        easingType: root.quick,
        overshoot: 0.0
    })

    // ScaleIn: باز شدن popup — scale از 0.8 به 1.0
    readonly property var scaleIn: ({
        duration: root.medium02,
        easingType: root.emphasize,
        overshoot: root.emphasizeOvershoot,
        from: 0.8,
        to: 1.0
    })

    // ScaleOut: بسته شدن popup — scale از 1.0 به 0.8
    readonly property var scaleOut: ({
        duration: root.fast02,
        easingType: root.quick,
        overshoot: 0.0,
        from: 1.0,
        to: 0.8
    })

    // ============================================================
    // ۵. کامپوننت‌های QML برای استفاده با Loader
    // ============================================================
    //
    // این Componentها برای استفاده با Loader یا به‌عنوان template طراحی
    // شده‌اند. هر کدام یک NumberAnimation یا ColorAnimation با پیکربندی
    // استاندارد NimehOS می‌سازند.
    //
    // نمونه استفاده:
    //   Loader {
    //       sourceComponent: Animations.fadeInComponent
    //       onLoaded: if (item) item.start()
    //   }

    // NumberAnimation برای hover lift
    readonly property Component hoverLiftComponent: Component {
        NumberAnimation {
            duration: root.fast02
            easing.type: root.emphasize
            easing.overshoot: root.emphasizeOvershoot
        }
    }

    // ColorAnimation استاندارد برای تغییرات رنگ
    readonly property Component colorAnimationComponent: Component {
        ColorAnimation {
            duration: root.medium02
            easing.type: root.smooth
        }
    }

    // NumberAnimation برای fade in
    readonly property Component fadeInComponent: Component {
        NumberAnimation {
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: root.medium02
            easing.type: root.smooth
        }
    }

    // NumberAnimation برای fade out
    readonly property Component fadeOutComponent: Component {
        NumberAnimation {
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: root.fast02
            easing.type: root.quick
        }
    }

    // NumberAnimation برای scale in
    readonly property Component scaleInComponent: Component {
        NumberAnimation {
            property: "scale"
            from: 0.8
            to: 1.0
            duration: root.medium02
            easing.type: root.emphasize
            easing.overshoot: root.emphasizeOvershoot
        }
    }

    // NumberAnimation برای scale out
    readonly property Component scaleOutComponent: Component {
        NumberAnimation {
            property: "scale"
            from: 1.0
            to: 0.8
            duration: root.fast02
            easing.type: root.quick
        }
    }

    // ============================================================
    // ۶. نگاشت نام به easing (برای استفاده پویا)
    // ============================================================
    //
    // جدول lookup برای تبدیل نام (string) به نوع easing.
    // نمونه استفاده: Animations.easingByName["emphasize"] → Easing.OutBack

    readonly property var easingByName: ({
        "standard":   root.standard,
        "emphasize":  root.emphasize,
        "decelerate": root.decelerate,
        "accelerate": root.accelerate,
        "sharp":      root.sharp,
        "spring":     root.spring,
        "bouncy":     root.bouncy,
        "smooth":     root.smooth,
        "gentle":     root.gentle,
        "quick":      root.quick,
        "lazy":       root.lazy,
        "snap":       root.snap
    })

    // نگاشت نام به overshoot (یا null برای non-Back).
    readonly property var overshootByName: ({
        "emphasize": root.emphasizeOvershoot,
        "spring":    root.springOvershoot,
        "bouncy":    root.bouncyOvershoot
    })

    // نگاشت نام به مدت پیش‌فرض (برای هر الگوی استاندارد).
    readonly property var durationByName: ({
        "hoverLift":  root.fast02,
        "clickPress": root.instant,
        "fadeIn":     root.medium02,
        "fadeOut":    root.fast02,
        "slideIn":    root.medium04,
        "slideOut":   root.medium02,
        "scaleIn":    root.medium02,
        "scaleOut":   root.fast02
    })
}
