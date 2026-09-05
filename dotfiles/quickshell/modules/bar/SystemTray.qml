// modules/bar/SystemTray.qml

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import qs.config

RowLayout {
    id: root
    spacing: 4

    // Placeholder to maintain minimum size when no system tray items are present
    Item {
        visible: SystemTray.items.count === 0
        Layout.preferredWidth: 24
        Layout.preferredHeight: 20
    }

    Repeater {
        model: SystemTray.items
        delegate: Item {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 18

            Rectangle {
                id: bg
                anchors.fill: parent
                radius: 2
                color: "transparent"

                // Hover effect
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: bg.color = Colors.overlay
                    onExited: bg.color = "transparent"
                    onClicked: {
                        // Left click activates the item
                        if (mouse.button === Qt.LeftButton) {
                            modelData.activate(parent);
                        } else
                        // Right click shows context menu if available
                        if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                            modelData.display(parent, 0, 0);
                        }
                    }
                }

                // Icon
                Image {
                    id: icon
                    source: modelData.icon
                    width: 16
                    height: 16
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }
        }
    }
}
