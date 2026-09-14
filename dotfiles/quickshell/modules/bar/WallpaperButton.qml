import QtQuick
import qs.config
import qs.modules.wallpaper

Rectangle {
    id: root
    implicitWidth: 28
    implicitHeight: 28
    radius: 6
    color: "transparent"

    Text {
        anchors.centerIn: parent
        text: "󰸉"
        font.pixelSize: 14
        color: Colors.text
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: WallpaperState.togglePicker()
    }
}
