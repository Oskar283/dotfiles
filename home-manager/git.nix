# Git — portable settings shared across all machines. No sops/company
# dependency here on purpose — company-specific identity (email, name,
# gerrit aliases) is filled in by homelab's own home-manager config via
# `programs.git.includes` (see homelab/workpc/home-manager/company-git.nix),
# which reuses homelab's existing sops-nix setup instead of duplicating it
# here.
{ ... }: {
  home.file.".gitconfig.local".source = ../home/gitconfig.local;

  programs.git = {
    enable = true;

    settings = {
      core.editor = "vim";
      pull.rebase = true;

      merge.tool = "kdiff3";
      diff.guitool = "kdiff3";

      alias = {
        st = "status";
        co = "checkout";
        ci = "commit";
        br = "branch";
        cc = "cherry-pick --continue";
        rc = "rebase --continue";
        ca = "cherry-pick --continue";
        ra = "rebase --abort";
        ri = "rebase -i HEAD^^^^^";
        hist = "log --graph --format=format:\"%C(red)%h%C(reset) %C(yellow)%ad%C(reset) | %s %C(green)\\[%an\\]%C(reset)%C(bold blue)%d%C(reset)\" --abbrev-commit --date=short";
        root = "rev-parse";
        alias = "config --global --get-regexp alias";
        head = "rev-list -n1 --abbrev-commit HEAD";
        diffhead = "diff HEAD^";
        detach = "checkout origin/master --detach";
        su = "branch --set-upstream-to=origin/master";
        pu = "push origin HEAD:refs/for/master";
        puwip = "push origin HEAD:refs/for/master%wip";
      };

      include.path = "~/.gitconfig.local";
    };
  };
}
