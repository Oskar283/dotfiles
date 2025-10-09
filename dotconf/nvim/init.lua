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
vim.o.termguicolors = false        -- Ensures teriminal colorscheme. Without this i get something else
vim.o.background = "light"         -- Set background light
vim.o.swapfile = false             -- No swapfiles

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


-- Avoid partial writes when accidentally highlithing before :w
vim.api.nvim_create_user_command('W', 'write', {})


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
        "williamboman/mason-lspconfig.nvim"
      },
      config = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

        require('mason').setup()
        local mason_lspconfig = require('mason-lspconfig')
        mason_lspconfig.setup {
          ensure_installed = { "pyright", "clangd" }
        }
        require("lspconfig").pyright.setup {
          capabilities = capabilities,
	    on_attach = function(client, bufnr)
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', { noremap = true, silent = true })
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', { noremap = true, silent = true })
            vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
          end,
        }
        require("lspconfig").clangd.setup {
          cmd = { "clangd", "--compile-commands-dir=/repo/src/compile_commands.json"},
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
      end,
    },
{ "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip"
  },
  config = function()
    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    local cmp = require('cmp')
    local luasnip = require('luasnip')

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end
      },
      completion = {
        autocomplete = { cmp.TriggerEvent.InsertEnter, cmp.TriggerEvent.TextChanged },
      },
      mapping = cmp.mapping.preset.insert ({
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
        ["<CR>"] = cmp.mapping.confirm({ select=true }),
      }),
      sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
      }
    })
  end
},
    {
      "tpope/vim-fugitive",
      cmd = { "G", "Git", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse", "GRemove", "GRename", "Glgrep", "Gedit" },
    },
        {
      "FabijanZulj/blame.nvim",
      keys = {
        { "gb", function()
            require("blame").toggle()
          end,
          mode = "n", noremap = true, silent = true
        }
      },
      config = function()
        require("blame").setup()
      end,
    },

    {
      "junegunn/fzf.vim",
      dependencies = {
        "junegunn/fzf", -- The fzf binary
        build = function()
          vim.fn["fzf#install"]()
        end
      },
      cmd = { "GFiles", "GTags", "BTags", "Buffers",}, -- Load lazily on these commands
      keys = {
        { "<F2>", ":GFiles<CR>", "fzf files" },
        { "<F8>", ":Buffers<CR>", "fzf buffers" }
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
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require'nvim-treesitter.configs'.setup{
        ensure_installed = { "lua", "python", "c", "cpp" },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      }
    end
  },
    {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-tree").setup({
       update_focused_file = {
        enable = true,
        update_root = true, -- set to false if you don’t want cwd to follow file
      },
        view = { width = 30, side = "left", },
      view = {
          width = 30,
          side = "left",
        },
    renderer = {
        highlight_opened_files = "name",
        highlight_git = true,
        full_name = true,
        icons = { show = { file = false, folder = false, git = false } },
      },
        git = { enable = false },
      })
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
    end
  }
},
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { },
  -- automatically check for plugin updates
  checker = { enabled = true, notify = false },

})
-- End lazy.nvim


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
