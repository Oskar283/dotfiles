# General Neovim options, globals, autocmds, and non-plugin keymaps.
# Plugin-specific keymaps live alongside their plugin in plugins/*.nix.
{ ... }: {

  # ── Editor options (vim.opt.*) ───────────────────────────────────────────
  opts = {
    laststatus    = 2;       # Always show statusline
    splitright    = true;    # Vertical splits open to the right
    splitbelow    = true;    # Horizontal splits open below
    autoread      = true;    # Reload files changed externally
    number        = true;    # Line numbers
    confirm       = true;    # Ask to save on quit
    visualbell    = true;    # Visual indicator instead of beep
    cmdheight     = 2;       # Taller command line
    ignorecase    = true;    # Case-insensitive search
    smartcase     = true;    # … unless search contains uppercase
    incsearch     = true;    # Incremental search
    wildmenu      = true;    # Enhanced command-line completion
    history       = 1000;    # Command history
    hidden        = true;    # Allow switching unsaved buffers
    completeopt   = "menuone,noinsert,noselect";
    termguicolors = false;   # Use terminal colorscheme (no 24-bit RGB)
    background    = "light";
    swapfile      = false;
    cursorline    = true;
    shiftwidth    = 4;
    softtabstop   = 4;
    expandtab     = true;
    updatetime    = 300;     # Trigger CursorHold sooner for diagnostics
    grepprg       = "rg --vimgrep --smart-case --hidden --glob '!.git/*'";
    grepformat    = "%f:%l:%c:%m";
  };

  # ── Global variables (vim.g.*) ───────────────────────────────────────────
  globals = {
    mapleader      = " ";
    maplocalleader = "\\";
    is_posix       = 1;      # POSIX-compatible shell syntax highlighting
    termdebug_wide = 1;      # termdebug uses a wide layout
  };

  # ── Non-plugin keymaps ───────────────────────────────────────────────────
  keymaps = [
    # Disable F1 (default :help — opens accidentally)
    { mode = "n"; key = "<F1>"; action = "<Nop>"; }

    # Repeat last command
    { mode = "n"; key = "<F5>"; action = "@:"; }

    # Quickfix navigation
    { mode = "n"; key = "<F3>"; action = ":cn<CR>"; options.silent = true; }
    { mode = "n"; key = "<F4>"; action = ":cp<CR>"; options.silent = true; }

    # Exit terminal mode
    { mode = "t"; key = "<C-d>"; action = "<C-\\><C-n>"; }
  ];

  # ── Autocmds ─────────────────────────────────────────────────────────────
  autoCmd = [
    # Trim trailing whitespace on every save
    {
      event   = [ "BufWritePre" ];
      pattern = [ "*" ];
      command = "%s/\\s\\+$//e";
    }

    # Cursorline highlight only in the focused window
    {
      event   = [ "WinEnter" ];
      pattern = [ "*" ];
      command = "setlocal cursorline";
    }
    {
      event   = [ "WinLeave" ];
      pattern = [ "*" ];
      command = "setlocal nocursorline";
    }

    # Show floating diagnostics after cursor is still for updatetime ms
    {
      event   = [ "CursorHold" ];
      pattern = [ "*" ];
      callback = {
        __raw = ''
          function()
            vim.diagnostic.open_float(nil, {
              focusable    = false,
              close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
              border       = "rounded",
              source       = "always",
              prefix       = "",
            })
          end
        '';
      };
    }
  ];

  # ── Raw Lua (things without a nixvim DSL option) ─────────────────────────
  extraConfigLua = ''
    -- Load the built-in termdebug debugger adapter
    vim.cmd("packadd termdebug")

    -- Cursorline: number column highlight, no line background
    vim.cmd([[
      highlight clear CursorLine
      highlight CursorLineNr ctermbg=blue
    ]])

    -- :W as a safe alias for :write (avoids accidental visual-range writes)
    vim.api.nvim_create_user_command("W", "write", { desc = "Safe :w alias" })

    -- Visual-mode <F8>: grep the current selection with rg, open quickfix
    -- (Normal-mode <F8> is fzf :Buffers — defined in plugins/fzf.nix)
    vim.keymap.set("v", "<F8>", function()
      vim.cmd('normal! "vy')
      local text = vim.fn.getreg("v")
      if text == "" then return end
      text = vim.fn.escape(text, "\\/.*$^~[]")
      vim.cmd("grep " .. text .. " --")
      vim.cmd("copen")
    end, { noremap = true, silent = true })
  '';
}
