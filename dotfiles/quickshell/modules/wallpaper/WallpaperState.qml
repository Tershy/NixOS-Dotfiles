// modules/wallpaper/WallpaperState.qml
//
// Singleton trzymający stan "która tapeta jest aktywna" oraz proces,
// który odpala matugena. To jest analogiczny wzorzec do Twojego
// AppLauncherState.qml - stan i logika żyją w singletonie, komponenty
// wizualne (WallpaperPicker.qml) są "głupie" i tylko wołają metody stąd.

pragma Singleton
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string currentWallpaper: ""

    // Lista tapet - w realnej wersji chcesz to wypełnić dynamicznie
    // (np. Process odpalający `find ~/Pictures/Wallpapers -type f`),
    // ale na start prostszy jest hardcoded model do testów.
    property var wallpapers: []

    function scanWallpapers() {
        scanProcess.running = true;
    }

    Process {
        id: scanProcess
        command: ["find", Quickshell.env("HOME") + "/Pictures/Wallpapers",
                  "-maxdepth", "1", "-type", "f"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.wallpapers = this.text.trim().split("\n").filter(p => p.length > 0);
            }
        }
    }

    // Główna akcja: ustaw tapetę i wygeneruj z niej paletę.
    // Dwa oddzielne Process, bo to dwie oddzielne odpowiedzialności -
    // nie chcemy, żeby matugen sam zarządzał ustawianiem tapety
    // (config.wallpaper.set = false, jak w Kroku 4), bo wtedy
    // ta logika żyje w jednym miejscu (tutaj), a nie rozjeżdża się
    // między config.toml matugena i QML.
    function setWallpaper(path) {
        root.currentWallpaper = path;

        setWallpaperProcess.command = ["swww", "img", path,
                                        "--transition-type", "wipe",
                                        "--transition-duration", "1"];
        setWallpaperProcess.running = true;

        matugenProcess.command = ["matugen", "image", path];
        matugenProcess.running = true;
    }

    Process {
        id: setWallpaperProcess
    }

    Process {
        id: matugenProcess

        // onExited zamiast zakładania że proces zawsze się uda -
        // warto zalogować błąd, bo brak wygenerowanego colors.json
        // to cichy failure (Colors.qml po prostu zostanie na
        // starych/domyślnych wartościach, bez żadnego wyjątku).
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.warn("matugen failed with exit code", exitCode);
            }
        }
    }

    Component.onCompleted: scanWallpapers()
}
