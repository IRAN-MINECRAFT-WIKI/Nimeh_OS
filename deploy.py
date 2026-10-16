#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
══════════════════════════════════════════════════════════════════
  NimehOS Deploy Script — FINAL (v5)  با C++ Plugin Build
══════════════════════════════════════════════════════════════════

این اسکریپت فایل‌های NimehOS رو روی VM مستقر می‌کنه، پلاگین C++

روش استفاده (روی ویندوز):
  cd D:\\NimehOS\\NimehOS
  python deploy.py <command>

دستورات:
                         → build C++ → configure hyprland → restart → screenshot)
  snapshot             - گرفتن VirtualBox snapshot از VM
  deploy               - انتقال فایل‌های QML و scripts به VM
  build-cpp            - build و install پلاگین C++ روی VM
  configure            - پیکربندی hyprland.conf و hyprlock.conf
  restart              - ری‌استارت Quickshell با env vars درست
  shot                 - گرفتن اسکرین‌شات با grim
  logs                 - نمایش لاگ‌های Quickshell (/tmp/qs.log)
  list                 - لیست فایل‌های محلی برای deploy
  help                 - نمایش این راهنما

مراحل (all):
  ۱. گرفتن snapshot از VM
  ۳. انتقال فایل‌های shell/ scripts/ bin/ apps/ به VM
  ۴. build و install پلاگین C++ روی VM
  ۵. پیکربندی Hyprland (backup + copy hyprland.conf) و hyprlock.conf
  ۶. راه‌اندازی Quickshell با env vars درست
  ۷. اسکرین‌شات

نکات مهم:
  - تمام subprocessها از encoding="utf-8", errors="replace" استفاده می‌کنن
  - برای kill quickshell از pkill -x استفاده می‌شه (exact match، SSH رو نمی‌بنده)
  - تمام خروجی‌ها قبل از slicing با `if out:` چک می‌شن
  - در صورت شکست build، آخرین ۳۰ خط لاگ build نمایش داده می‌شه
  - در صورت شکست quickshell، محتوای /tmp/qs.log نمایش داده می‌شه
  - همیشه راهنمای rollback در پایان چاپ می‌شه
══════════════════════════════════════════════════════════════════
"""
import os
import sys
import subprocess
import time
import base64
from pathlib import Path

# ============================================================
# Configuration
# ============================================================
BASE_DIR = Path(__file__).parent.resolve()
DEPLOY_DIRS = ["shell", "scripts", "bin", "apps"]

# SSH
SSH_KEY = r"C:\Users\wwwha\.ssh\nimeh_key"
SSH_HOST = "nimeh@127.0.0.1"
SSH_PORT = "2222"

# Remote paths
REMOTE_BASE = "$HOME/NimehOS/"
REMOTE_SHELL = "$HOME/NimehOS/shell"
REMOTE_SCRIPTS = "$HOME/NimehOS/scripts"
REMOTE_BIN = "$HOME/NimehOS/bin"
REMOTE_APPS = "$HOME/NimehOS/apps"
REMOTE_PLUGIN = "$HOME/NimehOS/NimehOS_plugin"
REMOTE_HYPR_DIR = "~/.config/hypr"
REMOTE_HYPR_CONF = "~/.config/hypr/hyprland.conf"
REMOTE_HYPR_BAK = "~/.config/hypr/hyprland.conf.bak"
REMOTE_HYPRLOCK = "~/.config/hypr/hyprlock.conf"

# Local paths
SHOTS_DIR = Path(r"D:\NimehOS\screenshots")
BUNDLED_HYPR_CONF = "shell/hyprland/hyprland.conf"
LOCAL_PLUGIN_DIR = "NimehOS_plugin"
LOCAL_BUILD_CPP_SH = "build_cpp_on_vm.sh"
LOCAL_INSTALL_DEPS_SH = "install_deps.sh"

# VirtualBox
VBOX = r"D:\VirtualBox\VBoxManage.exe"
VM_NAME = "NimehOS-Dev"

# Credentials
SUDO_PASS = "habib9170"

# Process detection
# برای quickshell از -x (exact match) استفاده می‌کنیم تا SSH رو نبنده.
# خودش رو match نکنه (suicide prevention).
QUICKSHELL_KILL = "pkill -x quickshell"

# Quickshell env vars (به‌صورت مشترک برای restart و screenshot و restore)
QS_ENV = (
    "export XDG_RUNTIME_DIR=/run/user/$(id -u); "
    "export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}; "
    "export HYPRLAND_INSTANCE_SIGNATURE="
    "$(ls /run/user/$(id -u)/hypr/ 2>/dev/null | tail -1); "
    "export QT_QPA_PLATFORM=wayland; "
    "export QT_QUICK_BACKEND=software; "
    "export QML_IMPORT_PATH=/usr/lib/qt6/qml:$HOME/NimehOS/shell; "
)

# ============================================================
# Embedded hyprlock.conf — نوشته می‌شه به ~/.config/hypr/hyprlock.conf
# این محتوا مستقل از fix_lockscreen.sh نوشته می‌شه تا مطمئن باشیم
# در مسیر درست ($HOME/) قرار می‌گیره نه /root/.
# ============================================================
HYPRLOCK_CONF = r"""# ═════════════════════════════════════════════════════════
#  NimehOS — hyprlock configuration
#  ساخته‌شده توسط deploy.py (FINAL v5)
# ═════════════════════════════════════════════════════════

general {
    disable_loading_bar = false
    grace = 0
    hide_cursor = false
    no_fade_in = false
    no_fade_out = false
}

background {
    monitor =
    path = screenshot
    blur_size = 5
    blur_passes = 2
    color = rgba(10, 10, 12, 0.85)
}

# ساعت بزرگ
label {
    monitor =
    text = cmd[update:1000] echo "$(date +%H:%M)"
    color = rgba(240, 244, 255, 1.0)
    font_size = 120
    font_family = Inter
    position = 0, 200
    halign = center
    valign = center
}

# تاریخ شمسی
label {
    monitor =
    text = cmd[update:60000] echo "$(/usr/local/bin/jdate.sh 2>/dev/null || date +%A)"
    color = rgba(122, 133, 152, 1.0)
    font_size = 18
    font_family = Vazirmatn
    position = 0, 100
    halign = center
    valign = center
}

# آواتار کاربر
label {
    monitor =
    text = nimeh
    color = rgba(240, 244, 255, 1.0)
    font_size = 16
    font_family = Vazirmatn
    position = 0, -100
    halign = center
    valign = center
}

# فیلد رمز
input-field {
    monitor =
    size = 320, 44
    outline_thickness = 1
    dots_size = 0.3
    dots_spacing = 0.3
    inner_color = rgba(28, 28, 30, 0.85)
    outer_color = rgba(0, 153, 255, 0.6)
    font_color = rgba(240, 244, 255, 1.0)
    fade_on_empty = true
    placeholder_text = <i>رمز خود را وارد کنید</i>
    hide_input = false
    position = 0, -200
    halign = center
    valign = center
}

# راهنما
label {
    monitor =
    text = Enter برای ورود
    color = rgba(82, 92, 110, 1.0)
    font_size = 11
    font_family = Vazirmatn
    position = 0, -260
    halign = center
    valign = center
}
"""

# ============================================================
# Logging — با ANSI colors و پیام‌های فارسی
# ============================================================
_COLORS = {
    "INFO":  "\033[36m",   # cyan
    "OK":    "\033[32m",   # green
    "WARN":  "\033[33m",   # yellow
    "ERROR": "\033[31m",   # red
    "STEP":  "\033[35m",   # magenta
    "TITLE": "\033[1;34m", # bold blue
}
_RESET = "\033[0m"


def log(msg, lvl="INFO"):
    """لاگ با رنگ ANSI. پیام‌ها flush می‌شن تا زنده نمایش داده بشن."""
    color = _COLORS.get(lvl, "")
    print(f"{color}[{lvl}]{_RESET} {msg}", flush=True)


def step_header(num, title):
    bar = "═" * 60
    log(bar, "STEP")
    log(f"مرحله {num}: {title}", "STEP")
    log(bar, "STEP")


def show_rollback_hint():
    """راهنمای rollback در صورت بروز مشکل."""
    log("=" * 60, "TITLE")
    log("راهنمای rollback:", "TITLE")
    log("=" * 60, "TITLE")
    log("اگه SSH وصل نمی‌شه، VM رو از VirtualBox snapshot بازیابی کنید.", "INFO")
    log("ساختار snapshotها رو ببینید:", "INFO")
    log(f'  "{VBOX}" snapshot "{VM_NAME}" list', "INFO")


# ============================================================
# SSH / SCP / VBox helpers — همه با encoding="utf-8", errors="replace"
# ============================================================
def _ssh_opts():
    """گزینه‌های مشترک SSH/SCP."""
    return [
        "-o", "StrictHostKeyChecking=no",
        "-o", "UserKnownHostsFile=NUL",
        "-o", "ConnectTimeout=10",
    ]


def ssh_run(cmd, timeout=120):
    """اجرای دستور روی VM از طریق SSH.
    
    برمی‌گردونه: (returncode, stdout, stderr)
    تمام خروجی‌ها با encoding="utf-8", errors="replace" پردازش می‌شن.
    """
    full = [
        "ssh", "-i", SSH_KEY,
        "-p", SSH_PORT,
    ] + _ssh_opts() + [SSH_HOST, cmd]
    try:
        r = subprocess.run(
            full,
            capture_output=True,
            timeout=timeout,
            encoding="utf-8",
            errors="replace",
        )
        return r.returncode, (r.stdout or ""), (r.stderr or "")
    except subprocess.TimeoutExpired:
        return 124, "", "TIMEOUT"
    except FileNotFoundError:
        return 127, "", "ssh پیدا نشد — روی ویندوز اجرا کنید"
    except Exception as e:
        return 1, "", str(e)


def scp_to(local, remote):
    """کپی فایل محلی به VM. برمی‌گردونه: (success, stderr)."""
    full = [
        "scp", "-i", SSH_KEY,
        "-P", SSH_PORT,
    ] + _ssh_opts() + [str(local), f"{SSH_HOST}:{remote}"]
    try:
        r = subprocess.run(
            full,
            capture_output=True,
            timeout=60,
            encoding="utf-8",
            errors="replace",
        )
        return r.returncode == 0, (r.stderr or "")
    except subprocess.TimeoutExpired:
        return False, "TIMEOUT"
    except Exception as e:
        return False, str(e)


def scp_to_dir(local_dir, remote_dir):
    """کپی بازگشتی یک پوشه محلی به VM با scp -r.
    
    برمی‌گردونه: (success, stderr).
    """
    full = [
        "scp", "-r", "-i", SSH_KEY,
        "-P", SSH_PORT,
    ] + _ssh_opts() + [str(local_dir), f"{SSH_HOST}:{remote_dir}"]
    try:
        r = subprocess.run(
            full,
            capture_output=True,
            timeout=180,
            encoding="utf-8",
            errors="replace",
        )
        return r.returncode == 0, (r.stderr or "")
    except subprocess.TimeoutExpired:
        return False, "TIMEOUT"
    except Exception as e:
        return False, str(e)


def scp_from(remote, local):
    """کپی فایل از VM به محلی. برمی‌گردونه: (success, stderr)."""
    full = [
        "scp", "-i", SSH_KEY,
        "-P", SSH_PORT,
    ] + _ssh_opts() + [f"{SSH_HOST}:{remote}", str(local)]
    try:
        r = subprocess.run(
            full,
            capture_output=True,
            timeout=60,
            encoding="utf-8",
            errors="replace",
        )
        return r.returncode == 0, (r.stderr or "")
    except subprocess.TimeoutExpired:
        return False, "TIMEOUT"
    except Exception as e:
        return False, str(e)


def vbox_run(args, timeout=120):
    """اجرای VBoxManage. برمی‌گردونه: (returncode, stdout, stderr)."""
    if not Path(VBOX).exists():
        return 1, "", f"VBoxManage پیدا نشد: {VBOX}"
    full = [VBOX] + args
    try:
        r = subprocess.run(
            full,
            capture_output=True,
            timeout=timeout,
            encoding="utf-8",
            errors="replace",
        )
        return r.returncode, (r.stdout or ""), (r.stderr or "")
    except subprocess.TimeoutExpired:
        return 124, "", "TIMEOUT"
    except Exception as e:
        return 1, "", str(e)


# ============================================================
# File collection
# ============================================================
def collect_files():
    """تمام فایل‌های shell/ scripts/ bin/ apps/ رو جمع می‌کنه.
    __pycache__ و پسوندهای .pyc/.tmp/.bak/.swp رو رد می‌کنه.
    """
    files = []
    skip_dirs = {"__pycache__", ".git", "node_modules", ".mypy_cache"}
    skip_exts = (".pyc", ".pyo", ".tmp", ".bak", ".swp")
    for deploy_dir in DEPLOY_DIRS:
        d = BASE_DIR / deploy_dir
        if not d.exists():
            continue
        for root, dirs, filenames in os.walk(d):
            # فیلتر کردن dirها درجا برای pruning
            dirs[:] = [x for x in dirs if x not in skip_dirs]
            for fn in filenames:
                if fn.endswith(skip_exts):
                    continue
                full = Path(root) / fn
                rel = full.relative_to(BASE_DIR)
                files.append(rel)
    return files


# ============================================================
# Step 1: VirtualBox Snapshot (قبل از هر کاری)
# ============================================================
def step_snapshot():
    step_header("۱", "گرفتن VirtualBox Snapshot")

    if not Path(VBOX).exists():
        log(f"VBoxManage پیدا نشد: {VBOX}", "ERROR")
        return False

    name = f"pre-deploy-{time.strftime('%Y%m%d-%H%M%S')}"
    log(f"نام snapshot: {name}", "INFO")

    rc, out, err = vbox_run(["snapshot", VM_NAME, "take", name], timeout=180)
    if rc == 0:
        log(f"✓ Snapshot گرفته شد: {name}", "OK")
        return True
    else:
        err_short = err[:200] if err else "unknown"
        log(f"خطا در snapshot (rc={rc}): {err_short}", "ERROR")
        if out:
            log(f"خروجی: {out[:200]}", "INFO")
        return False


# ============================================================
# ============================================================

    # ابتدا تست SSH
    rc, out, err = ssh_run("echo SSH_OK", timeout=15)
    if rc != 0 or not out or "SSH_OK" not in out:
        log(f"SSH وصل نمی‌شه: {err[:200] if err else 'no output'}", "ERROR")
        log("برای rollback: VM رو از VirtualBox snapshot بازیابی کنید.", "WARN")
        return False
    log("✓ اتصال SSH برقراره", "OK")

    rc, out, err = ssh_run(
        timeout=15,
    )
    if out and "EXIT=0" in out:
        log("  ✓ systemctl stop موفق بود", "OK")
    else:
        out_short = out[:150] if out else "(no output)"
        log(f"  ⚠ systemctl کار نکرد (احتمالاً service نیست): {out_short}", "WARN")

    # روش ۲: pkill با bracket trick
    # '[c]aelestia' باعث می‌شه pkill خودش رو match نکنه (suicide prevention)
    log("تلاش با pkill -f '[c]aelestia'...", "INFO")
    # روش ۳: kill تمام quickshellها (exact match — SSH رو نمی‌بنده)
    log("بستن تمام نمونه‌های quickshell (pkill -x)...", "INFO")
    rc, out, err = ssh_run(f"{QUICKSHELL_KILL} 2>/dev/null; sleep 2; echo DONE", timeout=15)
    if out and "DONE" in out:
        log("  ✓ quickshell بسته شد", "OK")

    # بررسی نهایی
    time.sleep(1)
    rc, out, err = ssh_run("pgrep -x quickshell 2>/dev/null | wc -l", timeout=10)
    count = out.strip() if out else "0"
    if count == "0":
        log("✓ هیچ quickshell در حال اجرا نیست", "OK")
        return True
    else:
        log(f"⚠ هنوز {count} نمونه quickshell اجراست — force kill...", "WARN")
        rc, out, err = ssh_run(
            f"{QUICKSHELL_KILL} -9 2>/dev/null; sleep 1; echo DONE",
            timeout=10,
        )
        log("  force kill انجام شد", "INFO")
        return True


# ============================================================
# Step 3: Deploy QML files to VM
# ============================================================
def step_deploy():
    step_header("۳", "انتقال فایل‌های QML و scripts به VM")

    files = collect_files()
    if not files:
        log("هیچ فایلی برای deploy پیدا نشد!", "ERROR")
        return False
    log(f"تعداد فایل‌ها: {len(files)}", "INFO")

    # ساخت پوشه‌های remote
    log("ساخت پوشه‌های remote...", "INFO")
    rc, out, err = ssh_run(
        f"mkdir -p {REMOTE_SHELL}/icons/png {REMOTE_SHELL}/hyprland "
        f"{REMOTE_SCRIPTS} {REMOTE_BIN} {REMOTE_APPS}/nimehos-settings/pages "
        f"&& echo MKDIR_OK",
        timeout=15,
    )
    if not out or "MKDIR_OK" not in out:
        log(f"خطا در ساخت پوشه‌ها: {err[:200] if err else 'no output'}", "ERROR")
        return False
    log("✓ پوشه‌های remote آماده‌ست", "OK")

    success = 0
    failed = []
    for rel in files:
        local = BASE_DIR / rel
        if not local.exists():
            log(f"  ✗ {rel} — فایل محلی وجود نداره", "ERROR")
            failed.append(str(rel))
            continue

        rel_str = str(rel).replace("\\", "/")
        remote = REMOTE_BASE + rel_str
        remote_parent = remote.rsplit("/", 1)[0]

        # اطمینان از وجود پوشه والد
        ssh_run(f"mkdir -p '{remote_parent}'", timeout=10)

        ok, err = scp_to(local, remote)
        if ok:
            success += 1
            log(f"  ✓ {rel_str}", "OK")
        else:
            failed.append(str(rel))
            err_short = err[:120] if err else "unknown error"
            log(f"  ✗ {rel_str}: {err_short}", "ERROR")

    log(f"\n{success}/{len(files)} فایل منتقل شد", "OK" if not failed else "WARN")
    if failed:
        log(f"فایل‌های ناموفق ({len(failed)}):", "WARN")
        for f in failed:
            log(f"    • {f}", "WARN")

    # تنظیم permission
    log("تنظیم permission...", "INFO")
    ssh_run(
        f"chmod +x {REMOTE_SCRIPTS}/*.sh {REMOTE_BIN}/float-daemon 2>/dev/null; echo DONE",
        timeout=10,
    )
    log("✓ تنظیم permission انجام شد", "OK")
    return True


# ============================================================
# Step 4: Build و install پلاگین C++ روی VM
# ============================================================
def step_build_cpp():
    step_header("۴", "build و install پلاگین C++ روی VM")

    local_plugin = BASE_DIR / LOCAL_PLUGIN_DIR
    local_build_sh = BASE_DIR / LOCAL_BUILD_CPP_SH
    local_install_sh = BASE_DIR / LOCAL_INSTALL_DEPS_SH

    # بررسی وجود پوشه پلاگین
    if not local_plugin.exists():
        log(f"پوشه پلاگین پیدا نشد: {local_plugin}", "WARN")
        log("از مرحله build صرف‌نظر می‌شه (شاید پلاگین لازم نیست)", "WARN")
        return True  # optional step

    log(f"پوشه پلاگین محلی: {local_plugin}", "INFO")

    # اگه install_deps.sh موجوده، اول اون رو به VM کپی کن و اجرا کن
    if local_install_sh.exists():
        log("کپی install_deps.sh به VM و نصب وابستگی‌ها...", "INFO")
        ok, err = scp_to(local_install_sh, f"{REMOTE_BASE}{LOCAL_INSTALL_DEPS_SH}")
        if not ok:
            log(f"  ⚠ خطا در کپی install_deps.sh: {err[:150] if err else ''}", "WARN")
        else:
            rc, out, err = ssh_run(
                f"chmod +x {REMOTE_BASE}{LOCAL_INSTALL_DEPS_SH} && "
                f"bash {REMOTE_BASE}{LOCAL_INSTALL_DEPS_SH} 2>&1 | tail -15",
                timeout=600,
            )
            if out:
                log(f"  خروجی install_deps (آخرین خطوط):", "INFO")
                for line in out.strip().split("\n")[-10:]:
                    print(f"    {line}")
            if err:
                log(f"  stderr: {err[:200] if err else ''}", "WARN")
            log("✓ نصب وابستگی‌ها تمام شد", "OK" if (not rc or rc == 0) else "WARN")
    else:
        log(f"install_deps.sh محلی پیدا نشد — از مرحله نصب deps صرف‌نظر می‌شه", "WARN")

    # کپی بازگشتی پوشه پلاگین به VM
    log("کپی پوشه NimehOS_plugin به VM (scp -r)...", "INFO")
    # اول پوشه remote قدیمی رو پاک کن تا build تکراری تمیز بمونه
    ssh_run(f"rm -rf {REMOTE_PLUGIN} 2>/dev/null; mkdir -p {REMOTE_BASE}", timeout=15)

    ok, err = scp_to_dir(local_plugin, REMOTE_BASE)
    if not ok:
        err_short = err[:200] if err else "unknown"
        log(f"✗ خطا در کپی پلاگین: {err_short}", "ERROR")
        return False
    log("  ✓ پلاگین کپی شد", "OK")

    # کپی build_cpp_on_vm.sh به VM
    if local_build_sh.exists():
        log("کپی build_cpp_on_vm.sh به VM...", "INFO")
        ok2, err2 = scp_to(local_build_sh, f"{REMOTE_BASE}{LOCAL_BUILD_CPP_SH}")
        if ok2:
            ssh_run(f"chmod +x {REMOTE_BASE}{LOCAL_BUILD_CPP_SH}", timeout=10)
            log("  ✓ build_cpp_on_vm.sh کپی شد", "OK")
        else:
            err2_short = err2[:150] if err2 else ""
            log(f"  ⚠ خطا در کپی build_cpp_on_vm.sh: {err2_short}", "WARN")

    # اجرای build روی VM
    log("اجرای build روی VM...", "INFO")
    rc, out, err = ssh_run(
        f"cd {REMOTE_PLUGIN} && bash build.sh 2>&1",
        timeout=600,
    )

    # تشخیص موفقیت از خروجی
    build_ok = False
    if out:
        lower = out.lower()
        # نشانه‌های موفقیت: نصب install یا 100% complete یا "Built target"
        if "install" in lower and ("error" not in lower or "0 error" in lower):
            build_ok = True
        if "built target" in lower or "installing" in lower:
            build_ok = True
        if "configure done" in lower and "build finished" in lower:
            build_ok = True
        # اگه rc == 0 و خطای واضحی نیست، موفق فرض می‌کنیم
        if rc == 0 and "error" not in lower and "fatal" not in lower:
            build_ok = True

    if build_ok:
        log("✓ build پلاگین با موفقیت انجام شد", "OK")
        # نمایش آخرین خطوط موفقیت
        if out:
            log("  آخرین خطوط build:", "INFO")
            for line in out.strip().split("\n")[-8:]:
                print(f"    {line}")
        return True
    else:
        log(f"✗ build شکست خورد (rc={rc})", "ERROR")
        # نمایش آخرین ۳۰ خط لاگ build
        log("آخرین ۳۰ خط لاگ build:", "ERROR")
        if out:
            lines = out.strip().split("\n")
            for line in lines[-30:]:
                print(f"    {line}")
        if err:
            log(f"stderr (آخرین ۲۰۰ کاراکتر): {err[-200:] if err else ''}", "ERROR")
        return False


# ============================================================
# Step 5: Configure Hyprland + Hyprlock
# ============================================================
def step_configure():
    step_header("۵", "پیکربندی Hyprland و hyprlock")

    local_conf = BASE_DIR / BUNDLED_HYPR_CONF
    if not local_conf.exists():
        log(f"hyprland.conf محلی پیدا نشد: {local_conf}", "ERROR")
        return False

    # ─── ۵.۱: backup از hyprland.conf فعلی ───
    log("بررسی backup از hyprland.conf فعلی...", "INFO")
    rc, out, err = ssh_run(
        f"if [ -f {REMOTE_HYPR_CONF} ] && [ ! -f {REMOTE_HYPR_BAK} ]; then "
        f"  cp {REMOTE_HYPR_CONF} {REMOTE_HYPR_BAK} && echo BACKED_UP; "
        f"elif [ -f {REMOTE_HYPR_BAK} ]; then "
        f"  echo BAK_EXISTS; "
        f"else "
        f"  echo NO_CONF; "
        f"fi",
        timeout=15,
    )
    if out:
        if "BACKED_UP" in out:
            pass
        elif "BAK_EXISTS" in out:
            log("  • backup قبلاً گرفته شده — حفظ می‌شه", "INFO")
        elif "NO_CONF" in out:
            log("  • کانفیگ قبلی وجود نداشت — بدون backup ادامه", "INFO")

    # ساخت پوشه hypr
    ssh_run(f"mkdir -p {REMOTE_HYPR_DIR}", timeout=10)

    # ─── ۵.۲: کپی hyprland.conf محلی به VM ───
    log("کپی hyprland.conf به VM...", "INFO")
    ok, err = scp_to(local_conf, REMOTE_HYPR_CONF)
    if ok:
        log("  ✓ hyprland.conf کپی شد", "OK")
    else:
        err_short = err[:150] if err else "unknown"
        log(f"  ✗ خطا در کپی: {err_short}", "ERROR")
        return False

    # بررسی محتوای exec-once
    log("بررسی exec-once در hyprland.conf...", "INFO")
    rc, out, err = ssh_run(
        f"grep -c 'quickshell -p $HOME/NimehOS/shell' {REMOTE_HYPR_CONF} 2>/dev/null",
        timeout=10,
    )
    count = out.strip() if out else "0"
    if count and count != "0":
        log("  ✓ exec-once روی NimehOS shell تنظیم شده", "OK")
    else:
        log("  ⚠ exec-once برای NimehOS پیدا نشد — بررسی کنید", "WARN")

    # ─── ۵.۳: نوشتن hyprlock.conf مستقل ───
    log("نوشتن hyprlock.conf در ~/.config/hypr/...", "INFO")
    ssh_run(f"mkdir -p {REMOTE_HYPR_DIR}", timeout=10)

    # محتوا رو base64 کد می‌کنیم تا از مشکلات کاراکترهای خاص جلوگیری کنیم
    b64 = base64.b64encode(HYPRLOCK_CONF.encode("utf-8")).decode("ascii")
    rc, out, err = ssh_run(
        f"echo '{b64}' | base64 -d > {REMOTE_HYPRLOCK} && echo WROTE_OK",
        timeout=15,
    )
    if out and "WROTE_OK" in out:
        log("  ✓ hyprlock.conf نوشته شد", "OK")
    else:
        log(f"  ✗ خطا در نوشتن hyprlock: {err[:200] if err else 'no output'}", "ERROR")
        return False

    # بررسی
    rc, out, err = ssh_run(f"wc -l {REMOTE_HYPRLOCK} 2>/dev/null", timeout=10)
    if out:
        log(f"  تعداد خطوط hyprlock.conf: {out.strip()}", "INFO")

    log("✓ پیکربندی Hyprland و hyprlock کامل شد", "OK")
    return True


# ============================================================
# Step 6: Restart Quickshell با env vars درست
# ============================================================
def step_restart_quickshell():
    step_header("۶", "راه‌اندازی Quickshell (NimehOS shell)")

    # اطمینان از بسته بودن quickshell قبلی
    log("بستن quickshell فعلی (pkill -x)...", "INFO")
    ssh_run(f"{QUICKSHELL_KILL} 2>/dev/null; sleep 2", timeout=15)

    # تشخیص env vars و راه‌اندازی
    log("راه‌اندازی quickshell جدید با env vars...", "INFO")
    cmd = (
        QS_ENV +
        f"nohup quickshell -p {REMOTE_SHELL} > /tmp/qs.log 2>&1 < /dev/null &"
    )
    ssh_run(cmd, timeout=15)
    time.sleep(4)

    # بررسی اجرا
    rc, out, err = ssh_run("pgrep -x quickshell | head -1", timeout=10)
    pid = out.strip() if out else ""
    if pid:
        log(f"✓ Quickshell در حال اجراست (PID: {pid})", "OK")
    else:
        log("✗ Quickshell اجرا نشد!", "ERROR")

    # بررسی لاگ برای خطا
    rc, out, err = ssh_run("tail -25 /tmp/qs.log 2>/dev/null", timeout=10)
    if out:
        error_lines = [
            l for l in out.split("\n")
            if l and ("error" in l.lower() or "Error" in l or "FATAL" in l)
        ]
        if error_lines:
            log("⚠ خطا در لاگ quickshell:", "WARN")
            for line in error_lines[:8]:
                print(f"    {line}")
        else:
            log("✓ خطایی در لاگ quickshell نیست", "OK")
            log("  لاگ (آخرین خطوط):", "INFO")
            for line in out.strip().split("\n")[-6:]:
                print(f"    {line}")
    else:
        log("  لاگ خالیه", "INFO")

    if not pid:
        return False
    return True


# ============================================================
# Step 7: Screenshot با grim
# ============================================================
def step_screenshot():
    step_header("۷", "گرفتن اسکرین‌شات")

    try:
        SHOTS_DIR.mkdir(parents=True, exist_ok=True)
    except Exception as e:
        log(f"نتونستم پوشه screenshots بسازم: {e}", "WARN")

    remote_shot = "/tmp/nimeh-deploy.png"
    log("گرفتن اسکرین‌شات با grim...", "INFO")
    cmd = (
        QS_ENV +
        f"grim {remote_shot} 2>&1; echo EXIT=$?"
    )
    rc, out, err = ssh_run(cmd, timeout=20)

    if not out or "EXIT=0" not in out:
        out_short = out[:200] if out else "no output"
        log(f"✗ grim خطا داد: {out_short}", "ERROR")
        return False

    log("  ✓ اسکرین‌شات گرفته شد، در حال کپی...", "OK")

    local_shot = SHOTS_DIR / f"nimeh-{time.strftime('%Y%m%d-%H%M%S')}.png"
    ok, err = scp_from(remote_shot, local_shot)
    if ok:
        log(f"✓ اسکرین‌شات ذخیره شد: {local_shot}", "OK")
        try:
            os.startfile(str(local_shot))
            log("  ✓ اسکرین‌شات باز شد", "OK")
        except AttributeError:
            # os.startfile فقط روی ویندوز هست
            pass
        except Exception as e:
            log(f"  ⚠ نتونستم باز کنم: {e}", "WARN")
        return True
    else:
        err_short = err[:200] if err else "unknown"
        log(f"✗ خطا در کپی اسکرین‌شات: {err_short}", "ERROR")
        return False


# ============================================================
# Logs: نمایش لاگ Quickshell
# ============================================================
def step_logs():
    log("=" * 60, "TITLE")
    log("لاگ‌های Quickshell (/tmp/qs.log)", "TITLE")
    log("=" * 60, "TITLE")

    # بررسی اینکه quickshell در حال اجراست
    rc, out, err = ssh_run("pgrep -x quickshell | head -3", timeout=10)
    if out and out.strip():
        log(f"✓ Quickshell در حال اجراست (PIDها: {out.strip().replace(chr(10), ', ')})", "OK")
    else:
        log("⚠ Quickshell در حال اجرا نیست", "WARN")

    # خوندن لاگ
    log("محتوای /tmp/qs.log:", "INFO")
    rc, out, err = ssh_run("tail -60 /tmp/qs.log 2>/dev/null", timeout=15)
    if out:
        print()
        print("─" * 60)
        for line in out.strip().split("\n"):
            print(f"  {line}")
        print("─" * 60)
        log(f"تعداد خطوط نمایش‌داده‌شده: {len(out.strip().split(chr(10)))}", "INFO")
    else:
        log("لاگ خالیه یا وجود نداره", "WARN")

    if out:
        for line in out.strip().split("\n")[-10:]:
            print(f"  {line}")

    return True


# ============================================================
# ============================================================

    # ۱. kill NimehOS quickshell
    log("۱. بستن NimehOS quickshell (pkill -x quickshell)...", "INFO")
    rc, out, err = ssh_run(f"{QUICKSHELL_KILL} 2>/dev/null; sleep 2; echo DONE", timeout=15)
    if out and "DONE" in out:
        log("  ✓ quickshell بسته شد", "OK")

    # ۲. بازگرداندن hyprland.conf از backup
    log("۲. بازگرداندن hyprland.conf از backup...", "INFO")
    rc, out, err = ssh_run(
        f"if [ -f {REMOTE_HYPR_BAK} ]; then "
        f"  cp {REMOTE_HYPR_BAK} {REMOTE_HYPR_CONF} && echo RESTORED; "
        f"else "
        f"  echo NO_BAK; "
        f"fi",
        timeout=15,
    )
    if out:
        if "RESTORED" in out:
            log("  ✓ hyprland.conf از backup بازگردانده شد", "OK")
        elif "NO_BAK" in out:
            log("  ⚠ backup وجود نداره — hyprland.conf فعلی نگه داشته شد", "WARN")

    cmd = (
        QS_ENV +
        f"nohup quickshell -p {REMOTE_SHELL} > /tmp/qs.log 2>&1 < /dev/null &"
    )
    ssh_run(cmd, timeout=15)
    time.sleep(4)

    # بررسی اجرا
    rc, out, err = ssh_run("pgrep -x quickshell | head -1", timeout=10)
    pid = out.strip() if out else ""
    if pid:
        pass
    else:
        rc, out, err = ssh_run("tail -20 /tmp/qs.log 2>/dev/null", timeout=10)
        if out:
            log("آخرین خطوط لاگ:", "INFO")
            for line in out.strip().split("\n")[-10:]:
                print(f"    {line}")

    return bool(pid)


# ============================================================
# List files
# ============================================================
def step_list():
    log("=" * 60, "TITLE")
    log("لیست فایل‌های NimehOS برای deploy", "TITLE")
    log("=" * 60, "TITLE")
    files = collect_files()
    log(f"تعداد فایل‌ها: {len(files)}", "INFO")
    total = 0
    for rel in files:
        full = BASE_DIR / rel
        if full.exists():
            size = full.stat().st_size
            total += size
            print(f"  {str(rel):55s}  {size:>8,} bytes")
    print(f"\n  {'مجموع':55s}  {total:>8,} bytes")

    # نمایش فایل‌های پلاگین اگه هستن
    plugin_dir = BASE_DIR / LOCAL_PLUGIN_DIR
    if plugin_dir.exists():
        log(f"\nپوشه پلاگین ({LOCAL_PLUGIN_DIR}):", "INFO")
        pcount = 0
        ptotal = 0
        for root, dirs, filenames in os.walk(plugin_dir):
            dirs[:] = [d for d in dirs if d not in {"__pycache__", ".git", "build"}]
            for fn in filenames:
                if fn.endswith((".pyc", ".tmp", ".bak", ".swp", ".o", ".so")):
                    continue
                full = Path(root) / fn
                rel = full.relative_to(BASE_DIR)
                size = full.stat().st_size
                pcount += 1
                ptotal += size
                print(f"  {str(rel):55s}  {size:>8,} bytes")
        print(f"\n  {'مجموع پلاگین':55s}  {ptotal:>8,} bytes ({pcount} فایل)")


# ============================================================
# Help
# ============================================================
def show_help():
    print()
    print("=" * 60)
    print("  NimehOS Deploy Script — FINAL v5 (C++ Plugin Build)")
    print("=" * 60)
    print()
    print(__doc__)


# ============================================================
# Main
# ============================================================
def main():
    print()
    print("=" * 60)
    print("=" * 60)
    print()

    args = sys.argv[1:]
    if not args or args[0] in ("help", "--help", "-h"):
        show_help()
        return 0

    cmd = args[0].lower()

    # --- list ---
    if cmd == "list":
        step_list()
        return 0

    # --- snapshot ---
    if cmd == "snapshot":
        ok = step_snapshot()
        if not ok:
            show_rollback_hint()
        return 0 if ok else 1

    # --- deploy (QML + scripts only) ---
    if cmd == "deploy":
        ok = step_deploy()
        if not ok:
            show_rollback_hint()
        else:
            log("\n✓ deploy کامل شد — برای پیکربندی: python deploy.py configure", "OK")
        return 0 if ok else 1

    # --- build-cpp (build & install C++ plugin on VM) ---
    if cmd == "build-cpp":
        ok = step_build_cpp()
        if not ok:
            show_rollback_hint()
        return 0 if ok else 1

    # --- configure (hyprland + hyprlock) ---
    if cmd == "configure":
        ok = step_configure()
        if not ok:
            show_rollback_hint()
        else:
            log("\n✓ پیکربندی کامل شد — برای restart: python deploy.py restart", "OK")
        return 0 if ok else 1

    # --- restart (quickshell) ---
    if cmd == "restart":
        ok = step_restart_quickshell()
        if not ok:
            show_rollback_hint()
        return 0 if ok else 1

    # --- shot ---
    if cmd == "shot":
        ok = step_screenshot()
        return 0 if ok else 1

    # --- logs ---
    if cmd == "logs":
        step_logs()
        return 0

        if ok:
            pass
        return 0 if ok else 1

    # --- all ---
    if cmd == "all":
        ok = True
        if not step_snapshot():
            log("snapshot ناموفق — ادامه با احتیاط", "WARN")
        if not step_deploy():
            ok = False
        if not step_build_cpp():
            log("build پلاگین ناموفق — ادامه بدون پلاگین", "WARN")
            # ادامه می‌دیم چون پلاگین اختیاریه
        if not step_configure():
            log("پیکربندی hyprland ناموفق", "WARN")
            ok = False
        if not step_restart_quickshell():
            ok = False
        if not step_screenshot():
            log("screenshot ناموفق", "WARN")

        print()
        if ok:
            log("✓✓✓ همه مراحل با موفقیت انجام شد ✓✓✓", "OK")
        else:
            log("⚠ بعضی مراحل ناموفق بودن — لاگ‌ها رو بررسی کنید", "WARN")
            log("برای مشاهده لاگ: python deploy.py logs", "INFO")
        return 0 if ok else 1

    # --- unknown ---
    log(f"دستور نامشخص: {cmd}", "ERROR")
    log("برای راهنما: python deploy.py help", "INFO")
    return 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print()
        log("قطع شد توسط کاربر (Ctrl+C)", "WARN")
        sys.exit(130)
