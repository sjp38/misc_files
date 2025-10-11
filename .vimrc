set nu
set ls=2
set noswapfile
colorscheme koehler

" Do git blame with \g
vmap <Leader>g :<C-U>!git blame <C-R>=expand("%:p") <CR> \| sed -n <C-R>=line("'<") <CR>,<C-R>=line("'>") <CR>p <CR>

set smartindent
set autoindent
filetype plugin indent on
syntax on
set hlsearch

" Reopen the last edited position in files
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

set sel=exclusive

" Show colored line at 80-th column
set colorcolumn=80

