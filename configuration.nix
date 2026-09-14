# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, pkgs-unstable, fetch, awww, wlctl, zen-browser, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/sddm.nix
  ];

  ##############################################
  ## Boot
  ##############################################

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  ##############################################
  ## Networking
  ##############################################

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  ##############################################
  ## Localization
  ##############################################

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS     = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY    = "pl_PL.UTF-8";
    LC_NAME        = "pl_PL.UTF-8";
    LC_NUMERIC     = "pl_PL.UTF-8";
    LC_PAPER       = "pl_PL.UTF-8";
    LC_TELEPHONE   = "pl_PL.UTF-8";
    LC_TIME        = "pl_PL.UTF-8";
  };

  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };
  console.keyMap = "pl2";

  ##############################################
  ## Graphics 
  ##############################################

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [

      # Intel UHD 620 — primary Wayland renderer, VAAPI decode
      intel-media-driver
      intel-vaapi-driver

      # Shared / cross-vendor
      libva-vdpau-driver
      libvdpau-va-gl

    ];
  };
  
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD"; # forces Intel iGPU VAAPI driver system-wide
  };

  ##############################################
  ## Users
  ##############################################

  users.users."tershy" = {
    isNormalUser = true;
    description = "Tershy";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  ##############################################
  ## Desktop / Window Manager
  ##############################################

  programs.hyprland.enable = true;
  programs.uwsm.enable = true;
  # services.displayManager.defaultSession = "hyprland";

  ##############################################
  ## Hardware & Peripherals
  ##############################################

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  services.upower.enable = true;

  ##############################################
  ## Shell
  ##############################################

  programs.fish.enable = true;

  ##############################################
  ## Nix Settings
  ##############################################

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ##############################################
  ## Services
  ##############################################

  services.flatpak.enable = true;
  # services.openssh.enable = true;

  ##############################################
  ## Fonts
  ##############################################

  fonts.packages = with pkgs; [
    maple-mono.NF-unhinted
  ];

  ##############################################
  ## System Packages
  ##############################################

  environment.systemPackages = with pkgs; [
    # Editors
    vim
    neovim

    # Hyprland / desktop
    hyprland
    hyprshot
    quickshell
    nwg-look

    # Theming
    matugen
    satty

    # Terminal / shell tools
    kitty
    fish
    yazi
    fastfetch
    fd
    tree
    tree-sitter
    git
    wget
    gcc

    # Apps
    librewolf
    vesktop

    # Audio / Bluetooth
    pavucontrol
    wiremix
    bluetui

    # Graphics diagnostics
    mesa-demos
    libva-utils

    # Flake-sourced packages
    awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
    fetch.packages.${pkgs.system}.default
    wlctl.packages.${pkgs.system}.default
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  ##############################################
  ## System State Version
  ##############################################

  system.stateVersion = "26.05"; # Did you read the comment?
}
