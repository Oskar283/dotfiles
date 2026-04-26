# Shell aliases for all machines.
# Machine-specific overrides go in ~/.aliases.local (sourced automatically).
{ ... }: {
  home.shellAliases = {
    ll                  = "ls -lah --color";
    ls                  = "ls --color";
    dfind               = "find . -iname";
    tmux_reset          = "clear && tmux clear-history";
    delete_git_branches = "git for-each-ref --format '%(refname:short)' refs/heads | grep -v master | xargs git branch -D";
    p3                  = "python3";
    vi                  = "vi -u NONE";
  };

  # Source machine-local aliases if present.
  programs.bash.bashrcExtra = ''
    if [ -f ~/.aliases.local ]; then
      . ~/.aliases.local
    fi
  '';
}
