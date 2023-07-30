
"+++++++++common+++++++++

"===moving around
noremap H 4b
noremap J 5j
noremap K 5k
noremap L 4w

"===page up/down
noremap <C-e> <C-u>

"===undo
noremap <C-y> <C-r>

"===inc dec 1
noremap _ <C-x>
noremap + <C-a>

"===select all
noremap <C-a> ggVG

"===move the cursor out of the braket
inoremap <C-l> <RIGHT>

"===make Y copy till end of the line
nnoremap Y y$

"===searching select
noremap - Nzz
noremap = nzz

"===cancel highlight
noremap <silent> 0 :nohlsearch<CR>

"===save&quit
noremap <C-s> :w<CR>
noremap <C-q> :q<CR>

"===combine lines
noremap Q J

"+++++++++common+++++++++

"===leaderkey
let mapleader=" "

set guicursor=i-ci:ver30-iCursor-blinkwait300-blinkon200-blinkoff150
set hlsearch
set laststatus=2
set cursorline
set number
set relativenumber
set scrolloff=7
set shiftwidth=2
set tabstop=4
set softtabstop=4
set termguicolors
set list
set listchars=tab:→\ ,space:·
set wrap
set tw=0
set noshowmode
set mouse=a
set ignorecase
set wildignorecase
set smartcase
set undofile
set undodir=~/.cache/vim/undo
set clipboard+=unnamedplus
set ttimeout
set ttimeoutlen=1
set ttyfast
set viminfofile=NONE


"===cursor shape settings
let &t_SI.="\e[6 q"
let &t_EI.="\e[2 q"

"===fade whitespace/tabs
augroup dracula_customization
    au!
    autocmd ColorScheme dracula hi! link SpecialKey DraculaSubtle
augroup END

packadd! dracula
syntax enable
colorscheme dracula

"===vim lightline
let g:lightline = {
        \ 'colorscheme': 'dracula',
        \ 'active': {
        \   'left': [ [ 'mode', 'paste'  ], [ 'filename'  ], [ 'bufferline'  ]  ],
        \ },
\ }
