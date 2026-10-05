import Quickshell
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import qs.config

RowLayout {
    id: root
    spacing: 6

    property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
    property var active: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null

    readonly property real signal: active ? active.signalStrength : 0

    readonly property string icon: {
        if (!Networking.wifiEnabled)
            return String.fromCodePoint(0xF05AA);
        if (!active)
            return String.fromCodePoint(0xF092D);

        let tier = signal >= 0.75 ? 4 : signal >= 0.50 ? 3 : signal >= 0.25 ? 2 : 1;

        return String.fromCodePoint(0xF091F + (tier - 1) * 3);
    }


    Timer {
        id: debugTimer
        interval: 4000
        running: true
        repeat: true

        property int ticks: 0

        onTriggered: {
            ticks++;

            const dev = root.wifiDevice;
            if (!dev) {
                console.log("[net-debug] no wifi device");
                return;
            }

            if (ticks === 1) {
                dev.scannerEnabled = true;
                console.log("[net-debug] scanner enabled, waiting for results");
                return;
            }

            console.log("[net-debug] tick", ticks, "| device connected:", dev.connected, "state:", dev.state, "scanner:", dev.scannerEnabled, "| networks:", dev.networks.values.length);

            for (const n of dev.networks.values)
                console.log("[net-debug]  ", JSON.stringify(n.name), "connected:", n.connected, "state:", n.state, "signal:", n.signalStrength);

            if (ticks >= 4)
                running = false;
        }
    }


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
            if (!root.active)
                return "Disconnected";

            return root.active.name;
        }

        color: Colors.text

        font {
            family: "Maple Mono NF"
            weight: 650
        }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: Quickshell.execDetached(["kitty", "-e", "wlctl"])
        cursorShape: Qt.PointingHandCursor
    }
}
