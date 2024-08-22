syntax on "Enable syntax highlighting
set backspace=2 "More powerful backspacing
set laststatus=2 "Always show statusline even if only 1 window visible
set splitright "New vsplits are opened to the right
set splitbelow "New splits are opened to the below
set autoread "Suppress warnings when git,etc. changes files on disk.
set noswapfile "Who wants those anyway
set nu "Turn on numbering
set confirm "Ask to save on quit
set visualbell "Use visual instead of sound on error
set mouse-=a "Disable mouse usage
set cmdheight=2 "Increase cmd window height
set notimeout ttimeout ttimeoutlen=200 "Quickly time out on keycodes, but never time out on mappings
set ignorecase "Ignores case when searching. Applies to *,#,gd,/
set smartcase "Search casesensitive when UPPERCASE chars is included in search. Applies only to /
set incsearch "Find the next match as we type the search
set t_Co=256 "Set 256 Vim colors
set wildmode=list:longest "Enable wild menu
set wildmenu "Enable ctrl-n and ctrl-p to scroll thru matches
set wildignore=*.o,*.obj,*/tmp/*,*.so,*~ "Stuff to ignore when tab completing
set history=1000 "Store lots of :cmdline history
set hidden "Allow buffers to go into the background without needing to save
set noconfirm "Do not confirm saving when closing a buffer
set completeopt-=preview "Do not open preview window
set background=light "Yellow Terminal background makes colors bad
set mouse=a "Allow mouse for editing
let mapleader=","

" Enable cursorline position tracking
set cursorline
:highlight clear CursorLine
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
:highlight CursorLineNr ctermbg=blue

autocmd BufWritePre * %s/\s\+$//e "Always trim trailing whitespace on save

let g:is_posix = 1  "Vim's default is archaic bourne shell, bring it up to the 90s.

"Indentation
set shiftwidth=4
set softtabstop=4
set expandtab


" Autoreload init.vim
autocmd! BufWritePost $MYVIMRC source $MYVIMRC | echom "Reloaded $NVIMRC"

"Default load termdebug
packadd termdebug
let g:termdebug_wide=1
"Make Ctrl-d exit terminal insert mode
tnoremap <C-d> <C-\><C-n>

"Automatic Install Plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
"Imo musthaves
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

"Good to have
" No need with coc-clangd
"Plug 'derekwyatt/vim-fswitch' "Quick header switching
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
Plug 'aklt/plantuml-syntax'
Plug 'neoclide/coc.nvim', {'branch': 'release'} "Autocompletion Requires NodeJs
Plug 'github/copilot.vim'
Plug 'tpope/vim-abolish' "Switch between e.g snake_case and camelCase https://stackoverflow.com/questions/5185235/camelcase-to-underscore-in-vim

"Testing
Plug 'puremourning/vimspector'
Plug 'lervag/vimtex'
"Plug 'erietz/vim-terminator', { 'branch': 'main'}
"Plug 'tpope/vim-unimpaired'
"Plug 'tpope/vim-surround'

call plug#end()

" START markdown-preview options
"Config for Markdown-preview, see https://github.com/iamcco/markdown-preview.nvim
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'maid': {},
    \ 'uml': { 'server': 'http://localhost:8080' },
    \ 'disable_sync_scroll': 1,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 0,
    \ 'toc': {}
    \ }

" vim-tex options, https://github.com/lervag/vimtex?tab=readme-ov-file
let g:vimtex_view_method = 'zathura'
let g:vimtex_compiler_latexmk = {
    \ 'options' : [
    \   '-pdf',
    \   '-shell-escape',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
    \}

" recognized filetypes
" these filetypes will have MarkdownPreview... commands
let g:mkdp_filetypes = ['markdown', 'plantuml']

"END markdown-preview options

"Mappings
"nnoremap <silent> gd g<C-]> "if using ctags
"Unmap <F1> to avoid help menu on missclick
map <F1> <Nop>
nmap <F2> :GFiles<CR>
nmap <F4> @:
nmap <F7> :CocCommand clangd.switchSourceHeader<CR>

set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
set grepformat=%f:%l:%c:%m,%f:%l:%m
map <F8> :Buffers<CR>
vnoremap <silent> <F8> :<C-U>grep <C-R><C-W><CR>

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

nmap <leader>rn <Plug>(coc-rename)


"""""CocConfig
" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"


" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

"vim-terminator bindings
let g:terminator_clear_default_mappings="clear"
"nnoremap <silent> <leader>ot :TerminatorOpenTerminal <CR>
"nnoremap <silent> <leader>or :TerminatorStartREPL <CR>
"nnoremap <silent> <leader>rt :TerminatorRunFileInTerminal <CR>
nnoremap <silent> <F10> :TerminatorRunFileInTerminal <CR>
"nnoremap <silent> <leader>rf :TerminatorRunFileInOutputBuffer <CR>
nnoremap <silent> <F11> :TerminatorRunFileInOutputBuffer <CR>
"nnoremap <silent> <leader>rs :TerminatorStopRun <CR>
"nnoremap <leader>rm :TerminatorRunAltCmd <C-R>=terminator#get_run_cmd(fnameescape(expand("%")))<CR>
"nnoremap <silent> <leader>sd :TerminatorSendDelimiterToTerminal<CR>
"vnoremap <silent> <leader>ss :TerminatorSendSelectionToTerminal<CR>
"vnoremap <silent> <leader>rf :TerminatorRunPartOfFileInOutputBuffer<CR>
"vnoremap <silent> <leader>rt :TerminatorRunPartOfFileInTerminal<CR>
let g:terminator_split_location = 'vertical botright'
let g:terminator_split_fraction = 0.3

