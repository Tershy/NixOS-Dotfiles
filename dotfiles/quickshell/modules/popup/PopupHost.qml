// modules/popup/PopupHost.qml

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Services.UPower
import qs.config

PanelWindow {
    id: root

    // --- Tunables ----------------------------------------------------------
    property int maxVisible: 5
    property int warnLevel: 20
    property int criticalLevel: 10

    // --- Window --------------------------------------------------------------
    anchors {
        top: true
        right: true
    }
    margins {
        top: 40   // bar is 32px + 8px gap
    }
    // Fixed size so the Wayland surface isn't resized every animation frame;
    // the mask below makes everything outside the cards click-through.
    implicitWidth: 372
    implicitHeight: 640
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: cards.count > 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-popups"
    mask: Region {
        item: col
    }

    // --- State ---------------------------------------------------------------
    property int _nextUid: 1
    property var _notifs: ({})   // uid -> Notification object

    ListModel {
        id: cards
    }

    function indexOf(uid) {
        for (let i = 0; i < cards.count; i++) {
            if (cards.get(i).uid === uid)
                return i;
        }
        return -1;
    }

    function closeUid(uid) {
        const i = indexOf(uid);
        if (i >= 0)
            cards.setProperty(i, "closing", true);
    }

    function push(p) {
        const uid = _nextUid++;
        cards.insert(0, {
            uid: uid,
            title: p.title ?? "",
            body: p.body ?? "",
            glyph: p.glyph ?? "",
            imageSource: p.imageSource ?? "",
            accent: p.accent ?? Colors.blue.toString(),
            timeout: p.timeout ?? 5000,
            closing: false
        });

        // Over the limit -> push the oldest ones out
        let live = 0;
        for (let i = 0; i < cards.count; i++) {
            if (!cards.get(i).closing && ++live > maxVisible)
                cards.setProperty(i, "closing", true);
        }
        return uid;
    }

    // Called by a card once its exit animation is done
    function remove(uid, reason) {
        const i = indexOf(uid);
        if (i >= 0)
            cards.remove(i);

        const n = _notifs[uid];
        if (n) {
            delete _notifs[uid];
            if (reason === "user")
                n.dismiss();
            else
                n.expire();
        }
    }

    // --- Notifications -------------------------------------------------------
    NotificationServer {
        id: server
        bodySupported: true
        imageSupported: true

        onNotification: notif => {
            notif.tracked = true;

            const urgent = notif.urgency === NotificationUrgency.Critical;

            let img = notif.image;
            if (img === "" && notif.appIcon !== "")
                img = Quickshell.iconPath(notif.appIcon, true) ?? "";

            // expireTimeout is in seconds; <= 0 means "client has no opinion"
            const ms = notif.expireTimeout > 0 ? Math.round(notif.expireTimeout * 1000) : (urgent ? 0 : 5000);

            const uid = root.push({
                title: notif.summary !== "" ? notif.summary : notif.appName,
                body: notif.body,
                glyph: String.fromCodePoint(0xF009A),
                imageSource: img,
                accent: urgent ? Colors.red.toString() : Colors.blue.toString(),
                timeout: ms
            });

            root._notifs[uid] = notif;
            // The app can close its own notification (e.g. a finished download)
            notif.closed.connect(() => {
                delete root._notifs[uid];
                root.closeUid(uid);
            });
        }
    }

    // --- Low battery ---------------------------------------------------------
    readonly property var bat: UPower.displayDevice
    readonly property int level: Math.round(bat.percentage * 100)
    readonly property bool discharging: bat.state === UPowerDeviceState.Discharging

    property int _stage: 0      // 0 = fine, 1 = warning shown, 2 = critical shown
    property int _batUid: -1

    function showBattery(stage, lvl) {
        closeUid(_batUid);
        // Same fixed warning colours as Battery.qml (deliberately not matugen)
        _batUid = push({
            title: stage === 2 ? "Battery critically low" : "Battery low",
            body: lvl + " % remaining" + (stage === 2 ? " - plug in the charger now" : ""),
            glyph: String.fromCodePoint(0xF0083),
            accent: stage === 2 ? "#A43347" : "#CF9059",
            timeout: stage === 2 ? 0 : 8000   // critical stays until you plug in or click it
        });
    }

    function checkBattery() {
        let stage = 0;
        if (discharging) {
            if (level <= criticalLevel)
                stage = 2;
            else if (level <= warnLevel)
                stage = 1;
        }

        if (stage === 0) {
            // Charger plugged in (or level recovered): clear any warning
            if (_stage !== 0) {
                closeUid(_batUid);
                _batUid = -1;
                _stage = 0;
            }
            return;
        }

        if (stage > _stage) {
            showBattery(stage, level);
            _stage = stage;
        }
    }

    onLevelChanged: checkBattery()
    onDischargingChanged: checkBattery()
    Component.onCompleted: checkBattery()

    // --- Test hook:  qs ipc call popups battery 1|2 ---------------------------
    IpcHandler {
        target: "popups"

        function battery(stage: int): void {
            root.showBattery(stage, stage === 2 ? 9 : 19);
        }
    }

    // --- Rendering -----------------------------------------------------------
    Column {
        id: col
        anchors {
            top: parent.top
            right: parent.right
            rightMargin: 12
        }
        width: 360
        spacing: 10

        move: Transition {
            NumberAnimation {
                properties: "y"
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Repeater {
            model: cards

            delegate: PopupCard {
                required property var model

                title: model.title
                body: model.body
                glyph: model.glyph
                imageSource: model.imageSource
                accent: model.accent
                timeout: model.timeout
                closing: model.closing

                onFinished: reason => root.remove(model.uid, reason)
            }
        }
    }
}
