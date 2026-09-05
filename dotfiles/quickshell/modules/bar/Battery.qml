// modules/bar/Battery.qml

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

RowLayout {
    id: root
    spacing: 6

    property var battery: UPower.displayDevice
    property bool charging: battery.state === UPowerDeviceState.Charging
    readonly property int level: Math.round(battery.percentage * 100)

    readonly property string icon: {
        if (charging)
            return String.fromCodePoint(0xF0084);
        if (level >= 100)
            return String.fromCodePoint(0xF0079);
        if (level < 20)
            return String.fromCodePoint(0xF0083);
        return String.fromCodePoint(0xF007A + (Math.floor(level / 10) - 1));
    }

    // Świadomy wyjątek od reguły "wszystko dynamiczne z matugena" - patrz
    // uzasadnienie w poprzedniej wersji tego pliku / w rozmowie o theme
    // switcherze. Skrót: poziom baterii to kod ostrzegawczy, nie branding,
    // więc musi być rozpoznawalny niezależnie od aktywnej tapety. Material
    // You nie gwarantuje że "tertiary"/"error" wypadną akurat zielono/
    // czerwono dla danej tapety.
    //
    // Zamiast importować qs.config i referencjonować Colors.red/orange/
    // green/sky (jak w wersji którą user wrzucił do repo), te wartości są
    // trzymane lokalnie jako stałe - ten komponent celowo NIE dziedziczy
    // motywu.
    readonly property color statusCharging: "#39A2CA"
    readonly property color statusOk: "#3FA662"
    readonly property color statusWarning: "#CF9059"
    readonly property color statusCritical: "#A43347"
    readonly property color statusNeutral: "#D0D9E1"
    

    readonly property color iconColor: {
        if (charging)
            return root.statusCharging;
        if (level <= 15)
            return root.statusCritical;
        if (level <= 30)
            return root.statusWarning;
        return root.statusOk;
    }

    Text {
        text: root.icon
        color: root.iconColor

        font {
            family: "Maple Mono NF"
            pixelSize: 14
        }
    }

    Text {
        text: root.level + " %"
        color: root.statusNeutral

        font {
            family: "Maple Mono NF"
            weight: 650
        }
    }
}
