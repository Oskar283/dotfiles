# Extra plugins without dedicated nixvim DSL modules.
# nvim-surround: add/change/delete surrounding pairs.
# markview.nvim: rich markdown rendering in the buffer.
# quicker.nvim: enhanced quickfix list.
{ pkgs, ... }: {
  plugins.nvim-surround = {
    enable = true;
  };

  plugins.markview = {
    enable = true;
    lazyLoad.settings.lazy = false;
  };

  extraPlugins = [
    pkgs.vimPlugins.quicker-nvim
  ];

  extraConfigLua = ''
    require("quicker").setup({})
  '';
}
