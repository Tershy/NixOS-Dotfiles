{ ... }:

{
  # Entire config tree managed as one directory; matugen output
  # (config/generated/colors.json) is included for now but will need
  # re-evaluation once live regeneration is wired up in Stage 2.
  xdg.configFile."quickshell" = {
    source = ../dotfiles/quickshell;
    recursive = true;
  };
}
