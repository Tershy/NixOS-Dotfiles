// config/Colors.qml
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    FileView {
        id: colorsFile
        path: Qt.resolvedUrl("./generated/colors.json")
        // Forces the file to be loaded by the time we call JSON.parse()
        // — see FileView.blockLoading docs.
        blockLoading: true
        watchChanges: true
        onFileChanged: this.reload()
    }

    // Recomputes automatically whenever colorsFile.text() changes
    // (i.e. on every reload() triggered by watchChanges).
    readonly property var _data: JSON.parse(colorsFile.text())

    // --- Backgrounds ---------------------------------------------------
    readonly property color crust: _data.crust ?? "#06101A"
    readonly property color base: _data.base ?? "#0B1D2F"
    readonly property color surface0: _data.surface0 ?? "#0C304C"
    readonly property color surface1: _data.surface1 ?? "#55324C"
    readonly property color overlay: _data.overlay ?? "#345779"
    readonly property color barBg: _data.barBg ?? "#1F2937"

    // --- Text ------------------------------------------------------------
    readonly property color subtext0: _data.subtext0 ?? "#738CA5"
    readonly property color subtext1: _data.subtext1 ?? "#9A79A3"
    readonly property color text: _data.text ?? "#D0D9E1"

    // --- Accents -----------------------------------------------------
    readonly property color red: _data.red ?? "#A43347"
    readonly property color orange: _data.orange ?? "#CF9059"
    readonly property color yellow: _data.yellow ?? "#CBA54D"
    readonly property color green: _data.green ?? "#3FA662"
    readonly property color teal: _data.teal ?? "#46918A"
    readonly property color sky: _data.sky ?? "#39A2CA"
    readonly property color blue: _data.blue ?? "#5198C2"
    readonly property color pink: _data.pink ?? "#C092AB"
    readonly property color mauve: _data.mauve ?? "#9A79A3"

    // --- Bright variants (terminal slots 8-15) --------------------------
    readonly property color brightRed: _data.brightRed ?? "#C0546A"
    readonly property color brightGreen: _data.brightGreen ?? "#67C185"
    readonly property color brightYellow: _data.brightYellow ?? "#D5C090"
    readonly property color brightBlue: _data.brightBlue ?? "#5198C2"
    readonly property color brightPink: _data.brightPink ?? "#B79BBF"
    readonly property color brightCyan: _data.brightCyan ?? "#6FB8DE"
    readonly property color brightWhite: _data.brightWhite ?? "#F0EDEF"
    readonly property color brightBlack: _data.brightBlack ?? "#55324C"
}
