# Git — portable settings shared across all machines.
# Server-specific overrides (e.g. sops credential helper) live in
# homelab/karlatornet/nixos/home-manager/home.nix and are merged on top.
{ ... }: {
  programs.git = {
    enable = true;

    userName  = "Oskar";
    userEmail = "oskar@oskar";

    extraConfig = {
      core.editor = "vim";
      pull.rebase  = true;

      alias = {
        st       = "status";
        co       = "checkout";
        ci       = "commit";
        br       = "branch";
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
