# LSP servers — managed by Nix packages, no Mason.
# blink.cmp provides completion and wires its capabilities into every LSP client.
{ ... }: {

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
        menu.draw.treesitter         = [ "lsp" ];
        documentation = {
          auto_show          = true;
          auto_show_delay_ms = 200;
        };
      };
      sources.default      = [ "lsp" "path" "snippets" "buffer" ];
      fuzzy.implementation = "prefer_rust_with_warning";
    };
  };
}
