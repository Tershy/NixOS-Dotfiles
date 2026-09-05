// modules/app_launcher/AppLauncher.qml

import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.config
import qs.modules.app_launcher

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "app-launcher" // przyda się później do hl.layer_rule (np. blur)
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"

    // Sterowane wyłącznie imperatywnie (patrz Timer + Connections niżej) —
    // bindowanie tego bezpośrednio do AppLauncherState.launcherVisible ucięłoby
    // animację zjazdu, bo okno zniknęłoby natychmiast.
    visible: false

    Timer {
        id: hideTimer
        interval: 500 // musi odpowiadać czasowi animacji transform.y niżej
        onTriggered: root.visible = false
    }

    // ── State ──────────────────────────────────────────────────────────────

    property string searchQuery: ""
    property int selectedIndex: 0
    readonly property bool isSearching: searchQuery.trim() !== ""

    property var filteredApps: {
        var q = searchQuery.trim().toLowerCase();
        var vals = DesktopEntries.applications.values;

        if (q !== "") {
            return vals.filter(function (e) {
                if (e.name.toLowerCase().indexOf(q) !== -1)
                    return true;
                if (e.genericName && e.genericName.toLowerCase().indexOf(q) !== -1)
                    return true;
                for (var i = 0; i < e.keywords.length; i++)
                    if (e.keywords[i].toLowerCase().indexOf(q) !== -1)
                        return true;
                return false;
            }).sort(function (a, b) {
                return a.name.localeCompare(b.name);
            });
        }
        var recent = AppLauncherState.recentIds;
        return vals.slice().sort(function (a, b) {
            var ai = recent.indexOf(a.id);
            var bi = recent.indexOf(b.id);
            if (ai !== -1 && bi !== -1)
                return ai - bi;
            if (ai !== -1)
                return -1;
            if (bi !== -1)
                return 1;
            return a.name.localeCompare(b.name);
        });
    }

    onFilteredAppsChanged: selectedIndex = 0

    // ── Launch ─────────────────────────────────────────────────────────────
    function launchEntry(entry) {
        AppLauncherState.recordLaunch(entry.id);
        entry.execute();
        AppLauncherState.hide();
    }

    // ── Navigation ─────────────────────────────────────────────────────────
    function navigate(delta) {
        if (filteredApps.length === 0)
            return;
        selectedIndex = (selectedIndex + delta + filteredApps.length) % filteredApps.length;
        listView.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    Connections {
        target: AppLauncherState
        function onLauncherVisibleChanged() {
            if (AppLauncherState.launcherVisible) {
                hideTimer.stop();
                root.visible = true;
                searchInput.text = "";
                root.searchQuery = "";
                root.selectedIndex = 0;
                Qt.callLater(function () {
                    searchInput.forceActiveFocus();
                });
            } else {
                hideTimer.restart();
            }
        }
    }

    // ── Accent colours ─────────────────────────────────────────────────────
    readonly property color accentFill: Colors.surface0
    readonly property color accentIcon: Colors.sky
    readonly property color fgDim: Colors.subtext1

    // ── Panel geometry ─────────────────────────────────────────────────────
    readonly property int maxVisible: 7
    readonly property int itemH: 42
    readonly property int panelW: 440
    readonly property int panelH: 88 + Math.min(filteredApps.length, maxVisible) * itemH

    // Klik poza panelem → zamknij
    MouseArea {
        anchors.fill: parent
        enabled: AppLauncherState.launcherVisible
        onClicked: AppLauncherState.hide()
    }

    // ── Panel ──────────────────────────────────────────────────────────────
    Rectangle {
        id: panel
        width: root.panelW
        height: root.panelH
        color: Colors.base
        radius: 16
        clip: true // trzyma listę wewnątrz podczas animacji wysokości

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        Behavior on height {
            NumberAnimation {
                duration: 500
                easing.type: Easing.OutCubic
            }
        }

        transform: Translate {
            y: AppLauncherState.launcherVisible ? 0 : root.panelH + 6
            Behavior on y {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Połyka kliknięcia w pustą przestrzeń panelu, żeby nie
        // przechodziły do MouseArea zamykającej launcher powyżej.
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        // ── Content ────────────────────────────────────────────────────
        Column {
            anchors {
                top: parent.top
                topMargin: 12
                left: parent.left
                leftMargin: 12
                right: parent.right
                rightMargin: 12
            }
            spacing: 0

            // Drag handle
            Rectangle {
                width: 36
                height: 4
                radius: 2
                anchors.horizontalCenter: parent.horizontalCenter
                color: Colors.overlay
            }

            Item {
                width: 1
                height: 8
            }

            // ── Search box ─────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 44
                radius: 10
                color: Colors.surface0

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "transparent"
                    border.color: Colors.sky
                    border.width: 1
                    opacity: searchInput.activeFocus ? 0.55 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                Row {
                    anchors {
                        fill: parent
                        leftMargin: 14
                        rightMargin: 14
                    }
                    spacing: 10

                    Item {
                        width: parent.width - 40
                        height: parent.height

                        Text {
                            anchors.fill: parent
                            text: root.isSearching ? "" : "Search apps…"
                            color: Colors.text
                            opacity: 0.28
                            font {
                                pixelSize: 13
                                family: "Maple Mono NF"
                            }
                            verticalAlignment: Text.AlignVCenter
                            visible: searchInput.text === ""
                        }

                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            color: Colors.text
                            selectionColor: root.accentFill
                            font {
                                pixelSize: 13
                                family: "Maple Mono NF"
                                weight: 500
                            }
                            verticalAlignment: TextInput.AlignVCenter
                            clip: true

                            onTextChanged: root.searchQuery = text

                            Keys.onPressed: function (event) {
                                if (event.key === Qt.Key_Up) {
                                    root.navigate(-1);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Down) {
                                    root.navigate(1);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    if (root.filteredApps.length > 0)
                                        root.launchEntry(root.filteredApps[root.selectedIndex]);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Escape) {
                                    AppLauncherState.hide();
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                }
            }

            Item {
                width: 1
                height: 8
            }

            // ── App list ───────────────────────────────────────────────
            ListView {
                id: listView
                width: parent.width
                height: Math.min(root.filteredApps.length, root.maxVisible) * root.itemH
                model: root.filteredApps
                clip: true
                interactive: false // scroll wyłącznie przez navigate()/wheel poniżej

                MouseArea {
                    anchors.fill: parent
                    onWheel: function (wheel) {
                        if (wheel.angleDelta.y < 0)
                            root.navigate(1);
                        else
                            root.navigate(-1);
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.filteredApps.length === 0
                    text: "No apps found"
                    color: Colors.text
                    opacity: 0.28
                    font {
                        pixelSize: 13
                        family: "Maple Mono NF"
                    }
                }

                delegate: Item {
                    id: appRow
                    width: listView.width
                    height: root.itemH

                    readonly property bool sel: root.selectedIndex === index
                    readonly property bool isRecent: !root.isSearching && AppLauncherState.recentIds.indexOf(modelData.id) !== -1 && AppLauncherState.recentIds.indexOf(modelData.id) < 5

                    Rectangle {
                        anchors {
                            fill: parent
                            topMargin: 2
                            bottomMargin: 2
                        }
                        radius: 10
                        color: appRow.sel ? root.accentFill : "transparent"
                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }

                        Row {
                            anchors {
                                fill: parent
                                leftMargin: 8
                                rightMargin: 8
                            }
                            spacing: 12

                            // Icon bubble
                            Rectangle {
                                width: 36
                                height: 36
                                radius: 9
                                anchors.verticalCenter: parent.verticalCenter
                                color: appRow.sel ? root.accentIcon : Colors.surface1
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 100
                                    }
                                }

                                Image {
                                    id: appIcon
                                    anchors.centerIn: parent
                                    width: 22
                                    height: 22
                                    source: modelData.icon !== "" ? Quickshell.iconPath(modelData.icon, true) : ""
                                    smooth: true
                                    mipmap: true
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: appIcon.status !== Image.Ready
                                    text: modelData.name.charAt(0).toUpperCase()
                                    font {
                                        pixelSize: 15
                                        family: "Maple Mono NF"
                                        weight: 700
                                    }
                                    color: appRow.sel ? Colors.base : Colors.text
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 100
                                        }
                                    }
                                }
                            }

                            // Name + subtitle
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2

                                Text {
                                    text: modelData.name
                                    font {
                                        pixelSize: 13
                                        family: "Maple Mono NF"
                                        weight: appRow.sel ? 600 : 500
                                    }
                                    color: appRow.sel ? Colors.text : root.fgDim
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 100
                                        }
                                    }
                                }

                                Row {
                                    spacing: 6
                                    visible: appRow.isRecent || modelData.genericName !== ""

                                    Rectangle {
                                        visible: appRow.isRecent
                                        width: recentLabel.width + 8
                                        height: 14
                                        radius: 4
                                        color: Qt.rgba(Colors.sky.r, Colors.sky.g, Colors.sky.b, 0.22)
                                        anchors.verticalCenter: parent.verticalCenter

                                        Text {
                                            id: recentLabel
                                            anchors.centerIn: parent
                                            text: "recent"
                                            font {
                                                pixelSize: 9
                                                family: "Maple Mono NF"
                                            }
                                            color: Colors.sky
                                        }
                                    }

                                    Text {
                                        visible: modelData.genericName !== ""
                                        text: modelData.genericName
                                        font {
                                            pixelSize: 11
                                            family: "Maple Mono NF"
                                        }
                                        color: Colors.text
                                        opacity: 0.35
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.selectedIndex = index
                            onClicked: root.launchEntry(modelData)
                            onWheel: function (wheel) {
                                if (wheel.angleDelta.y < 0)
                                    root.navigate(1);
                                else
                                    root.navigate(-1);
                            }
                        }
                    }
                }
            }

            Item {
                width: 1
                height: 4
            }
        }
    }
}
