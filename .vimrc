
#git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vimsyntax enable
set number
set relativenumber
highlight LineNr ctermfg=167
highlight CursorLineNr ctermfg=167
set background=dark
colorscheme jellybeans
set clipboard=unnamed

set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'jiangmiao/auto-pairs'
Plugin 'VundleVim/Vundle.vim'
Plugin 'ycm-core/YouCompleteMe'

call vundle#end()

filetype plugin indent on 
