// modules/bar/SystemTray.qml

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.config

RowLayout {
    id: root
    spacing: 4

    // Placeholder to maintain minimum size when no system tray items are present
    Item {
        visible: SystemTray.items.values.length === 0
        Layout.preferredWidth: 24
        Layout.preferredHeight: 20
    }

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: slot
            required property var modelData

            Layout.preferredWidth: 24
            Layout.preferredHeight: 18

            // Opens the item's native menu just below the icon.
            // display() needs the window (not an Item) and window-relative coords.
            function openMenu() {
                if (!modelData.hasMenu)
                    return;
                const p = slot.mapToItem(null, 0, slot.height);
                modelData.display(QsWindow.window, p.x, p.y);
            }

            Rectangle {
                id: bg
                anchors.fill: parent
                radius: 2
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                    onEntered: bg.color = Colors.overlay
                    onExited: bg.color = "transparent"

                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) {
                            // menu-only items (activate() does nothing) open their menu instead
                            if (slot.modelData.onlyMenu)
                                slot.openMenu();
                            else
                                slot.modelData.activate();
                        } else if (mouse.button === Qt.RightButton) {
                            slot.openMenu();
                        } else if (mouse.button === Qt.MiddleButton) {
                            slot.modelData.secondaryActivate();
                        }
                    }
                }

                Image {
                    source: slot.modelData.icon
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
