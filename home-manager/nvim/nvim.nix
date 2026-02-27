# Neovim — fully declarative configuration via Nixvim.
# All plugins, LSP servers, formatters, and keymaps are managed by Nix.
#
# nixvim's homeModules.nixvim is imported at the dotfiles flake level
# (dotfiles/flake.nix), so programs.nixvim options are available here
# without needing to reference `inputs` inside `imports` (which would
# cause infinite recursion in the module system).
#
# ── Escape hatches for things not yet in nixpkgs ─────────────────────────────
# Raw .lua file loaded into the Neovim runtime (require()-able):
#   programs.nixvim.extraFiles."lua/myplugin.lua".source = ./lua/myplugin.lua;
#
# Plugin not in nixpkgs, built from source:
#   programs.nixvim.extraPlugins = [(pkgs.vimUtils.buildVimPlugin {
#     name = "myplugin";
#     src  = pkgs.fetchFromGitHub { owner = "..."; repo = "..."; rev = "..."; hash = "..."; };
#   })];
#   programs.nixvim.extraConfigLua = ''require('myplugin').setup({})'';
# ─────────────────────────────────────────────────────────────────────────────
{ ... }: {
  programs.nixvim = {
    enable        = true;
    vimAlias      = true;
    defaultEditor = true;

    # Sub-modules use the short nixvim option namespace (no programs.nixvim. prefix).
    imports = [
      ./options.nix
      ./plugins/lsp.nix
      ./plugins/treesitter.nix
      ./plugins/ui.nix
      ./plugins/formatting.nix
      ./plugins/git.nix
      ./plugins/fzf.nix
      ./plugins/terminator.nix
    ];
  };
}
