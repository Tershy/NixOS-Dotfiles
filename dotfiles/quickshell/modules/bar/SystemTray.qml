// modules/bar/SystemTray.qml

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.config

RowLayout {
    id: root
    spacing: Math.round(4 * Colors.scale)

    // Placeholder to maintain minimum size when no system tray items are present
    Item {
        visible: SystemTray.items.values.length === 0
        Layout.preferredWidth: Math.round(24 * Colors.scale)
        Layout.preferredHeight: Math.round(20 * Colors.scale)
    }

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: slot
            required property var modelData

            Layout.preferredWidth: Math.round(24 * Colors.scale)
            Layout.preferredHeight: Math.round(18 * Colors.scale)

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
                radius: Math.max(1, Math.round(2 * Colors.scale))
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
                    width: Math.round(16 * Colors.scale)
                    height: Math.round(16 * Colors.scale)
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }
        }
    }
}
