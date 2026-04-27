# Company-specific / machine-local overrides.
# These files are gitignored — they stay out of GitHub but are deployed
# to ~ by Home Manager via mkOutOfStoreSymlink (symlinks point directly
# at the on-disk repo files, bypassing the Nix store).
#
# The runtime "if [ -f ~/.foo.local ]" guards in bash.nix, aliases.nix,
# and git.nix pick them up automatically.
#
# NOTE: If you'd rather have HM copy the content into the Nix store
# (e.g. for reproducibility on another machine), un-gitignore the files
# in .gitignore and change `mkOutOfStoreSymlink` to plain `source`:
#   home.file.".aliases.local".source = ../home/aliases.local;
#
# Adjust repoDir if you clone the dotfiles somewhere else.
{ config, ... }:
let
  repoDir = "/repo/external/dotfiles";
in {
  home.file.".aliases.local".source   = config.lib.file.mkOutOfStoreSymlink "${repoDir}/home/aliases.local";
  home.file.".bashrc.local".source    = config.lib.file.mkOutOfStoreSymlink "${repoDir}/home/bashrc.local";
  home.file.".gitconfig.local".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/home/gitconfig.local";
  home.file.".gitconfig".source       = config.lib.file.mkOutOfStoreSymlink "${repoDir}/home/gitconfig";
}
