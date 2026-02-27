# fzf.vim — fuzzy file and buffer picker.
# No nixvim DSL module exists for fzf.vim, so we use extraPlugins.
# The fzf binary is already in PATH via home-manager/fzf.nix (programs.fzf).
#
# Note: if you want a fully Lua-native alternative with a nixvim DSL module,
# consider migrating to ibhagwan/fzf-lua (plugins.fzf-lua) which has a
# "fzf-vim" profile that replicates this behaviour.
{ pkgs, ... }: {
  extraPlugins = with pkgs.vimPlugins; [
    fzf-vim  # the fzf.vim plugin (provides :GFiles, :Buffers, etc.)
    fzf      # the Vim-side fzf integration library (required by fzf-vim)
  ];

  # fzf binary on the Neovim wrapper PATH (belt-and-suspenders alongside
  # programs.fzf.enable which puts it on the user PATH)
  extraPackages = [ pkgs.fzf ];

  keymaps = [
    # Git-tracked files picker (normal mode)
    { mode = "n"; key = "<F2>"; action = ":GFiles<CR>";  options.silent = true; }
    # Open buffers picker (normal mode; visual <F8> is the grep shortcut in options.nix)
    { mode = "n"; key = "<F8>"; action = ":Buffers<CR>"; options.silent = true; }
  ];

  # Override the default fzf.vim commands to suppress the preview window.
  # Uses nvim_create_user_command instead of vim.cmd Vimscript to avoid
  # embedding '' (two single-quotes) inside a Nix ''...'' string, which
  # would prematurely terminate the Nix string literal.
  extraConfigLua = ''
    vim.api.nvim_create_user_command("GFiles", function(_)
      vim.fn["fzf#vim#gitfiles"]("", { options = "--no-preview" })
    end, { bang = true, desc = "fzf git files (no preview)" })

    vim.api.nvim_create_user_command("Buffers", function(_)
      vim.fn["fzf#vim#buffers"]("", { options = "--no-preview" })
    end, { bang = true, desc = "fzf buffers (no preview)" })
  '';
}
