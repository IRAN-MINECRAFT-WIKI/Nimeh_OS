# NimehOS — Troubleshooting

Common errors you might hit while deploying or running NimehOS, with the
exact fix for each one.

---

## 1. `<TypeName> is not a type`

**Symptom**: In `/tmp/qs.log` you see lines like:

```
file:///home/nimeh/NimehOS/shell/NimehTaskbar.qml:42:1: BlobRect is not a type
file:///home/nimeh/NimehOS/shell/NimehStartMenu.qml:53:1: GlassPanel is not a type
```

**Cause**: The `shell/qmldir` file on the VM is incomplete — it doesn't
declare every QML type, so the QML engine can't resolve references between
sibling files.

**Fix**:

- Verify the local qmldir lists **every** `.qml` file in `shell/`
  (except `shell.qml`, the entry point). The v2 package ships with a
  complete qmldir (31 entries: 2 singletons + 29 components).
- Re-deploy just the qmldir:
  ```bash
  python3 deploy.py deploy
  python3 deploy.py restart
  ```
- Confirm the qmldir landed on the VM:
  ```bash
  ssh -i <KEY> -p 2222 nimeh@127.0.0.1 \
    'wc -l /home/nimeh/NimehOS/shell/qmldir'
  ```
  Should report ~40 lines.

---

## 2. `config.py not found`

**Symptom**: Running `python3 deploy.py all` exits immediately with:

```
============================================================
خطا: فایل config.py پیدا نشد!
============================================================
```

**Cause**: `config.py` doesn't exist in the package root. The deploy script
imports `SSH_KEY`, `SSH_HOST`, `REMOTE_PLUGIN`, etc. from `config.py`.

**Fix**:

```bash
cp config.example.py config.py
$EDITOR config.py   # set SSH_KEY, SUDO_PASS, VBOX, VM_NAME
```

`config.py` is excluded from the ZIP on purpose (it contains credentials),
so you must create it from the example after extracting the package.

---

## 3. `SSH connection failed`

**Symptom**:

```
[ERROR] SSH وصل نمی‌شه: ssh: connect to host 127.0.0.1 port 2222: Connection refused
```

Or:

```
[ERROR] SSH وصل نمی‌شه: Permission denied (publickey).
```

**Cause**: The VM isn't running, the SSH port forward isn't set up, or the
SSH key path/permissions are wrong.

**Fix** (check each one in order):

1. **Is the VM running?**
   ```bash
   "D:\VirtualBox\VBoxManage.exe" list runningvms
   ```
   If `NimehOS-Dev` (or whatever `VM_NAME` is) isn't listed, start it:
   ```bash
   "D:\VirtualBox\VBoxManage.exe" startvm NimehOS-Dev --type headless
   ```

2. **Is port 2222 forwarded to the VM's port 22?**
   In VirtualBox → VM Settings → Network → Advanced → Port Forwarding,
   there should be a rule:
   ```
   HostPort 2222 → GuestPort 22, Protocol TCP
   ```

3. **Does the SSH key exist and have correct perms?**
   ```bash
   ls -l C:\Users\YOU\.ssh\nimeh_key     # must be -rw------- (600)
   ```
   On Windows, fix with `icacls` or by recreating the key.

4. **Can you SSH manually?**
   ```bash
   ssh -i C:\Users\YOU\.ssh\nimeh_key -p 2222 nimeh@127.0.0.1 echo OK
   ```
   If this works but `deploy.py` doesn't, double-check `config.py`:
   ```python
   SSH_KEY  = r"C:\Users\YOU\.ssh\nimeh_key"   # raw string, exact path
   SSH_HOST = "nimeh@127.0.0.1"
   SSH_PORT = "2222"
   ```

---

## 4. `Quickshell failed to start`

**Symptom**:

```
[ERROR] Quickshell اجرا نشد!
محتوای /tmp/qs.log:
...
```

**Cause**: Most often a QML import or type error, or a missing env var.
Sometimes the previous Quickshell process didn't die.

**Fix**:

1. **Read the log carefully**:
   ```bash
   python3 deploy.py logs
   ```
   Look for the first `Error` or `TypeError` line — that's the root cause.

2. **If it's a "type not found" error**, see issue #1 above (qmldir).

3. **If it's an `import` error** (e.g. `module "NimehOS" not installed`):
   - Either build the C++ plugin: `python3 deploy.py build-cpp`
   - Or set `BUILD_CPP_PLUGIN = False` in `config.py` to use the QML-only
     `BlobRect.qml`/`BlobGroup.qml` (which is what the local qmldir
     points at by default).

4. **If it's a Wayland env error**:
   ```bash
   export XDG_RUNTIME_DIR=/run/user/$(id -u)
   export WAYLAND_DISPLAY=wayland-1
   export HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/hypr/ | tail -1)
   export QT_QPA_PLATFORM=wayland
   export QT_QUICK_BACKEND=software
   ```
   `deploy.py` already sets these in `step_restart()` — but if you're
   running Quickshell manually you need them too.

5. **Force-kill any zombie Quickshell**:
   ```bash
   ssh -i <KEY> -p 2222 nimeh@127.0.0.1 \
     'pkill -x quickshell; sleep 2; pgrep -x quickshell'
   ```
   If `pgrep` returns nothing, you're clean. Re-run `python3 deploy.py restart`.

---

## 5. `Build failed` (C++ plugin)

**Symptom**:

```
[STEP] مرحله: build و install پلاگین C++ روی VM
[WARN]  build پلاگین ممکنه ناموفق باشه — لاگ رو چک کن
```

Or the build log mentions missing `Qt6Quick`, `Qt6Qml`, `Qt6ShaderTools`,
or `Qt6Concurrent`.

**Cause**: The VM is missing the Qt6 build dependencies.

**Fix**:

1. **Install deps on the VM** (the deploy script does this automatically,
   but if it failed, run it manually):
   ```bash
   python3 deploy.py build-cpp
   ```
   This runs `install_deps.sh` on the VM, which installs:
   ```
   qt6-base-dev qt6-declarative-dev qt6-shadertools-dev
   cmake ninja-build g++ libgl1-mesa-dev
   ```

2. **Manual install** (if the above still fails):
   ```bash
   ssh -i <KEY> -p 2222 nimeh@127.0.0.1
   sudo apt update
   sudo apt install -y qt6-base-dev qt6-declarative-dev qt6-shadertools-dev \
                       cmake ninja-build g++ libgl1-mesa-dev
   ```

3. **Try the build manually** to see the full error:
   ```bash
   ssh -i <KEY> -p 2222 nimeh@127.0.0.1
   cd /home/nimeh/NimehOS/plugin
   ./build.sh
   ```
   The last 40 lines of the build log are printed on failure.

4. **Skip the plugin entirely** (fallback): the QML-only `BlobRect.qml` and
   `BlobGroup.qml` work without the C++ plugin. In `config.py`:
   ```python
   BUILD_CPP_PLUGIN = False
   ```
   Then re-run `python3 deploy.py all`. You lose the real SDF shader and
   `ImageAnalyser`, but the shell runs.

5. **Rollback the plugin** if a previous build left a broken `.so` lying
   around:
   ```bash
   ssh -i <KEY> -p 2222 nimeh@127.0.0.1
   cd /home/nimeh/NimehOS/plugin
   ./rollback.sh
   ```

---

## 6. Other useful commands

- **List files that would be deployed** (without actually deploying):
  ```bash
  python3 deploy.py list
  ```
- **Take a fresh screenshot without redeploying**:
  ```bash
  python3 deploy.py shot
  ```
- **Restore the original Caelestia shell** (full rollback):
  ```bash
  python3 deploy.py restore-caelestia
  ```

---

## 7. Still stuck?

Collect this info and ask:

1. Output of `python3 deploy.py logs` (last 50 lines of `/tmp/qs.log`).
2. Output of `python3 deploy.py list` (to confirm file counts).
3. `cat config.py` with `SUDO_PASS` redacted.
4. `ssh -i <KEY> -p 2222 nimeh@127.0.0.1 'cat /etc/os-release; quickshell --version'`
5. The exact command you ran and the full output.
