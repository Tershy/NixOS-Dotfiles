import QtQuick
import qs.config
import qs.modules.wallpaper

Pill {
    id: root

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
