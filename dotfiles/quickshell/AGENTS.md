# AGENTS.md — Quickshell-rice-learn

Context file for AI agents working in this repository. Read this before making changes.

## Project purpose

Tershy is building a custom desktop environment on Arch Linux from scratch — with full understanding of every component, not by copying pre-made dotfiles. The primary goal is **learning** Quickshell, Hyprland, and Arch Linux internals through hands-on building. Repo: `Tershy/Quickshell-rice-learn`.

**Working style — read this before generating code:**
- Explain *why*, not just *what*. Concepts and sources before or alongside code, never bare files to copy blindly.
- When asked to simplify or narrow scope, comply immediately without pushback.
- Verify real system state before changes (`pacman -Ql`, `grep`, `fc-list`, `efibootmgr -v`, etc.) rather than assuming.
- Backup before deletion, never after.
- Work on topic branches; open PRs via GitHub rather than local `git merge`.
- **When building multi-file features, explicitly wire components together — do not duplicate logic inline "just in case." If a component is extracted into its own file, reference it, don't reimplement it.** (See Known Pitfalls below for why this rule exists.)

## Hardware

Dell Vostro 3580 — Intel Core i5-8265U (8 threads @ 3.90GHz), AMD Radeon R5 M435 (dedicated), Intel UHD 620 (integrated), 237GB btrfs, 7.62GB RAM.

Low RAM is a real constraint: avoid source-built AUR packages where `-bin` variants exist (OOM risk), and be conservative with concurrent processes (e.g. multi-agent delegation concurrency) on this machine.

## Stack

- Arch Linux + Hyprland 0.56.0 (config in Lua: `hyprland.lua`, not hyprlang)
- kitty + fish + VS Code + Quickshell
- Browser: Zen (qutebrowser and impala both evaluated and not used for browsing)
- Network: iwd + impala (working)
- Display manager: SDDM
- Filesystem: btrfs + Snapper + limine-snapper-sync + Limine bootloader

## Color system

"Japanese Navy" palette — 17 colors (5 backgrounds, 3 text tones, 9 accents + 8 terminal variants), singleton `Colors.qml` in `config/`, accessed by name (`Colors.red`, `Colors.sky`, etc.). Reference doc: `japanese-navy-palette.md`. Colors are derived mathematically (hue rotation, fixed lightness/saturation) — never picked by eye.

## Current architecture (Quickshell bar)

Modular structure, refactored off `main`:

- **`Bar.qml`** — top-level `PanelWindow` (top-anchored, `ExclusionMode.Auto`, `implicitHeight: 30`, transparent background — visual weight comes from `Pill` wrappers around each module, not the bar itself)
- **`Workspaces.qml`** — 10-workspace repeater, pill-style indicators (Rectangle, radius 15, height 24) with tri-state appearance (active/occupied/empty) via `Hyprland.workspaces.values.find`, animated `Behavior on color` (150ms), clickable via `Hyprland.dispatch("hl.dsp.focus(...)")`
- **`Battery.qml`** — `UPower.displayDevice.percentage`, color-coded via `batteryColor()` (charging=blue, then green/yellow/orange/red by threshold). Tooltip for time-remaining was deliberately removed — **do not re-add without asking**.
- **`Clock.qml`** — `SystemClock` (minute precision) via `Qt.formatDateTime`. Requires explicit `import Quickshell` in this file even though parent imports it — QML imports are per-file, never inherited.
- **`PowerMenu.qml` + `PowerMenuButton.qml`** — power menu via `PopupWindow` + `Quickshell.Io.Process` calling systemctl/loginctl/hyprlock. Logout uses a custom script (`~/.local/share/quickshell-lockscreen/lock.sh`) rather than `hyprshutdown`, to avoid a black-screen bug on logout.
- **`SystemTray.qml`** — standalone `Quickshell.Services.SystemTray` component: hover-highlighted icons, left-click activates, right-click opens context menu if `modelData.hasMenu`. **Must be referenced from `Bar.qml` as `SystemTray {}`, not reimplemented inline** — see Known Pitfalls.
- **`ScreenFrame.qml`** — decorative screen border as a `PanelWindow` with a `Rectangle border` (shader-based version was rejected — see Known Pitfalls)

Theme is consistent across kitty (ANSI slots), fish (`.theme` files), fastfetch (inline escape syntax), and Hyprland (plain hex accepted in Lua config).

## Known pitfalls (learned the hard way — don't repeat)

- **QML imports are per-file.** A child file omitting `import Quickshell` fails even if the parent imports it.
- **Verify property names against `quickshell.org/docs/v0.3.0`, not v0.1.0.** Caught via `exclusionZone` vs `exclusionMode` mismatch.
- **Shader-based borders are extremely GPU-expensive.** A plain `Rectangle border` is sufficient — don't reach for shaders on this hardware.
- **Hyprland's Lua config accepts plain hex** (`"#39A2CA"`), not just `rgba()` packed format.
- **Fish built-in themes are compiled into the binary** (`__fish_theme_cat <name>`); user themes are `.theme` files in `~/.config/fish/themes/`, looked up by filename, not the `# name:` header inside the file.
- **Fastfetch only requires `##` inside format strings for hex colors** — a single `#` is fine outside them.
- **`LIMINE_CONF_PATH` is an undocumented, maintainer-discouraged workaround variable.** Limine has its own auto-discovery; don't reintroduce this.
- **Qt6 binaries are suffixed `6` on Arch** (`qmlls6`, not `qmlls`).
- **mkinitcpio hook is `btrfs-overlayfs`, not `sd-btrfs-overlayfs`**, for non-systemd-style hook lists (`base udev ...`).
- **A model (or a rushed pass) can duplicate a component inline instead of referencing the standalone file it already built**, silently losing an import along the way (e.g. `Colors.overlay` used without `import qs.config`). When building multi-file features, always do a final pass confirming every extracted component is actually *referenced* somewhere, not just present in the repo. Concretely: a `SystemTray.qml` component was built correctly but `Bar.qml` reimplemented the same tray logic inline instead of using it, and the inline copy was missing the `qs.config` import that the standalone version had — a real bug caught only by explicit review, not by anything failing loudly at parse time.

## Multi-agent / delegation setup (Hermes-side)

Hermes is configured for delegated subagent work via `delegate_task`, separate from the primary conversational model:

- **Primary/orchestrator model**: `nvidia/nemotron-3-super-120b-a12b` (confirmed working, ~35 tok/s observed)
- **Delegate model**: `nvidia/nemotron-3-nano-30b-a3b` (confirmed working; chosen over `llama-3.3-nemotron-super-49b-v1` after a head-to-head test — the smaller reasoning-enabled nano model gave a correct, reasoning-transparent answer about Quickshell's `PanelWindow`, while the larger non-reasoning 49B model confidently hallucinated an incorrect answer by analogy to generic Qt/QML)
- **`max_concurrent_children`: 2** (not the default 3) — deliberately reduced given 7.62GB RAM and the observation that even single-request calls to the primary model can hit shared-worker-pool saturation (`503 ResourceExhausted`) on NVIDIA's free tier; running concurrent subagents multiplies exposure to that.
- `nvidia/llama-3.1-nemotron-ultra-253b-v1` is catalog-listed but **not actually invokable on this account** (confirmed via direct curl — 404 on the resolved backend function, despite appearing in `/v1/models`). Don't reach for it as a fallback model without re-testing.
- Lesson for future delegation tasks: multi-file architectural work (e.g. "build component X, then wire it into file Y") should be given to delegation as **explicit, separate, ordered child tasks** rather than one open-ended task — this is believed to reduce the inline-duplication failure mode described above, though not yet re-tested.

## On the horizon (open items)

1. Power plan control via `Quickshell.Services.UPower` PowerProfiles
2. Own lockscreen in Quickshell (`ext-session-lock-v1` protocol), conceptually inspired by `Darkkal44/qylock` but written from scratch, not copied
3. Multi-monitor support for the bar — deferred until an external monitor is acquired; `import Quickshell` was added early to `Workspaces.qml` in anticipation of this (`Quickshell.screens`)
4. Re-test the "explicit ordered subtasks" delegation pattern against the SystemTray-style duplication bug, to confirm it actually prevents recurrence

## Completed

- PR `refactor/modular-structure` → `main`, merged
- Snapper snapshot boot test, done
- Power menu implemented and working; fixed a bug where all 4 buttons (lock/logout/reboot/shutdown) called the same `lockProcess` instead of their own — fixed via correct references + `console.log` debugging
- Logout switched from `hyprshutdown` to custom `lock.sh` script — confirmed working, no more black-screen-on-logout
- Workspace pills redesigned from bare `Text` to tri-state animated pills, made clickable
- Icon-based workspace indicators (verified Nerd Font glyphs) — done
- Network stack decision: iwd + impala confirmed working; qutebrowser dropped in favor of Zen
- Full Hermes backup restore performed and verified (state.db, 6 sessions, MEMORY.md, USER.md, config migrated v32→v33)
- Multi-agent delegation configured and model-tested (see above)

---
*Last updated: 2026-07-30*
