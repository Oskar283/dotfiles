# StyLua formatter configuration.
{ ... }: {
  home.file.".stylua.toml".text = ''
    indent_type = "Spaces"
    indent_width = 2
    column_width = 100
    quote_style = "AutoPreferDouble"
  '';
}
