# Neovim — fully declarative configuration via Nixvim.
# All plugins, LSP servers, formatters, and keymaps are managed by Nix.
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
{ inputs, ... }: {
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable      = true;
    vimAlias    = true;
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
