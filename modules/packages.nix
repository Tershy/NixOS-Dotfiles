{ pkgs, fetch, awww, wlctl, zen-browser, spotatui, craft-launcher, ... }:

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
    craft-launcher.packages.${hostSystem}.default

    # System
    tzdata

    # Development
    git
    gcc
    gdb
    cmake
    gnumake
    clang-tools # provides clangd for LazyVim
    tree-sitter
    qt6.qtdeclarative # qmlls for QML LSP
    wineWow64Packages.stable
    winetricks

    # IDEs
    qtcreator
    jetbrains.clion
  ];
}
