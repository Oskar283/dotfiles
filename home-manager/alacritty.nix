# Alacritty — Gruvbox light color scheme, wrapped with nixGL for GPU access.
{
  pkgs,
  nixgl ? null,
  ...
}:
let
  # Wrap alacritty with nixGLIntel so it can access system GPU drivers on non-NixOS.
  alacrittyWrapped =
    if nixgl != null then
      pkgs.writeShellScriptBin "alacritty" ''
        exec ${nixgl.packages.x86_64-linux.nixGLIntel}/bin/nixGLIntel ${pkgs.alacritty}/bin/alacritty "$@"
      ''
    else
      pkgs.alacritty;
in
{
  programs.alacritty = {
    enable = true;
    package = alacrittyWrapped;

    settings = {
      selection.save_to_clipboard = false;
      keyboard.bindings = [
        # Use CLIPBOARD clipboard instead of primary
        {
          key = "Insert";
          mods = "Shift";
          action = "Paste";
        } # CLIPBOARD
        {
          key = "Insert";
          mods = "Control";
          action = "Copy";
        }
        {
          key = "Tab";
          mods = "Control";
          chars = "\u001b[9;5u";
        }
        {
          key = "Tab";
          mods = "Control|Shift";
          chars = "\u001b[9;6u";
        }
      ];
      colors = {
        primary = {
          background = "#fbf1c7";
          foreground = "#3c3836";
        };
        normal = {
          black = "#3c3836";
          red = "#cc241d";
          green = "#98971a";
          yellow = "#d79921";
          blue = "#458588";
          magenta = "#b16286";
          cyan = "#689d6a";
          white = "#fbf1c7";
        };
        bright = {
          black = "#928374";
          red = "#9d0006";
          green = "#79740e";
          yellow = "#b57614";
          blue = "#076678";
          magenta = "#8f3f71";
          cyan = "#427b58";
          white = "#d5c4a1";
        };
      };
    };
  };

  # Desktop entry so Ubuntu launcher can find Nix-installed alacritty.
  home.file.".local/share/applications/alacritty.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Alacritty
    GenericName=Terminal
    Exec=${alacrittyWrapped}/bin/alacritty
    Icon=${pkgs.alacritty}/share/icons/hicolor/scalable/apps/Alacritty.svg
    Terminal=false
    Categories=System;TerminalEmulator;
  '';
}
