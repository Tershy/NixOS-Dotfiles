# Quickshell-rice-learn

Personal Project built on my spare laptop where i installed arch + hyprland. Nothing big, just a learning project.

> **This is not a dotfiles package meant to be cloned.** Paths are hardcoded for my hardware and this repo serves as a learning log, not a product.

## Stack

| Layer | Choice |
|---|---|
| Distro | Arch Linux (rolling) |
| Compositor | Hyprland 0.56.0  |
| Shell / bar | [Quickshell](https://quickshell.org) v0.3.0 (QML) |
| Terminal | kitty |
| Shell (login) | fish |
| Wallpaper daemon | `awww` |
| Palette generator | matugen  |
| Bootloader | Limine |


## Specs

| Dell Vostro 3580 | Hardware | 
|---|---|
| CPU | Intel i5-8265U |
| GPU | AMD Radeon R5 M435 (discrete) + Intel UHD 620 (integrated) |
| RAM | 8GB | 

## What's built

- **Bar** (`modules/bar/`) — top bar with a pill-based design (`Pill.qml` as a reusable wrapper), workspaces as animated tri-state pills, clock, network, volume, battery, system tray, power menu.
- **App launcher** (`modules/app_launcher/`) — app launcher with search, keyboard navigation, recently-launched history, and a fallback for missing icons.
- **Screen frame** (`modules/frame/`) — decorative screen border (`PanelWindow` + `Rectangle border` — a shader-based version was rejected due to GPU cost).
- **Color system** (`config/Colors.qml`) — "Japanese Navy" palette, 17 colors, `pragma Singleton`, available everywhere as `Colors.name`.
- **In progress:** a dynamic theme switcher built on matugen — a wallpaper generates `colors.json`, Quickshell reads it via `FileView` + `JsonAdapter`, and `Colors.qml` is meant to act as a facade mapping Material You names to semantic palette names, so downstream components don't need changes.

## TODO

- [ ] Power plan control via `Quickshell.Services.UPower` `PowerProfiles`
- [ ] A custom lockscreen (`ext-session-lock-v1`), written from scratch, conceptually inspired by [Darkkal44/qylock](https://github.com/Darkkal44/qylock)
- [ ] Multi-monitor support for the bar — deferred until I get an external monitor
- [ ] Finishing the theme switcher (propagating colors to Hyprland borders and kitty)

## Things I'm learning from

- [Quickshell docs (v0.3.0)](https://quickshell.org/docs/v0.3.0) — the only trustworthy, versioned API source
- [Hyprland Wiki](https://wiki.hypr.land/) — configuration, Wayland protocols
- [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) and [caelestia-dots/shell](https://github.com/caelestia-dots/shell) — read for patterns, not copied
- [Darkkal44/qylock](https://github.com/Darkkal44/qylock) — reference for my own lockscreen
- [SaneAspect](https://www.youtube.com/@saneAspect/featured) - Helpful Youtube tutorials

---

*This project is a learning environment, not a finished product — if something looks "unfinished" or "unoptimized," it's usually a deliberate choice in favor of understanding over speed.*

**Disclaimer! AI was used here**
