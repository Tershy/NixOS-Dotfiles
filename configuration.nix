# Host entry point: every feature lives in ./modules, this file just wires them together.
{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/locale.nix
    ./modules/graphics.nix
    ./modules/users.nix
    ./modules/desktop.nix
    ./modules/sddm.nix
    ./modules/hardware.nix
    ./modules/shell.nix
    ./modules/nix-settings.nix
    ./modules/services.nix
    ./modules/gaming.nix
    ./modules/fonts.nix
    ./modules/packages.nix
  ];

  system.stateVersion = "26.05"; # Did you read the comment?
}
