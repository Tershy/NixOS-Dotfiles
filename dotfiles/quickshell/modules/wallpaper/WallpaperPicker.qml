import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.config

PanelWindow {
    id: pickerWindow

    visible: WallpaperState.pickerVisible
    
    // Wayland automatically centers surfaces without explicit layout anchors when width/height are provided
    width: 640
    height: 420
    color: "transparent"

    // Dismiss when clicking outside the window content
    HyprlandFocusGrab {
        active: WallpaperState.pickerVisible
        onCleared: WallpaperState.hidePicker()
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.surface0
        radius: 12
        border.color: Colors.overlay
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: "Select Wallpaper"
                color: Colors.text
                font.pixelSize: 16
                font.bold: true
            }

            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                cellWidth: 140
                cellHeight: 100

                model: WallpaperState.wallpapers

                delegate: Item {
                    width: grid.cellWidth
                    height: grid.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 6
                        radius: 8
                        color: Colors.surface1
                        border.color: WallpaperState.currentWallpaper === modelData ? Colors.sky : "transparent"
                        border.width: 2

                        Image {
                            anchors.fill: parent
                            anchors.margins: 2
                            source: "file://" + modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 200
                            sourceSize.height: 120
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
