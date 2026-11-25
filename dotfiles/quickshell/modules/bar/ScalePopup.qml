// modules/bar/ScalePopup.qml

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config

PanelWindow {
    id: root

    property bool shown: false

    visible: shown

    anchors {
        top: true
        right: true
    }
    margins {
        top: Math.round(40 * Colors.scale)
        right: Math.round(60 * Colors.scale)
    }

    implicitWidth: Math.round(220 * Colors.scale)
    implicitHeight: Math.round(130 * Colors.scale)

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-scale"

    HyprlandFocusGrab {
        active: root.shown
        onCleared: root.shown = false
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.surface0
        radius: Math.round(12 * Colors.scale)
        border.color: Colors.overlay
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Math.round(12 * Colors.scale)
            spacing: Math.round(10 * Colors.scale)

            // ── Title ──────────────────────────────────────────────
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Scale"
                color: Colors.text
                font.pixelSize: Math.round(13 * Colors.scale)
                font.weight: Font.DemiBold
                font.family: "Maple Mono NF"
            }

            // ── Increment / Decrement ──────────────────────────────
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Math.round(12 * Colors.scale)

                // Minus
                Rectangle {
                    implicitWidth: Math.round(28 * Colors.scale)
                    implicitHeight: Math.round(24 * Colors.scale)
                    radius: Math.round(6 * Colors.scale)
                    color: minusArea.containsMouse ? Colors.overlay : Colors.surface1
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: "−"
                        color: Colors.text
                        font.pixelSize: Math.round(14 * Colors.scale)
                        font.family: "Maple Mono NF"
                    }
                    MouseArea {
                        id: minusArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Colors.setScale(Colors.scale - 0.05)
                    }
                }

                // Current percentage
                Text {
                    text: Math.round(Colors.scale * 100) + "%"
                    color: Colors.text
                    font.pixelSize: Math.round(14 * Colors.scale)
                    font.weight: Font.DemiBold
                    font.family: "Maple Mono NF"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.minimumWidth: Math.round(48 * Colors.scale)
                }

                // Plus
                Rectangle {
                    implicitWidth: Math.round(28 * Colors.scale)
                    implicitHeight: Math.round(24 * Colors.scale)
                    radius: Math.round(6 * Colors.scale)
                    color: plusArea.containsMouse ? Colors.overlay : Colors.surface1
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        color: Colors.text
                        font.pixelSize: Math.round(14 * Colors.scale)
                        font.family: "Maple Mono NF"
                    }
                    MouseArea {
                        id: plusArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Colors.setScale(Colors.scale + 0.05)
                    }
                }
            }

            // ── Quick presets ──────────────────────────────────────
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Math.round(6 * Colors.scale)

                Repeater {
                    model: [0.8, 1.0, 1.2, 1.5]

                    Rectangle {
                        required property real modelData
                        property bool active: Math.abs(Colors.scale - modelData) < 0.01

                        implicitWidth: Math.round(40 * Colors.scale)
                        implicitHeight: Math.round(22 * Colors.scale)
                        radius: Math.round(6 * Colors.scale)
                        color: active
                            ? Colors.sky
                            : (presetArea.containsMouse ? Colors.overlay : Colors.surface1)
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: Math.round(parent.modelData * 100) + "%"
                            color: parent.active ? Colors.base : Colors.text
                            font.pixelSize: Math.round(10 * Colors.scale)
                            font.family: "Maple Mono NF"
                            font.weight: 500
                        }
                        MouseArea {
                            id: presetArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Colors.setScale(parent.modelData)
                        }
                    }
                }
            }
        }
    }
}
