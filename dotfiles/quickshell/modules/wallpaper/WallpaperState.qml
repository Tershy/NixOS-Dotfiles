pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentWallpaper: ""
    property var wallpapers: []
    property bool pickerVisible: false

    function togglePicker() {
        if (pickerVisible) {
            hidePicker();
        } else {
            showPicker();
        }
    }

    function showPicker() {
        scanWallpapers();
        pickerVisible = true;
    }

    function hidePicker() {
        pickerVisible = false;
    }

    function setWallpaper(path) {
        root.currentWallpaper = path;

        setWallpaperProcess.command = [
            "awww", "img", path,
            "--transition-type", "wipe",
            "--transition-duration", "1"
        ];
        setWallpaperProcess.running = true;

        matugenProcess.command = [
            "matugen", "image", path,
            "--source-color-index", "0"
        ];
        matugenProcess.running = true;
    }

    function scanWallpapers() {
        scanProcess.running = true;
    }

    Process {
        id: setWallpaperProcess
        stdout: SplitParser {
            onRead: data => console.log("[awww stdout]", data)
        }
        stderr: SplitParser {
            onRead: data => console.log("[awww stderr]", data)
        }
        onExited: (exitCode, exitStatus) => {
            console.log("[awww] exited with code", exitCode)
        }
    }

    Process {
        id: matugenProcess
        stdout: SplitParser {
            onRead: data => console.log("[matugen stdout]", data)
        }
        stderr: SplitParser {
            onRead: data => console.log("[matugen stderr]", data)
        }
        onExited: (exitCode, exitStatus) => {
            console.log("[matugen] exited with code", exitCode)
        }
    }

    Process {
        id: scanProcess
        command: ["sh", "-c", "find ~/Pictures/Wallpapers -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \\)"]
        stdout: SplitParser {
            onRead: data => {
                let trimmed = data.trim();
                if (trimmed.length > 0 && !root.wallpapers.includes(trimmed)) {
                    root.wallpapers.push(trimmed);
                    root.wallpapersChanged();
                }
            }
        }
        onExited: {
            root.wallpapers.sort();
            root.wallpapersChanged();
        }
    }

    Component.onCompleted: {
        scanWallpapers();
    }
}
