// ═════════════════════════════════════════════════════════
//  ContextOverlay — یک پنجره‌ی تمام‌صفحه‌ی شفاف برای همه‌ی منوهای کلیک راست
//  - موقعیت با مختصات صفحه (screen) داده می‌شود و داخل صفحه نگه داشته می‌شود
//  - اگر fromBottom=true باشد (مثلاً از تسک‌بار)، منو بالای نقطه باز می‌شود
//  - بیرون منو کلیک شود، بسته می‌شود
//  استفاده:  ctx.show(x, y, { accent, title, fromBottom, items: [...] }, ownerTag)
//            onActivated: (id, owner) => ...
// ═════════════════════════════════════════════════════════
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: ov

    property bool shown: false
    property string ownerTag: ""
    property var menuSpec: ({})

    signal activated(string id, string owner)

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.namespace: "nimeh-contextmenu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    visible: shown

    function show(px, py, spec, owner) {
        menuSpec = spec
        ownerTag = owner
        menu.accent = spec.accent
        menu.title = spec.title || ""
        menu.items = spec.items || []

        // ابعاد صفحه از خود مانیتور گرفته می‌شود (ov.width/height لحظه‌ی باز شدن صفر است)
        var sw = (ov.screen && ov.screen.width > 0) ? ov.screen.width : 1920
        var sh = (ov.screen && ov.screen.height > 0) ? ov.screen.height : 1080

        // اگر منو از تسک‌بار آمده، py نسبت به بالای پنجره‌ی تسک‌بار است
        if (spec.fromBottom) {
            var winH = spec.windowH !== undefined ? spec.windowH : 70
            py = sh - winH + py
        }
        var w = menu.width
        var h = menu.implicitHeight > 0 ? menu.implicitHeight : 260
        var nx = Math.min(Math.max(px, 8), sw - w - 8)
        var ny = spec.fromBottom ? (py - h - 8) : py
        ny = Math.min(Math.max(ny, 8), sh - h - 8)
        menu.x = nx
        menu.y = ny
        shown = true
        menu.show(nx, ny)
    }

    function hide() {
        shown = false
        menu.shown = false
    }

    // پس‌زمینه‌ی کلیک‌گیر: بیرون منو = بستن
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: ov.hide()
    }

    ColorContextMenu {
        id: menu
        onActivated: id => ov.activated(id, ov.ownerTag)
        onDismissed: ov.hide()
    }

}
