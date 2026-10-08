{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;             # Steam Remote Play
    dedicatedServer.openFirewall = true;        # Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Local Network Game Transfers
  };

  environment.systemPackages = with pkgs; [
    steam-tui
    steamcmd
    protonup-qt
  ];
}
