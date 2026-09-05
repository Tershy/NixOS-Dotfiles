import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs.config

RowLayout {
    id: root
    spacing: 7

    property var sink: Pipewire.defaultAudioSink

    readonly property bool ready: sink && sink.ready
    readonly property bool muted: ready && sink.audio.muted
    readonly property int vol: ready ? Math.round(sink.audio.volume * 100) : 0

    readonly property string icon: {
        if (!ready)
            return String.fromCodePoint(0xF0581);
        if (muted)
            return "󰸈";

        if (vol === 0)
            return String.fromCodePoint(0xF0581);
        if (vol < 34)
            return String.fromCodePoint(0xF057F);
        if (vol < 67)
            return String.fromCodePoint(0xF0580);

        return String.fromCodePoint(0xF057E);
    }

    Text {
        text: root.icon
        color: Colors.yellow

        font {
            family: "Maple Mono NF"
            pixelSize: 14
            weight: 650
        }
    }

    Text {
        text: {
            if (!root.ready)
                return "-";
            if (root.muted)
                return "Muted";

            return root.vol + "%";
        }

        color: root.muted ? Colors.red : Colors.text

        font {
            family: "Maple Mono NF"
            weight: 650
        }
    }

    PwObjectTracker {
        objects: [root.sink]
    }

    MouseArea {
        anchors.fill: parent

        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                Quickshell.execDetached(["pavucontrol"]);
            } else if (mouse.button === Qt.RightButton) {
                Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
            }
        }
        cursorShape: Qt.PointingHandCursor
    }
}
