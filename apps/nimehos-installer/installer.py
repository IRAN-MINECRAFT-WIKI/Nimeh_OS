#!/usr/bin/env python3
"""منطق نصب بسته‌ها"""
import subprocess, os, shutil

def install_flatpak(path, progress_cb=None):
    """نصب flatpak — بدون sudo"""
    if progress_cb: progress_cb(10, "در حال بررسی وابستگی‌ها...")
    if not shutil.which("flatpak"):
        return {"success": False, "error": "flatpak نصب نیست. ابتدا نصب کنید: sudo apt install flatpak"}
    if progress_cb: progress_cb(30, "در حال نصب...")
    try:
        r = subprocess.run(["flatpak","install","--user","-y",path],
                          capture_output=True, text=True, timeout=300)
        if r.returncode == 0:
            if progress_cb: progress_cb(100, "نصب کامل شد")
            return {"success": True, "message": "نصب موفق بود"}
        return {"success": False, "error": r.stderr[:500]}
    except Exception as e:
        return {"success": False, "error": str(e)}

def install_appimage(path, progress_cb=None):
    """نصب AppImage — کپی به ~/.local/bin/"""
    if progress_cb: progress_cb(20, "در حال کپی...")
    bin_dir = os.path.expanduser("~/.local/bin")
    os.makedirs(bin_dir, exist_ok=True)
    dest = os.path.join(bin_dir, os.path.basename(path))
    try:
        shutil.copy2(path, dest)
        os.chmod(dest, 0o755)
        if progress_cb: progress_cb(100, "نصب کامل شد")
        return {"success": True, "message": f"نصب شد در {dest}"}
    except Exception as e:
        return {"success": False, "error": str(e)}

def install_deb(path, sudo_pass=None, progress_cb=None):
    """نصب .deb — نیاز به sudo"""
    if progress_cb: progress_cb(10, "در حال بررسی...")
    if not shutil.which("dpkg"):
        return {"success": False, "error": "dpkg نصب نیست"}
    if progress_cb: progress_cb(30, "در حال نصب با sudo...")
    try:
        cmd = ["sudo","-S","dpkg","-i",path]
        r = subprocess.run(cmd, input=(sudo_pass+"\n") if sudo_pass else None,
                          capture_output=True, text=True, timeout=120)
        if r.returncode == 0:
            if progress_cb: progress_cb(100, "نصب کامل شد")
            return {"success": True, "message": "نصب موفق بود"}
        return {"success": False, "error": r.stderr[:500]}
    except Exception as e:
        return {"success": False, "error": str(e)}

def install_rpm(path, sudo_pass=None, progress_cb=None):
    """نصب .rpm — نیاز به sudo"""
    if progress_cb: progress_cb(10, "در حال بررسی...")
    if not shutil.which("rpm"):
        return {"success": False, "error": "rpm نصب نیست (این Debian است)"}
    if progress_cb: progress_cb(30, "در حال نصب با sudo...")
    try:
        cmd = ["sudo","-S","rpm","-i",path]
        r = subprocess.run(cmd, input=(sudo_pass+"\n") if sudo_pass else None,
                          capture_output=True, text=True, timeout=120)
        if r.returncode == 0:
            if progress_cb: progress_cb(100, "نصب کامل شد")
            return {"success": True, "message": "نصب موفق بود"}
        return {"success": False, "error": r.stderr[:500]}
    except Exception as e:
        return {"success": False, "error": str(e)}

def install(path, fmt, sudo_pass=None, progress_cb=None):
    """نقطه‌ی ورود — بر اساس فرمت مسیر نصب را انتخاب می‌کند"""
    if fmt == "flatpak": return install_flatpak(path, progress_cb)
    elif fmt == "AppImage": return install_appimage(path, progress_cb)
    elif fmt == "deb": return install_deb(path, sudo_pass, progress_cb)
    elif fmt == "rpm": return install_rpm(path, sudo_pass, progress_cb)
    return {"success": False, "error": f"فرمت پشتیبانی نمی‌شود: {fmt}"}
