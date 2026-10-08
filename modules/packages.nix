{ pkgs, fetch, awww, wlctl, zen-browser, spotatui, ... }:

let
  hostSystem = pkgs.stdenv.hostPlatform.system;
in
{
  environment.systemPackages = with pkgs; [
    # Editors
    vim
    neovim

    # Terminal / shell tools
    kitty
    yazi
    fastfetch
    fetch.packages.${hostSystem}.default

    # Files & search
    fd
    tree

    # Archives & compression
    unzip
    gnutar
    gzip
    brotli

    # Network
    wget
    curl
    wlctl.packages.${hostSystem}.default

    # Development
    git
    gcc
    tree-sitter
    qt6.qtdeclarative # qmlls for QML LSP

    # Hyprland / desktop
    quickshell
    libnotify
    awww.packages.${hostSystem}.awww

    # Theming
    matugen
    nwg-look

    # Screenshots
    hyprshot
    satty

    # Audio / Bluetooth
    pavucontrol
    wiremix
    bluetui

    # Media / music
    spotify
    spotatui.packages.${hostSystem}.default

    # Apps
    zen-browser.packages.${hostSystem}.default
    vesktop

    # System
    tzdata
  ];
}
