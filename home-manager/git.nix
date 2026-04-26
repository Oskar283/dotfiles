# Git — portable settings shared across all machines.
# Machine-specific overrides (work email, gerrit aliases, etc.) go in
# ~/.gitconfig.local which is included automatically.
{ ... }: {
  programs.git = {
    enable = true;

    includes = [
      { path = "~/.gitconfig.local"; }
    ];

    settings = {
      user.name  = "Oskar";
      user.email = "oskar@oskar";

      core.editor = "vim";
      pull.rebase  = true;

      merge.tool    = "kdiff3";
      diff.guitool  = "kdiff3";

      alias = {
        st       = "status";
        co       = "checkout";
        ci       = "commit";
        br       = "branch";
        cc       = "cherry-pick --continue";
        rc       = "rebase --continue";
        ca       = "cherry-pick --continue";
        ra       = "rebase --abort";
        ri       = "rebase -i HEAD^^^^^";
        hist     = "log --graph --format=format:\"%C(red)%h%C(reset) %C(yellow)%ad%C(reset) | %s %C(green)\\[%an\\]%C(reset)%C(bold blue)%d%C(reset)\" --abbrev-commit --date=short";
        root     = "rev-parse";
        alias    = "config --global --get-regexp alias";
        head     = "rev-list -n1 --abbrev-commit HEAD";
        diffhead = "diff HEAD^";
        detach   = "checkout origin/master --detach";
        su       = "branch --set-upstream-to=origin/master";
        pu       = "push origin HEAD:refs/for/master";
        puwip    = "push origin HEAD:refs/for/master%wip";
      };
    };
  };
}
