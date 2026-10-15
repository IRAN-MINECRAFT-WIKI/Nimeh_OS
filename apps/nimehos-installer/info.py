#!/usr/bin/env python3
"""استخراج اطلاعات بسته از .flatpak/.AppImage/.deb/.rpm"""
import subprocess, os, json, hashlib

def get_file_size(path):
    return os.path.getsize(path) if os.path.exists(path) else 0

def format_size(bytes):
    if bytes < 1024: return f"{bytes} B"
    if bytes < 1024*1024: return f"{bytes/1024:.1f} KB"
    if bytes < 1024*1024*1024: return f"{bytes/(1024*1024):.1f} MB"
    return f"{bytes/(1024*1024*1024):.2f} GB"

def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()

def inspect_flatpak(path):
    info = {"format": "flatpak", "needs_sudo": False, "install_path": "~/.local/share/flatpak/"}
    try:
        r = subprocess.run(["flatpak", "info", path], capture_output=True, text=True, timeout=10)
        for line in r.stdout.split("\n"):
            if line.startswith("ID:"): info["app_id"] = line.split(":",1)[1].strip()
            elif line.startswith("Version:"): info["version"] = line.split(":",1)[1].strip()
            elif line.startswith("Ref:"): info["ref"] = line.split(":",1)[1].strip()
            elif line.startswith("Installed:"): info["installed_size"] = line.split(":",1)[1].strip()
        if not info.get("app_id"): info["app_id"] = os.path.basename(path).replace(".flatpak","")
    except: info["app_id"] = os.path.basename(path)
    info["name"] = info.get("app_id","").split(".")[-1] or os.path.basename(path)
    return info

def inspect_appimage(path):
    info = {"format": "AppImage", "needs_sudo": False, "install_path": "~/.local/bin/"}
    info["name"] = os.path.basename(path).replace(".AppImage","").replace("-"," ").title()
    info["app_id"] = info["name"].lower().replace(" ","-")
    info["version"] = "unknown"
    info["executable"] = os.access(path, os.X_OK)
    return info

def inspect_deb(path):
    info = {"format": "deb", "needs_sudo": True, "install_path": "/usr/"}
    try:
        r = subprocess.run(["dpkg-deb","-I",path], capture_output=True, text=True, timeout=10)
        for line in r.stdout.split("\n"):
            l = line.strip()
            if l.startswith("Package:"): info["app_id"] = l.split(":",1)[1].strip()
            elif l.startswith("Version:"): info["version"] = l.split(":",1)[1].strip()
            elif l.startswith("Description:"): info["description"] = l.split(":",1)[1].strip()
    except: pass
    info["name"] = info.get("app_id","").split("-")[0].title() or os.path.basename(path)
    return info

def inspect_rpm(path):
    info = {"format": "rpm", "needs_sudo": True, "install_path": "/usr/"}
    try:
        r = subprocess.run(["rpm","-qpi",path], capture_output=True, text=True, timeout=10)
        for line in r.stdout.split("\n"):
            if "Name:" in line: info["app_id"] = line.split(":",1)[1].strip()
            elif "Version:" in line: info["version"] = line.split(":",1)[1].strip().split()[0]
            elif "Summary:" in line: info["description"] = line.split(":",1)[1].strip()
    except: pass
    info["name"] = info.get("app_id","") or os.path.basename(path)
    return info

def inspect(path):
    """نقطه‌ی ورود — فرمت را تشخیص می‌دهد و اطلاعات را برمی‌گرداند"""
    if not os.path.exists(path): return {"error": "فایل وجود ندارد"}
    ext = os.path.splitext(path)[1].lower()
    size = get_file_size(path)
    if ext == ".flatpak": info = inspect_flatpak(path)
    elif ext == ".appimage": info = inspect_appimage(path)
    elif ext == ".deb": info = inspect_deb(path)
    elif ext == ".rpm": info = inspect_rpm(path)
    else: return {"error": f"فرمت پشتیبانی نمی‌شود: {ext}"}
    info["file_size"] = format_size(size)
    info["file_path"] = path
    info["sha256"] = sha256(path)[:16] + "..."
    if "version" not in info: info["version"] = "unknown"
    if "description" not in info: info["description"] = f"بسته‌ی {info.get('name','نامشخص')}"
    # security
    if info["needs_sudo"]:
        info["security"] = "yellow"
        info["security_text"] = "نیاز به دسترسی مدیر (sudo) — نصب سیستمی"
    else:
        info["security"] = "green"
        info["security_text"] = "نصب در فضای کاربر — امن"
    return info

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2: print("Usage: info.py <file>"); sys.exit(1)
    print(json.dumps(inspect(sys.argv[1]), indent=2, ensure_ascii=False))
