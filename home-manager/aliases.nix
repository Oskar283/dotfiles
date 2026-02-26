# Shell aliases for all machines.
# Work-specific entries are commented out — uncomment when on a work machine.
{ ... }: {
  home.shellAliases = {
    ll                  = "ls -la --color";
    ls                  = "ls --color";
    dfind               = "find . -iname";
    tmux_reset          = "clear && tmux clear-history";
    delete_git_branches = "git for-each-ref --format '%(refname:short)' refs/heads | grep -v master | xargs git branch -D";
    p3                  = "python3";
    vi                  = "vi -u NONE";

    # repo      = "cd /repo/";
    # em        = "/snap/bin/emacsclient --tty";
    # src_tmux  = "tmux new-session -d -s work -c /repo/src \\; new-window -c /repo/src \\; new-window -c /repo/src2 \\; new-window -c /repo/src2 \\; new-window -c ~ \\; attach";
    # format_src = "./bazel.py run cppformat";
  };

  # compile_all: work-specific shell function.
  # Uncomment work aliases above (repo, em, src_tmux, format_src) on work machines.
  programs.bash.bashrcExtra = ''
    compile_all() {
      target="$1"
      ./bazel.py run compile_commands -- --absolute_external --skip_failed_targets -t "$target" &&
      sed -i "s#$HOME/\.cache/bazel/_bazel[^/]*/[^/]*/execroot/_main/\?\(\s\|\"\)#$(git rev-parse --show-toplevel)\1#g" \
          "$(git rev-parse --show-toplevel)/compile_commands.json"
    }
  '';
}
