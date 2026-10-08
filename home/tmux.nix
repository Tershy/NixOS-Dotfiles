{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shortcut = "a"; # Changes Prefix from Ctrl-b to Ctrl-a
    baseIndex = 1; # Starts window/pane numbering at 1 instead of 0
    escapeTime = 0; # Eliminates Vim Esc key lag inside tmux
    keyMode = "vi"; # Enables Vi keybindings in copy mode
    mouse = true; # Enables mouse clicking/scrolling

    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -g focus-events on # Passes focus events to Neovim for auto-reloads

      # Intuitive splits opening in the current path
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
    '';

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator # Seamless Ctrl-h/j/k/l navigation between Neovim splits and tmux panes
      catppuccin
    ];
  };
}
