" Install vim-plug
let data_dir = '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
call plug#begin()
Plug 'itchyny/lightline.vim'
Plug 'dracula/vim', { 'as': 'dracula' }
call plug#end()

" Plugin settings
let g:dracula_colorterm = 0
colorscheme dracula
let g:lightline = {
      \ 'colorscheme': 'dracula',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste'  ], [ 'filename'  ], [ 'bufferline'  ]  ],
      \ },
      \ }

"============ Key Mappings ============
" Navigation
noremap H 4b
noremap J 5j
noremap K 5k
noremap L 4w

" Page scrolling
noremap <C-e> <C-u>

" Undo/Redo
noremap <C-y> <C-r>

" Number increment/decrement
noremap _ <C-x>
noremap + <C-a>

" Select all text
noremap <C-a> ggVG

" Move cursor out of brackets in insert mode
inoremap <C-l> <RIGHT>

" Make Y consistent with D and C (yank until end of line)
nnoremap Y y$

" Search navigation with centering
noremap - Nzz
noremap = nzz

" Clear search highlighting
noremap <silent> 0 :nohlsearch<CR>

" Save and quit shortcuts
noremap <C-s> :w<CR>
noremap <C-q> :q!<CR>

" Join lines
noremap Q J

" Leader key
let mapleader=" "

"============ Basic Settings ============
set hlsearch              " Highlight search results
set cursorline           " Highlight current line
set number               " Show line numbers
set relativenumber       " Show relative line numbers
set scrolloff=7          " Keep 7 lines above/below cursor
set shiftwidth=2         " Number of spaces for autoindent
set tabstop=4           " Number of spaces for tab
set softtabstop=4       " Number of spaces for tab while editing
set list                " Show invisible characters
set listchars=tab:→\    " Show tabs as arrows
set wrap                " Wrap long lines
set tw=0                " No automatic text wrapping
set noshowmode          " Don't show mode (lightline shows it)
set mouse=a             " Enable mouse support
set ignorecase          " Case insensitive search
set wildignorecase      " Case insensitive command-line completion
set smartcase           " Case sensitive if search pattern has uppercase
set clipboard+=unnamedplus  " Use system clipboard