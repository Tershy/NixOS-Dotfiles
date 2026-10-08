{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # Intel UHD 620: primary Wayland renderer, VAAPI decode
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

  # Diagnostics (vainfo, glxinfo, ...)
  environment.systemPackages = with pkgs; [
    mesa-demos
    libva-utils
  ];
}
