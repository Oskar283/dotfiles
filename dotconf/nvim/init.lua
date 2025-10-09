-- Options
vim.opt.laststatus = 2 -- Always show statusline
vim.opt.splitright = true -- Open vsplits to the right
vim.opt.splitbelow = true -- Open splits below
vim.opt.autoread = true -- Auto-reload files changed externally
vim.opt.number = true -- Line numbers
vim.opt.confirm = true -- Ask to save changes on quit
vim.opt.visualbell = true -- Use visual indicator instead of sound
vim.opt.cmdheight = 2 -- Command line height
vim.opt.ignorecase = true -- Case-insensitive search
vim.opt.smartcase = true -- Case-sensitive if search includes uppercase
vim.opt.incsearch = true -- Incremental search
vim.opt.wildmenu = true -- Enhanced command-line completion
vim.opt.history = 1000 -- Command history limit
vim.opt.hidden = true -- Allow switching unsaved buffers
vim.opt.completeopt = "menuone,noinsert,noselect" -- Completion options
vim.o.termguicolors = false -- Ensures teriminal colorscheme. Without this i get something else
vim.o.background = "light" -- Set background light
vim.o.swapfile = false -- No swapfiles

-- Cursorline
vim.opt.cursorline = true
vim.cmd([[
  highlight clear CursorLine
  autocmd WinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
  highlight CursorLineNr ctermbg=blue
]])

-- Trim trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Use POSIX shell
vim.g.is_posix = 1

-- Indentation
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

-- Default load termdebug
vim.cmd("packadd termdebug")
vim.g.termdebug_wide = 1

-- Terminal key mappings
vim.keymap.set("t", "<C-d>", "<C-\\><C-n>")

-- Avoid partial writes when accidentally highlithing before :w
vim.api.nvim_create_user_command("W", "write", {})

-- Start lazy.nvim
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out =
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  -- Follows many of the steps on https://www.playfulpython.com/configuring-neovim-as-a-python-ide/
  spec = {
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
      },
      config = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

        require("mason").setup()
        local mason_lspconfig = require("mason-lspconfig")
        mason_lspconfig.setup({
          ensure_installed = { "pyright", "clangd" },
        })

        -- Pyright
        vim.lsp.config("pyright", {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            local opts = { silent = true, buffer = bufnr }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "<C-LeftMouse>", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          end,
        })
        vim.lsp.enable("pyright")

        -- Clangd
        vim.lsp.config("clangd", {
          cmd = { "clangd", "--compile-commands-dir=/repo/src" },
          on_attach = function(client, bufnr)
            local opts = { silent = true, buffer = bufnr }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", "<C-LeftMouse>", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          end,
          handlers = {
            ["textDocument/publishDiagnostics"] = vim.lsp.with(
              vim.lsp.diagnostic.on_publish_diagnostics,
              {
                virtual_text = false,
                signs = true,
                update_in_insert = false,
              }
            ),
          },
        })
        vim.lsp.enable("clangd")

        -- Custom Bazel LSP
        vim.lsp.config("bazel_lsp", {
          cmd = { "bazel-lsp", "--bazel", "/repo/src/development/src/bazel.py" },
          filetypes = { "starlark", "bazel", "bzl" },
          root_dir = vim.fs.root(0, { "WORKSPACE", "WORKSPACE.bazel", "MODULE.bazel" }),
          capabilities = capabilities,
        })
        vim.lsp.enable("bazel_lsp")
      end,
    },
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
      },
      config = function()
        local has_words_before = function()
          unpack = unpack or table.unpack
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0
            and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s")
              == nil
        end

        local cmp = require("cmp")
        local luasnip = require("luasnip")

        cmp.setup({
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          completion = {
            autocomplete = { cmp.TriggerEvent.InsertEnter, cmp.TriggerEvent.TextChanged },
          },
          mapping = cmp.mapping.preset.insert({
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              elseif has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<s-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<c-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
          }),
          sources = {
            { name = "nvim_lsp" },
            { name = "luasnip" },
          },
        })
      end,
    },
    {
      "tpope/vim-fugitive",
      cmd = {
        "G",
        "Git",
        "Gdiffsplit",
        "Gread",
        "Gwrite",
        "Ggrep",
        "GMove",
        "GDelete",
        "GBrowse",
        "GRemove",
        "GRename",
        "Glgrep",
        "Gedit",
      },
    },

    {
      "junegunn/fzf.vim",
      dependencies = {
        "junegunn/fzf", -- The fzf binary
        build = function()
          vim.fn["fzf#install"]()
        end,
      },
      cmd = { "GFiles", "GTags", "BTags", "Buffers" }, -- Load lazily on these commands
      keys = {
        { "<F2>", ":GFiles<CR>", "fzf files" },
        { "<F8>", ":Buffers<CR>", "fzf buffers" },
      },
      config = function()
        vim.cmd([[
          command! GFiles call fzf#vim#gitfiles('', {'options': '--no-preview'})
        ]])

        vim.cmd([[
          command! Buffers call fzf#vim#buffers('', {'options': '--no-preview'})
        ]])
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      branch = "master",
      lazy = false,
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "lua", "python", "c", "cpp", "markdown" },
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
          },
        })
      end,
    },
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = "nvim-tree/nvim-web-devicons",
      config = function()
        require("nvim-tree").setup({
          update_focused_file = {
            enable = true,
          },
          view = { width = 50, side = "left" },
          renderer = {
            highlight_opened_files = "name",
            highlight_git = true,
            full_name = true,
            icons = { show = { file = false, folder = false, git = false } },
          },
          git = { enable = false },
        })
        vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
      end,
    },
    {
      "zbirenbaum/copilot.lua",
      dependencies = {
        "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
      },
      cmd = "Copilot",
      event = "InsertEnter",
      config = function()
        require("copilot").setup({
          suggestion = { enabled = true, auto_trigger = true },
          panel = { enabled = false },
          -- optionally other settings
        })
      end,
    },
    {
      "zbirenbaum/copilot-cmp",
      dependencies = { "zbirenbaum/copilot.lua" },
      config = function()
        require("copilot_cmp").setup()
      end,
    },
    {
      "stevearc/conform.nvim",
      opts = {
        formatters = {
          stylua = {
            args = {
              "--config-path",
              vim.fn.expand("~/.stylua.toml"),
              "-",
            },
          },
        },
        formatters_by_ft = {
          python = { "black" },
          javascript = { "prettier" },
          markdown = { "prettier" },
          lua = { "stylua" },
          json = { "prettier" },
          cpp = { "clang_format" },
          bzl = { "buildifier" },
        },
        format_on_save = function(bufnr)
          return { timeout_ms = 500, lsp_fallback = true }
        end,
      },
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = {},
  -- automatically check for plugin updates
  checker = { enabled = true, notify = false },
})
-- End lazy.nvim

-- Function to show diagnostics in a floating window
local function show_diagnostics()
  local opts = {
    focusable = false,
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    border = "rounded",
    source = "always",
    prefix = "",
  }
  vim.diagnostic.open_float(nil, opts)
end

-- Keybinding to show diagnostics on hover
vim.api.nvim_create_autocmd("CursorHold", {
  buffer = 0,
  callback = show_diagnostics,
})

-- Show diagnostics after 300ms
vim.o.updatetime = 300

-- vim-tex options
vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_latexmk = {
  options = {
    "-pdf",
    "-shell-escape",
    "-verbose",
    "-file-line-error",
    "-synctex=1",
    "-interaction=nonstopmode",
  },
}

-- Key mappings
vim.keymap.set("n", "<F1>", "<Nop>")
vim.keymap.set("n", "<F5>", "@:")
vim.opt.grepprg = "rg --vimgrep --smart-case --hidden --glob '!.git/*'"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.keymap.set("v", "<F8>", function()
  -- yank visual selection to a temporary register
  vim.cmd('normal! "vy')
  local text = vim.fn.getreg("v")
  if text == "" then
    return
  end
  text = vim.fn.escape(text, "\\/.*$^~[]")
  vim.cmd("grep " .. text .. " --")
  vim.cmd("copen")
end, { noremap = true, silent = true })

-- vim-terminator bindings
vim.g.terminator_clear_default_mappings = "clear"
vim.g.terminator_split_location = "vertical botright"
vim.g.terminator_split_fraction = 0.3
vim.keymap.set("n", "<F3>", ":cn<CR>")
vim.keymap.set("n", "<F4>", ":cp<CR>")
vim.keymap.set("n", "<F10>", ":TerminatorRunFileInTerminal<CR>")
vim.keymap.set("n", "<F11>", ":TerminatorRunFileInOutputBuffer<CR>")
