# Fzf — fuzzy finder with keybindings (Ctrl-R, Ctrl-T, Alt-C).
# programs.fzf.enable wires keybindings into the shell automatically.
# The fzf binary is also available as a system package (configuration.nix).
{ ... }: {
  programs.fzf.enable = true;
}
