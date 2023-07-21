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
set mouse=a "Enable mouse usage
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
set background=light "Guarantee light background

autocmd BufWritePre * %s/\s\+$//e "Always trim trailing whitespace on save

let g:is_posix = 1  "Vim's default is archaic bourne shell, bring it up to the 90s.

"Directory explorer Netrw
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25

"Indentation
set shiftwidth=4
set softtabstop=4
set expandtab

"Easy access commandLine
nnoremap ; :
nnoremap q; q:
vnoremap ; :

"Easy git grep in visual selection. TODO: Find a good place to put this
" -- :/ added at the end to alwyas search from root_level of git repo
command! -nargs=+ Silent
\   execute 'silent <args>'
\ | redraw!
vnoremap <F8> y:Silent Git grep --recurse-submodules "<C-r>"" -- :/<CR>
vnoremap <F9> y:Silent Git grep --recurse-submodules --name-only "<C-r>"" -- :/<CR>

"Easy pane swiching
nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-Left> <C-W><C-H>
nnoremap <C-Down> <C-W><C-J>
nnoremap <C-Up> <C-W><C-K>
nnoremap <C-Right> <C-W><C-L>

"Make preview window appear on bottom of window
augroup previewWindowPosition
   au!
   autocmd BufWinEnter * call PreviewWindowPosition()
augroup END
function! PreviewWindowPosition()
   if &previewwindow
      wincmd J
      resize 12
   endif
endfunction

"Plantuml-syntax
let g:plantuml_executable_script="~/.vim/configs/makeprg.sh"

"YCM extra conf
let g:ycm_confirm_extra_conf = 0
let g:ycm_clangd_binary_path = "~/.vim/bundle/YouCompleteMe/third_party/ycmd/third_party/clangd/output/bin/clangd" "The Clangd path that was built when I built YCM (?)
"let $LD_LIBRARY_PATH=$LD_LIBRARY_PATH."Removed to not show work paths" "Required by YCM to find the compiler that I used to compile everything.
let g:ycm_server_keep_logfiles = 1
let g:ycm_server_log_level = 'info'
let g:ycm_clangd_uses_ycmd_caching = 0 "Let clangd fully control code completion




"Tabulous settings
let tabulousLabelNameOptions = ':t' "Show file ending in tabline
let tabulousLabelNameTruncate = 0 "Do not truncate filenames

"Tagbar settings
let g:tagbar_ctags_bin = '~/.vim/configs/universal-ctags/ctags'


" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \| PlugInstall --sync | source $MYVIMRC
\| endif

"PLUGINS
"Set the runtime path to include Vundle and initialize
call plug#begin('~/.vim/plugged')

"Imo musthaves
Plug 'tpope/vim-fugitive'

"Good to have
Plug 'ycm-core/YouCompleteMe', { 'do': './install.py --clang-completer'}
Plug 'webdevel/tabulous' "Modify how tabline looks and updates.
Plug 'majutsushi/tagbar' "Tags outline bar

"Testing if needed
Plug 'ericcurtin/CurtineIncSw.vim' "Easy switch to the headerfile
Plug 'aklt/plantuml-syntax' "Add vim syntax for plantuml files. TODO: Not completely installed. Look up installation instrutions!
Plug 'scrooloose/vim-slumlord' "Add preview window when editing plantuml files

"Syntax and highlighting
Plug 'bfrg/vim-cpp-modern' "Cpp, c syntax highlighting files
Plug '5nord/vim-ttcn3' "TTCN-3 Syntax file. Modified by me to work...

call plug#end()

"Command to update Compilation Database such that YCM finds its tags
"You need to be located in the root folder of the REPO.
"OLD_TODO: Create a script for this AND/OR MAKE IT AUTOMATIC
"Update: Looks like it already is automatic. Keeping for future reference
"Ninja -C build/<config> -t compdb $(awk '/^rule (C|CXX)_COMPILER__/ { print $2 }' build/<config>/rules.ninja ) > compile_commands.json


"""""""""""""""""Start: Dmenu in vim
"Strip the newline from the end of a string
function! Chomp(str)
  return substitute(a:str, '\n$', '', '')
endfunction

"Find a file and pass it to cmd
function! DmenuOpen(cmd)
  let fname = Chomp(system("git ls-files --full-name | dmenu -i -l 20 -p " . a:cmd))
  if empty(fname)
    return
  endif
  execute a:cmd . " " . fname
endfunction

function! DeleteHiddenBuffers()
  let tpbl=[]
  let closed = 0
  call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
  for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
    if getbufvar(buf, '&mod') == 0
      silent execute 'bwipeout' buf
      let closed += 1
    endif
  endfor
  echo "Closed ".closed." hidden buffers"
endfunction

map <F1> :call DmenuOpen("vsplit")<CR>
map <F2> :call DmenuOpen("tabe")<CR>
nmap <F3> :YcmCompleter GoTo<CR>
nmap <F5> :YcmCompleter GetDoc<CR>
nmap <F6>  :YcmCompleter GoToReferences<CR>
nmap <F7> :call CurtineIncSw()<CR>
nmap <F9> :set hlsearch!<CR>
nmap <F9> :TagbarToggle<CR>
nnoremap <F8> :buffers<CR>:buffer<Space>
