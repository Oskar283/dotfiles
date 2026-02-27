# vim-terminator — run the current file in a terminal split.
# No nixvim DSL module; pkgs.vimPlugins.vim-terminator is in nixpkgs.
{ pkgs, ... }: {
  extraPlugins = [ pkgs.vimPlugins.vim-terminator ];

  globals = {
    terminator_clear_default_mappings = "clear";
    terminator_split_location         = "vertical botright";
    terminator_split_fraction         = 0.3;
  };

  keymaps = [
    { mode = "n"; key = "<F10>"; action = ":TerminatorRunFileInTerminal<CR>";    options.silent = true; }
    { mode = "n"; key = "<F11>"; action = ":TerminatorRunFileInOutputBuffer<CR>"; options.silent = true; }
  ];
}
