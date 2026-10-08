{ ... }:

{
  # hyprland.lua and its modules are hand-written and stable.
  # matugen's generated colors file lives next to them (unmanaged) and is
  # sourced from hyprland.lua, which is why this is a recursive directory
  # (real dir + per-file symlinks) rather than one symlink to the store.
  xdg.configFile."hypr" = {
    source = ../dotfiles/hypr;
    recursive = true;
  };
}
