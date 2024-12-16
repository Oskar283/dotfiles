-- Enable syntax highlighting
vim.cmd('syntax on')

-- Options
vim.opt.laststatus = 2             -- Always show statusline
vim.opt.splitright = true          -- Open vsplits to the right
vim.opt.splitbelow = true          -- Open splits below
vim.opt.autoread = true            -- Auto-reload files changed externally
vim.opt.number = true              -- Line numbers
vim.opt.confirm = true             -- Ask to save changes on quit
vim.opt.visualbell = true          -- Use visual indicator instead of sound
vim.opt.cmdheight = 2              -- Command line height
vim.opt.ignorecase = true          -- Case-insensitive search
vim.opt.smartcase = true           -- Case-sensitive if search includes uppercase
vim.opt.incsearch = true           -- Incremental search
vim.opt.wildmenu = true            -- Enhanced command-line completion
vim.opt.history = 1000             -- Command history limit
vim.opt.hidden = true              -- Allow switching unsaved buffers
vim.opt.completeopt = "menuone,noinsert,noselect" -- Completion options
vim.o.termguicolors = true         -- True color support

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
    command = [[%s/\s\+$//e]]
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


-- Start lazy.nvim
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
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
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "neovim/nvim-lspconfig" },
    {
      "hrsh7th/nvim-cmp",
      ---@param opts cmp.ConfigSchema
      opts = function(_, opts)
        local has_words_before = function()
          unpack = unpack or table.unpack
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end

        local cmp = require("cmp")

        opts.mapping = vim.tbl_extend("force", opts.mapping, {
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              -- You could replace select_next_item() with confirm({ select = true }) to get VS Code autocompletion behavior
              cmp.select_next_item()
            elseif vim.snippet.active({ direction = 1 }) then
              vim.schedule(function()
                vim.snippet.jump(1)
              end)
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.snippet.active({ direction = -1 }) then
              vim.schedule(function()
                vim.snippet.jump(-1)
              end)
            else
              fallback()
            end
          end, { "i", "s" }),
        })
      end,
    },
    { "tpope/vim-fugitive" },
    { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },
    {
      "junegunn/fzf.vim",
      dependencies = {
        "junegunn/fzf", -- The fzf binary
        build = function()
          vim.fn"fzf#install" -- Installs fzf binary if not already installed
        end
      },
      cmd = { "GFiles", "GTags", "BTags", "Buffers" }, -- Load lazily on these commands
      keys = {
        { "<F2>", ":GFiles<CR>", "fzf files" },
        { "<F8>", ":Buffers<CR>", "fzf buffers" }
      }
    },
    -- Good-to-have plugins
    {
      "iamcco/markdown-preview.nvim", -- Markdown preview
      build = "cd app && yarn install", -- Build script
    },
    "aklt/plantuml-syntax", -- Syntax highlighting for PlantUML
    "tpope/vim-abolish", -- Switch between snake_case and camelCase
  },
  -- Configure any other settings here. See the documentation for more details.
  -- automatically check for plugin updates
  checker = { enabled = true, notify = false },
})
-- End lazy.nvim

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "clangd" }
})

require("lspconfig").clangd.setup{
  on_attach = function(client, bufnr)
    -- Keymap for Go To Definition
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
    -- Optionally configure other keymaps for LSP
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
  end,

  handlers = {
    ["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
        signs = true,
        update_in_insert = false,
      }
    ),
  },
}

-- Function to show diagnostics in a floating window
local function show_diagnostics()
  local opts = {
    focusable = false,
    close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
    border = 'rounded',
    source = 'always',
    prefix = '',
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

-- Markdown-preview options
vim.g.mkdp_preview_options = {
  mkit = {},
  katex = {},
  maid = {},
  uml = { server = "http://localhost:8080" },
  disable_sync_scroll = 1,
  sync_scroll_type = "middle",
  hide_yaml_meta = 1,
  sequence_diagrams = {},
  flowchart_diagrams = {},
  content_editable = false,
  disable_filename = 0,
  toc = {}
}
vim.g.mkdp_filetypes = { "markdown", "plantuml" }

-- vim-tex options
vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_latexmk = {
  options = {
    "-pdf",
    "-shell-escape",
    "-verbose",
    "-file-line-error",
    "-synctex=1",
    "-interaction=nonstopmode"
  }
}

-- Key mappings
vim.keymap.set("n", "<F1>", "<Nop>")
vim.keymap.set("n", "<F4>", "@:")
vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
vim.keymap.set("v", "<F8>", ":<C-U>grep <C-R><C-W><CR>")

-- vim-terminator bindings
vim.g.terminator_clear_default_mappings = "clear"
vim.g.terminator_split_location = "vertical botright"
vim.g.terminator_split_fraction = 0.3
vim.keymap.set("n", "<F10>", ":TerminatorRunFileInTerminal<CR>")
vim.keymap.set("n", "<F11>", ":TerminatorRunFileInOutputBuffer<CR>")
