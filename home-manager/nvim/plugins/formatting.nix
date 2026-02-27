# conform.nvim — format-on-save.
# Formatter binaries are provided as Nix packages in extraPackages so they
# are available on the Neovim wrapper's PATH without polluting the global env.
#
# stylua reads ~/.stylua.toml which is placed there by home-manager/stylua.nix.
{ pkgs, ... }: {
  plugins.conform-nvim = {
    enable = true;

    settings = {
      formatters.stylua.args = {
        __raw = ''{ "--config-path", vim.fn.expand("~/.stylua.toml"), "-" }'';
      };

      formatters_by_ft = {
        python     = [ "black" ];
        javascript = [ "prettier" ];
        markdown   = [ "prettier" ];
        lua        = [ "stylua" ];
        json       = [ "prettier" ];
        cpp        = [ "clang_format" ];
        bzl        = [ "buildifier" ];
      };

      format_on_save = {
        __raw = ''
          function(_bufnr)
            return { timeout_ms = 500, lsp_fallback = true }
          end
        '';
      };
    };
  };

  # Formatter binaries available to the Neovim wrapper
  extraPackages = with pkgs; [
    black
    nodePackages.prettier
    clang-tools  # provides clang-format
    stylua
    buildifier
  ];
}
