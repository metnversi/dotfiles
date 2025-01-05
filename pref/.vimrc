syntax on
filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
set guifont=Iosevka\ 10
set guioptions-=m
set guioptions-=T
set noesckeys
set relativenumber
set number
set ignorecase
set smartcase
set incsearch
set cinoptions=l1
set modeline
set keymap=russian-jcukenwin
set iminsert=0
set imsearch=0
set autoindent
set autochdir
colorscheme habamax
autocmd FileType yaml setlocal ai ts=2 sw=2 et
autocmd FileType yml setlocal ai ts=2 sw=2 et

autocmd BufEnter * if &filetype == "go" | setlocal noexpandtab
autocmd BufNewFile,BufRead ?\+.c3 setf c

map gf :e <cfile><CR>
