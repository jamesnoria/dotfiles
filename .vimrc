
set number
set numberwidth=1
set clipboard=unnamed
syntax enable
set showcmd
set ruler
set cursorline
set encoding=utf-8
set showmatch
set sw=2

set laststatus=2
set noshowmode

call plug#begin('~/.vim/plugged')

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'frazrepo/vim-rainbow'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-fugitive'
Plug 'NLKNguyen/papercolor-theme'
Plug 'ryanoasis/vim-devicons'

call plug#end()

"Theme
set background=dark
colorscheme PaperColor

"NerdTree
map <F1> :NERDTreeToggle<CR>

""VimRainbow
let g:rainbow_active = 1

""Emmet
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall
let g:user_emmet_leader_key=','

""autclose
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

""Html, CSS, JS
au BufReadPost *.ezt set syntax=html
au BufNewFile,BufRead *.js, *.html, *.css
    \ set tabstop=2
    \ set softtabstop=2
    \ set shiftwidth=2

"Autoident
"map <F7> gg=G<C-o><C-o>
"
""AutorunPython
autocmd FileType python map <buffer> <F12> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
autocmd FileType python imap <buffer> <F12> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>
