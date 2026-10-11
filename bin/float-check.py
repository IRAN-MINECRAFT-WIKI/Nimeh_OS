#!/usr/bin/env python3
import json, subprocess
try:
    r = subprocess.run(['hyprctl', 'clients', '-j'],
                      capture_output=True, text=True, timeout=3)
    data = json.loads(r.stdout)
    for c in data:
        if not c.get('floating', True) and not c.get('fullscreen', False):
            addr = c.get('address', '')
            size = c.get('size', [0, 0])
            if addr and size[0] > 300 and size[1] > 200:
                subprocess.run(['hyprctl', 'dispatch', 'togglefloating',
                              f'address:{addr}'], capture_output=True, timeout=3)
                subprocess.run(['hyprctl', 'dispatch', 'resizeactive',
                              'exact', '1100', '700'], capture_output=True, timeout=3)
                subprocess.run(['hyprctl', 'dispatch', 'centerwindow'],
                              capture_output=True, timeout=3)
except Exception:
    pass

