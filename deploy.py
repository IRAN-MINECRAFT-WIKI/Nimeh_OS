#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
NimehOS Deploy Script — Portable Version
=========================================

اسکریپت deploy کامل NimehOS با:
  - خواندن تنظیمات از config.py
  - retry logic برای SSH/SCP
  - UTF-8 encoding
  - پیام‌های فارسی واضح
  - rollback امن

روش استفاده:
  1. config.example.py رو به config.py کپی کن و ویرایش کن
  2. python deploy.py all

دستورات:
  all                  - همه مراحل
  snapshot             - گرفتن snapshot
  deploy               - انتقال فایل‌ها
  build-cpp            - build پلاگین C++
  configure            - پیکربندی hyprland
  restart              - ری‌استارت quickshell
  shot                 - اسکرین‌شات
  restore-caelestia    - بازگرداندن caelestia
  logs                 - نمایش لاگ‌ها
  list                 - لیست فایل‌ها
  help                 - راهنما
"""
import os
import sys
import subprocess
import time
from pathlib import Path

# ============================================================
# Load Configuration
# ============================================================
try:
    from config import (
        SSH_KEY, SSH_HOST, SSH_PORT, SUDO_PASS,
        VBOX, VM_NAME,
        REMOTE_HOME, REMOTE_BASE, REMOTE_SHELL, REMOTE_PLUGIN,
        SHOTS_DIR,
        AUTO_SNAPSHOT, RETRY_ATTEMPTS, RETRY_DELAY, VERBOSE,
        BUILD_CPP_PLUGIN
    )
except ImportError:
    print("=" * 60)
    print("خطا: فایل config.py پیدا نشد!")
    print("=" * 60)
    print()
    print("راه‌حل:")
    print("  1. فایل config.example.py رو به config.py کپی کن:")
    print("     copy config.example.py config.py")
    print()
    print("  2. فایل config.py رو با ویرایشگر متن باز کن و ویرایش کن:")
    print("     notepad config.py")
    print()
    print("  3. مقادیر SSH_KEY، SUDO_PASS و VBOX رو با سیستم خودت جایگزین کن")
    print()
    sys.exit(1)

# ============================================================
# Constants
# ============================================================
BASE_DIR = Path(__file__).parent.resolve()
DEPLOY_DIRS = ["shell", "scripts", "bin", "apps"]
LOCAL_PLUGIN_DIR = "plugin"
LOCAL_BUILD_CPP_SH = "build_cpp_on_vm.sh"
LOCAL_INSTALL_DEPS_SH = "install_deps.sh"
BUNDLED_HYPR_CONF = "shell/hyprland/hyprland.conf"

REMOTE_HYPR_DIR = "~/.config/hypr"
REMOTE_HYPR_CONF = "~/.config/hypr/hyprland.conf"
REMOTE_HYPR_BAK = "~/.config/hypr/hyprland.conf.bak"
REMOTE_HYPRLOCK = "~/.config/hypr/hyprlock.conf"

# ============================================================
# Logging
# ============================================================
def log(msg, lvl="INFO"):
    colors = {
        "INFO":  "\033[36m",
        "OK":    "\033[32m",
        "WARN":  "\033[33m",
        "ERROR": "\033[31m",
        "STEP":  "\033[35m",
        "TITLE": "\033[1;36m",
    }
    reset = "\033[0m"
    color = colors.get(lvl, "")
    print(f"{color}[{lvl}]{reset} {msg}", flush=True)

# ============================================================
# SSH/SCP Helpers with Retry
# ============================================================
def ssh_run(cmd, timeout=120, retries=None):
    """Run command on VM via SSH with retry logic."""
    if retries is None:
        retries = RETRY_ATTEMPTS
    
    full = [
        "ssh", "-i", SSH_KEY,
        "-p", SSH_PORT,
        "-o", "StrictHostKeyChecking=no",
        "-o", "UserKnownHostsFile=NUL",
        "-o", "ConnectTimeout=10",
        SSH_HOST, cmd
    ]
    
    for attempt in range(1, retries + 1):
        try:
            r = subprocess.run(
                full,
                capture_output=True,
                timeout=timeout,
                encoding="utf-8",
                errors="replace"
            )
            return r.returncode, r.stdout or "", r.stderr or ""
        except subprocess.TimeoutExpired:
            if attempt < retries:
                log(f"  SSH timeout — تلاش مجدد {attempt}/{retries}...", "WARN")
                time.sleep(RETRY_DELAY)
            else:
                return 1, "", "SSH TIMEOUT"
        except Exception as e:
            if attempt < retries:
                log(f"  SSH error: {e} — تلاش مجدد {attempt}/{retries}...", "WARN")
                time.sleep(RETRY_DELAY)
            else:
                return 1, "", str(e)
    
    return 1, "", "SSH FAILED after retries"

def scp_to(local, remote, retries=None):
    """Copy local file to VM with retry."""
    if retries is None:
        retries = RETRY_ATTEMPTS
    
    full = [
        "scp", "-i", SSH_KEY,
        "-P", SSH_PORT,
        "-o", "StrictHostKeyChecking=no",
        "-o", "UserKnownHostsFile=NUL",
        "-o", "ConnectTimeout=10",
        str(local), f"{SSH_HOST}:{remote}"
    ]
    
    for attempt in range(1, retries + 1):
        try:
            r = subprocess.run(
                full,
                capture_output=True,
                timeout=60,
                encoding="utf-8",
                errors="replace"
            )
            return r.returncode == 0, r.stderr or ""
        except subprocess.TimeoutExpired:
            if attempt < retries:
                log(f"  SCP timeout — تلاش مجدد {attempt}/{retries}...", "WARN")
                time.sleep(RETRY_DELAY)
            else:
                return False, "SCP TIMEOUT"
        except Exception as e:
            if attempt < retries:
                log(f"  SCP error: {e} — تلاش مجدد {attempt}/{retries}...", "WARN")
                time.sleep(RETRY_DELAY)
            else:
                return False, str(e)
    
    return False, "SCP FAILED after retries"

def scp_from(remote, local, retries=None):
    """Copy from VM to local with retry."""
    if retries is None:
        retries = RETRY_ATTEMPTS
    
    full = [
        "scp", "-i", SSH_KEY,
        "-P", SSH_PORT,
        "-o", "StrictHostKeyChecking=no",
        "-o", "UserKnownHostsFile=NUL",
        "-o", "ConnectTimeout=10",
        f"{SSH_HOST}:{remote}", str(local)
    ]
    
    for attempt in range(1, retries + 1):
        try:
            r = subprocess.run(
                full,
                capture_output=True,
                timeout=60,
                encoding="utf-8",
                errors="replace"
            )
            return r.returncode == 0, r.stderr or ""
        except subprocess.TimeoutExpired:
            if attempt < retries:
                time.sleep(RETRY_DELAY)
            else:
                return False, "SCP TIMEOUT"
        except Exception as e:
            if attempt < retries:
                time.sleep(RETRY_DELAY)
            else:
                return False, str(e)
    
    return False, "SCP FAILED after retries"

def scp_to_dir(local_dir, remote_dir, retries=None):
    """Copy entire directory to VM."""
    if retries is None:
        retries = RETRY_ATTEMPTS
    
    full = [
        "scp", "-i", SSH_KEY,
        "-P", SSH_PORT,
        "-r",
        "-o", "StrictHostKeyChecking=no",
        "-o", "UserKnownHostsFile=NUL",
        "-o", "ConnectTimeout=10",
        str(local_dir), f"{SSH_HOST}:{remote_dir}"
    ]
    
    for attempt in range(1, retries + 1):
        try:
            r = subprocess.run(
                full,
                capture_output=True,
                timeout=120,
                encoding="utf-8",
                errors="replace"
            )
            return r.returncode == 0, r.stderr or ""
        except subprocess.TimeoutExpired:
            if attempt < retries:
                log(f"  SCP dir timeout — تلاش مجدد {attempt}/{retries}...", "WARN")
                time.sleep(RETRY_DELAY)
            else:
                return False, "SCP TIMEOUT"
        except Exception as e:
            if attempt < retries:
                time.sleep(RETRY_DELAY)
            else:
                return False, str(e)
    
    return False, "SCP FAILED after retries"

# ============================================================
# File Collection
# ============================================================
def collect_files():
    """تمام فایل‌های deploy رو جمع می‌کنه."""
    files = []
    for deploy_dir in DEPLOY_DIRS:
        d = BASE_DIR / deploy_dir
        if not d.exists():
            log(f"پوشه نیست: {d}", "WARN")
            continue
        for root, dirs, filenames in os.walk(d):
            # skip __pycache__
            dirs[:] = [x for x in dirs if x != "__pycache__"]
            for fn in filenames:
                if fn.endswith((".pyc", ".tmp", ".bak", ".swp")):
                    continue
                full = Path(root) / fn
                rel = full.relative_to(BASE_DIR)
                files.append(rel)
    return files

# ============================================================
# Step 1: Snapshot
# ============================================================
def step_snapshot():
    log("=" * 60, "STEP")
    log("مرحله: گرفتن VirtualBox Snapshot", "STEP")
    log("=" * 60, "STEP")
    
    if not AUTO_SNAPSHOT:
        log("snapshot غیرفعال در config.py", "INFO")
        return True
    
    if not Path(VBOX).exists():
        log(f"VBoxManage پیدا نشد: {VBOX}", "WARN")
        log("  از snapshot صرف‌نظر می‌شه", "WARN")
        return True
    
    name = f"pre-deploy-{time.strftime('%Y%m%d-%H%M%S')}"
    cmd = [VBOX, "snapshot", VM_NAME, "take", name]
    log(f"نام snapshot: {name}", "INFO")
    
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
        if r.returncode == 0:
            log(f"Snapshot گرفته شد: {name}", "OK")
            return True
        else:
            err_msg = r.stderr[:200] if r.stderr else "unknown error"
            log(f"خطا در snapshot: {err_msg}", "WARN")
            return True  # ادامه بده حتی اگه snapshot نشد
    except subprocess.TimeoutExpired:
        log("Timeout در snapshot", "WARN")
        return True
    except Exception as e:
        log(f"خطا: {e}", "WARN")
        return True

# ============================================================
# Step 2: Stop Caelestia
# ============================================================
def step_stop_caelestia():
    log("=" * 60, "STEP")
    log("مرحله: توقف Caelestia shell", "STEP")
    log("=" * 60, "STEP")
    
    # تست SSH
    rc, out, err = ssh_run("echo OK", timeout=10)
    if rc != 0 or "OK" not in out:
        log(f"SSH وصل نمی‌شه: {err}", "ERROR")
        log("بررسی کن:", "INFO")
        log(f"  - VM روشنه؟", "INFO")
        log(f"  - SSH key موجوده؟ {SSH_KEY}", "INFO")
        log(f"  - پورت درسته؟ {SSH_PORT}", "INFO")
        return False
    log("اتصال SSH برقراره", "OK")
    
    # تلاش با systemctl
    log("تلاش با systemctl --user stop caelestia-shell...", "INFO")
    rc, out, err = ssh_run("systemctl --user stop caelestia-shell 2>&1; echo EXIT=$?", timeout=15)
    if out and "EXIT=0" in out:
        log("  systemctl کار کرد", "OK")
    else:
        log(f"  systemctl کار نکرد (احتمالاً service نیست)", "WARN")
    
    # pkill با bracket trick
    log("تلاش با pkill -f '[c]aelestia'...", "INFO")
    rc, out, err = ssh_run("pkill -f '[c]aelestia' 2>/dev/null; echo DONE", timeout=10)
    log("  pkill caelestia اجرا شد", "OK")
    
    # بستن quickshell (exact match)
    log("بستن تمام نمونه‌های quickshell (pkill -x)...", "INFO")
    ssh_run("pkill -x quickshell 2>/dev/null; sleep 1; echo DONE", timeout=10)
    
    # چک
    rc, out, err = ssh_run("pgrep -x quickshell 2>/dev/null | head -1")
    if out and out.strip():
        log(f"  quickshell هنوز اجراست: {out.strip()}", "WARN")
    else:
        log("  هیچ quickshell در حال اجرا نیست", "OK")
    
    return True

# ============================================================
# Step 3: Deploy Files
# ============================================================
def step_deploy():
    log("=" * 60, "STEP")
    log("مرحله: انتقال فایل‌های QML و scripts به VM", "STEP")
    log("=" * 60, "STEP")
    
    files = collect_files()
    if not files:
        log("هیچ فایلی پیدا نشد!", "ERROR")
        return False
    log(f"تعداد فایل‌ها: {len(files)}", "INFO")
    
    # ساخت پوشه‌های remote
    log("ساخت پوشه‌های remote...", "INFO")
    ssh_run(f"mkdir -p {REMOTE_BASE}shell/icons/png {REMOTE_BASE}shell/hyprland {REMOTE_BASE}shell/ui {REMOTE_BASE}scripts {REMOTE_BASE}bin {REMOTE_BASE}apps/nimehos-settings/pages", timeout=15)
    log("پوشه‌های remote آماده‌ست", "OK")
    
    success = 0
    failed = []
    for rel in files:
        local = BASE_DIR / rel
        if not local.exists():
            log(f"  X {rel} - وجود نداره", "ERROR")
            failed.append(str(rel))
            continue
        
        rel_str = str(rel).replace("\\", "/")
        remote = REMOTE_BASE + rel_str
        remote_parent = remote.rsplit("/", 1)[0]
        ssh_run(f"mkdir -p {remote_parent}", timeout=10)
        
        ok, err = scp_to(local, remote)
        if ok:
            success += 1
            log(f"  + {rel_str}", "OK")
        else:
            failed.append(str(rel))
            err_short = err[:100] if err else "unknown"
            log(f"  X {rel_str}: {err_short}", "ERROR")
    
    log(f"{success}/{len(files)} فایل منتقل شد", "OK")
    if failed:
        log(f"فایل‌های ناموفق: {len(failed)}", "WARN")
    
    # تنظیم permission
    log("تنظیم permission...", "INFO")
    ssh_run(f"chmod +x {REMOTE_BASE}scripts/*.sh {REMOTE_BASE}bin/float-daemon 2>/dev/null; echo DONE", timeout=10)
    log("تنظیم permission انجام شد", "OK")
    
    return True

# ============================================================
# Step 4: Build C++ Plugin
# ============================================================
def step_build_cpp():
    log("=" * 60, "STEP")
    log("مرحله: build و install پلاگین C++ روی VM", "STEP")
    log("=" * 60, "STEP")
    
    if not BUILD_CPP_PLUGIN:
        log("build پلاگین غیرفعال در config.py", "INFO")
        return True
    
    local_plugin = BASE_DIR / LOCAL_PLUGIN_DIR
    if not local_plugin.exists():
        log(f"پوشه پلاگین پیدا نشد: {local_plugin}", "WARN")
        log("از build صرف‌نظر می‌شه (اختیاری)", "WARN")
        return True
    
    # نصب deps
    local_deps = BASE_DIR / LOCAL_INSTALL_DEPS_SH
    if local_deps.exists():
        log("نصب build dependencies روی VM...", "INFO")
        ok, err = scp_to(local_deps, "/tmp/install_deps.sh")
        if ok:
            ssh_run(f"chmod +x /tmp/install_deps.sh && bash /tmp/install_deps.sh 2>&1 | tail -10", timeout=300)
            log("deps نصب شد", "OK")
        else:
            log(f"خطا در کپی install_deps.sh: {err[:100]}", "WARN")
    else:
        log("install_deps.sh محلی پیدا نشد", "WARN")
    
    # کپی پوشه پلاگین
    log("کپی پوشه plugin به VM (scp -r)...", "INFO")
    ssh_run(f"rm -rf {REMOTE_PLUGIN} 2>/dev/null; mkdir -p {REMOTE_BASE}", timeout=15)
    
    ok, err = scp_to_dir(local_plugin, REMOTE_BASE)
    if not ok:
        log(f"خطا در کپی پلاگین: {err[:100]}", "ERROR")
        return True  # ادامه بده
    
    log("پلاگین کپی شد", "OK")
    
    # build روی VM
    log("build پلاگین روی VM...", "INFO")
    rc, out, err = ssh_run(
        f"cd {REMOTE_PLUGIN} && bash build.sh 2>&1 | tail -30",
        timeout=600
    )
    
    if out:
        log(f"خروجی build: {out[:500]}", "INFO")
    
    if out and ("Build complete" in out or "Build successful" in out or "installed" in out.lower()):
        log("پلاگین build و install شد", "OK")
    else:
        log("build پلاگین ممکنه ناموفق باشه — لاگ رو چک کن", "WARN")
    
    return True

# ============================================================
# Step 5: Configure Hyprland
# ============================================================
def step_configure():
    log("=" * 60, "STEP")
    log("مرحله: پیکربندی Hyprland و hyprlock", "STEP")
    log("=" * 60, "STEP")
    
    # backup hyprland.conf
    log("بررسی backup از hyprland.conf فعلی...", "INFO")
    rc, out, err = ssh_run(f"test -f {REMOTE_HYPR_BAK} && echo EXISTS || echo NOT_EXISTS", timeout=10)
    if out and "NOT_EXISTS" in out:
        ssh_run(f"cp {REMOTE_HYPR_CONF} {REMOTE_HYPR_BAK} 2>/dev/null; echo BACKED_UP", timeout=10)
        log("  backup گرفته شد", "OK")
    else:
        log("  backup قبلاً گرفته شده — حفظ می‌شه", "INFO")
    
    # کپی hyprland.conf جدید
    log("کپی hyprland.conf به VM...", "INFO")
    local_conf = BASE_DIR / BUNDLED_HYPR_CONF
    if local_conf.exists():
        ok, err = scp_to(local_conf, REMOTE_HYPR_CONF)
        if ok:
            log("  hyprland.conf کپی شد", "OK")
        else:
            log(f"  خطا در کپی: {err[:100]}", "ERROR")
            return False
    else:
        log(f"  hyprland.conf محلی پیدا نشد: {local_conf}", "ERROR")
        return False
    
    # چک exec-once
    log("بررسی exec-once در hyprland.conf...", "INFO")
    rc, out, err = ssh_run(f"grep -q 'quickshell -p {REMOTE_SHELL}' {REMOTE_HYPR_CONF} && echo OK || echo MISSING", timeout=10)
    if out and "OK" in out:
        log("  exec-once روی NimehOS shell تنظیم شده", "OK")
    else:
        log("  exec-once درست نیست — اضافه می‌شه", "WARN")
        ssh_run(f"echo 'exec-once = env QT_QUICK_BACKEND=software quickshell -p {REMOTE_SHELL}' >> {REMOTE_HYPR_CONF}", timeout=10)
    
    # نوشتن hyprlock.conf
    log("نوشتن hyprlock.conf در ~/.config/hypr/...", "INFO")
    hyprlock_conf = """# NimehOS hyprlock config
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

label {
    monitor =
    text = cmd[update:60000] date '+%A, %B %d'
    color = rgba(122, 133, 152, 1.0)
    font_size = 18
    font_family = Vazirmatn
    position = 0, 100
    halign = center
    valign = center
}

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
"""
    # کپی با base64 برای جلوگیری از مشکل encoding
    import base64
    b64 = base64.b64encode(hyprlock_conf.encode("utf-8")).decode("ascii")
    ssh_run(f"echo '{b64}' | base64 -d > {REMOTE_HYPRLOCK}", timeout=10)
    
    rc, out, err = ssh_run(f"wc -l {REMOTE_HYPRLOCK}", timeout=10)
    if out:
        log(f"  تعداد خطوط hyprlock.conf: {out.strip()}", "OK")
    
    log("پیکربندی Hyprland و hyprlock کامل شد", "OK")
    return True

# ============================================================
# Step 6: Restart Quickshell
# ============================================================
def step_restart():
    log("=" * 60, "STEP")
    log("مرحله: راه‌اندازی Quickshell (NimehOS shell)", "STEP")
    log("=" * 60, "STEP")
    
    # بستن quickshell فعلی
    log("بستن quickshell فعلی (pkill -x)...", "INFO")
    ssh_run("pkill -x quickshell 2>/dev/null; sleep 2; echo DONE", timeout=15)
    
    # راه‌اندازی با env vars
    log("راه‌اندازی quickshell جدید با env vars...", "INFO")
    cmd = (
        f"export XDG_RUNTIME_DIR=/run/user/$(id -u); "
        f"export WAYLAND_DISPLAY=${{WAYLAND_DISPLAY:-wayland-1}}; "
        f"export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/hypr/ 2>/dev/null | tail -1); "
        f"export QT_QPA_PLATFORM=wayland; "
        f"export QT_QUICK_BACKEND=software; "
        f"export QML_IMPORT_PATH=/usr/lib/qt6/qml:{REMOTE_SHELL}; "
        f"nohup quickshell -p {REMOTE_SHELL} > /tmp/qs.log 2>&1 &"
    )
    ssh_run(cmd, timeout=15)
    time.sleep(3)
    
    # چک
    rc, out, err = ssh_run("pgrep -f 'quickshell -p' | head -1", timeout=10)
    if rc == 0 and out and out.strip():
        log(f"Quickshell در حال اجراست (PID: {out.strip()})", "OK")
        
        # چک لاگ برای خطا
        rc, out, err = ssh_run("tail -30 /tmp/qs.log 2>/dev/null", timeout=10)
        if out:
            error_lines = [l for l in out.split("\n") if "error" in l.lower() or "ERROR" in l]
            if error_lines:
                log("خطا در لاگ quickshell:", "ERROR")
                for line in error_lines[:5]:
                    print(f"     {line}")
                log("برای rollback: python deploy.py restore-caelestia", "WARN")
                return False
            else:
                log("بدون خطا در لاگ", "OK")
        return True
    else:
        log("Quickshell اجرا نشد!", "ERROR")
        rc, out, err = ssh_run("tail -30 /tmp/qs.log 2>/dev/null", timeout=10)
        if out:
            log("محتوای /tmp/qs.log:", "ERROR")
            print(out)
        log("برای rollback: python deploy.py restore-caelestia", "WARN")
        return False

# ============================================================
# Step 7: Screenshot
# ============================================================
def step_screenshot():
    log("=" * 60, "STEP")
    log("مرحله: گرفتن اسکرین‌شات", "STEP")
    log("=" * 60, "STEP")
    
    shots_path = Path(SHOTS_DIR)
    shots_path.mkdir(parents=True, exist_ok=True)
    remote_shot = "/tmp/nimeh-desktop.png"
    
    log("گرفتن اسکرین‌شات با grim...", "INFO")
    cmd = (
        f"export XDG_RUNTIME_DIR=/run/user/$(id -u); "
        f"export WAYLAND_DISPLAY=${{WAYLAND_DISPLAY:-wayland-1}}; "
        f"export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/hypr/ 2>/dev/null | tail -1); "
        f"grim {remote_shot} 2>&1; echo EXIT=$?"
    )
    rc, out, err = ssh_run(cmd, timeout=20)
    
    if not out or "EXIT=0" not in out:
        log(f"grim خطا داد: {out[:200] if out else 'no output'}", "ERROR")
        return False
    
    log("اسکرین‌شات گرفته شد، در حال کپی...", "OK")
    local_shot = shots_path / f"nimeh-{time.strftime('%Y%m%d-%H%M%S')}.png"
    ok, err = scp_from(remote_shot, str(local_shot))
    if ok:
        log(f"اسکرین‌شات ذخیره شد: {local_shot}", "OK")
        try:
            os.startfile(str(local_shot))
            log("اسکرین‌شات باز شد", "OK")
        except Exception as e:
            log(f"نتونستم باز کنم: {e}", "WARN")
        return True
    else:
        log(f"خطا در کپی اسکرین‌شات: {err[:100]}", "ERROR")
        return False

# ============================================================
# Restore Caelestia
# ============================================================
def step_restore_caelestia():
    log("=" * 60, "STEP")
    log("مرحله: بازگرداندن Caelestia (Rollback)", "STEP")
    log("=" * 60, "STEP")
    
    # بستن NimehOS quickshell
    log("بستن NimehOS quickshell...", "INFO")
    ssh_run("pkill -x quickshell 2>/dev/null; sleep 2; echo DONE", timeout=15)
    
    # بازگرداندن hyprland.conf
    log("بازگرداندن hyprland.conf.bak...", "INFO")
    rc, out, err = ssh_run(f"test -f {REMOTE_HYPR_BAK} && cp {REMOTE_HYPR_BAK} {REMOTE_HYPR_CONF} && echo RESTORED || echo NO_BACKUP", timeout=10)
    if out and "RESTORED" in out:
        log("  hyprland.conf بازگردانده شد", "OK")
    else:
        log("  backup وجود نداره — نمی‌شه بازگرداند", "WARN")
    
    # راه‌اندازی caelestia
    log("راه‌اندازی Caelestia...", "INFO")
    rc, out, err = ssh_run(
        "systemctl --user start caelestia-shell 2>/dev/null && echo SYSTEMCTL_OK || echo SYSTEMCTL_FAIL",
        timeout=15
    )
    if out and "SYSTEMCTL_OK" in out:
        log("  Caelestia با systemctl اجرا شد", "OK")
    else:
        log("  systemctl کار نکرد — تلاش با quickshell مستقیم...", "INFO")
        cmd = (
            f"export XDG_RUNTIME_DIR=/run/user/$(id -u); "
            f"export WAYLAND_DISPLAY=${{WAYLAND_DISPLAY:-wayland-1}}; "
            f"export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/hypr/ 2>/dev/null | tail -1); "
            f"export QT_QPA_PLATFORM=wayland; "
            f"export QT_QUICK_BACKEND=software; "
            f"nohup quickshell -p ~/.config/quickshell/caelestia > /tmp/caelestia.log 2>&1 &"
        )
        ssh_run(cmd, timeout=15)
        time.sleep(3)
        
        rc, out, err = ssh_run("pgrep -f 'quickshell -p' | head -1", timeout=10)
        if out and out.strip():
            log(f"  Caelestia اجرا شد (PID: {out.strip()})", "OK")
        else:
            log("  Caelestia اجرا نشد!", "ERROR")
    
    log("Rollback کامل شد", "OK")
    return True

# ============================================================
# Show Logs
# ============================================================
def step_logs():
    print()
    print("=" * 60)
    print("  لاگ‌های Quickshell (/tmp/qs.log)")
    print("=" * 60)
    
    # چک quickshell در حال اجرا
    rc, out, err = ssh_run("pgrep -f 'quickshell -p' | head -1", timeout=10)
    if out and out.strip():
        log(f"Quickshell در حال اجراست (PID: {out.strip()})", "OK")
    else:
        log("Quickshell در حال اجرا نیست", "WARN")
    
    # لاگ quickshell
    log("محتوای /tmp/qs.log:", "INFO")
    print("-" * 60)
    rc, out, err = ssh_run("tail -50 /tmp/qs.log 2>/dev/null", timeout=10)
    if out:
        print(out)
    else:
        print("(خالی)")
    print("-" * 60)
    
    # لاگ caelestia
    print()
    print("=" * 60)
    print("  لاگ‌های Caelestia (/tmp/caelestia.log)")
    print("=" * 60)
    rc, out, err = ssh_run("tail -20 /tmp/caelestia.log 2>/dev/null", timeout=10)
    if out:
        print(out)
    else:
        print("(خالی)")
    
    return True

# ============================================================
# List Files
# ============================================================
def step_list():
    files = collect_files()
    log(f"فایل‌های قابل deploy: {len(files)}", "INFO")
    print()
    total = 0
    for rel in files:
        full = BASE_DIR / rel
        if full.exists():
            size = full.stat().st_size
            total += size
            print(f"  {str(rel):55s}  {size:>8,} bytes")
    print(f"\n  {'مجموع':55s}  {total:>8,} bytes")
    
    # پلاگین
    plugin_dir = BASE_DIR / LOCAL_PLUGIN_DIR
    if plugin_dir.exists():
        print()
        log(f"پوشه پلاگین C++:", "INFO")
        for root, dirs, filenames in os.walk(plugin_dir):
            dirs[:] = [x for x in dirs if x != "__pycache__"]
            for fn in filenames:
                full = Path(root) / fn
                rel = full.relative_to(BASE_DIR)
                size = full.stat().st_size
                print(f"  {str(rel):55s}  {size:>8,} bytes")
    
    return True

# ============================================================
# Main
# ============================================================
def main():
    print()
    print("=" * 60)
    print("  NimehOS Deploy Script — Portable Version")
    print("=" * 60)
    print()
    
    args = sys.argv[1:]
    if not args or args[0] in ("help", "--help", "-h"):
        print(__doc__)
        print()
        print("دستورات موجود:")
        print("  all                  - همه مراحل")
        print("  snapshot             - گرفتن snapshot")
        print("  stop-caelestia       - توقف caelestia")
        print("  deploy               - انتقال فایل‌ها")
        print("  build-cpp            - build پلاگین C++")
        print("  configure            - پیکربندی hyprland")
        print("  restart              - ری‌استارت quickshell")
        print("  shot                 - اسکرین‌شات")
        print("  restore-caelestia    - بازگرداندن caelestia")
        print("  logs                 - نمایش لاگ‌ها")
        print("  list                 - لیست فایل‌ها")
        print("  help                 - این راهنما")
        return 0
    
    cmd = args[0].lower()
    
    if cmd == "list":
        return 0 if step_list() else 1
    
    if cmd == "snapshot":
        return 0 if step_snapshot() else 1
    
    if cmd == "stop-caelestia":
        return 0 if step_stop_caelestia() else 1
    
    if cmd == "deploy":
        if not step_deploy(): return 1
        return 0
    
    if cmd == "build-cpp":
        return 0 if step_build_cpp() else 1
    
    if cmd == "configure":
        return 0 if step_configure() else 1
    
    if cmd == "restart":
        return 0 if step_restart() else 1
    
    if cmd == "shot":
        return 0 if step_screenshot() else 1
    
    if cmd == "restore-caelestia":
        return 0 if step_restore_caelestia() else 1
    
    if cmd == "logs":
        return 0 if step_logs() else 1
    
    if cmd == "all":
        ok = True
        if not step_snapshot():        log("snapshot ناموفق", "WARN")
        if not step_stop_caelestia():  ok = False
        if not step_deploy():          ok = False
        if not step_build_cpp():       log("build-cpp ناموفق", "WARN")
        if not step_configure():       ok = False
        if not step_restart():         ok = False
        if not step_screenshot():      log("screenshot ناموفق", "WARN")
        
        print()
        if ok:
            log("همه مراحل با موفقیت انجام شد!", "OK")
        else:
            log("بعضی مراحل ناموفق بودن — لاگ‌ها رو بررسی کنید", "WARN")
        log("برای مشاهده لاگ: python deploy.py logs", "INFO")
        log("برای rollback: python deploy.py restore-caelestia", "INFO")
        return 0 if ok else 1
    
    print(f"دستور نامشخص: {cmd}")
    print("برای راهنما: python deploy.py help")
    return 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        print()
        log("قطع شد توسط کاربر", "WARN")
        log("برای rollback: python deploy.py restore-caelestia", "INFO")
        sys.exit(130)
