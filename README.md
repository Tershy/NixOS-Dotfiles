# NixOS-Dotfiles

Tershy's NixOS desktop environment, built from scratch with Hyprland + Quickshell.

This is a **learning project**, run in parallel to an existing Arch Linux setup ([`Quickshell-rice-learn`](https://github.com/Tershy/Quickshell-rice-learn)). The two are intentionally independent — no dotfiles are copied between them. Reference repos below are studied as patterns, not copied as sources.

## Stack

| Component     | Details |
|---------------|---------|
| OS            | NixOS 26.05, x86_64-linux, flake-based |
| Compositor    | Hyprland 0.56.0, config in native Lua (`hyprland.lua`) |
| Shell (bar/widgets) | Quickshell v0.3.0 (QML) |
| Terminal      | kitty |
| Shell (CLI)   | fish |
| File manager  | yazi |
| Fonts         | Rubik (UI), Maple Mono NF (terminal / glyphs) |
| Hardware      | Dell Vostro 3580 — Intel UHD 620 (iGPU, active renderer) + AMD Radeon 520 (discrete, muxless PRIME) |

## Repository layout

```
.
├── configuration.nix        # System-level config (NixOS)
├── hardware-configuration.nix
├── flake.nix / flake.lock   # Flake inputs, nixosConfigurations + homeConfigurations
├── home.nix                 # Home Manager config (standalone, not NixOS-module-imported)
├── modules/
│   └── sddm.nix
└── dotfiles/                 # Source files for HM-managed configs (edit these, not ~/.config/*)
    ├── hypr/
    │   ├── hyprland.lua
    │   └── modules/           # decorations, monitors, env, windowrules, input, autostart, misc, binds, layouts
    ├── quickshell/            # Full Quickshell config tree (bar, app launcher, wallpaper state, colors)
    ├── yazi/
    │   └── yazi.toml
    └── themes/                 # Static theme references (not currently live-applied)
        ├── japanese-navy.theme # fish
        └── japanese-navy.conf  # kitty
```

## How this is applied

There are **two independent rebuild pipelines** — NixOS system config and Home Manager are *not* merged (standalone HM setup, deliberately kept separate for now):

| Command       | Alias         | Applies |
|---------------|---------------|---------|
| `sudo nixos-rebuild switch --flake /etc/nixos#nixos` | `nixrebuild` | `configuration.nix` — system packages, drivers, services, hardware |
| `home-manager switch -b backup --flake /etc/nixos#tershy` | `homerebuild` | `home.nix` — fish, kitty, hypr, yazi, quickshell |

The `-b backup` flag renames any pre-existing conflicting file to `.backup` instead of erroring — important since this repo grew out of an already-configured system, not a fresh install.

### Editing configs

Files under `dotfiles/` are symlinked into `~/.config/*` by Home Manager (read-only at the destination). **Edit the source under `/etc/nixos/dotfiles/`, never the symlinked copy in `~/.config`** — changes to the symlink target are overwritten on the next `homerebuild`.

Handy aliases (defined in `home.nix`):
```
nixconf    → nvim /etc/nixos/configuration.nix
homeconf   → nvim /etc/nixos/home.nix
flakeconf  → nvim /etc/nixos/flake.nix
hypconf    → nvim /etc/nixos/dotfiles/hypr/hyprland.lua
dotconf    → nvim /etc/nixos/dotfiles/
```

### Flake gotcha

Nix flakes only see **git-tracked** files. Any new file added under this repo must be `git add`-ed (staging is enough — a commit isn't strictly required) before a rebuild will pick it up, or you'll hit "path is not tracked by Git" errors.

## Neovim

Deliberately **not** Home Manager-managed. Plain LazyVim, self-bootstrapping via `lazy.nvim`. Left alone since replicating LazyVim's install flow through Nix isn't worth the complexity for a setup that already works.

## Quickshell + matugen (in progress)

The plan is a dynamic theme switcher: a wallpaper change triggers `matugen`, which regenerates `dotfiles/quickshell/config/generated/colors.json`, and `Colors.qml` reads it as a facade so downstream components never need direct changes.

**Current state:**
- `WallpaperState.qml` already invokes `matugen image <path>` as a Quickshell `Process` — untested end-to-end
- `matugen` itself is **not installed** on this machine yet
- `Colors.qml` is currently a **disconnected placeholder** — hardcoded Catppuccin-style values, not wired to `colors.json` at all
- `colors.json` present in the repo is real matugen output, but from an earlier/other run — nothing regenerates it here yet

This is being tracked as a follow-up, not yet functional.

## Architectural principle: HM vs. generated files

Home Manager manages **static, hand-written config**. Anything matugen (or another generator) writes at runtime stays a **plain, writable file** that HM-managed files `source`/`include`/read — never a path HM itself owns. This is why `colors.json` sits in the repo but isn't hardcoded into `home.nix` as an `xdg.configFile` target the same way `Colors.qml` is.

## Reference repos (patterns studied, not copied)

- [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)
- [caelestia-dots/shell](https://github.com/caelestia-dots/shell)
- [Darkkal44/qylock](https://github.com/Darkkal44/qylock)

## On the horizon

- [ ] Install `matugen`, verify the wallpaper → colors.json pipeline end-to-end
- [ ] Rewrite `Colors.qml` as a real facade over `colors.json` (Material You names → semantic names)
- [ ] Install `qmlls` LSP for QML editing in Neovim (nixpkgs attribute TBD)
- [ ] Declare `hardware.graphics` explicitly in `configuration.nix` (currently working but undeclared)
- [ ] Resolve Bluetooth (`hardware.bluetooth.enable` / `powerOnBoot`)
- [ ] Clean up unused flake inputs (`nixpkgs-unstable`, `nixpkgs-wayland` — declared but not wired through `outputs`)
- [ ] Consider merging `nixrebuild` + `homerebuild` into one command once the setup stabilizes
