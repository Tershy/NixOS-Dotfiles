import QtQuick
import qs.config
import qs.modules.wallpaper

Rectangle {
    id: root
    implicitWidth: Math.round(28 * Colors.scale)
    implicitHeight: Math.round(28 * Colors.scale)
    radius: Math.round(6 * Colors.scale)
    color: "transparent"

    Text {
        anchors.centerIn: parent
        text: "󰸉"
        font.pixelSize: Math.round(14 * Colors.scale)
        color: Colors.text
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: WallpaperState.togglePicker()
    }
}
