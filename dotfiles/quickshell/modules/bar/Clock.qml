// modules/bar/Clock.qml

import Quickshell
import QtQuick
import qs.config

Text {
    text: Qt.formatDateTime(clock.date, "hh:mm")
    color: Colors.text

    font {
        family: "Maple Mono NF"
        weight: 650
        letterSpacing: 0
        pixelSize: Math.round(13 * Colors.scale)
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
