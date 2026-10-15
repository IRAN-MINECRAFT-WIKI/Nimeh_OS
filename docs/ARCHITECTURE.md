# ARCHITECTURE — معماری NimehOS (فاز ۰)

> این سند معماری NimehOS را پس از ممیزی شاخه `feat/visual-and-perf` تعریف می‌کند.
> اصل کلیدی: **بیشترین تعاملات سیستمی از سرویس‌های داخلی Quickshell v0.3.0 استفاده می‌کنند**؛
> سرویس‌های Python فقط برای آنچه در Quickshell موجود نیست (شبکه، روشنایی، فهرست برنامه‌ها).
>
> شاخه: `feat/visual-and-perf`
> زبان: فارسی (RTL) برای توضیحات؛ انگلیسی برای اصطلاحات فنی، نام فایل‌ها، و کد.

---

## ۱. لایه‌های سیستم

معماری NimehOS از ۵ لایه تشکیل می‌شود. داده از پایین به بالا جریان دارد؛ UI هرگز مستقیم با سیستم صحبت نمی‌کند (مگر از طریق سرویس‌های داخلی Quickshell یا سرویس‌های Python).

```
┌────────────────────────────────────────────────────────────┐
│  لایه ۵: apps/                                             │
│  اپ‌های مستقل (Settings, File Manager, ...)                │
│  Qt6/QML — مستقل از شل                                     │
└────────────────────────────────────────────────────────────┘
                            ▲
┌────────────────────────────────────────────────────────────┐
│  لایه ۴: shell/  (QML — فقط نمایش)                          │
│  نمایش داده از Quickshell services + Python services       │
│  هیچ فرمان سیستمی مستقیم                                   │
└────────────────────────────────────────────────────────────┘
                            ▲
┌────────────────────────────────────────────────────────────┐
│  لایه ۳: Python services (فقط برای مmissing features)       │
│  network (nmcli) | brightness (brightnessctl) | app-registry│
│  خروجی JSON در $XDG_RUNTIME_DIR/nimehos/state.json          │
└────────────────────────────────────────────────────────────┘
                            ▲
┌────────────────────────────────────────────────────────────┐
│  لایه ۲: Quickshell built-in services (v0.3.0)             │
│  Pipewire, UPower, Notifications, Mpris, Hyprland,         │
│  Bluetooth, SystemTray, Pam                                │
└────────────────────────────────────────────────────────────┘
                            ▲
┌────────────────────────────────────────────────────────────┐
│  لایه ۱: Hyprland (کانفیگ Lua)                             │
│  compositor + keybinds فقط — بدون منطق                     │
└────────────────────────────────────────────────────────────┘
```

### توضیح لایه‌ها

| لایه | نام | مسئولیت | تکنولوژی |
|------|-----|---------|----------|
| **۱** | Hyprland | compositor، مدیریت پنجره، keybinds. هیچ منطق UI. | `hyprland.lua` (تأیید شده کار می‌کند روی 0.55.2). `hyprland.conf` خطا می‌دهد — فعلاً استفاده نشود. |
| **۲** | Quickshell built-in services | منبع اصلی داده سیستم: صدا، باتری، اعلان‌ها، رسانه، پنجره‌ها، بلوتوث، system tray، PAM. | ماژول‌های `Quickshell.Services.*` و `Quickshell.Hyprland`. |
| **۳** | Python services | فقط برای قابلیت‌هایی که در Quickshell نیست: شبکه (nmcli)، روشنایی (brightnessctl)، فهرست برنامه‌ها (اسکن `.desktop`). | Python 3، خروجی JSON در state.json. |
| **۴** | shell/ | نمایش. فقط می‌خواند (از Quickshell services و state.json). هیچ فرمان سیستمی مستقیم. | Quickshell QML. |
| **۵** | apps/ | اپ‌های مستقل. | Qt6/QML. |

---

## ۲. جدول سرویس‌های داخلی Quickshell

این جدول بر اساس بررسی caelestia-shell (که از Quickshell v0.3.0 استفاده می‌کند) تأیید شده است.

### آنچه در Quickshell داخلی است (لازم به Python نیست)

| سرویس | ماژول Quickshell | چه می‌دهد | نمونه استفاده |
|-------|------------------|-----------|----------------|
| Audio (PipeWire) | `Quickshell.Services.Pipewire` | `Pipewire.defaultAudioSink`, `PwNode`, volume, muted, sinks, sources | کنترل صدا در QuickSettings، OSD |
| Battery (UPower) | `Quickshell.Services.UPower` | `UPower.displayDevice.percentage`, `UPower.onBattery` | BatteryIcon.qml |
| Notifications | `Quickshell.Services.Notifications` | سرور D-Bus `org.freedesktop.Notifications`، `NotifData` | NotificationCenter.qml |
| MPRIS (Media) | `Quickshell.Services.Mpris` | `Mpris.players`, track info, playback control | MediaControls.qml |
| System Tray | `Quickshell.Services.SystemTray` | `SystemTray.items`, tray icons | SystemTray.qml |
| PAM (Auth) | `Quickshell.Services.Pam` | احراز هویت PAM | LockScreen.qml |
| Hyprland | `Quickshell.Hyprland` | `Hyprland.toplevels`, `Hyprland.workspaces`, `Hyprland.activeToplevel`, `Hyprland.focusedWorkspace`, `Hyprland.usingLua` | NimehTaskbar.qml, WindowTitleBar.qml, TaskView.qml, AltTabPreview.qml |
| Bluetooth | `Quickshell.Bluetooth` | `Bluetooth.defaultAdapter`, `Bluetooth.devices` | Bluetooth.qml (Settings) |
| Wayland | `Quickshell.Wayland` | `PanelWindow`, `WlrLayershell`, layers | همه فایل‌های شل |
| I/O | `Quickshell.Io` | `Process`, `FileView`, `StdioCollector` | فقط برای لانچ برنامه، نه فرمان سیستمی |

### آنچه در Quickshell داخلی نیست (لازم به Python یا Process محدود)

| نیاز | راه‌حل در NimehOS | ملاحظه |
|------|------------------|--------|
| Network/WiFi status | سرویس Python (nmcli) | caelestia هم از `nmcli` استفاده می‌کند (`services/Nmcli.qml`) |
| Brightness | سرویس Python (brightnessctl/ddcutil) | caelestia هم از این مسیر استفاده می‌کند (`services/Brightness.qml`) |
| App registry (اسکن `.desktop`) | سرویس Python (یا پلاگین C++ در آینده) | caelestia از پلاگین C++ `AppDb` استفاده می‌کند |
| File operations (ls, mkdir, touch) | `Quickshell.Io.FileView` یا سرویس Python | برای مدیر فایل |

> **قانون طلایی**: هر داده‌ای که در جدول اول است، **نباید** از Python یا `Process` بخواند. Python فقط برای جدول دوم است.

---

## ۳. قوانین وابستگی

۸ قانون که هر PR باید رعایت کند. هر قانون با یک ID (`R1`–`R8`) شناسایی می‌شود تا در code review ارجاع داده شود.

| قانون | شرح | مثال نقض (ممنوع) | مثال صحیح |
|-------|-----|--------------------|------------|
| **R1** | UI فقط از Quickshell services یا Python state می‌خواند؛ هرگز `Process` برای فرمان سیستمی. | `Process { command: ["hyprctl", "activewindow", "-j"] }` در QML | `Quickshell.Hyprland.activeToplevel` |
| **R2** | هیچ انیمیشن بی‌نهایتی زمانی که مخفی است اجرا نمی‌شود. | `NumberAnimation { loops: Animation.Infinite }` بدون شرط `visible` | `running: visible && ...` |
| **R3** | هیچ `Timer` زیر ۱۰۰۰ms بدون دلیل موجه و کامنت. | `Timer { interval: 50; repeat: true }` برای polling | `Timer { interval: 2000 /* state refresh */ }` |
| **R4** | هیچ مسیر hardcode شده. همیشه `$HOME` یا متغیر محیطی. | `file: "/home/nimeh/..."` | `file: Qt.resolvedUrl("file://" + ...)` |
| **R5** | هیچ `import NimehOS` در QML. | `import NimehOS 1.0` | فقط `import Quickshell`, `import Quickshell.Hyprland`, `import "."` |
| **R6** | برای داده پنجره/workspace از `Quickshell.Hyprland` استفاده شود، نه `hyprctl`. | `Process { command: ["hyprctl", "activewindow", "-j"] }` | `Quickshell.Hyprland.activeToplevel` |
| **R7** | برای صدا از `Quickshell.Services.Pipewire` استفاده شود، نه `wpctl`. | `Process { command: ["wpctl", "set-volume", ...] }` | `Pipewire.defaultAudioSink.volume = ...` |
| **R8** | برای اعلان‌ها از `Quickshell.Services.Notifications` استفاده شود، نه دیمن اختصاصی. | نوشتن سرور D-Bus سفارشی در Python | استفاده از `Quickshell.Services.Notifications` |

### چک‌لیست code review (خلاصه)

- [ ] R1: هیچ `Process` برای فرمان سیستمی در QML؟
- [ ] R2: انیمیشن‌های بی‌نهایت با `visible` گیت شده‌اند؟
- [ ] R3: تایمرها ≥ ۱۰۰۰ms یا کامنت موجه دارند؟
- [ ] R4: هیچ مسیر hardcode شده؟
- [ ] R5: هیچ `import NimehOS`؟
- [ ] R6: داده پنجره از `Quickshell.Hyprland`؟
- [ ] R7: صدا از `Quickshell.Services.Pipewire`؟
- [ ] R8: اعلان‌ها از `Quickshell.Services.Notifications`؟

---

## ۴. قرارداد داده

این قرارداد **فقط** برای سرویس‌های Python است (network, brightness, apps).
سایر داده‌ها (audio, battery, notifications, windows, workspaces, media) **همگی از Quickshell built-in** می‌آیند و در state.json نیستند.

### مسیر فایل

```
$XDG_RUNTIME_DIR/nimehos/state.json
```

معمولاً: `/run/user/1000/nimehos/state.json`

### Schema

```json
{
  "version": 1,
  "timestamp": 1697000000,
  "network": {
    "connected": true,
    "ssid": "MyWiFi",
    "strength": 80,
    "type": "wifi"
  },
  "display": {
    "brightness": 80
  },
  "apps": [
    {
      "id": "firefox",
      "name": "Firefox",
      "icon": "firefox",
      "exec": "firefox"
    },
    {
      "id": "org.gnome.Nautilus",
      "name": "Files",
      "icon": "org.gnome.Nautilus",
      "exec": "nautilus"
    }
  ]
}
```

### توضیح فیلدها

| فیلد | منبع | نرخ به‌روزرسانی | توضیح |
|------|------|------------------|-------|
| `version` | ثابت | — | نسخه schema. در صورت تغییر structure، bump شود. |
| `timestamp` | Python | هر بار نوشتن | Unix timestamp (ثانیه). |
| `network.connected` | `nmcli -t -f GENERAL.STATE dev` یا `nmcli networking connectivity check` | ۵s | `true` اگر `full` یا `limited`. |
| `network.ssid` | `nmcli -t -f active,ssid dev wifi` | ۵s | خالی اگر وصل نباشد. |
| `network.strength` | `nmcli -t -f active,signal dev wifi` | ۵s | ۰–۱۰۰. |
| `network.type` | `nmcli -t -f TYPE,STATE dev` | ۵s | `"wifi"` یا `"ethernet"` یا `"none"`. |
| `display.brightness` | `brightnessctl info -m` | ۲s | ۰–۱۰۰. |
| `apps[]` | اسکن `~/.local/share/applications/*.desktop` و `/usr/share/applications/*.desktop` | ۳۰s | آرایه برنامه‌ها. `id` = نام فایل `.desktop`. |

### قوانین schema

1. **Atomic write**: Python با `mkstemp` + `os.replace` می‌نویسد تا QML هرگز JSON ناقص نخواند.
2. **Optional fields**: اگر سرویسی در دسترس نباشد (مثلاً `nmcli` نصب نباشد)، کلید موجود نباشد یا `null` باشد — QML باید با غیبت کنار بیاید.
3. **No error field**: اگر خطا رخ دهد، Python لاگ کند و فایل را به‌روز نکند. QML با timestamp قدیمی کار می‌کند.
4. **Versioning**: اگر schema تغییر کند، `version` bump شود و QML بر اساس `version` رفتار کند.

### نمونه Python (services/network.py)

```python
import subprocess, json, os

def read_network() -> dict:
    try:
        out = subprocess.check_output(
            ["nmcli", "-t", "-f", "GENERAL.STATE", "dev"],
            stderr=subprocess.DEVNULL, timeout=2
        ).decode().strip()
        connected = "100 (connected)" in out
        # ... ssid, strength, type
        return {"connected": connected, "ssid": ssid, "strength": s, "type": t}
    except Exception:
        return {"connected": False, "ssid": "", "strength": 0, "type": "none"}
```

> صدا، باتری، اعلان‌ها، پنجره‌ها، workspaces، رسانه — **همه از Quickshell built-in**، نه از Python.

---

## ۵. مدیر فایل

مدیر فایل NimehOS یک اپ مستقل در `apps/nimehos-files/` خواهد بود (نه در `shell/`).

### جدول لایسنس

| پروژه | لایسنس | سازگار با MIT؟ | تصمیم |
|-------|--------|----------------|--------|
| **sigma-file-manager** | **GNU GPLv3** | ❌ خیر | فقط الهام UX، کد کپی ممنوع. پیاده‌سازی از صفر در Qt6/QML. |

> GPLv3 با MIT سازگار نیست (در جهت MIT → GPL نه، GPL → MIT خیر). کپی کد از sigma-file-manager به NimehOS (MIT) مجاز نیست.
> NimehOS می‌تواند از sigma-file-manager به‌عنوان **مرجع UX** (نه کد) استفاده کند: چیدمان، رفتار، میانبرها.

### انتخاب تکنولوژی

- **پیشنهاد**: Qt6/QML (هماهنگ با Quickshell، reusable components از `shell/ui/`).
- **ممنوع**: GTK (تضاد با اکوسیستم Quickshell) یا کپی کد sigma (GPL).

### فهرست قابلیت‌ها (الهام از Windows Explorer + sigma UX)

| # | قابلیت | اولویت |
|---|--------|--------|
| F1 | نمایش فایل/پوشه به‌صورت grid و list | بالا |
| F2 | باز کردن/پیمایش مسیر | بالا |
| F3 | کپی/انتقال/حذف | بالا |
| F4 | جستجوی فایل | بالا |
| F5 | نمایش پیش‌نمایش تصویر | متوسط |
| F6 | نمایش خصوصیات فایل | متوسط |
| F7 | ایجاد پوشه/فایل جدید | بالا |
| F8 | میانبرهای کیبورد (Ctrl+C/V/X/Y/Z) | بالا |
| F9 | drag-and-drop | متوسط |
| F10 | نمایش فایل‌های مخفی (Ctrl+H) | پایین |

### ساختار پوشه پیشنهادی

```
apps/nimehos-files/
├── main.qml              # entry point
├── FileListView.qml
├── FileGrid.qml
├── FilePreview.qml
├── PathBar.qml
├── SearchBar.qml
├── FileContextMenu.qml
└── README.md
```

---

## ۶. ترتیب فازها

۱۰ فاز. وابستگی‌ها خطی نیستند؛ هر فاز خروجی مشخصی دارد که فاز بعدی به آن وابسته است.

| فاز | نام | خروجی | وابستگی |
|-----|-----|-------|----------|
| **۰** | مستندسازی (این فاز) | `AUDIT.md`, `ARCHITECTURE.md` | — |
| **۱** | رفع باگ قفل با تم | قفل کار می‌کند با تم swaylock | فاز ۰ |
| **۲** | حذف Process از UI | ۰ بلوک `Process` برای فرمان سیستمی در `shell/*.qml`؛ جایگزینی با `Quickshell.Services.Pipewire`, `UPower`, `Hyprland`, `Notifications`, `Mpris` | فاز ۱ (مستقل، می‌تواند موازی) |
| **۳** | سرویس‌های کم‌بود (Python) | `services/network.py`, `services/brightness.py`, `services/apps.py` + `state.json` | فاز ۰ |
| **۴** | تسک‌بار واقعی | آیکون `.desktop` + برنامه‌های در حال اجرا از `Hyprland.toplevels` | فاز ۲، فاز ۳ |
| **۵** | Start + جستجو | منوی استارت با جستجوی برنامه از app registry | فاز ۳، فاز ۴ |
| **۶** | نوار عنوان + snap + task view + alt+tab | `WindowTitleBar.qml` از `Hyprland.activeToplevel`؛ snap layouts؛ task view؛ alt+tab | فاز ۲ |
| **۷** | اعلان‌ها | `NotificationCenter.qml` از `Quickshell.Services.Notifications` | فاز ۲ |
| **۸** | انیمیشن‌ها | gating با `visible`؛ حذف حلقه‌های بی‌نهایت غیرضروری | فاز ۲ |
| **۹** | مدیر فایل + اپ تنظیمات | `apps/nimehos-files/`, `apps/nimehos-settings/` (منطق واقعی) | فاز ۳ |
| **۱۰** | QA | تست نهایی، چک‌لیست R1–R8، بنچمارک CPU | همه فازها |

### گراف وابستگی

```
فاز ۰ (مستندسازی)
   ├──> فاز ۱ (قفل) ──────────────────────┐
   ├──> فاز ۲ (Quickshell services) ──────┤
   ├──> فاز ۳ (Python services) ──────────┤
   │                                       │
   │   فاز ۲ ──> فاز ۴ (تسک‌بار) ──> فاز ۵ (Start)
   │   فاز ۲ ──> فاز ۶ (نوار عنوان + snap + taskview)
   │   فاز ۲ ──> فاز ۷ (اعلان‌ها)
   │   فاز ۲ ──> فاز ۸ (انیمیشن‌ها)
   │   فاز ۳ ──> فاز ۹ (مدیر فایل + Settings)
   │                                       │
   └───────────────────────────────────────┴──> فاز ۱۰ (QA)
```

### نکات کلیدی وابستگی

- **فاز ۲ بنیاد است**: بدون حذف `Process` از UI، فازهای ۴، ۵، ۶، ۷، ۸ نمی‌توانند شروع شوند.
- **فاز ۱ و فاز ۳ موازی**: باگ قفل مستقل از سرویس‌های Python است.
- **فاز ۸ (انیمیشن) آخرین فاز قبل از QA**: تا وقتی داده واقعی وصل نشده، بهینه‌سازی انیمیشن بی‌معنی است.
- **فاز ۹ (مدیر فایل + Settings)** بعد از فاز ۳ چون به قرارداد داده وابسته است.

---

## ۷. سؤال‌های باز

این سؤال‌ها باید پیش از شروع فاز ۱ از کاربر پرسیده شوند. برای جزئیات بیشتر به [`AUDIT.md`](./AUDIT.md) بخش ۳ مراجعه کنید.

| # | سؤال | فرمان پیشنهادی |
|---|------|-----------------|
| **Q1** | نسخه Quickshell نصب‌شده؟ | `quickshell --version` |
| **Q2** | محتوای کانفیگ swaylock فعلی؟ | `cat ~/.config/swaylock/config 2>/dev/null \|\| echo "no config"` |
| **Q3** | خروجی `swaylock -c ~/.config/swaylock/config 2>&1` (برای دیباگ بسته شدن بعد ۳ ثانیه) | `swaylock -c ~/.config/swaylock/config 2>&1` |
| **Q4** | آیا `nmcli` روی VM نصب است؟ | `which nmcli` |
| **Q5** | آیا `brightnessctl` روی VM نصب است؟ | `which brightnessctl` |

> پاسخ این سؤال‌ها در فاز ۱ به `docs/ANSWERS.md` اضافه خواهد شد.

---

## پیوست A: ماژول‌های Quickshell v0.3.0 (مرجع سریع)

```qml
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.Notifications
import Quickshell.Services.Mpris
import Quickshell.Services.SystemTray
import Quickshell.Services.Pam
```

## پیوست B: مسیرهای کلیدی

| متغیر | مقدار پیش‌فرض | کاربرد |
|-------|---------------|--------|
| `$XDG_RUNTIME_DIR` | `/run/user/1000` | state.json |
| `$HOME` | کاربر | کانفیگ، `.desktop` محلی |
| `$NIMEHOS_HOME` | (اختیاری) | ریشه پروژه در dev |
| `$NIMEHOS_STATE_INTERVAL` | `2000` (ms) | نرخ polling state در QML |
