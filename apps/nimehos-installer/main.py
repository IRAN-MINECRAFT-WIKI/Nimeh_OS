#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""NimehOS Installer — نصب‌کننده‌ی گرافیکی بسته‌ها"""
import sys, os, json, subprocess
from pathlib import Path
from PySide6.QtCore import Qt, QThread, Signal, QObject
from PySide6.QtGui import QFont, QPalette, QColor
from PySide6.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout,
    QHBoxLayout, QLabel, QPushButton, QProgressBar, QFrame, QScrollArea)
from info import inspect
from installer import install

# ─── استایل تیره NimehOS ───
DARK_STYLE = """
QMainWindow { background: #202020; }
QLabel { color: #FFFFFF; font-family: 'Vazirmatn','Inter'; }
QPushButton {
    background: #0078D4; color: white; border: none; border-radius: 6px;
    padding: 8px 24px; font-size: 13px; font-family: 'Vazirmatn';
}
QPushButton:hover { background: #1084E0; }
QPushButton:disabled { background: #333333; color: #666666; }
QPushButton#cancel { background: #333333; }
QPushButton#cancel:hover { background: #444444; }
QProgressBar {
    background: #2A2A2A; border: 1px solid #333333; border-radius: 4px;
    text-align: center; color: #FFFFFF; height: 20px;
}
QProgressBar::chunk { background: #0078D4; border-radius: 3px; }
QFrame#card { background: #2A2A2A; border-radius: 8px; border: 1px solid #333333; }
QFrame#warn { background: rgba(245,158,11,0.15); border-radius: 6px; border: 1px solid #F59E0B; }
"""

class InstallThread(QThread):
    progress = Signal(int, str)
    finished_signal = Signal(dict)
    def __init__(self, path, fmt, sudo_pass=None):
        super().__init__()
        self.path = path; self.fmt = fmt; self.sudo_pass = sudo_pass
    def run(self):
        def cb(pct, msg): self.progress.emit(pct, msg)
        result = install(self.path, self.fmt, self.sudo_pass, cb)
        self.finished_signal.emit(result)

class InstallerWindow(QMainWindow):
    def __init__(self, file_path):
        super().__init__()
        self.file_path = file_path
        self.info = inspect(file_path)
        self.install_thread = None
        self.init_ui()

    def init_ui(self):
        self.setWindowTitle("نصب‌کننده NimehOS")
        self.setFixedSize(600, 480)
        self.setStyleSheet(DARK_STYLE)
        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        layout.setContentsMargins(24, 24, 24, 24)
        layout.setSpacing(12)

        if "error" in self.info:
            layout.addWidget(QLabel(f"❌ خطا: {self.info['error']}"))
            btn = QPushButton("بستن"); btn.clicked.connect(self.close)
            layout.addWidget(btn); return

        # ─── آیکون + نام ───
        top = QHBoxLayout()
        icon_label = QLabel("📦")
        icon_label.setStyleSheet("font-size: 48px;")
        icon_label.setFixedSize(64, 64)
        icon_label.setAlignment(Qt.AlignCenter)
        top.addWidget(icon_label)
        info_col = QVBoxLayout()
        name_label = QLabel(self.info.get("name", "نامشخص"))
        name_label.setStyleSheet("font-size: 18px; font-weight: bold;")
        info_col.addWidget(name_label)
        id_label = QLabel(f"ID: {self.info.get('app_id','—')}")
        id_label.setStyleSheet("color: #888888; font-size: 11px;")
        info_col.addWidget(id_label)
        ver_label = QLabel(f"نسخه: {self.info.get('version','—')}")
        ver_label.setStyleSheet("color: #888888; font-size: 11px;")
        info_col.addWidget(ver_label)
        top.addLayout(info_col)
        top.addStretch()
        layout.addLayout(top)

        # ─── توضیحات ───
        desc = QLabel(self.info.get("description", ""))
        desc.setWordWrap(True)
        desc.setStyleSheet("color: #AAAAAA; font-size: 12px;")
        layout.addWidget(desc)

        # ─── کارت اطلاعات ───
        card = QFrame(); card.setObjectName("card")
        card_layout = QVBoxLayout(card)
        for label, key in [("حجم فایل", "file_size"), ("مسیر نصب", "install_path"),
                           ("فرمت", "format"), ("SHA256", "sha256")]:
            row = QHBoxLayout()
            k = QLabel(label); k.setStyleSheet("color: #888888; font-size: 11px;"); k.setFixedWidth(100)
            v = QLabel(str(self.info.get(key, "—"))); v.setStyleSheet("color: #CCCCCC; font-size: 11px;")
            row.addWidget(k); row.addWidget(v); row.addStretch()
            card_layout.addLayout(row)
        layout.addWidget(card)

        # ─── هشدار امنیتی ───
        sec = self.info.get("security", "green")
        sec_text = self.info.get("security_text", "")
        if sec != "green":
            warn = QFrame(); warn.setObjectName("warn")
            warn_layout = QHBoxLayout(warn)
            icon = QLabel("⚠" if sec == "yellow" else "🛑")
            icon.setStyleSheet("font-size: 16px;")
            warn_layout.addWidget(icon)
            warn_layout.addWidget(QLabel(sec_text))
            warn_layout.addStretch()
            layout.addWidget(warn)

        # ─── progress bar ───
        self.progress = QProgressBar()
        self.progress.setVisible(False)
        layout.addWidget(self.progress)
        self.status_label = QLabel("")
        self.status_label.setStyleSheet("color: #888888; font-size: 11px;")
        self.status_label.setVisible(False)
        layout.addWidget(self.status_label)

        # ─── نتیجه ───
        self.result_label = QLabel("")
        self.result_label.setStyleSheet("font-size: 14px;")
        self.result_label.setVisible(False)
        layout.addWidget(self.result_label)

        layout.addStretch()

        # ─── دکمه‌ها ───
        btn_row = QHBoxLayout()
        btn_row.addStretch()
        self.cancel_btn = QPushButton("انصراف"); self.cancel_btn.setObjectName("cancel")
        self.cancel_btn.clicked.connect(self.close)
        btn_row.addWidget(self.cancel_btn)
        self.install_btn = QPushButton("📦 نصب")
        self.install_btn.clicked.connect(self.do_install)
        btn_row.addWidget(self.install_btn)
        self.run_btn = QPushButton("▶ اجرا")
        self.run_btn.clicked.connect(self.run_app)
        self.run_btn.setVisible(False)
        btn_row.addWidget(self.run_btn)
        layout.addLayout(btn_row)

    def do_install(self):
        self.install_btn.setVisible(False)
        self.cancel_btn.setText("بستن")
        self.progress.setVisible(True)
        self.status_label.setVisible(True)
        self.progress.setValue(0)
        self.status_label.setText("آماده‌سازی...")
        self.install_thread = InstallThread(
            self.file_path, self.info.get("format",""),
            sudo_pass=None  # در نسخه‌ی بعد از کاربر گرفته می‌شه
        )
        self.install_thread.progress.connect(self.on_progress)
        self.install_thread.finished_signal.connect(self.on_finished)
        self.install_thread.start()

    def on_progress(self, pct, msg):
        self.progress.setValue(pct)
        self.status_label.setText(msg)

    def on_finished(self, result):
        self.progress.setVisible(False)
        self.status_label.setVisible(False)
        if result.get("success"):
            self.result_label.setText("✅ نصب موفق بود!")
            self.result_label.setStyleSheet("color: #22D3AE; font-size: 14px;")
            self.run_btn.setVisible(True)
        else:
            self.result_label.setText(f"❌ خطا: {result.get('error','نامشخص')}")
            self.result_label.setStyleSheet("color: #EF4444; font-size: 14px;")
            self.install_btn.setVisible(True)
        self.result_label.setVisible(True)

    def run_app(self):
        exec_cmd = self.info.get("app_id", self.info.get("name","")).lower()
        if self.info["format"] == "flatpak":
            subprocess.Popen(["flatpak","run", self.info.get("app_id","")])
        elif self.info["format"] == "AppImage":
            subprocess.Popen([self.info.get("install_path","") + os.path.basename(self.file_path)])
        self.close()


def main():
    if len(sys.argv) < 2:
        print("Usage: nimehos-installer <file>")
        sys.exit(1)
    app = QApplication(sys.argv)
    app.setApplicationName("NimehOS Installer")
    window = InstallerWindow(sys.argv[1])
    window.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
