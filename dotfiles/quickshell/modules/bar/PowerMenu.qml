// modules/bar/PowerMenu.qml

// 󰌾 = lock
// 󰍃 = logout
// 󰜉 = restart
// 󰐥 = poweroff

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.config
import Quickshell.Wayland

PopupWindow {
    id: root

    implicitWidth: row.implicitWidth + 24
    implicitHeight: row.implicitHeight + 16

    color: Colors.base

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 18

        //LOCK
        Item {
            implicitWidth: lockText.implicitWidth
            implicitHeight: lockText.implicitHeight

            Text {
                id: lockText
                text: "󰌾"
                color: Colors.text
                font.pixelSize: 20
            }
            Process {
                id: lockProcess
                command: ["hyprlock"]
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    console.log("LOCK CLICKED");
                    lockProcess.running = true;
                    root.visible = false;
                }
            }
        }

        //LOGOUT
        Item {
            implicitWidth: logoutText.implicitWidth
            implicitHeight: logoutText.implicitHeight

            Text {
                id: logoutText
                text: "󰍃"
                color: Colors.text
                font.pixelSize: 20
            }
            Process {
                id: logoutProcess
                //command: ["hyprshutdown", "--vt", "2"]
                command: ["/home/tershy/.local/share/quickshell-lockscreen/lock.sh"]
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    console.log("LOGOUT CLICKED");
                    logoutProcess.running = true;
                    root.visible = false;
                }
            }
        }

        // REBOOT

        Item {
            implicitWidth: rebootText.implicitWidth
            implicitHeight: rebootText.implicitHeight

            Text {
                id: rebootText
                text: "󰜉"
                color: Colors.text
                font.pixelSize: 20
            }
            Process {
                id: rebootProcess
                command: ["systemctl", "reboot"]
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    console.log("REBOOT CLICKED");
                    rebootProcess.running = true;
                    root.visible = false;
                }
            }
        }

        //POWEROFF

        Item {
            implicitWidth: poweroffText.implicitWidth
            implicitHeight: poweroffText.implicitHeight

            Text {
                id: poweroffText
                text: "󰐥"
                color: Colors.red
                font.pixelSize: 20
            }
            Process {
                id: poweroffProcess
                command: ["systemctl", "poweroff"]
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    console.log("SHUTDOWN CLICKED");
                    poweroffProcess.running = true;
                    root.visible = false;
                }
            }
        }
    }
}
