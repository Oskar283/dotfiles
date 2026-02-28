# Treesitter — grammars compiled by Nix, no runtime compilation needed.
{ pkgs, ... }: {
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
