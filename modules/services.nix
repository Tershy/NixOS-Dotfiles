{ ... }:

{
  services.flatpak.enable = true;
  # services.openssh.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
