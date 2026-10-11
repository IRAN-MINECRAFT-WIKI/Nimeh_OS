# -*- coding: utf-8 -*-
"""
NimehOS Deploy Configuration — نمونه
=====================================
این فایل رو به config.py کپی کن و ویرایش کن.

  copy config.example.py config.py
  notepad config.py
"""

# ============================================================
# SSH Configuration
# ============================================================
# مسیر فایل کلید SSH روی ویندوز (با r" ..." بنویس)
# مثال: r"C:\Users\YOUR_USERNAME\.ssh\nimeh_key"
SSH_KEY = r"C:\Users\YOUR_USERNAME\.ssh\nimeh_key"

# آدرس SSH (user@ip)
SSH_HOST = "nimeh@127.0.0.1"

# پورت SSH
SSH_PORT = "2222"

# رمز sudo کاربر VM
SUDO_PASS = "YOUR_SUDO_PASSWORD"

# ============================================================
# VirtualBox Configuration
# ============================================================
# مسیر VBoxManage.exe روی ویندوز
# مثال‌ها:
#   r"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
#   r"D:\VirtualBox\VBoxManage.exe"
VBOX = r"C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

# نام VM در VirtualBox
VM_NAME = "NimehOS-Dev"

# ============================================================
# Remote Paths (روی VM)
# ============================================================
REMOTE_HOME = "/home/nimeh"
REMOTE_BASE = "/home/nimeh/NimehOS/"
REMOTE_SHELL = "/home/nimeh/NimehOS/shell"
REMOTE_PLUGIN = "/home/nimeh/NimehOS/plugin"

# ============================================================
# Local Paths (روی ویندوز)
# ============================================================
SHOTS_DIR = r"D:\NimehOS\screenshots"

# ============================================================
# Behavior
# ============================================================
AUTO_SNAPSHOT = True
RETRY_ATTEMPTS = 3
RETRY_DELAY = 2
VERBOSE = True
BUILD_CPP_PLUGIN = True
