# NimehOS

> دسکتاپ مدرن لینوکسی شبیه Windows 11 با Hyprland + Quickshell

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)
[![Compositor: Hyprland](https://img.shields.io/badge/Compositor-Hyprland-purple.svg)](https://hyprland.org/)

## 📖 درباره

NimehOS یک محیط دسکتاپ سفارشی برای لینوکس است که با هدف ارائه‌ی تجربه‌ای روان، مدرن و فارسی‌زبان ساخته شده. این پروژه از طراحی Windows 11 الهام گرفته اما کاملاً اختصاصی است.

### ویژگی‌های کلیدی
- 🎨 ظاهر شیشه‌ای (Acrylic) و مدرن
- 🇮🇷 پشتیبانی کامل از فارسی و تاریخ شمسی
- ⚡ تسک‌بار، منوی استارت، Quick Settings (شبیه ویندوز ۱۱)
- 🪟 Title Bar سفارشی با دکمه‌های ─ ▢ ✕
- 📋 Notification Center + تقویم
- 🔒 Lock Screen با hyprlock
- 🎬 انیمیشن‌های نرم با spring physics
- 🎯 Snap Layouts (Win+Z)
- 📊 Task View (Win+Tab)
- 🤖 دستیار AI آفلاین (در حال توسعه)
- 🐧 پایه: Debian 13 + Hyprland + Quickshell

## 🛠️ تکنولوژی‌ها

| لایه | تکنولوژی |
|------|----------|
| Compositor | Hyprland 0.55+ |
| Shell UI | Quickshell + QML/Qt6 |
| Lock Screen | hyprlock |
| Audio | PipeWire (wpctl) |
| Network | NetworkManager |
| Battery | UPower |
| Boot Animation | Plymouth |
| C++ Plugin | Qt6 (BlobRect SDF shader + ImageAnalyser) |

## 📦 نصب

### پیش‌نیازها
- Debian 13 (Trixie) یا مشابه
- Hyprland 0.55+
- Quickshell 0.3+
- VirtualBox (برای تست در VM)

### راه‌اندازی سریع

برای راه‌اندازی سریع، فایل [QUICKSTART.md](QUICKSTART.md) را بخوانید.

```bash
# ۱. کلون کردن
git clone https://github.com/IRAN-MINECRAFT-WIKI/Nimeh_OS.git
cd Nimeh_OS

# ۲. تنظیم config
cp config.example.py config.py
nano config.py  # مقادیر خودت رو جایگزین کن

# ۳. Deploy به VM
python deploy.py all
```

## 📁 ساختار پروژه

```
NimehOS/
├── deploy.py              # اسکریپت deploy اصلی
├── config.example.py      # نمونه config
├── DESIGN.md              # مرجع طراحی (اعداد، رنگ، قواعد)
├── QUICKSTART.md          # راه‌اندازی سریع
├── TROUBLESHOOTING.md     # رفع خطاها
├── shell/                 # فایل‌های QML دسکتاپ
│   ├── shell.qml          # entry point
│   ├── Theme.qml          # singleton تم
│   ├── Animations.qml     # singleton انیمیشن
│   ├── NimehTaskbar.qml   # تسک‌بار
│   ├── NimehStartMenu.qml # منوی استارت
│   ├── GlassPanel.qml     # کامپوننت شیشه‌ای
│   ├── StateLayer.qml     # لایه تعامل M3
│   ├── hyprland/          # کانفیگ Hyprland
│   ├── icons/png/         # آیکون‌ها
│   └── ui/                # کامپوننت‌های UI
├── plugin/                # C++ plugin (BlobRect + ImageAnalyser)
├── scripts/               # اسکریپت‌های کمکی
├── bin/                   # باینری‌ها (float-daemon)
└── apps/                  # اپ‌های NimehOS (settings)
```

## ⌨️ میانبرهای کیبورد

| کلید | کار |
|------|-----|
| `Win` | Start Menu |
| `Win+D` | App Launcher |
| `Win+Tab` | Task View |
| `Win+Z` | Snap Layouts |
| `Alt+Tab` | Alt+Tab سه‌بعدی |
| `Win+L` / `Win+B` | قفل صفحه |
| `Win+X` | منوی خاموش |
| `Win+N` | Notification Center |
| `Win+W` | Widgets Panel |
| `Win+A` | Quick Settings |
| `Win+M` | Minimize |
| `Win+درگ` | حرکت آزاد پنجره |

برای لیست کامل، [DESIGN.md](DESIGN.md) را بخوانید.

## 🎨 طراحی

تمام اعداد، رنگ‌ها و قواعد طراحی در [DESIGN.md](DESIGN.md) مستند شده‌اند. این فایل مرجع واحد پروژه است.

## 🤝 مشارکت

1. Fork کنید
2. Branch بسازید (`git checkout -b feature/amazing`)
3. Commit کنید (`git commit -m 'Add amazing'`)
4. Push کنید (`git push origin feature/amazing`)
5. Pull Request بزنید

## 📝 لایسنس

MIT License - see [LICENSE](LICENSE) for details.

## 👥 اعتبارها

- **NimehOS Team** - توسعه‌دهنده اصلی
- **Hyprland** - compositor
- **Quickshell** - shell toolkit  
- **Caelestia** - الهام‌بخش معماری
- **Windows 11** - مرجع تجربه کاربری

## 📞 تماس

- **GitHub Issues**: [ایجاد issue](https://github.com/IRAN-MINECRAFT-WIKI/Nimeh_OS/issues)
- **Wiki**: [مشاهده wiki](https://github.com/IRAN-MINECRAFT-WIKI/Nimeh_OS/wiki)

---

<div align="center">

ساخته‌شده با ❤️ برای جامعه فارسی‌زبان لینوکس

</div>
