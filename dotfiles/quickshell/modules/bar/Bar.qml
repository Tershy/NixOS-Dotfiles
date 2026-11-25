// modules/bar/Bar.qml

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.modules.bar
import qs.modules.wallpaper

PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Math.round(32 * Colors.scale)
    color: Colors.barBg
    exclusionMode: ExclusionMode.Auto

    Item {
        anchors.fill: parent
        anchors.leftMargin: Math.round(5 * Colors.scale)
        anchors.rightMargin: Math.round(5 * Colors.scale)

        //LEFT SIDE
        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            Workspaces {}
            WallpaperButton {}
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
            spacing: Math.round(10 * Colors.scale)

            Network {}
            Volume {}
            Battery {}
            ScaleButton {
                onClicked: scalePopup.shown = !scalePopup.shown
            }
            SystemTray {}

            Pill {
              id: powerPill

              PowerMenuButton {
                id: powerButton
                onClicked: powerMenu.shown = !powerMenu.shown
              }
            }


            PowerMenu {
                id: powerMenu
            }

            ScalePopup {
                id: scalePopup
            }
        }
    }
}

