# LSP servers — managed by Nix packages, no Mason.
# blink.cmp provides completion and wires its capabilities into every LSP client.
# copilot.lua + blink-copilot provide AI-powered ghost-text completions.
{ pkgs, ... }: {

  plugins.lsp = {
    enable = true;

    # Let blink.cmp advertise its extra capabilities to every LSP server.
    capabilities = ''
      capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
    '';

    servers = {
      # Lua — sumneko lua-language-server
      lua_ls.enable = true;

      # C / C++
      clangd = {
        enable      = true;
        filetypes   = [ "c" "cpp" "objc" "objcpp" ];
        rootMarkers = [ "compile_commands.json" "compile_flags.txt" ".git" ];
      };

      # Python
      pyright = {
        enable      = true;
        filetypes   = [ "python" ];
        rootMarkers = [ ".git" "pyproject.toml" "setup.py" "setup.cfg" "requirements.txt" ];
      };
    };
  };

  # ── Completion (blink.cmp) ───────────────────────────────────────────────
  plugins.blink-cmp = {
    enable = true;
    settings = {
      keymap.preset = "cmdline";
      completion = {
        accept.auto_brackets.enabled = true;
        ghost_text.enabled           = true;
        trigger.show_on_accept_on_trigger_character = true;
        menu.draw.treesitter         = [ "lsp" ];
        documentation = {
          auto_show          = true;
          auto_show_delay_ms = 200;
        };
      };
      sources = {
        default = [ "lsp" "path" "snippets" "buffer" "copilot" ];
        providers.copilot = {
          name   = "copilot";
          module = "blink-copilot";
          async  = true;
          opts.ghost_text = true;
        };
      };
      fuzzy.implementation = "prefer_rust_with_warning";
    };
  };

  # ── CodeCompanion (AI chat + inline assistant via Copilot) ───────────────
  plugins.codecompanion = {
    enable = true;
    settings = {
      adapters.copilot.__raw = ''
        function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = { model = { default = "claude-sonnet-4-6" } }
          })
        end
      '';
      strategies = {
        chat.adapter   = "copilot";
        inline.adapter = "copilot";
        agent.adapter  = "copilot";
      };
    };
  };

  keymaps = [
    { mode = [ "n" "x" ]; key = "<leader>cc"; action = "<cmd>CodeCompanionChat Toggle<CR>"; options = { desc = "CodeCompanion chat";    silent = true; }; }
    { mode = [ "n" "x" ]; key = "<leader>ca"; action = "<cmd>CodeCompanionActions<CR>";     options = { desc = "CodeCompanion actions"; silent = true; }; }
    { mode = [ "n" "x" ]; key = "<leader>ci"; action = "<cmd>CodeCompanion<CR>";            options = { desc = "CodeCompanion inline";  silent = true; }; }
  ];

  # ── Copilot (ghost-text completions) ─────────────────────────────────────
  plugins.copilot-lua = {
    enable = true;
    settings = {
      suggestion.enabled = false;
      panel.enabled      = false;
    };
  };

  # blink-copilot bridges copilot.lua into blink.cmp as a source.
  # No nixvim DSL module; use extraPlugins.
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      name = "blink-copilot";
      src  = pkgs.fetchFromGitHub {
        owner = "fang2hou";
        repo  = "blink-copilot";
        rev   = "main";
        hash  = "sha256-cDvbUmnFZbPmU/HPISNV8zJV8WsH3COl3nGqgT5CbVQ=";
      };
    })
  ];

  # Custom highlight for ghost text + clangd auto-restart on compile_commands.json changes
  extraConfigLua = ''
    vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { ctermfg = 8 })

    -- Watch the git root for changes to compile_commands.json and restart clangd.
    -- This means running compile_commands_pap in the terminal automatically
    -- refreshes clangd diagnostics without a manual :LspRestart.
    local function watch_compile_commands()
      local uv = vim.uv or vim.loop
      local root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
      if not root or root == "" then return end

      local handle = uv.new_fs_event()
      if not handle then return end

      handle:start(root, { recursive = false }, vim.schedule_wrap(function(err, filename)
        if err or not filename then return end
        if filename == "compile_commands.json" then
          vim.notify("compile_commands.json updated — restarting clangd", vim.log.levels.INFO)
          vim.cmd("LspRestart clangd")
        end
      end))
    end

    vim.api.nvim_create_autocmd("VimEnter", {
      once     = true,
      callback = watch_compile_commands,
    })
  '';
}
