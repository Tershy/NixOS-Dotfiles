{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      if test -f ~/.config/matugen/generated/fish-colors.fish
        source ~/.config/matugen/generated/fish-colors.fish
      end
      set fish_greeting
    '';
    shellAliases = {

      nixrebuild = "sudo nixos-rebuild switch";
      homerebuild = "home-manager switch -b backup --flake /etc/nixos#tershy";
      dotadd = "cd /etc/nixos && git add -A";

      nixconf = "nvim /etc/nixos/modules/";
      flakeconf = "nvim /etc/nixos/flake.nix";
      homeconf = "nvim /etc/nixos/home/";
      dotconf = "nvim /etc/nixos/dotfiles/";
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
}
