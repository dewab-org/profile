set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" All of your Plugins must be added before the following line
"
" airline plugin 2019-02-26
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" Enable ALE linting engine
Plugin 'w0rp/ale'

call vundle#end()            " required
filetype plugin indent on    " required

" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

set t_Co=256

" have syntax highlighting in terminals which can display colours:
if has('syntax') && (&t_Co > 2)
  syntax on
endif

" have command-line completion <Tab> (for filenames, help topics, option names)
" first list the available options and complete the longest common part, then
" have further <Tab>s cycle through the possibilities:
set wildmode=list:longest,full

" display the current mode and partially-typed commands in the status line:
set showmode
set showcmd

" added 2015-09-16
" Set to auto read when a file is changed from the outside
set autoread

"Always show current position
"set ruler

" Highlight search results
"set hlsearch

" search as characters are entered
set incsearch

" Highlight matching [{()}] when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=2

" show line numbers
"set number 
" was getting in the way of copy and paste! 
" Use the location in the status line instead!

" show cursorline
set cursorline

" folding
set foldmethod=indent   "fold based on indent
set foldnestmax=10      "deepest fold is 10 levels
set nofoldenable        "dont fold by default
set foldlevel=1         "this is just what i use

" Two Spaces replace tab key when editin YAML files
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    en
    return ''
endfunction

" Set Airline Theme
let g:airline_theme='cool'

" Set color scheme
"colorscheme molokai

au BufNewFile,BufRead *.zshrc set filetype=zsh

" Below Added for ALE

" Load all plugins now.
" Plugins need to be added to runtimepath before helptags can be generated.
"packloadall
" Load all of the helptags now, after plugins have been loaded.
" All messages and errors will be ignored.
silent! helptags ALL
