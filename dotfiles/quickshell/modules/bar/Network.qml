import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import qs.config

Item {
    id: root

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    readonly property bool wifiLinked: Networking.wifiEnabled && !!wifiDevice && wifiDevice.connected

    // Set by the device-status poll below. Wired wins over wifi when both are up,
    // matching NetworkManager's default routing preference.
    property bool wired: false

    property string ssid: ""
    property real strength: 0

    readonly property string icon: {
        if (wired)
            return String.fromCodePoint(0xF0200);
        if (!Networking.wifiEnabled)
            return String.fromCodePoint(0xF05AA);
        if (!wifiLinked)
            return String.fromCodePoint(0xF092D);

        let tier = strength >= 0.75 ? 4 : strength >= 0.50 ? 3 : strength >= 0.25 ? 2 : 1;

        return String.fromCodePoint(0xF091F + (tier - 1) * 3);
    }

    readonly property string label: {
        if (wired)
            return "Ethernet";
        if (!Networking.wifiEnabled)
            return "off";
        if (!wifiLinked)
            return "Disconnected";

        return ssid !== "" ? ssid : "Connected";
    }

    // Terse output looks like "ethernet:connected" or "wifi:disconnected".
    // A cable managed outside NM reports "connected (externally)", hence startsWith.
    Process {
        id: deviceScan
        command: ["nmcli", "-t", "-f", "TYPE,STATE", "dev", "status"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.wired = text.split("\n").some(l => l.startsWith("ethernet:connected"));
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (!deviceScan.running)
                deviceScan.running = true;
        }
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

    // No point reading wifi details while a cable is the active connection.
    Timer {
        interval: 5000
        running: root.wifiLinked && !root.wired
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
            color: (root.wired || Networking.wifiEnabled) ? Colors.mauve : Colors.surface1

            font {
                family: "Maple Mono NF"
                pixelSize: 14
            }
        }

        Text {
            text: root.label
            color: Colors.text

            font {
                family: "Maple Mono NF"
                weight: 650
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: Quickshell.execDetached(["kitty", "-e", "wlctl"])
    }
}
