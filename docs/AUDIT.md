# AUDIT — ممیزی شاخه `feat/visual-and-perf`

> فاز ۰ — پیش از شروع بازنویسی، وضعیت فعلی مخزن NimehOS ممیزی شد.
> هدف: شناسایی دقیق مشکلات با `file:line`، تعیین اولویت، و آماده‌سازی برنامه فازها.
>
> تاریخ ممیزی: فاز ۰
> شاخه: `feat/visual-and-perf`
> زبان: فارسی (RTL) برای توضیحات؛ انگلیسی برای اصطلاحات فنی، نام فایل‌ها، و کد.

---

## ۰. خلاصه اجرایی

ممیزی شاخه `feat/visual-and-perf` نشان می‌دهد که پایه UI کار می‌کند (شل بالا می‌آید، hyprland.lua کار می‌کند، swaylock برای قفل کار می‌کند) اما چند مشکل ساختاری وجود دارد که باید پیش از افزودن قابلیت‌های جدید برطرف شوند:

1. **۷ بلوک `Process` در QML** که فرمان‌های سیستمی را مستقیم از UI اجرا می‌کنند. این الگوی ممنوعه است؛ باید با سرویس‌های داخلی Quickshell یا سرویس‌های Python جایگزین شوند.
2. **۶ حلقه انیمیشن بی‌نهایت** در `AIAssistantOrb.qml` و `NovaOrb.qml` که بدون توجه به `visible` بودن اجرا می‌شوند.
3. **۲۱ تایمر** در شل — برخی زیر ۱۰۰۰ms بدون دلیل موجه.
4. **باگ قفل با تم**: `swaylock -c ...` بعد از ~۳ ثانیه بسته می‌شود. نیاز به دیباگ.
5. **مرکز اعلان‌ها فقط داده نمونه دارد**؛ سرور D-Bus وجود ندارد (در حالی که `Quickshell.Services.Notifications` موجود است).
6. **تسک‌بار از حرف اول نام برنامه به‌جای آیکون `.desktop` استفاده می‌کند**.
7. **نوار عنوان از `hyprctl activewindow -j` استفاده می‌کند** به‌جای `Quickshell.Hyprland`.
8. **اپ تنظیمات فقط اسکلت است** (بدون منطق واقعی).

دو مشکل قبلی (مسیرهای hardcode شده و فایل‌های `.bak`) در این شاخه **برطرف شده‌اند** (✅).

---

## ۱. جدول مشکلات

هر ردیف با یک ID منحصربه‌فرد شناسایی می‌شود تا در فازهای بعدی ارجاع داده شود.

| ID | فایل:خط | اثر | اولویت | راه‌حل پیشنهادی |
|----|---------|-----|--------|------------------|
| **A1** | `LockScreen.qml:28` | قفل با تم (`swaylock -c ...`) بعد از ~۳ ثانیه بسته می‌شود؛ `pgrep hyprlock` استفاده می‌شود در حالی که hyprlock روی VM کرش می‌کند | **بحرانی** | (۱) دیباگ کانفیگ swaylock (`swaylock -c ~/.config/swaylock/config 2>&1`) برای یافتن علت خروج. (۲) حذف ارجاع به `hyprlock`. (۳) استفاده از `loginctl lock-session` + اورلی LockScreen.qml روی swaylock. |
| **A2** | `AppLauncher.qml:51` | فرمان سیستمی در UI از طریق `Process` | **بالا** | جایگزینی با سرویس Python «app registry» (اسکن `.desktop`) یا `Quickshell.Io.Process` فقط برای لانچ برنامه — نه برای اسکن دایرکتوری. |
| **A3** | `DesktopIcons.qml:23` | فرمان سیستمی (`ls` یا مشابه) در UI | **بالا** | انتقال به سرویس Python یا استفاده از `Quickshell.Io.FileView`. |
| **A4** | `LockScreen.qml:28` | استفاده از `pgrep hyprlock` برای تشخیص وضعیت قفل | **بحرانی** | (همان A1) استفاده از `loginctl show-session` یا متغیر حالت Quickshell. |
| **A5** | `MediaControls.qml:33` | کنترل رسانه از طریق `Process` (احتمالاً `playerctl`) | **بالا** | جایگزینی با `Quickshell.Services.Mpris` — `Mpris.players` داده زنده می‌دهد. |
| **A6** | `NimehStartMenu.qml:412` | اسکن `.desktop` با `sh -c` در UI | **بالا** | انتقال به سرویس Python «app registry» (یا پلاگین C++ مانند `AppDb` در caelestia). |
| **A7** | `WindowTitleBar.qml:47` | `hyprctl activewindow -j` از طریق `Process` | **بالا** | جایگزینی با `Quickshell.Hyprland.activeToplevel` — داده زنده بدون polling. |
| **A8** | `AppContextMenu.qml:117,131` | فرمان‌های سیستمی در منوی زمینه برنامه | **متوسط** | انتقال لانچ به IPC یا سرویس Python. |
| **A9** | `NotificationCenter.qml` | داده نمونه؛ بدون سرور D-Bus واقعی | **بالا** | استفاده از `Quickshell.Services.Notifications` (سرور D-Bus داخلی Quickshell). حذف داده نمونه. |
| **A10** | `NimehTaskbar.qml` | استفاده از حرف اول نام برنامه به‌جای آیکون `.desktop` | **بالا** | خواندن آیکون از app registry + نمایش برنامه‌های در حال اجرا از `Quickshell.Hyprland.toplevels`. |
| **A11** | `TaskView.qml`, `AltTabPreview.qml` | بدون داده واقعی پنجره‌ها | **متوسط** | استفاده از `Quickshell.Hyprland.toplevels` و `activeToplevel`. |
| **A12** | `AIAssistantOrb.qml`, `NovaOrb.qml` | ۶ حلقه انیمیشن بی‌نهایت بدون gating با `visible` | **متوسط** | گیت کردن هر انیمیشن با `running: visible && ...`. توقف زمان مخفی بودن. |
| **A13** | `apps/nimehos-settings/` | اپ تنظیمات فقط اسکلت است؛ صفحه‌ها بدون منطق | **پایین** | پیاده‌سازی در فاز ۹ — پس از تثبیت قرارداد داده. |
| **A14** | ۲۱ تایمر در شل | برخی زیر ۱۰۰۰ms؛ احتمال مصرف CPU | **متوسط** | ممیزی هر تایمر؛ هیچ تایمری زیر ۱۰۰۰ms بدون دلیل موجه نباشد (R3). |
| **A15** | `shell.qml` | مدیریت حالت پنل‌ها با IpcHandler | **پایین** | قابل‌قبول است؛ فقط مستندسازی شود. |
| **A16** | `hyprland/hyprland.conf` | روی Hyprland 0.55.2 خطا می‌دهد | **بالا** | استفاده از `hyprland.lua` (کار می‌کند) یا اصلاح سینتکس `hyprland.conf` به‌فرم پشتیبانی‌شده. |

### مشکلات برطرف‌شده در این شاخه ✅

| ID | شرح | وضعیت |
|----|-----|--------|
| ~~A17~~ | مسیرهای hardcode شده `/home/nimeh` | ✅ ۰ مورد (برطرف شد) |
| ~~A18~~ | فایل‌های پشتیبان `.bak` | ✅ ۰ مورد (برطرف شد) |
| ~~A19~~ | `import NimehOS` در QML | ✅ ۰ مورد (برطرف شد) |

---

## ۲. آمار فعلی

شمارش دقیق از شاخه `feat/visual-and-perf`:

| معیار | مقدار | توضیح |
|-------|-------|-------|
| تعداد بلوک `Process` در QML | **۷** | در `AppLauncher.qml`، `DesktopIcons.qml` (×۲)، `LockScreen.qml`، `MediaControls.qml`، `NimehStartMenu.qml`، `WindowTitleBar.qml`، `AppContextMenu.qml` (×۲). ملاحظه: برخی فایل‌ها چند بلوک دارند. |
| تعداد `Timer` در شل | **۲۱** | در کل `shell/*.qml` |
| تعداد حلقه انیمیشن بی‌نهایت | **۶** | در `AIAssistantOrb.qml` و `NovaOrb.qml` |
| مسیرهای hardcode شده `/home/nimeh` | **۰** ✅ | برطرف شد |
| فایل‌های `.bak` | **۰** ✅ | برطرف شد |
| `import NimehOS` در QML | **۰** ✅ | برطرف شد |
| فایل‌های QML در `shell/` | **۳۲** | شامل `ui/` |
| خطوط کل QML در `shell/` | **~۶٬۹۲۷** | |
| اپ‌های مستقل | **۱** | `apps/nimehos-settings/` (اسکلت) |
| پلاگین C++ | **۰** | (caelestia از `AppDb` استفاده می‌کند — NimehOS فعلاً ندارد) |
| سرویس Python | **۰** | هنوز ساخته نشده |
| سرور D-Bus اعلان | **۰** | (اما `Quickshell.Services.Notifications` موجود است — استفاده نشده) |

### توزیع اولویت مشکلات

| اولویت | تعداد | IDs |
|--------|-------|-----|
| **بحرانی** | ۲ | A1, A4 (هر دو مربوط به قفل) |
| **بالا** | ۸ | A2, A3, A5, A6, A7, A9, A10, A16 |
| **متوسط** | ۴ | A8, A11, A12, A14 |
| **پایین** | ۲ | A13, A15 |

---

## ۳. سؤال‌های باز

این سؤال‌ها قبل از شروع فاز ۱ باید از کاربر پرسیده شوند. پاسخ‌ها روی مسیر پیاده‌سازی اثر مستقیم دارند.

| # | سؤال | فرمان پیشنهادی برای پاسخ | چرا مهم است |
|---|------|--------------------------|-------------|
| **Q1** | نسخه Quickshell نصب‌شده روی VM چیست؟ | `quickshell --version` | کانفیگ ماژول‌ها وابسته به نسخه است (v0.3.0 تأیید شده از caelestia، اما نسخه VM ممکن است متفاوت باشد) |
| **Q2** | محتوای کانفیگ swaylock فعلی چیست؟ | `cat ~/.config/swaylock/config 2>/dev/null \|\| echo "no config"` | برای دیباگ بسته شدن بعد از ۳ ثانیه (A1) |
| **Q3** | خروجی اجرای `swaylock -c ~/.config/swaylock/config` چیست؟ | `swaylock -c ~/.config/swaylock/config 2>&1` | پیدا کردن علت خروج سریع — احتمالاً خطای سینتکس کانفیگ یا مشکل تصویر پس‌زمینه |
| **Q4** | آیا `nmcli` روی VM نصب است؟ | `which nmcli` | اگر نصب نباشد، سرویس network باید از مسیر دیگری (NetworkManager D-Bus) داده بگیرد |
| **Q5** | آیا `brightnessctl` روی VM نصب است؟ | `which brightnessctl` | اگر نصب نباشد، ممکن است `ddcutil` یا `light` لازم باشد |

### سؤال‌های ثانویه (در صورت نیاز در فاز بعدی)

| # | سؤال | ملاحظه |
|---|------|--------|
| Q6 | آیا `Quickshell.Services.UPower` روی VM کار می‌کند؟ (یعنی upower daemon در حال اجراست؟) | `systemctl --user status upower` یا `upower -d` |
| Q7 | آیا `Quickshell.Services.Pipewire` default sink را درست برمی‌گرداند؟ | تست در فاز ۲ |
| Q8 | آیا `Quickshell.Hyprland` روی Hyprland 0.55.2 کار می‌کند؟ | مهم برای A7 و A11 |

---

## ۴. نتیجه‌گیری فاز ۰

پایه UI سالم است اما سه مشکل بحرانی/بالا باید پیش از هر افزودن قابلیت جدید برطرف شوند:

1. **باگ قفل با تم (A1, A4)** — بحرانی؛ باید در فاز ۱ حل شود.
2. **۷ بلوک Process در UI (A2, A3, A5, A6, A7, A8)** — باید در فاز ۲ با سرویس‌های داخلی Quickshell جایگزین شوند.
3. **استفاده‌نشدن از `Quickshell.Services.Notifications` (A9)** — باید در فاز ۷ اصلاح شود.

مشکلات برطرف‌شده (مسیرهای hardcode، `.bak`، `import NimehOS`) نشان می‌دهند که شاخه در مسیر درست است؛ کارهای قبلی مؤثر بوده‌اند.

برای جزئیات معماری و ترتیب فازها، به [`ARCHITECTURE.md`](./ARCHITECTURE.md) مراجعه کنید.
