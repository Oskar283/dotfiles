# Root Home Manager module exported by this flake.
# Import this from the homelab flake via:
#   inputs.dotfiles.homeManagerModules.default
#
# Add new configs here as they are migrated
{ ... }: {
  imports = [
    ./tmux.nix
    ./git.nix
    ./aliases.nix
  ];
}
