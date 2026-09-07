import Quickshell
import Quickshell.Io
import qs.modules.bar
import qs.modules.app_launcher
import qs.modules.wallpaper

ShellRoot {
    Bar {}
    AppLauncher {}
    WallpaperPicker{}

    IpcHandler {
        target: "launcher" // musi być unikalne w całej konfiguracji

        // Typ zwracany jest wymagany — bez ": void" funkcja się nie zarejestruje.
        function toggle(): void {
            AppLauncherState.toggle();
        }

        function show(): void {
            AppLauncherState.show();
        }

        function hide(): void {
            AppLauncherState.hide();
        }
    }
}
