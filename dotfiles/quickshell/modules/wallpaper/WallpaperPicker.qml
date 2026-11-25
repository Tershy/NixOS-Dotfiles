import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.config

PanelWindow {
    id: pickerWindow

    visible: WallpaperState.pickerVisible
    
    // Wayland automatically centers surfaces without explicit layout anchors when width/height are provided
    implicitWidth: Math.round(640 * Colors.scale)
    implicitHeight: Math.round(420 * Colors.scale)
    color: "transparent"

    // Dismiss when clicking outside the window content
    HyprlandFocusGrab {
        active: WallpaperState.pickerVisible
        onCleared: WallpaperState.hidePicker()
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.surface0
        radius: Math.round(12 * Colors.scale)
        border.color: Colors.overlay
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.round(16 * Colors.scale)
            spacing: Math.round(12 * Colors.scale)

            Text {
                text: "Select Wallpaper"
                color: Colors.text
                font.pixelSize: Math.round(16 * Colors.scale)
                font.bold: true
            }

            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                cellWidth: Math.round(140 * Colors.scale)
                cellHeight: Math.round(100 * Colors.scale)

                model: WallpaperState.wallpapers

                delegate: Item {
                    width: grid.cellWidth
                    height: grid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: Math.round(6 * Colors.scale)
                        radius: Math.round(8 * Colors.scale)
                        color: Colors.surface1
                        border.color: WallpaperState.currentWallpaper === modelData ? Colors.sky : "transparent"
                        border.width: 2

                        Image {
                            anchors.fill: parent
                            anchors.margins: Math.round(2 * Colors.scale)
                            source: "file://" + modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: Math.round(200 * Colors.scale)
                            sourceSize.height: Math.round(120 * Colors.scale)
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                WallpaperState.setWallpaper(modelData);
                                WallpaperState.hidePicker();
                            }
                        }
                    }
                }
            }
        }
    }
}
