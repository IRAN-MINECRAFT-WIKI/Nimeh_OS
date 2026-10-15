import QtQuick
import Quickshell
import Quickshell.Wayland

// NimehOS ORBIT — low-cost animated wallpaper
// Uses simple Qt Quick shapes and slow opacity/position animations.
// No per-frame JavaScript Timer, ShaderEffect, or blur filters.

PanelWindow {
    id: wallpaper

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    color: "#090A12"

    WlrLayershell.namespace: "nimeh-wallpaper"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    property bool motionEnabled: true

    Rectangle {
        anchors.fill: parent
        color: "#090A12"

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#06121F" }
            GradientStop { position: 0.52; color: "#090A12" }
            GradientStop { position: 1.0; color: "#05070E" }
        }
    }

    // Large, soft color fields. Their movement is deliberately very subtle.
    Item {
        id: orbitLayers
        anchors.fill: parent
        visible: true

        Rectangle {
            id: emeraldGlow
            width: wallpaper.width * 0.78
            height: wallpaper.height * 0.66
            x: -width * 0.16
            y: -height * 0.18
            radius: height * 0.48
            color: "#0B5270"
            opacity: 0.30

            SequentialAnimation on x {
                running: wallpaper.motionEnabled
                loops: 1
                NumberAnimation {
                    to: -emeraldGlow.width * 0.11
                    duration: 26000
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to: -emeraldGlow.width * 0.16
                    duration: 26000
                    easing.type: Easing.InOutSine
                }
            }
        }

        Rectangle {
            id: purpleGlow
            width: wallpaper.width * 0.62
            height: wallpaper.height * 0.52
            x: wallpaper.width * 0.51
            y: wallpaper.height * 0.30
            radius: height * 0.48
            color: "#38245D"
            opacity: 0.25

            SequentialAnimation on x {
                running: wallpaper.motionEnabled
                loops: 1
                NumberAnimation {
                    to: wallpaper.width * 0.46
                    duration: 32000
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to: wallpaper.width * 0.51
                    duration: 32000
                    easing.type: Easing.InOutSine
                }
            }
        }

        Rectangle {
            id: lowerEmeraldGlow
            width: wallpaper.width * 0.42
            height: wallpaper.height * 0.28
            x: wallpaper.width * 0.20
            y: wallpaper.height * 0.72
            radius: height * 0.48
            color: "#073B38"
            opacity: 0.22

            SequentialAnimation on opacity {
                running: wallpaper.motionEnabled
                loops: 1
                NumberAnimation {
                    to: 0.28
                    duration: 11000
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    to: 0.16
                    duration: 11000
                    easing.type: Easing.InOutSine
                }
            }
        }
    }

    // Sparse static stars: no repeater bindings to a high-frequency timer.
    Item {
        anchors.fill: parent
        Repeater {
            model: 26
            Rectangle {
                required property int index

                readonly property real sx: ((index * 193 + 71) % 997) / 997
                readonly property real sy: ((index * 317 + 29) % 991) / 991
                readonly property real starSize: index % 5 === 0 ? 2 : 1

                x: sx * wallpaper.width
                y: sy * wallpaper.height
                width: starSize
                height: starSize
                radius: starSize / 2
                color: index % 4 === 0 ? "#A78BFA" : "#D9E8FF"
                opacity: index % 3 === 0 ? 0.42 : 0.20
            }
        }
    }

    // Gentle vignette for legible desktop icons and taskbar.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#05070E33" }
            GradientStop { position: 0.55; color: "#05070E00" }
            GradientStop { position: 1.0; color: "#02040ACC" }
        }
    }
}
