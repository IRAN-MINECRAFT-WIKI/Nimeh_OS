// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: 2024 NimehOS Contributors
//
// SettingsCard.qml — کارت پایه
// ============================================================
// پس‌زمینه rgba(255,255,255,0.06)، حاشیه ۱px، شعاع r-md (14px) و
// padding داخلی ۱۶px. فرزندان مستقیم در داخل padding قرار می‌گیرند.

import QtQuick

Rectangle {
    id: root
    color: SettingsTheme.cardBg
    border.width: 1
    border.color: SettingsTheme.border
    radius: SettingsTheme.rMd
    implicitHeight: 80

    // default property alias — فرزندان مستقیم داخل contentItem قرار می‌گیرند
    default property alias contentChildren: contentItem.data

    Item {
        id: contentItem
        anchors.fill: parent
        anchors.margins: 16
    }
}
