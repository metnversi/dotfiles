set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'
Plugin 'tpope/vim-fugitive'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'godlygeek/tabular'
Plugin 'preservim/vim-markdown'
Plugin 'preservim/nerdtree'
Plugin 'mhinz/vim-signify'
Plugin 'ryanoasis/vim-devicons'
call vundle#end()
filetype plugin indent on

syntax on
filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
set ignorecase
set incsearch
set cinoptions=l1
set modeline
set iminsert=0
set imsearch=0
set autoindent
set autochdir
set number
set conceallevel=2
set encoding=UTF-8
set guifont=Iosevka\ Nerd\ Font\ 11
colorscheme molokai
highlight Normal guibg=NONE ctermbg=NONE
highlight NonText guibg=NONE ctermbg=NONE
autocmd FileType yaml setlocal ai ts=2 sw=2 et
autocmd FileType yml setlocal ai ts=2 sw=2 et

autocmd BufEnter * if &filetype == "go" | setlocal noexpandtab
autocmd BufNewFile,BufRead ?\+.c3 setf c
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_fenced_languages = ['csharp=cs','bash=sh','ini=dosini','shell=cpp']
let g:vim_markdown_math = 1
let g:vim_markdown_frontmatter = 1
let g:signify_vcs_list = ['git']

map gf :e <cfile><CR>
nnoremap <C-e> :NERDTreeToggle<CR>
