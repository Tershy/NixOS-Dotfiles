# User entry point: identity only, every feature lives in ./home
{ ... }:

{
  imports = [
    ./home/shell.nix
    ./home/kitty.nix
    ./home/cursor.nix
    ./home/hyprland.nix
    ./home/quickshell.nix
    ./home/matugen.nix
    ./home/yazi.nix
  ];

  home.username = "tershy";
  home.homeDirectory = "/home/tershy";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
