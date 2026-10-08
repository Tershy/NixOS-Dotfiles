{ ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "MapleMono NF";
      size = 12.0;
    };
    settings = {
      cursor_shape = "block";
      cursor_trail = "1";
      window_margin_width = "5";
      window_padding_width = "5";
      background_opacity = "0.8";
      allow_remote_control = "yes";
      confirm_os_window_close = "0";
    };
    extraConfig = ''
      include current-theme.conf
    '';
  };
}
