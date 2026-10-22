# Zellij — canonical NixOS/Home Manager version.
# Brings over the main functionality from the tmux config (tmux.nix):
# large scrollback, explicit wl-copy clipboard (no implicit copying),
# Alt+1..4 tab switching, | / - splits in the tmux mode, and the tmux
# colors (orange focused pane frame, red active tab).
{ pkgs, ... }:
{
  # The config file is managed by home-manager now; replace the previously
  # hand-managed plain file on first activation (one-time migration).
  xdg.configFile."zellij/config.kdl".force = true;

  programs.zellij = {
    enable = true;

    # ── Native HM options ────────────────────────────────────────────────────
    settings = {
      # Scrollback (tmux: history-limit 50000)
      scroll_buffer_size = 50000;

      # Never write to the system clipboard implicitly (tmux: set-clipboard off).
      copy_on_select = false;

      # Explicit copy to the system clipboard (tmux: copy-pipe-and-cancel wl-copy).
      copy_command = "${pkgs.wl-clipboard}/bin/wl-copy";

      theme = "oskarr";
    };
    themes.oskarr = ''
      themes {
        oskarr {
          text_unselected { base 0; background 7; emphasis_0 9; emphasis_1 12; emphasis_2 10; emphasis_3 13; }
          text_selected { base 0; background 15; emphasis_0 9; emphasis_1 12; emphasis_2 10; emphasis_3 13; }
          ribbon_unselected { base 0; background 15; emphasis_0 9; emphasis_1 0; emphasis_2 12; emphasis_3 13; }
          ribbon_selected { base 7; background 1; emphasis_0 7; emphasis_1 7; emphasis_2 7; emphasis_3 7; }
          table_title { base 10; background 7; emphasis_0 9; emphasis_1 12; emphasis_2 10; emphasis_3 13; }
          table_cell_unselected { base 0; background 7; emphasis_0 9; emphasis_1 12; emphasis_2 10; emphasis_3 13; }
          table_cell_selected { base 0; background 15; emphasis_0 9; emphasis_1 12; emphasis_2 10; emphasis_3 13; }
          list_unselected { base 0; background 7; emphasis_0 9; emphasis_1 12; emphasis_2 10; emphasis_3 13; }
          list_selected { base 0; background 15; emphasis_0 9; emphasis_1 12; emphasis_2 10; emphasis_3 13; }
          frame_unselected { base 8; background 7; emphasis_0 11; emphasis_1 12; emphasis_2 13; emphasis_3 9; }
          frame_selected { base 11; background 7; emphasis_0 11; emphasis_1 12; emphasis_2 13; emphasis_3 9; }
          frame_highlight { base 11; background 7; emphasis_0 14; emphasis_1 13; emphasis_2 11; emphasis_3 11; }
          exit_code_success { base 10; background 7; emphasis_0 14; emphasis_1 7; emphasis_2 13; emphasis_3 12; }
          exit_code_error { base 1; background 7; emphasis_0 11; emphasis_1 9; emphasis_2 8; emphasis_3 13; }
          multiplayer_user_colors {
            player_1 5; player_2 4; player_3 6; player_4 3; player_5 9
            player_6 1; player_7 2; player_8 8; player_9 12; player_10 13
          }
        }
      }
    '';

    # ── Raw KDL for keybinds (not expressible via settings) ─────────────────
    # Carries over the existing keybinds setup (including the tmux prefix mode),
    # plus the tmux-inspired additions:
    #   - scroll mode: y copies the selection to the system clipboard and exits
    #     (tmux: copy-pipe-and-cancel in copy-mode-vi)
    #   - Alt+1..4 jump to tabs 1-4 in all modes (tmux: M-1..M-4 without prefix)
    #   - tmux mode: | and - split right / down (tmux: | and - with prefix)
    #   - session mode is Ctrl-E, not the default Ctrl-O, which stays free
    #     for nvim (one jump back / one command in insert mode)
    extraConfig = ''
      keybinds clear-defaults=true {
          locked {
              bind "Ctrl g" { SwitchToMode "normal"; }
          }
          pane {
              bind "left" { MoveFocus "left"; }
              bind "down" { MoveFocus "down"; }
              bind "up" { MoveFocus "up"; }
              bind "right" { MoveFocus "right"; }
              bind "c" { SwitchToMode "renamepane"; PaneNameInput 0; }
              bind "d" { NewPane "down"; SwitchToMode "normal"; }
              bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "normal"; }
              bind "f" { ToggleFocusFullscreen; SwitchToMode "normal"; }
              bind "h" { MoveFocus "left"; }
              bind "i" { TogglePanePinned; SwitchToMode "normal"; }
              bind "j" { MoveFocus "down"; }
              bind "k" { MoveFocus "up"; }
              bind "l" { MoveFocus "right"; }
              bind "n" { NewPane; SwitchToMode "normal"; }
              bind "p" { SwitchFocus; }
              bind "Ctrl p" { SwitchToMode "normal"; }
              bind "r" { NewPane "right"; SwitchToMode "normal"; }
              bind "s" { NewPane "stacked"; SwitchToMode "normal"; }
              bind "w" { ToggleFloatingPanes; SwitchToMode "normal"; }
              bind "z" { TogglePaneFrames; SwitchToMode "normal"; }
          }
          tab {
              bind "left" { GoToPreviousTab; }
              bind "down" { GoToNextTab; }
              bind "up" { GoToPreviousTab; }
              bind "right" { GoToNextTab; }
              bind "1" { GoToTab 1; SwitchToMode "normal"; }
              bind "2" { GoToTab 2; SwitchToMode "normal"; }
              bind "3" { GoToTab 3; SwitchToMode "normal"; }
              bind "4" { GoToTab 4; SwitchToMode "normal"; }
              bind "5" { GoToTab 5; SwitchToMode "normal"; }
              bind "6" { GoToTab 6; SwitchToMode "normal"; }
              bind "7" { GoToTab 7; SwitchToMode "normal"; }
              bind "8" { GoToTab 8; SwitchToMode "normal"; }
              bind "9" { GoToTab 9; SwitchToMode "normal"; }
              bind "[" { BreakPaneLeft; SwitchToMode "normal"; }
              bind "]" { BreakPaneRight; SwitchToMode "normal"; }
              bind "b" { BreakPane; SwitchToMode "normal"; }
              bind "h" { GoToPreviousTab; }
              bind "j" { GoToNextTab; }
              bind "k" { GoToPreviousTab; }
              bind "l" { GoToNextTab; }
              bind "n" { NewTab; SwitchToMode "normal"; }
              bind "r" { SwitchToMode "renametab"; TabNameInput 0; }
              bind "s" { ToggleActiveSyncTab; SwitchToMode "normal"; }
              bind "Ctrl t" { SwitchToMode "normal"; }
              bind "x" { CloseTab; SwitchToMode "normal"; }
              bind "tab" { ToggleTab; }
          }
          resize {
              bind "left" { Resize "Increase left"; }
              bind "down" { Resize "Increase down"; }
              bind "up" { Resize "Increase up"; }
              bind "right" { Resize "Increase right"; }
              bind "+" { Resize "Increase"; }
              bind "-" { Resize "Decrease"; }
              bind "=" { Resize "Increase"; }
              bind "H" { Resize "Decrease left"; }
              bind "J" { Resize "Decrease down"; }
              bind "K" { Resize "Decrease up"; }
              bind "L" { Resize "Decrease right"; }
              bind "h" { Resize "Increase left"; }
              bind "j" { Resize "Increase down"; }
              bind "k" { Resize "Increase up"; }
              bind "l" { Resize "Increase right"; }
              bind "Ctrl n" { SwitchToMode "normal"; }
          }
          move {
              bind "left" { MovePane "left"; }
              bind "down" { MovePane "down"; }
              bind "up" { MovePane "up"; }
              bind "right" { MovePane "right"; }
              bind "h" { MovePane "left"; }
              bind "Ctrl h" { SwitchToMode "normal"; }
              bind "j" { MovePane "down"; }
              bind "k" { MovePane "up"; }
              bind "l" { MovePane "right"; }
              bind "n" { MovePane; }
              bind "p" { MovePaneBackwards; }
              bind "tab" { MovePane; }
          }
          scroll {
              bind "e" { EditScrollback; SwitchToMode "normal"; }
              bind "s" { SwitchToMode "entersearch"; SearchInput 0; }
              bind "y" { Copy; SwitchToMode "normal"; }
          }
          search {
              bind "c" { SearchToggleOption "CaseSensitivity"; }
              bind "n" { Search "down"; }
              bind "o" { SearchToggleOption "WholeWord"; }
              bind "p" { Search "up"; }
              bind "w" { SearchToggleOption "Wrap"; }
          }
          session {
              bind "a" {
                  LaunchOrFocusPlugin "zellij:about" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
              }
              bind "c" {
                  LaunchOrFocusPlugin "configuration" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
              }
              bind "Ctrl e" { SwitchToMode "normal"; }
              bind "p" {
                  LaunchOrFocusPlugin "plugin-manager" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
              }
              bind "s" {
                  LaunchOrFocusPlugin "zellij:share" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
              }
              bind "w" {
                  LaunchOrFocusPlugin "session-manager" {
                      floating true
                      move_to_focused_tab true
                  }
                  SwitchToMode "normal"
              }
          }
          shared_except "locked" {
              bind "Alt left" { MoveFocusOrTab "left"; }
              bind "Alt down" { MoveFocus "down"; }
              bind "Alt up" { MoveFocus "up"; }
              bind "Alt right" { MoveFocusOrTab "right"; }
              bind "Alt +" { Resize "Increase"; }
              bind "Alt -" { Resize "Decrease"; }
              bind "Alt =" { Resize "Increase"; }
              bind "Alt [" { PreviousSwapLayout; }
              bind "Alt ]" { NextSwapLayout; }
              bind "Alt 1" { GoToTab 1; }
              bind "Alt 2" { GoToTab 2; }
              bind "Alt 3" { GoToTab 3; }
              bind "Alt 4" { GoToTab 4; }
              bind "Alt f" { ToggleFloatingPanes; }
              bind "Ctrl g" { SwitchToMode "locked"; }
              bind "Alt h" { MoveFocusOrTab "left"; }
              bind "Alt i" { MoveTab "left"; }
              bind "Alt j" { MoveFocus "down"; }
              bind "Alt k" { MoveFocus "up"; }
              bind "Alt l" { MoveFocusOrTab "right"; }
              bind "Alt n" { NewPane; }
              bind "Alt o" { MoveTab "right"; }
              bind "Alt p" { TogglePaneInGroup; }
              bind "Alt Shift p" { ToggleGroupMarking; }
          }
          shared_except "locked" "move" {
              bind "Ctrl h" { SwitchToMode "move"; }
          }
          shared_except "locked" "session" {
              bind "Ctrl e" { SwitchToMode "session"; }
          }
          shared_except "locked" "scroll" "search" "tmux" {
              bind "Ctrl b" { SwitchToMode "tmux"; }
          }
          shared_except "locked" "scroll" "search" {
              bind "Ctrl s" { SwitchToMode "scroll"; }
          }
          shared_except "locked" "tab" {
              bind "Ctrl t" { SwitchToMode "tab"; }
          }
          shared_except "locked" "pane" {
              bind "Ctrl p" { SwitchToMode "pane"; }
          }
          shared_except "locked" "resize" {
              bind "Ctrl n" { SwitchToMode "resize"; }
          }
          shared_except "normal" "locked" "entersearch" {
              bind "enter" { SwitchToMode "normal"; }
          }
          shared_except "normal" "locked" "entersearch" "renametab" "renamepane" {
              bind "esc" { SwitchToMode "normal"; }
          }
          shared_among "pane" "tmux" {
              bind "x" { CloseFocus; SwitchToMode "normal"; }
          }
          shared_among "scroll" "search" {
              bind "PageDown" { PageScrollDown; }
              bind "PageUp" { PageScrollUp; }
              bind "left" { PageScrollUp; }
              bind "down" { ScrollDown; }
              bind "up" { ScrollUp; }
              bind "right" { PageScrollDown; }
              bind "Ctrl b" { PageScrollUp; }
              bind "Ctrl c" { ScrollToBottom; SwitchToMode "normal"; }
              bind "d" { HalfPageScrollDown; }
              bind "Ctrl f" { PageScrollDown; }
              bind "h" { PageScrollUp; }
              bind "j" { ScrollDown; }
              bind "k" { ScrollUp; }
              bind "l" { PageScrollDown; }
              bind "Ctrl s" { SwitchToMode "normal"; }
              bind "u" { HalfPageScrollUp; }
          }
          entersearch {
              bind "Ctrl c" { SwitchToMode "scroll"; }
              bind "esc" { SwitchToMode "scroll"; }
              bind "enter" { SwitchToMode "search"; }
          }
          renametab {
              bind "esc" { UndoRenameTab; SwitchToMode "tab"; }
          }
          shared_among "renametab" "renamepane" {
              bind "Ctrl c" { SwitchToMode "normal"; }
          }
          renamepane {
              bind "esc" { UndoRenamePane; SwitchToMode "pane"; }
          }
          shared_among "session" "tmux" {
              bind "d" { Detach; }
          }
          tmux {
              bind "left" { MoveFocus "left"; SwitchToMode "normal"; }
              bind "down" { MoveFocus "down"; SwitchToMode "normal"; }
              bind "up" { MoveFocus "up"; SwitchToMode "normal"; }
              bind "right" { MoveFocus "right"; SwitchToMode "normal"; }
              bind "space" { NextSwapLayout; }
              bind "\"" { NewPane "down"; SwitchToMode "normal"; }
              bind "%" { NewPane "right"; SwitchToMode "normal"; }
              bind "|" { NewPane "right"; SwitchToMode "normal"; }
              bind "-" { NewPane "down"; SwitchToMode "normal"; }
              bind "," { SwitchToMode "renametab"; }
              bind "[" { SwitchToMode "scroll"; }
              bind "Ctrl b" { Write 2; SwitchToMode "normal"; }
              bind "c" { NewTab; SwitchToMode "normal"; }
              bind "h" { MoveFocus "left"; SwitchToMode "normal"; }
              bind "j" { MoveFocus "down"; SwitchToMode "normal"; }
              bind "k" { MoveFocus "up"; SwitchToMode "normal"; }
              bind "l" { MoveFocus "right"; SwitchToMode "normal"; }
              bind "n" { GoToNextTab; SwitchToMode "normal"; }
              bind "o" { FocusNextPane; }
              bind "p" { GoToPreviousTab; SwitchToMode "normal"; }
              bind "z" { ToggleFocusFullscreen; SwitchToMode "normal"; }
          }
      }
      plugins {
          about location="zellij:about"
          compact-bar location="zellij:compact-bar"
          configuration location="zellij:configuration"
          filepicker location="zellij:strider" {
              cwd "/"
          }
          plugin-manager location="zellij:plugin-manager"
          session-manager location="zellij:session-manager"
          status-bar location="zellij:status-bar"
          strider location="zellij:strider"
          tab-bar location="zellij:tab-bar"
          welcome-screen location="zellij:session-manager" {
              welcome_screen true
          }
      }
      web_client {
          font "monospace"
      }
    '';
  };
}
