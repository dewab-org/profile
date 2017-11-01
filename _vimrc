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

set background=dark
"colorscheme railcasts
colorscheme molokai

" added 2015-09-16
" Set to auto read when a file is changed from the outside
set autoread

"Always show current position
set ruler

" Highlight search results
set hlsearch

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

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

" Format the status line
set statusline=\ \ Filename:\ [%.20F]
"set statusline+=\ \ %{HasPaste()}
set statusline+=\ \ Flags:\ [%hm%r%w]
set statusline+=\ \ Type:\ %y
set statusline+=\ \ Encoding:\ [%{strlen(&fenc)?&fenc:'none'}] "file encoding
set statusline+=\ \ Format:\ [%{&fileformat}]              " file format
set statusline+=%=
set statusline+=\ \ Loc:\ [%02c][%04l/%04L]
set statusline+=\ [%P]

" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    en
    return ''
endfunction
