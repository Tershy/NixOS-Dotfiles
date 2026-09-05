{ config, pkgs, ... }:
{
  home.username = "tershy";
  home.homeDirectory = "/home/tershy";
  home.stateVersion = "26.05";
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  programs.home-manager.enable = true;

  # --- fish ---
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      fastfetch
      set fish_greeting
    '';
    shellAliases = {
      fetch = "nix run github:areofyl/fetch";

      nixrebuild = "sudo nixos-rebuild switch";
      homerebuild = "home-manager switch -b backup --flake /etc/nixos#tershy";

      nixconf = "nvim /etc/nixos/configuration.nix";
      hypconf = "nvim /etc/nixos/dotfiles/hypr/hyprland.lua";
      flakeconf = "nvim /etc/nixos/flake.nix";
      homeconf = "nvim /etc/nixos/home.nix";

    };
    functions = {
      y = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        command yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
          builtin cd -- "$cwd"
        end
        command rm -f -- "$tmp"
      '';
    };
    plugins = [
      {
        name = "tide";
        src = pkgs.fetchFromGitHub {
          owner = "IlanCosman";
          repo = "tide";
          rev = "v6.1.1";
          sha256 = "sha256-ZyEk/WoxdX5Fr2kXRERQS1U1QHH3oVSyBQvlwYnEYyc=";
        };
      }
    ];
  };

  # --- kitty ---
  programs.kitty = {
    enable = true;
    font = {
      name = "MapleMono NF";
      size = 12.0;
    };
    settings = {
      cursor_shape = "block";
      cursor_trail = "1";
      window_margin_width = "5";
      window_padding_width = "5";
      background_opacity = "0.8";
    };
    extraConfig = ''
      include current-theme.conf
    '';
  };

  # --- hyprland config files ---
  # hyprland.lua and its modules are hand-written and stable;
  # matugen theming will hook in as a separate, ungmanaged colors file
  # sourced from hyprland.lua, not managed here.
  xdg.configFile = {
    "hypr/hyprland.lua".source = ./dotfiles/hypr/hyprland.lua;
    "hypr/modules/decorations.lua".source = ./dotfiles/hypr/modules/decorations.lua;
    "hypr/modules/monitors.lua".source = ./dotfiles/hypr/modules/monitors.lua;
    "hypr/modules/env.lua".source = ./dotfiles/hypr/modules/env.lua;
    "hypr/modules/windowrules.lua".source = ./dotfiles/hypr/modules/windowrules.lua;
    "hypr/modules/input.lua".source = ./dotfiles/hypr/modules/input.lua;
    "hypr/modules/autostart.lua".source = ./dotfiles/hypr/modules/autostart.lua;
    "hypr/modules/misc.lua".source = ./dotfiles/hypr/modules/misc.lua;
    "hypr/modules/binds.lua".source = ./dotfiles/hypr/modules/binds.lua;
    "hypr/modules/layouts.lua".source = ./dotfiles/hypr/modules/layouts.lua;

    # --- yazi ---
    "yazi/yazi.toml".source = ./dotfiles/yazi/yazi.toml;
  };
}
