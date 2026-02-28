# Treesitter — grammars compiled by Nix, no runtime compilation needed.
{ pkgs, ... }: {
  # Silence :checkhealth warnings — grammars are Nix-managed so these
  # executables are never actually invoked for compilation.
  extraPackages = with pkgs; [
    gcc
    tree-sitter
    nodejs
  ];

  plugins.treesitter = {
    enable = true;

    settings.highlight = {
      enable                            = true;
      additional_vim_regex_highlighting = false;
    };

    # Explicit grammar list — add more here as needed.
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      lua
      python
      c
      cpp
      markdown
      nix
    ];
  };
}
