# Desktop / WM configuration.
# Note: enable = true installs the packages — harmless on the server but unused.
# Hikari has no HM module and uses a custom config format, so it stays as source.
{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./alacritty.nix
    ./zellij.nix
  ];

  # Ensure Ubuntu launcher sees Nix desktop entries.
  targets.genericLinux.enable = true;
  xdg.enable = true;

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
      menu = "dmenu_path | dmenu | xargs swaymsg exec --";
      left = "h";
      down = "j";
      up = "k";
      right = "l";

      input."*" = {
        xkb_layout = "se";
        xkb_options = "caps:escape";
      };

      # HM generates bindings for modifier+{left,down,up,right} and all workspace
      # bindings automatically. We only add the arrow-key duplicates on top.
      keybindings = lib.mkOptionDefault {
        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";
      };

      modes.resize = {
        h = "resize shrink width 10px";
        j = "resize grow height 10px";
        k = "resize shrink height 10px";
        l = "resize grow width 10px";
        Left = "resize shrink width 10px";
        Down = "resize grow height 10px";
        Up = "resize shrink height 10px";
        Right = "resize grow width 10px";
        Return = "mode default";
        Escape = "mode default";
      };

      bars = [
        {
          position = "top";
          statusCommand = "while date +'%Y-%m-%d %l:%M:%S %p'; do sleep 1; done";
          colors = {
            statusline = "#ffffff";
            background = "#323232";
            inactiveWorkspace = {
              border = "#32323200";
              background = "#32323200";
              text = "#5c5c5c";
            };
          };
        }
      ];
    };
    extraConfig = "include /etc/sway/config.d/*";
  };
}
