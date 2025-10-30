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
  spec = {
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "saghen/blink.cmp",
      },

      lazy = false,
      opts = {
        servers = {
          lua_ls = {},
          clangd = {
            cmd = { "clangd" },
            filetypes = { "c", "cpp", "objc", "objcpp" },
            root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
          },
          pyright = {
            filetypes = { "python" },
            root_pattern_files = {
              ".git",
              "pyproject.toml",
              "setup.py",
              "setup.cfg",
              "requirements.txt",
            },
          },
        },
      },

      config = function(_, opts)
        local capabilities = vim.lsp.protocol.make_client_capabilities()

        require("mason").setup()
        local mason_lspconfig = require("mason-lspconfig")
        mason_lspconfig.setup({
          ensure_installed = { "pyright", "clangd" },
        })
        local blink = require("blink.cmp")

        for server, config in pairs(opts.servers) do
          config.capabilities = blink.get_lsp_capabilities(config.capabilities)

          vim.lsp.config(server, config)
          vim.lsp.enable(server)
        end
      end,
    },
    {
      "saghen/blink.cmp",
      dependencies = { "rafamadriz/friendly-snippets", "fang2hou/blink-copilot" },
      version = "1.*",
      opts = {
        keymap = { preset = "cmdline" },
        completion = {
          accept = {
            auto_brackets = { enabled = true },
          },
          menu = {
            draw = {
              treesitter = { "lsp" },
            },
          },
          documentation = { auto_show = true, auto_show_delay_ms = 200 },
        },
        sources = {
          default = { "lsp", "path", "snippets", "buffer", "copilot" },
          providers = {
            copilot = {
              name = "copilot",
              module = "blink-copilot",
              score_offset = -4,
              async = true,
            },
          },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
      },
      opts_extend = { "sources.default" },
    },
    {
      "tpope/vim-fugitive",
      cmd = {
        "G",
        "Git",
        "Gwrite",
        "Ggrep",
        "GMove",
        "GDelete",
        "GBrowse",
        "GRemove",
        "GRename",
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
