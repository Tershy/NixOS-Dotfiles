// config/Colors.qml

pragma Singleton
import QtQuick

QtObject {
    // --- Backgrounds (od najciemniejszego do najjaśniejszego) ---------
    readonly property color crust: "#06101A"  // najgłębszy cień, np. pod popupami
    readonly property color base: "#0B1D2F"  // główne tło — pasek, terminal
    readonly property color surface0: "#0C304C"  // wyniesiona powierzchnia — popupy
    readonly property color surface1: "#55324C"  // druga powierzchnia, cieplejsza
    readonly property color overlay: "#345779"  // obramowania / linie podziału

    // --- Text (od najmniej do najbardziej widocznego) ------------------
    readonly property color subtext0: "#738CA5"  // wyłączony / bardzo przygaszony tekst
    readonly property color subtext1: "#9A79A3"  // tekst drugorzędny, etykiety
    readonly property color text: "#D0D9E1"  // główny tekst

    // --- Akcenty ---------------------------------------------------------
    readonly property color red: "#A43347"  // błędy, akcje niszczące (np. shutdown)
    readonly property color orange: "#CF9059"  // ostrzeżenia (drugorzędne)
    readonly property color yellow: "#CBA54D"  // ostrzeżenia (główne)
    readonly property color green: "#3FA662"  // sukces, stan aktywny
    readonly property color teal: "#46918A"  // info, linki
    readonly property color sky: "#39A2CA"  // główny akcent — aktywny workspace
    readonly property color blue: "#5198C2"  // drugorzędny akcent
    readonly property color pink: "#C092AB"  // podświetlony tekst
    readonly property color mauve: "#9A79A3"  // akcent trzeciorzędny (= subtext1)

    // --- Jasne warianty (do terminala, slot 8–15) -----------------------
    readonly property color brightRed: "#C0546A"
    readonly property color brightGreen: "#67C185"
    readonly property color brightYellow: "#D5C090"
    readonly property color brightBlue: "#5198C2"
    readonly property color brightPink: "#B79BBF"
    readonly property color brightCyan: "#6FB8DE"
    readonly property color brightWhite: "#F0EDEF"
    readonly property color brightBlack: "#55324C"
}
