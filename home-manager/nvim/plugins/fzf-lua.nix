# fzf-lua — Lua-native fuzzy finder with UI-select integration.
# Complements fzf.vim (plugins/fzf.nix) — fzf-lua handles UI-select
# (e.g. code actions) while fzf.vim provides :GFiles/:Buffers.
{ ... }: {
  plugins.fzf-lua = {
    enable = true;
  };

  extraConfigLua = ''
    require("fzf-lua").register_ui_select()
  '';
}
