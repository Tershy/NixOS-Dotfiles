// modules/bar/ScaleButton.qml

import QtQuick
import qs.config

Item {
    id: root

    signal clicked

    implicitWidth: Math.round(28 * Colors.scale)
    implicitHeight: Math.round(28 * Colors.scale)

    Text {
        anchors.centerIn: parent
        text: "󰍉"
        font.family: "Maple Mono NF"
        font.pixelSize: Math.round(14 * Colors.scale)
        color: Colors.text
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
