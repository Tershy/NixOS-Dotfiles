import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import qs.config

Item {
    id: root

    // Size the wrapper to the row so the bar still lays this module out by its content.
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    readonly property bool linked: Networking.wifiEnabled && !!wifiDevice && wifiDevice.connected

    property string ssid: ""
    property real strength: 0

    readonly property string icon: {
        if (!Networking.wifiEnabled)
            return String.fromCodePoint(0xF05AA);
        if (!linked)
            return String.fromCodePoint(0xF092D);

        let tier = strength >= 0.75 ? 4 : strength >= 0.50 ? 3 : strength >= 0.25 ? 2 : 1;

        return String.fromCodePoint(0xF091F + (tier - 1) * 3);
    }

    // `--rescan no` reads NetworkManager's cached list instead of triggering a scan.
    // Terse output looks like "yes:ZTE_C7E9CE:67"; colons inside an SSID are escaped as "\:".
    Process {
        id: activeScan
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi", "list", "--rescan", "no"]

        stdout: StdioCollector {
            onStreamFinished: {
                const line = text.split("\n").find(l => l.startsWith("yes:"));

                if (!line) {
                    root.ssid = "";
                    root.strength = 0;
                    return;
                }

                const rest = line.slice(4);
                const cut = rest.lastIndexOf(":");

                root.ssid = rest.slice(0, cut).replace(/\\:/g, ":");
                root.strength = parseInt(rest.slice(cut + 1)) / 100;
            }
        }
    }

    Timer {
        interval: 5000
        running: root.linked
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (!activeScan.running)
                activeScan.running = true;
        }
    }

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 6

        Text {
            text: root.icon
            color: Networking.wifiEnabled ? Colors.mauve : Colors.surface1

            font {
                family: "Maple Mono NF"
                pixelSize: 14
            }
        }

        Text {
            text: {
                if (!Networking.wifiEnabled)
                    return "off";
                if (!root.linked)
                    return "Disconnected";

                return root.ssid !== "" ? root.ssid : "Connected";
            }

            color: Colors.text

            font {
                family: "Maple Mono NF"
                weight: 650
            }
        }
    }

    // Declared after the layout so it sits on top and receives the clicks.
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: Quickshell.execDetached(["kitty", "-e", "wlctl"])
    }
}
