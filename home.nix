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
      nixconf = "nvim /etc/nixos/configuration.nix";
      hypconf = "nvim ~/.config/hypr/hyprland.lua";
      flakeconf = "nvim /etc/nixos/flake.nix";
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
}
