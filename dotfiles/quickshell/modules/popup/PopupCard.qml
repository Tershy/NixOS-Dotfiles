// modules/popup/PopupCard.qml

import QtQuick
import QtQuick.Layouts
import qs.config

Item {
    id: root

    property string title: ""
    property string body: ""
    property string glyph: ""
    property string imageSource: ""
    property color accent: Colors.blue
    property int timeout: 5000      // ms, 0 = stays until clicked
    property bool closing: false    // set by the host to force the exit animation

    // reason: "user" | "timeout" | "closed"
    signal finished(string reason)

    // 1 = off-screen to the right, 0 = in place
    property real slide: 1
    // 0 = slot has no height, 1 = full height (lets neighbours glide up/down)
    property real collapse: 0
    // 1 -> 0 timeout bar
    property real progress: 1

    property bool _leaving: false
    property string _reason: "timeout"

    width: 360
    height: card.height * collapse
    opacity: 1 - slide

    function close(reason) {
        if (_leaving)
            return;
        _leaving = true;
        _reason = reason;
        enterAnim.stop();
        progressAnim.stop();
        exitAnim.start();
    }

    onClosingChanged: if (closing) close("closed")
    Component.onCompleted: enterAnim.start()

    // Slot opens first, then the card slides in from the screen edge
    SequentialAnimation {
        id: enterAnim
        NumberAnimation {
            target: root
            property: "collapse"
            to: 1
            duration: 140
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: root
            property: "slide"
            to: 0
            duration: 380
            easing.type: Easing.OutCubic
        }
        ScriptAction {
            script: if (root.timeout > 0) progressAnim.start()
        }
    }

    SequentialAnimation {
        id: exitAnim
        NumberAnimation {
            target: root
            property: "slide"
            to: 1
            duration: 260
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: root
            property: "collapse"
            to: 0
            duration: 160
            easing.type: Easing.OutCubic
        }
        ScriptAction {
            script: root.finished(root._reason)
        }
    }

    // Drives the timeout; pauses while the mouse is over the card
    NumberAnimation {
        id: progressAnim
        target: root
        property: "progress"
        from: 1
        to: 0
        duration: root.timeout
        paused: hover.hovered
        onFinished: if (!root._leaving) root.close("timeout")
    }

    Rectangle {
        id: card
        x: root.slide * (root.width + 24)
        width: root.width
        implicitHeight: row.implicitHeight + 28
        height: implicitHeight
        radius: 16
        color: Colors.barBg
        border.width: 1
        border.color: Qt.alpha(Colors.text, 0.10)

        HoverHandler {
            id: hover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: root.close("user")
        }

        RowLayout {
            id: row
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 14
            }
            spacing: 12

            Item {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignTop

                Image {
                    anchors.fill: parent
                    visible: root.imageSource !== ""
                    source: root.imageSource
                    sourceSize: Qt.size(80, 80)
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                }
                Text {
                    anchors.centerIn: parent
                    visible: root.imageSource === ""
                    text: root.glyph
                    color: root.accent
                    font.family: "Maple Mono NF"
                    font.pixelSize: 30
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: root.title
                    color: Colors.text
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
                Text {
                    Layout.fillWidth: true
                    visible: root.body !== ""
                    text: root.body
                    color: Colors.subtext0
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    textFormat: Text.StyledText
                }
            }
        }

        // Timeout bar
        Rectangle {
            visible: root.timeout > 0
            anchors {
                left: parent.left
                bottom: parent.bottom
                leftMargin: 14
                bottomMargin: 6
            }
            height: 3
            radius: 1.5
            width: (parent.width - 28) * root.progress
            color: Qt.alpha(root.accent, 0.8)
        }
    }
}
