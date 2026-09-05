// modules/bar/PowerMenuButton.qml

import QtQuick
import qs.config

Item {
    id: root

    signal clicked

    implicitWidth: powerText.implicitWidth
    implicitHeight: powerText.implicitHeight

    Text {
        id: powerText
        text: "󰐥"
        font.family: "Maple Mono NF"
        color: Colors.red
        font.pixelSize: 14
        font.weight: 600
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
