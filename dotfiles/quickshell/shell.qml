import Quickshell
import Quickshell.Io
import qs.modules.bar
import qs.modules.app_launcher
import qs.modules.wallpaper

ShellRoot {
    
    Bar {}
    AppLauncher {}
    WallpaperPicker {}

    // Existing launcher IPC
    IpcHandler {
        target: "launcher"

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

    // NEW: Wallpaper Picker IPC
    IpcHandler {
        target: "WallpaperState"

        function togglePicker(): void {
            WallpaperState.togglePicker();
        }

        function showPicker(): void {
            WallpaperState.showPicker();
        }

        function hidePicker(): void {
            WallpaperState.hidePicker();
        }
    }
}
