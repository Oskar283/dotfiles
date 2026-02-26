# Desktop / WM configuration.
# Note: enable = true installs the packages — harmless on the server but unused.
# Hikari has no HM module and uses a custom config format, so it stays as source.
{ lib, ... }: {

  # Alacritty — Gruvbox light color scheme.
  programs.alacritty = {
    enable = true;
    settings.colors = {
      primary = { background = "#fbf1c7"; foreground = "#3c3836"; };
      normal  = { black = "#3c3836"; red = "#cc241d"; green = "#98971a";
                  yellow = "#d79921"; blue = "#458588"; magenta = "#b16286";
                  cyan = "#689d6a"; white = "#fbf1c7"; };
      bright  = { black = "#928374"; red = "#9d0006"; green = "#79740e";
                  yellow = "#b57614"; blue = "#076678"; magenta = "#8f3f71";
                  cyan = "#427b58"; white = "#d5c4a1"; };
    };
  };

  # Weston compositor — no HM module, Swedish keyboard layout.
  xdg.configFile."weston.ini".text = ''
    [keyboard]
    keymap_model=pc105
    keymap_layout=se
    keymap_variant=nodeadkeys
  '';

  # Sway window manager.
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod1";
      terminal = "alacritty";
      menu     = "dmenu_path | dmenu | xargs swaymsg exec --";
      left  = "h"; down = "j"; up = "k"; right = "l";

      input."*" = {
        xkb_layout  = "se";
        xkb_options = "caps:escape";
      };

      # HM generates bindings for modifier+{left,down,up,right} and all workspace
      # bindings automatically. We only add the arrow-key duplicates on top.
      keybindings = lib.mkOptionDefault {
        "${modifier}+Left"        = "focus left";
        "${modifier}+Down"        = "focus down";
        "${modifier}+Up"          = "focus up";
        "${modifier}+Right"       = "focus right";
        "${modifier}+Shift+Left"  = "move left";
        "${modifier}+Shift+Down"  = "move down";
        "${modifier}+Shift+Up"    = "move up";
        "${modifier}+Shift+Right" = "move right";
      };

      modes.resize = {
        h      = "resize shrink width 10px";
        j      = "resize grow height 10px";
        k      = "resize shrink height 10px";
        l      = "resize grow width 10px";
        Left   = "resize shrink width 10px";
        Down   = "resize grow height 10px";
        Up     = "resize shrink height 10px";
        Right  = "resize grow width 10px";
        Return = "mode default";
        Escape = "mode default";
      };

      bars = [{
        position      = "top";
        statusCommand = "while date +'%Y-%m-%d %l:%M:%S %p'; do sleep 1; done";
        colors = {
          statusline        = "#ffffff";
          background        = "#323232";
          inactiveWorkspace = { border = "#32323200"; background = "#32323200"; text = "#5c5c5c"; };
        };
      }];
    };
    extraConfig = ''include /etc/sway/config.d/*'';
  };

  # Hikari — custom config format, no HM module available.
  xdg.configFile."hikari" = {
    source    = ../dotconf/hikari;
    recursive = true;
  };
}
