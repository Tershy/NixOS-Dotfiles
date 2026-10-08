{ pkgs, ... }:

{
  users.users."tershy" = {
    isNormalUser = true;
    description = "Tershy";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };
}
