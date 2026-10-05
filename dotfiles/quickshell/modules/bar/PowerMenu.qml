// modules/bar/PowerMenu.qml

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config

PanelWindow {
    id: root

    // Toggle THIS from outside, not `visible`
    property bool shown: false

    // Stay mapped until the fade-out has finished
    visible: shown || backdrop.opacity > 0

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusionMode: ExclusionMode.Ignore
    focusable: true
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay

    onShownChanged: if (shown) keyCatcher.forceActiveFocus()

    // Runs whichever command was clicked
    Process {
        id: runner
    }

    function run(cmd) {
        root.shown = false;
        runner.command = cmd;
        runner.running = true;
    }

    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.alpha(Colors.barBg, 0.88)
        opacity: root.shown ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        // Click on empty space closes the menu
        MouseArea {
            anchors.fill: parent
            onClicked: root.shown = false
        }

        // Escape closes the menu
        Item {
            id: keyCatcher
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: root.shown = false
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 32

            Repeater {
                model: [
                    { icon: "󰌾", label: "Lock",     cmd: ["hyprlock"],                                              danger: false },
                    { icon: "󰍃", label: "Logout",   cmd: ["/home/tershy/.local/share/quickshell-lockscreen/lock.sh"], danger: false },
                    { icon: "󰜉", label: "Reboot",   cmd: ["systemctl", "reboot"],                                   danger: false },
                    { icon: "󰐥", label: "Shutdown", cmd: ["systemctl", "poweroff"],                                 danger: true  }
                ]

                delegate: Rectangle {
                    id: btn
                    required property var modelData

                    implicitWidth: 120
                    implicitHeight: 120
                    radius: 28
                    color: hover.containsMouse
                        ? Qt.alpha(modelData.danger ? Colors.red : Colors.text, 0.18)
                        : Qt.alpha(Colors.text, 0.08)

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: btn.modelData.icon
                            font.family: "Maple Mono NF"
                            font.pixelSize: 40
                            color: btn.modelData.danger ? Colors.red : Colors.text
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: btn.modelData.label
                            font.pixelSize: 14
                            color: Colors.text
                        }
                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.run(btn.modelData.cmd)
                    }
                }
            }
        }
    }
}
