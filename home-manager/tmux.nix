# Tmux — canonical NixOS/Home Manager version.
# The raw dotfiles/home/tmux.conf is kept in place for non-NixOS devenv
# machines and may diverge from this file over time.
{ ... }: {
  programs.tmux = {
    enable = true;

    # ── Native HM options ────────────────────────────────────────────────────
    mouse        = true;
    keyMode      = "vi";
    baseIndex    = 1;
    historyLimit = 50000;
    terminal     = "screen-256color";
    escapeTime   = 50;

    # ── Raw tmux config for settings without a native HM option ─────────────
    extraConfig = ''
      # Use $SHELL at runtime so the session inherits the user's configured shell.
      set-option -g default-command "''${SHELL}"

      # Ctrl-a as a secondary prefix (screen muscle-memory).
      bind C-a send-prefix

      # Focus events — required by Neovim (coc/LSP) for autoread.
      set-option -g focus-events on

      # Disable alternate screen so tmux content flows into terminal scrollback.
      set -g terminal-overrides 'xterm*:smcup@:rmcup@'
      setw -g alternate-screen on

      # True-color support for Neovim.
      set-option -sa terminal-overrides ',xterm-256color:Tc'

      # Status bar refresh rate (seconds).
      set -g status-interval 2

      # Renumber windows sequentially after closing.
      set-option -g renumber-windows on

      # Pane and window styling.
      set -g pane-active-border-style fg=colour208,bg=default
      set-window-option -g window-status-current-style bg=red,fg=black

      # Saner split bindings.
      bind | split-window -h
      bind - split-window -v

      # Activity alerts.
      setw -g monitor-activity on
      set -g visual-activity on

      # Clipboard integration (X11 / xclip).
      bind C-y run "tmux show-buffer | xclip -selection clipboard -i >/dev/null"
      bind C-p run "tmux set-buffer \"$(xclip -o)\"; tmux paste-buffer"
    '';
  };
}
