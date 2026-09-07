// modules/wallpaper/WallpaperPicker.qml

import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.config
import qs.modules.wallpaper

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "wallpaper-picker"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    // Same reasoning as AppLauncher.qml: controlled imperatively via the
    // Timer + Connections below, not bound directly to
    // WallpaperState.pickerVisible, so the slide-down animation can
    // finish before the window actually disappears.
    visible: false

    Timer {
        id: hideTimer
        interval: 500 // must match the transform.y animation duration below
        onTriggered: root.visible = false
    }

    Connections {
        target: WallpaperState
        function onPickerVisibleChanged() {
            if (WallpaperState.pickerVisible) {
                hideTimer.stop();
                root.visible = true;
            } else {
                hideTimer.restart();
            }
        }
    }

    // Click outside the panel → close
    MouseArea {
        anchors.fill: parent
        enabled: WallpaperState.pickerVisible
        onClicked: WallpaperState.hide()
    }

    // ── Panel geometry ─────────────────────────────────────────────────
    readonly property int panelW: 720
    readonly property int panelH: 480
    readonly property int thumbSize: 160
    readonly property int thumbSpacing: 12

    Rectangle {
        id: panel
        width: root.panelW
        height: root.panelH
        color: Colors.base
        radius: 16
        clip: true

        anchors.centerIn: parent

        transform: Translate {
            y: WallpaperState.pickerVisible ? 0 : 24
            Behavior on y {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutCubic
                }
            }
        }

        opacity: WallpaperState.pickerVisible ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }

        // Swallow clicks inside the panel so they don't fall through
        // to the outside-dismiss MouseArea above.
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            anchors {
                top: parent.top
                topMargin: 16
                left: parent.left
                leftMargin: 16
                right: parent.right
                rightMargin: 16
                bottom: parent.bottom
                bottomMargin: 16
            }
            spacing: 12

            Text {
                text: "Wallpapers"
                color: Colors.text
                font {
                    pixelSize: 16
                    family: "Maple Mono NF"
                    weight: 600
                }
            }

            Text {
                visible: WallpaperState.wallpapers.length === 0
                text: "No wallpapers found in ~/Pictures/Wallpapers"
                color: Colors.text
                opacity: 0.35
                font {
                    pixelSize: 12
                    family: "Maple Mono NF"
                }
            }

            GridView {
                id: grid
                width: parent.width
                height: parent.height - 40 // leaves room for the header above
                clip: true

                cellWidth: root.thumbSize + root.thumbSpacing
                cellHeight: root.thumbSize + root.thumbSpacing

                model: WallpaperState.wallpapers

                delegate: Item {
                    width: grid.cellWidth
                    height: grid.cellHeight

                    readonly property bool isCurrent: modelData === WallpaperState.currentWallpaper

                    Rectangle {
                        id: thumbFrame
                        anchors.centerIn: parent
                        width: root.thumbSize
                        height: root.thumbSize
                        radius: 10
                        color: Colors.surface0
                        border.width: isCurrent ? 2 : 0
                        border.color: Colors.sky
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: "file://" + modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            smooth: true
                            mipmap: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                WallpaperState.setWallpaper(modelData);
                                WallpaperState.hide();
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 10
                                color: Colors.base
                                opacity: parent.containsMouse ? 0.15 : 0
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 100
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
