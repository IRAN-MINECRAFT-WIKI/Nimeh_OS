# NimehOS — Quick Start (3 Steps)

## Step 1 — Configure

Copy the example config and edit it for your machine:

```bash
cd NimehOS_final_v2
cp config.example.py config.py
$EDITOR config.py
```

The values you **must** change:

```python
SSH_KEY   = r"C:\Users\YOUR_USERNAME\.ssh\nimeh_key"   # path to your SSH key
SSH_HOST  = "nimeh@127.0.0.1"                          # user@ip
SSH_PORT  = "2222"                                     # SSH port (forwarded from VM)
SUDO_PASS = "YOUR_SUDO_PASSWORD"                       # sudo password on the VM

VBOX      = r"D:\VirtualBox\VBoxManage.exe"            # VBoxManage path on host
VM_NAME   = "NimehOS-Dev"                              # VM name in VirtualBox

SHOTS_DIR = r"D:\NimehOS\screenshots"                  # where screenshots land
```

Already-correct defaults you can leave alone:

```python
REMOTE_HOME  = "/home/nimeh"
REMOTE_BASE  = "/home/nimeh/NimehOS/"
REMOTE_SHELL = "/home/nimeh/NimehOS/shell"
REMOTE_PLUGIN = "/home/nimeh/NimehOS/plugin"

AUTO_SNAPSHOT    = True
RETRY_ATTEMPTS   = 3
RETRY_DELAY      = 2
VERBOSE          = True
BUILD_CPP_PLUGIN = True
```

> **Sanity check**: from your host, `ssh -i <SSH_KEY> -p <SSH_PORT> <SSH_HOST> echo OK`
> should print `OK`. If it doesn't, fix SSH before going further.

## Step 2 — Deploy

Run the full pipeline (snapshot → stop Caelestia → push files → build C++ plugin
→ configure Hyprland → restart Quickshell → screenshot):

```bash
python3 deploy.py all
```

You'll see coloured Persian log lines like:

```
[STEP] مرحله: انتقال فایل‌های QML و scripts به VM
[OK]   103/103 فایل منتقل شد
[STEP] مرحله: build و install پلاگین C++ روی VM
[OK]   پلاگین build و install شد
[STEP] مرحله: راه‌اندازی Quickshell (NimehOS shell)
[OK]   Quickshell در حال اجراست (PID: 12345)
[STEP] مرحله: گرفتن اسکرین‌شات
[OK]   اسکرین‌شات ذخیره شد: D:\NimehOS\screenshots\nimeh-20251009-095400.png
```

If anything fails, the script tells you the failing step and points you at
the right rollback command:

```
[ERROR] Quickshell اجرا نشد!
[WARN]  برای rollback: python deploy.py restore-caelestia
```

## Step 3 — Test

1. **Visual check** — open the screenshot that was just saved to `SHOTS_DIR`.
   You should see the NimehOS taskbar at the bottom and the NimehOS wallpaper.

2. **Logs** — if anything looks off, pull the runtime logs:
   ```bash
   python3 deploy.py logs
   ```
   This prints the last 50 lines of `/tmp/qs.log` (NimehOS) and the last 20
   lines of `/tmp/caelestia.log` (the previous shell, for comparison).

3. **Rollback (if needed)** — to restore the previous Caelestia shell:
   ```bash
   python3 deploy.py restore-caelestia
   ```
   This kills NimehOS Quickshell, restores `~/.config/hypr/hyprland.conf.bak`,
   and restarts Caelestia.

4. **Re-deploy a single step** — for example, after editing a single QML file:
   ```bash
   python3 deploy.py deploy     # only push files
   python3 deploy.py restart    # only restart Quickshell
   ```

That's it — you're running NimehOS.
