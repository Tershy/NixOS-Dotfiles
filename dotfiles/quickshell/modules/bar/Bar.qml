// modules/bar/Bar.qml

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.modules.bar

PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 32
    color: Colors.base
    exclusionMode: ExclusionMode.Auto

    Item {
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5

        //LEFT SIDE
        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            Pill {
                Workspaces {}
            }
        }
        //CENTER
        Pill {
            id: clockPill
            anchors.centerIn: parent
            Clock {}
        }

        //RIGHT SIDE
        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Pill {
                Network {}
            }
            Pill {
                Volume {}
            }
            Pill {
                Battery {}
            }

            Pill {
                SystemTray {}
            }

            Pill {
                id: powerPill

                PowerMenuButton {
                    id: powerButton
                    onClicked: {
                        const pos = powerPill.mapToItem(bar.contentItem, 0, 0);
                        powerMenu.anchor.window = bar;
                        powerMenu.anchor.rect.x = pos.x;
                        powerMenu.anchor.rect.y = bar.implicitHeight;
                        powerMenu.visible = !powerMenu.visible;
                    }
                }
            }

            PowerMenu {
                id: powerMenu
            }
        }
    }
}
