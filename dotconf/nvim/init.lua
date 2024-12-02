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
      -- Must-have plugins
      {
        "tpope/vim-fugitive",                -- Git integration
      },
      {
        "junegunn/fzf",                      -- Fuzzy file finder-
        build = "./install --all",  -- This runs the fzf installer
      },

      -- Good-to-have plugins
      {
        "iamcco/markdown-preview.nvim",      -- Markdown preview
        build = "cd app && yarn install",    -- Build script
      },
      "aklt/plantuml-syntax",               -- Syntax highlighting for PlantUML
      "tpope/vim-abolish",                  -- Switch between snake_case and camelCase
--      "bazelbuild/vim-bazel",               -- Bazel build system support

      -- Testing plugins
      "puremourning/vimspector",            -- Debugger interface
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})
-- End lazy.nvim

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
vim.keymap.set("n", "<F2>", ":GFiles<CR>")
vim.keymap.set("n", "<F4>", "@:")
vim.keymap.set("n", "<F7>", ":CocCommand clangd.switchSourceHeader<CR>")
vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
vim.keymap.set("n", "<F8>", ":Buffers<CR>")
vim.keymap.set("v", "<F8>", ":<C-U>grep <C-R><C-W><CR>")
vim.keymap.set("n", "gd", "<Plug>(coc-definition)")
vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)")
vim.keymap.set("n", "gi", "<Plug>(coc-implementation)")
vim.keymap.set("n", "gr", "<Plug>(coc-references)")
vim.keymap.set("n", "<leader>rn", "<Plug>(coc-rename)")

-- vim-terminator bindings
vim.g.terminator_clear_default_mappings = "clear"
vim.g.terminator_split_location = "vertical botright"
vim.g.terminator_split_fraction = 0.3
vim.keymap.set("n", "<F10>", ":TerminatorRunFileInTerminal<CR>")
vim.keymap.set("n", "<F11>", ":TerminatorRunFileInOutputBuffer<CR>")

