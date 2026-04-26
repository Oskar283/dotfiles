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

  # ── Copilot (AI completion source for blink.cmp) ─────────────────────────
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
        hash  = "";
      };
    })
  ];

  # Custom highlight for ghost text
  extraConfigLua = ''
    vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { ctermfg = 8 })
  '';
}
