// modules/bar/Workspaces.qml

import QtQuick
import Quickshell.Hyprland
import qs.config

Row {
    id: wsRow
    spacing: 7 // The Row natively manages the spacing between visible items

    Repeater {
        model: 10 // Pre-allocate up to 10 workspaces. Adjust if you use more.

        Item {
            id: wsWrapper
            required property int index
            property int wsId: index + 1

            // Constantly check if this specific workspace ID currently exists in Hyprland
            property var ws: Hyprland.workspaces.values.find(w => w.id === wsId)

            property bool isActive: Hyprland.focusedWorkspace?.id === wsId
            property bool exists: ws !== undefined

            // The Roll-out Magic:
            // If the workspace exists, target the full width. If it is closed, target 0.
            width: exists ? (label.implicitWidth + 14) : 0
            height: label.implicitHeight

            // Hide entirely once the width hits 0 so the Row collapses the 7px spacing seamlessly
            visible: width > 0
            opacity: exists ? 1 : 0

            // Crucial: Keeps the button visually contained while the wrapper width shrinks/grows
            clip: true

            Behavior on width {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutQuart
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            // The actual visual indicator
            Rectangle {
                id: wsButton
                anchors.centerIn: parent
                width: label.implicitWidth + 14
                height: label.implicitHeight
                radius: 6

                color: isActive ? Colors.overlay : Colors.surface0

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: wsWrapper.wsId
                    color: wsWrapper.isActive ? Colors.sky : Colors.text

                    font {
                        family: "Maple Mono NF"
                        pixelSize: 14
                        weight: 500
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    // Standard Hyprland command to jump to the workspace
                    onClicked: Hyprland.dispatch("workspace " + wsWrapper.wsId)
                }
            }
        }
    }
}
