# NixOS-Dotfiles

Tershy's NixOS desktop environment, built from scratch with Hyprland + Quickshell.

This is a **learning project**, which used to be only based on the quickshell part ([`Quickshell-rice-learn`](https://github.com/Tershy/Quickshell-rice-learn)). Since i've moved to NixOS from Arch (btw) i've decided to throw my whole system here.

## Stack

| Component     | Details |
|---------------|---------|
| OS            | NixOS 26.05, x86_64-linux, flake-based |
| Compositor    | Hyprland 0.56.0, config in native Lua (`hyprland.lua`) |
| Shell (bar/widgets) | Quickshell v0.3.0 (QML) |
| Terminal      | kitty |
| Editor        | nvim (Lazyvim) |
| Shell (CLI)   | fish |
| File manager  | yazi |
| Theming       | matugen (dynamic, wallpaper-driven — see below) |
| Fonts         | Rubik (UI), Maple Mono NF (terminal / glyphs) |
| Hardware      | Dell Vostro 3580 — Intel UHD 620 (iGPU, active renderer) + AMD Radeon 520 (discrete, muxless PRIME) |

## Repository layout
```
.
├── configuration.nix # System-level config (NixOS)
├── hardware-configuration.nix
├── flake.nix / flake.lock # Flake inputs, nixosConfigurations + homeConfigurations
├── home.nix # Home Manager config (standalone, not NixOS-module-imported)
├── modules/
│ └── sddm.nix
└── dotfiles/ # Source files for HM-managed configs (edit these, not ~/.config/*)
├── hypr/
│ ├── hyprland.lua
│ └── modules/ # decorations, monitors, env, windowrules, input, autostart, misc, binds, layouts
├── quickshell/ # Full Quickshell config tree (bar, app launcher, wallpaper state/picker, colors)
├── matugen/
│ ├── config.toml # Template map + per-app post_hooks
│ └── templates/ # kitty.conf, quickshell-colors.json, hyprland-colors.lua, fish-colors.fish
├── yazi/
│ └── yazi.toml
└── themes/ # Static theme references (superseded by matugen; kept for reference)
├── japanese-navy.theme # fish
└── japanese-navy.conf # kitty
```

## How this is applied

There are **two independent rebuild pipelines** — NixOS system config and Home Manager are *not* merged (standalone HM setup, deliberately kept separate for now):

| Command       | Alias         | Applies |
|---------------|---------------|---------|
| `sudo nixos-rebuild switch --flake /etc/nixos#nixos` | `nixrebuild` | `configuration.nix` — system packages, drivers, services, hardware |
| `home-manager switch -b backup --flake /etc/nixos#tershy` | `homerebuild` | `home.nix` — fish, kitty, hypr, yazi, quickshell, matugen |

### Editing configs

Files under `dotfiles/` are symlinked into `~/.config/*` by Home Manager (read-only at the destination).

Handy aliases (defined in `home.nix`):

nixconf → nvim /etc/nixos/configuration.nix
homeconf → nvim /etc/nixos/home.nix
flakeconf → nvim /etc/nixos/flake.nix
hypconf → nvim /etc/nixos/dotfiles/hypr/hyprland.lua
dotconf → nvim /etc/nixos/dotfiles/


### Flakes

Nix flakes only see **git-tracked** files. Any new file added under this repo must be `git add`-ed.

## Neovim

Just using Lazyvim, no need to import it here, at least not yet

## Quickshell + matugen (dynamic theming)

Picking a wallpaper from the in-app picker triggers `matugen` in the same action, which regenerates a small set of per-app template outputs from the wallpaper's dominant colors. Each app has its own reload mechanism, since none of them share a live-reload story.

**Trigger:** `WallpaperState.qml`'s `setWallpaper()` runs two Quickshell `Process` calls back to back — `awww img <path>` to set the wallpaper, and `matugen image <path> -t scheme-vibrant --source-color-index 0` to regenerate colors. `--source-color-index 0` is required because matugen's interactive color-selection prompt has no TTY to talk to when run as a headless `Process`.

**Config:** `dotfiles/matugen/config.toml` maps four templates to four output paths, each with its own `post_hook` (or none):

| App | Output | Reload mechanism |
|---|---|---|
| kitty | `~/.config/kitty/current-theme.conf` | `post_hook` loops live `/tmp/kitty-*` sockets via `kitty @ set-colors` |
| Quickshell | `~/.config/quickshell/config/generated/colors.json` | None needed — `Colors.qml`'s `FileView` + `watchChanges` reloads live |
| Hyprland | `~/.config/matugen/generated/hyprland-colors.lua` | `post_hook` runs `hyprctl reload`; the Lua config loads this file with `loadfile()` + `pcall`, not `require()` (`require()` can't reach paths outside `~/.config/hypr/`) |
| fish | `~/.config/matugen/generated/fish-colors.fish` | No `post_hook` — sourced in `interactiveShellInit`, so only new shells pick it up |

**yazi is deliberately not templated** — it inherits its colors from kitty's ANSI palette instead. That palette (`color0`–`color15` in the kitty template) is intentionally hardcoded and never changes with the wallpaper; only the UI chrome (foreground/background/cursor/borders/tabs) is dynamic per-theme.

**Facade pattern:** `Colors.qml` and the fish/kitty/Hyprland templates all read from matugen's Material You token names (`primary`, `surface_container`, `on_background`, etc.) and re-expose them under each consumer's own naming scheme — e.g. Quickshell's `colors.json` maps `surface_container` → `barBg`/`surface0`, matching a Catppuccin-style naming convention so downstream QML components (like `WallpaperPicker.qml`) never reference Material You names directly.

**Home Manager wiring:** `config.toml` and all four templates are declared via `xdg.configFile` in `home.nix` — this part is fully HM-managed and read-only at the destination, same as everything else under `dotfiles/`. The *outputs* (`current-theme.conf`, `colors.json`, `hyprland-colors.lua`, `fish-colors.fish`) are deliberately **not** HM-managed — they're written at runtime by matugen and must stay writable, since HM's symlinks are read-only and would break regeneration.

**Wallpaper picker UI:** `WallpaperPicker.qml` is a working `PanelWindow` with a `GridView` of wallpaper thumbnails, dismissed via `HyprlandFocusGrab` on outside-click, and highlights the active wallpaper using `Colors.sky`. Backend (`WallpaperState.qml`) scans `~/Pictures/Wallpapers` on startup and on-demand via a `sh -c find` `Process`.

## Reference repos (patterns studied)

- [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)
- [caelestia-dots/shell](https://github.com/caelestia-dots/shell)
- [Darkkal44/qylock](https://github.com/Darkkal44/qylock)

## On the horizon

- [ ] Commit `~/Pictures/Wallpapers` into the repo as real image files, symlinked via `config.lib.file.mkOutOfStoreSymlink` so new wallpapers can be dropped in without a rebuild
- [ ] Migrate remaining `Pill`-based bar components to explicit `Rectangle` roots (same dead-hit-area bug fixed in `WallpaperButton.qml`)
- [ ] Add a scheme-type selector (e.g. `scheme-vibrant` vs `scheme-tonal-spot`) to the wallpaper picker UI, instead of it being hardcoded in `WallpaperState.qml`
- [ ] Install `qmlls` LSP for QML editing in Neovim (nixpkgs attribute TBD)
- [ ] Clean up unused flake inputs (`nixpkgs-unstable`, `nixpkgs-wayland` — declared but not wired through `outputs`)
- [ ] Consider merging `nixrebuild` + `homerebuild` into one command once the setup stabilizes
