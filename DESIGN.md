# NimehOS — DESIGN.md

> **مرجع واحد طراحی و معماری**
> هر عدد، هر رنگ، هر انیمیشن باید از این فایل بیاد.
> اگه عددی اینجا نیست، اول اضافه کن، بعد استفاده کن.

---

## بخش آموزشی: یک دسکتاپ Linux چطور کار می‌کند

### ۱. لایه‌ها (از پایین به بالا)

| لایه | کار |
|------|-----|
| **Kernel** | مدیریت سخت‌افزار، پردازنده، حافظه، درایورها |
| **Services** | systemd، NetworkManager، PipeWire، UPower — سرویس‌های پس‌زمینه بدون UI. با D-Bus حرف می‌زنن |
| **Compositor (Hyprland)** | پنجره‌ها رو روی صفحه نقاشی می‌کنه، ورودی ماوس/کیبورد رو به پنجره‌ها می‌ده، موقعیت و اندازه همه پنجره‌ها رو می‌دونه |
| **Shell (Quickshell)** | به compositor می‌گه «من یه پنل هستم، با این مشخصات روی صفحه بمونم». تسک‌بار، منو، اعلان‌ها این‌جان |
| **Apps** | مرورگر، تنظیمات و غیره — فقط پنجره‌های معمولی |

**قاعده مهم:** Shell و Apps پنجره‌های خودشون رو نمی‌بینن. فقط compositor همه رو می‌بینه.

---

### ۲. پروتکل Layer Shell (چطور تسک‌بار پایین صفحه می‌مونه)

پنل‌ها (تسک‌بار، منو) با پروتکل layer-shell درخواست جای خاص می‌دن:

| پراپرتی | کار |
|---------|-----|
| `anchors` | به کدام لبه‌ی صفحه چسبیده (top, bottom, left, right) |
| `implicitHeight` / `implicitWidth` | ابعاد پنل |
| `exclusiveZone` | چند پیکسل از صفحه رو برای خودش رزرو کنه. پنجره‌های دیگه زیر این ناحیه باز می‌شن |
| `layer` | ترتیب قرارگیری: Background < Bottom < Top < Overlay |

**مثال واقعی:**
- تسک‌بار ۴۸ پیکسل → `exclusiveZone: 48`
- اگه بزرگ‌تر کنی → پنجره‌ها زیرش قطع می‌شن
- اگه کوچیک‌تر کنی → پنجره‌ها زیرش می‌رن

**منوی استارت:** یه پنجره‌ی جدا روی لایه‌ی Overlay، با margins از لبه‌ی پایین:
```
margins.bottom = ارتفاع تسک‌بار + فاصله = 48 + 8 = 56
```

---

### ۳. جریان کلیک تا تغییر ظاهر (مسیر داده)

```
کاربر کلیک می‌کنه
    ↓
StateLayer سیگنال startClicked می‌فرسته
    ↓
NimehTaskbar سیگنال رو به shell.qml می‌ده (onStartClicked)
    ↓
shell.qml مقدار root.startMenuVisible رو عوض می‌کنه
    ↓
این مقدار به visible پنجره‌ی منو و به پراپرتی open منوی داخلی bind شده
    ↓
وقتی open = true شد، State از closed به open می‌ره و Transition انیمیشن رو اجرا می‌کنه
```

**اگه یکی از این حلقه‌ها قطع باشه** (مثلاً `open` به `visible` bind نشده)، کاربر کلیک می‌کنه و هیچی نمی‌بینه. این دقیقاً همون باگ قبلیه.

---

### ۴. قواعد عددی (منبع حقیقت)

این اعداد مرجع اصلی هستن. هر عدد غیر از این‌ها باید توجیه داشته باشه:

#### مقیاس فاصله (Spacing)
| توکن | مقدار | کاربرد |
|------|-------|--------|
| `spacingXs` | 4 | فاصله داخلی کوچیک (بین آیکون و متن) |
| `spacingSm` | 8 | فاصله استاندارد بین آیتم‌ها |
| `spacingMd` | 12 | فاصله بین گروه‌ها |
| `spacingLg` | 16 | padding داخلی پنل‌ها |
| `spacingXl` | 24 | فاصله بین بخش‌های بزرگ |
| `spacingXxl` | 32 | فاصله خارجی |

#### مقیاس شعاع گوشه (Radius)
| توکن | مقدار | کاربرد |
|------|-------|--------|
| `radiusSm` | 6 | دکمه‌های کوچیک، آیتم‌های منو |
| `radiusMd` | 10 | پنل‌های متوسط، کارت‌ها |
| `radiusLg` | 14 | پنل‌های بزرگ، دیالوگ‌ها |
| `radiusXl` | 20 | پنل‌های تمام‌صفحه |
| `radiusPill` | 9999 | دکمه‌های گرد، آواتار |

#### ابعاد ثابت
| المان | مقدار | توضیح |
|-------|-------|--------|
| ارتفاع تسک‌بار | 48px | `exclusiveZone` هم باید 48 باشه |
| آیکون برنامه | 24×24 | در تسک‌بار و منو |
| نقطه‌ی وضعیت (running) | 18×3 | خط زیر آیکون فعال |
| ناحیه‌ی کلیک ماوس | حداقل 32×32 | کوچک‌تر از این سخته |
| منوی استارت | 640×700 | عرض × ارتفاع |
| فاصله منو از تسک‌بار | 8px | `margins.bottom = 56` |
| Quick Settings | 380×600 | |
| Notification Center | 380×600 | |
| Title Bar | ارتفاع 32 | دکمه‌ها 46×32 |

#### مقیاس متن (Font Size)
| توکن | مقدار | کاربرد |
|------|-------|--------|
| `textCaption` | 10 | کپشن، timestamp |
| `textTooltip` | 11 | تولتیپ، متن کمکی |
| `textSecondary` | 12 | متن ثانویه، توضیح |
| `textBody` | 13 | متن اصلی |
| `textTitle` | 16 | عنوان بخش |
| `textHeader` | 18 | عنوان پنل |
| `textLarge` | 22 | عنوان بزرگ |
| `textClock` | 120 | ساعت قفل صفحه |

#### زمان انیمیشن (Duration)
| توکن | مقدار | کاربرد |
|------|-------|--------|
| `durFast` | 120ms | کلیک، hover |
| `durNormal` | 220ms | عادی، تغییر رنگ |
| `durSlow` | 350ms | باز شدن پنل |
| `durGlacial` | 600ms | کل‌صفحه، lock screen |

#### Easing
| نام | QEasingCurve | overshoot | کاربرد |
|-----|--------------|-----------|--------|
| standard | OutCubic | — | عمومی |
| emphasize | OutBack | 1.4 | hover، باز شدن |
| decelerate | OutQuint | — | بسته شدن |
| spring | OutBack | 1.2 | drag، toggle |
| bouncy | OutBack | 2.0 | click |
| smooth | InOutSine | — | transition |

---

### ۵. مرجع ذهنی برای فهم بهتر

- **قاعده‌ی 8px:** فاصله‌ها و اندازه‌ها مضرب ۴ یا ۸ باشن تا ریتم بصری یکدست بمونه
- **تراکم:** در تسک‌بار، فضای خالی بین آیکون‌ها کم و در منو زیاد باشه
- **کنتراست:** متن روی پس‌زمینه‌ی شیشه‌ای باید حداقل کنتراست خوانایی داشته باشه. اگه تیره‌ست، متن روشن

---

### ۶. قانون‌های رفتار (برای تصمیم‌گیری)

- **وقتی شک داری کجا منطق بذاری:** اگه به سیستم یا فایل دست می‌زنه، در سرویس بذار. اگه فقط نمایش می‌ده، در UI بذار
- **اگه تغییری روی یک پنل اثر می‌گذاره:** بگو روی کدام پنل‌های دیگه هم اثر داره
- **اگه نمی‌دونی یک API یا پراپرتی وجود داره:** حدس نزن. بگو و فایل مرجع رو بخواه

---

## بخش طراحی: رنگ‌ها و تم

### پالت پایه (Dark Mode)

| توکن | رنگ | کاربرد |
|------|------|--------|
| `bg` | `#0A0A0C` | پس‌زمینه‌ی اصلی |
| `bgDeep` | `#050507` | پس‌زمینه‌ی عمیق‌تر |
| `surface` | `#1C1C1E` | سطح پنل‌ها |
| `surfaceGlass` | `rgba(28,28,30,0.94)` | سطح شیشه‌ای |
| `surfaceElevated` | `rgba(40,40,46,0.96)` | سطح بالاتر |
| `border` | `rgba(255,255,255,0.08)` | حاشیه |
| `borderStrong` | `rgba(255,255,255,0.14)` | حاشیه قوی |
| `text` | `#F0F4FF` | متن اصلی |
| `textMuted` | `#7A8598` | متن کم‌رنگ |
| `textSubtle` | `#525C6E` | متن خیلی کم‌رنگ |
| `hover` | `rgba(255,255,255,0.08)` | پس‌زمینه‌ی hover |
| `hoverStrong` | `rgba(255,255,255,0.14)` | hover قوی |
| `pressed` | `rgba(255,255,255,0.22)` | حالت فشار |

### رنگ‌های معنایی

| توکن | رنگ | کاربرد |
|------|------|--------|
| `success` | `#22D3AE` | موفقیت، آنلاین |
| `warning` | `#F59E0B` | هشدار، باتری پایین |
| `danger` | `#EF4444` | خطا، بستن |
| `info` | `#0099FF` | اطلاعات |

### Accent داینامیک (بر اساس ساعت)

| ساعت | رنگ | حس |
|------|------|-----|
| ۵-۹ صبح | `#FF6B6B` → `#FFB84D` | طلوع (گرم) |
| ۹-۱۷ روز | `#0099FF` → `#33B1FF` | روز (آبی) |
| ۱۷-۲۰ غروب | `#A78BFA` → `#E879F9` | غروب (بنفش) |
| ۲۰-۵ شب | `#6366F1` → `#8B5CF6` | شب (نیلی) |

### فونت‌ها

| کاربرد | فونت |
|--------|------|
| Latin | Inter |
| Persian | Vazirmatn |
| Mono | JetBrains Mono |

---

## بخش معماری: ساختار فایل‌ها

```
~/NimehOS/shell/
├── shell.qml              ← Entry point — همه‌ی state‌ها این‌جا
├── Theme.qml              ← Singleton — رنگ‌ها، spacing، timing
├── Animations.qml         ← Singleton — duration و easing tokens
├── qmldir                 ← تعریف همه‌ی type‌ها
├── Wallpaper.qml          ← پس‌زمینه (Background layer)
├── NimehTaskbar.qml       ← تسک‌بار (Top layer, exclusiveZone: 48)
├── NimehStartMenu.qml     ← منوی استارت (Overlay layer)
├── NimehQuickSettings.qml ← Quick Settings (Overlay layer)
├── NotificationCenter.qml ← اعلان‌ها (Overlay layer)
├── WidgetsPanel.qml       ← ویجت‌ها (Overlay layer)
├── TaskView.qml           ← نمای وظایف (Overlay layer, fullscreen)
├── LockScreen.qml         ← قفل صفحه (Overlay layer, fullscreen)
├── PowerMenu.qml          ← منوی خاموش (Overlay layer, fullscreen)
├── OSD.qml                ← Volume/Brightness OSD (Overlay layer)
├── AppLauncher.qml        ← لانچر (Overlay layer)
├── SnapLayouts.qml        ← چیدمان پنجره (Overlay layer)
├── AltTabPreview.qml      ← Alt+Tab (Overlay layer, fullscreen)
├── DesktopIcons.qml       ← آیکون‌های دسکتاپ (Background layer)
├── DesktopContextMenu.qml ← منوی راست‌کلیک (Overlay layer)
├── WindowTitleBar.qml     ← نوار عنوان پنجره (Top layer)
├── WorkspaceIndicator.qml ← نشانگر workspace (داخل تسک‌بار)
├── AIAssistantOrb.qml     ← گوی AI (داخل تسک‌بار)
├── MediaControls.qml      ← کنترل موسیقی (داخل Quick Settings)
├── ScreenEdgeActions.qml  ← گوشه‌های فعال (Overlay, ignore)
├── MicroInteractions.qml  ← رد موس (Overlay, ignore)
├── ClickRipple.qml        ← اثر کلیک
├── NovaOrb.qml            ← دکمه‌ی استارت (داخل تسک‌بار)
├── BatteryIcon.qml        ← آیکون باتری (داخل تسک‌بار)
├── GlassPanel.qml         ← کامپوننت: پنل شیشه‌ای
├── StateLayer.qml         ← کامپوننت: لایه‌ی تعامل M3
├── BlobRect.qml           ← کامپوننت: blob (QML fallback)
├── BlobGroup.qml          ← کامپوننت: گروه blob
├── ui/
│   ├── NButton.qml        ← دکمه‌ی سفارشی
│   ├── NSlider.qml        ← اسلایدر سفارشی
│   ├── NTextInput.qml     ← ورودی متن
│   └── NToggle.qml        ← toggle سفارشی
├── hyprland/
│   └── hyprland.conf      ← کانفیگ Hyprland
└── icons/png/             ← آیکون‌ها
```

---

## بخش رفتار: Keybind‌ها و IPC

### Keybind‌ها (در hyprland.conf)

| کلید | IPC Handler | کار |
|------|-------------|-----|
| `Win` (super_l) | `toggleStart` | منوی استارت |
| `Win+D` | `toggleLauncher` | لانچر برنامه |
| `Win+Tab` | `toggleTaskView` | نمای وظایف |
| `Win+Z` | `toggleSnap` | چیدمان پنجره |
| `Alt+Tab` | `toggleAltTab` | سوییچ پنجره |
| `Win+L` / `Win+B` | (loginctl) | قفل صفحه |
| `Win+X` | `togglePower` | منوی خاموش |
| `Win+N` | `toggleNotifications` | اعلان‌ها |
| `Win+W` | `toggleWidgets` | ویجت‌ها |
| `Win+A` | `toggleQuick` | Quick Settings |
| `Win+S` | `searchStart` | جستجو |
| `Win+M` | (hyprctl) | Minimize |
| `Win+V` | (togglefloating) | Floating |
| `Win+F` | (fullscreen) | Fullscreen |
| `Win+E` | (exec dolphin) | فایل‌منیجر |
| `Win+I` | (exec settings) | تنظیمات |
| `Win+R` | `toggleLauncher` | اجرا |
| `Win+Return` | (exec konsole) | ترمینال |
| `Win+Q` | (killactive) | بستن پنجره |
| `Win+Arrow` | (movewindow) | اسنپ پنجره |
| `Win+Ctrl+Arrow` | (movefocus) | فوکوس |
| `Win+1-5` | (workspace) | ورک‌اسپیس |
| `Print` | (grim) | اسکرین‌شات |

### IPC Handler‌ها (در shell.qml)

```qml
IpcHandler {
    target: "shell"
    function toggleStart()         { root.startMenuVisible = !root.startMenuVisible }
    function toggleQuick()         { root.quickSettingsVisible = !root.quickSettingsVisible }
    function toggleTaskView()      { root.taskViewVisible = !root.taskViewVisible }
    function toggleSnap()          { root.snapLayoutsVisible = !root.snapLayoutsVisible }
    function togglePower()         { root.powerMenuVisible = !root.powerMenuVisible }
    function toggleNotifications() { root.notificationCenterVisible = !root.notificationCenterVisible }
    function toggleWidgets()       { root.widgetsPanelVisible = !root.widgetsPanelVisible }
    function toggleLauncher()      { root.appLauncherVisible = !root.appLauncherVisible }
    function toggleAltTab()        { root.altTabVisible = !root.altTabVisible }
    function lockNow()             { Quickshell.execDetached(["loginctl", "lock-session"]) }
}
```

---

## بخش قواعد QML

### ❌ ممنوع

1. **`import NimehOS`** — فایل‌های محلی نیاز به import خودشون ندارن
2. **`property real radius`** روی Rectangle — تداخل با `Rectangle.radius`
3. **`property real opacity`** روی Item — تداخل با `Item.opacity`
4. **`anchors` داخل Row/Column** — از `RowLayout`/`ColumnLayout` استفاده کن
5. **هاردکد کردن رنگ** — همه از `Theme.xxx`
6. **هاردکد کردن duration** — همه از `Animations.xxx`
7. **هاردکد کردن spacing** — همه از `Theme.spacingXxx`
8. **`Process` داخل function** — باید در file scope باشه
9. **`pkill -f` بدون bracket** — SSH رو می‌کشه
10. **`subprocess` بدون `encoding="utf-8"`** — کرش با فارسی

### ✅ واجب

1. **`pragma Singleton`** فقط برای Theme.qml و Animations.qml
2. **`qmldir`** همه‌ی type‌ها رو معرفی کنه
3. **`Behavior on color/scale`** روی همه‌ی تعامل‌ها
4. **`if out:`** قبل از slicing خروجی subprocess
5. **`pkill -x`** برای exact match
6. **`pkill -f '[c]aelestia'`** با bracket trick
7. **close-on-outside-click** برای همه‌ی پاپ‌آپ‌ها
8. **Persian comments** در همه‌ی فایل‌ها

---

## بخش منابع

برای درک عمیق‌تر:

- **Wayland Book** (wayland-book.com) — توضیح Wayland و compositor
- **Quickshell Docs** (quickshell.org) — API، PanelWindow، IpcHandler
- **Hyprland Wiki** (wiki.hyprland.org) — قوانین پنجره، workspace، IPC
- **Qt Quick/QML** (doc.qt.io) — پراپرتی‌ها، State، Transition، Layout
- **layer-shell** (wlr-layer-shell-unstable-v1) — پروتکل پنل‌ها
- **Material 3** (m3.material.io) — اصول اندازه، فاصله، حرکت
- **Fluent 2** (fluent2.microsoft.design) — مرجع ظاهر و حرکت

---

## نسخه

- **v1.0** — ایجاد شده بر اساس تحلیل caelestia + تجربه‌ی NimehOS
- **قاعده:** هر تغییری در اعداد باید اینجا ثبت شه
