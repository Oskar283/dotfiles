# Server-only Home Manager profile.
# Curated subset of `default` — drops desktop/WM, alacritty, stylua and
# anything else only useful on a workstation.
#
# Consumed via:
#   imports = [ inputs.dotfiles.homeManagerModules.server ];
{ ... }: {
  imports = [
    ./tmux.nix
    ./git.nix
    ./aliases.nix
    ./bash.nix
    ./fzf.nix
    ./nvim/nvim.nix
  ];
}
