# Bash configuration — generic settings for all machines.
# Work/machine-specific entries are commented out.
# Note: home.shellAliases (aliases.nix) are injected automatically by HM when
# programs.bash.enable = true — no need to source ~/.aliases manually.
{ ... }: {

  # Minimal vim config for use as $EDITOR in the shell
  home.file.".vimrc_cli".text = ''
    autocmd BufWritePre * %s/\s\+$//e " Always trim trailing whitespace on save
    set visualbell       " Use visual instead of sound on error
    set confirm          " Ask to save on quit
    set nocompatible     " be iMproved, required
    set noswapfile
    set backspace=2      " More powerful backspacing
  '';

  programs.bash = {
    enable = true;

    bashrcExtra = ''
      # Prevent instant logout on Ctrl-D (requires 2 presses).
      set -o ignoreeof
      export IGNOREEOF=2

      # Lightweight vim as $EDITOR — faster than nvim for quick shell edits.
      export EDITOR="vim -u ~/.vimrc_cli"

      # Add user-local bin to PATH.
      export PATH=~/.local/bin:"$PATH"

      # Prompt: time, path, git branch.
      export PS1='\[\033[01;32m\]\D{ %H:%M} :\[\033[01;34m\]\w\[\033[01;36m\]$(__git_ps1 "(%s)")\[\033[00m\] \$ '
    '';
  };
}
