// modules/bar/Pill.qml

import QtQuick
import QtQuick.Layouts
import qs.config

Rectangle {
    id: root

    default property alias content: contentRow.children

    property int horizontalPadding: 10
    property int verticalPadding: 4

    implicitWidth: contentRow.implicitWidth + horizontalPadding * 2
    implicitHeight: contentRow.implicitHeight + verticalPadding * 2

    radius: implicitHeight / 2
    color: Colors.surface0

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6
    }
}
