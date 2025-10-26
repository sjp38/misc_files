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

" Maps `<leader>b` in normal mode to call our custom function.
" nnoremap is used to prevent recursive mappings and ensure it only works
" in normal mode.
nnoremap <leader>b :call <SID>GitBlameShow()<CR>

" -----------------------------------------------------------------------------
"  Custom Vim Function: GitBlameShow
" -----------------------------------------------------------------------------
" This function performs the core logic for the mapping.
function! s:GitBlameShow()
  " Get the current line number and the full path of the current file.
  let lnum = line('.')
  let file = expand('%:p')

  " Abort if the file hasn't been saved to disk yet.
  if empty(file) || !filereadable(file)
    echo "File not saved. Cannot run git blame."
    return
  endif

  " Run `git blame` for the specific line.
  " --porcelain is used for a stable, machine-readable output format.
  " -- is used to separate options from file paths.
  let blame_output = system('git blame --porcelain -L ' . lnum . ',' . lnum . ' -- ' . shellescape(file))

  " Check if the git blame command returned an error (e.g., not a git repo).
  if v:shell_error
    echo "Error running git blame. (Not a git repository or other git error)"
    " Also print the actual error message from the git command.
    echo blame_output
    return
  endif

  " The first line of the porcelain output contains the commit hash as the first word.
  " We split the output by spaces and take the first element.
  let commit_hash = split(blame_output, ' ')[0]

  " Basic validation to check if we got something that looks like a commit hash.
  if strlen(commit_hash) < 7 || strlen(commit_hash) > 40
    echo "Could not find commit info for this line (is the change committed?)"
    return
  endif

  " Open a new horizontal split window to display the commit information.
  below new

  " Set buffer options for this new preview window:
  " - buftype=nofile: This buffer is not related to a file on disk.
  " - bufhidden=wipe: Wipe the buffer from memory when its window is closed.
  " - noswapfile:     Do not create a swap file for this buffer.
  " - readonly:       Prevent accidental modifications to the commit info.
  setlocal buftype=nofile bufhidden=wipe noswapfile readonly

  " Set the filetype to 'gitcommit' to get nice syntax highlighting for the output.
  setlocal filetype=gitcommit

  " Read the output of 'git log' of a custom format for our commit hash
  " directly into the new buffer.
  " 'silent' prevents messages like "press ENTER to continue".
  let cmd = 'silent read !git log -p -1'
  let cmd = cmd . ' --pretty='
  let cmd = cmd . '"\%h (\"\%s\")'
  let cmd = cmd . '\%n\%n'
  let cmd = cmd . 'Author: \%an <\%ae>'
  let cmd = cmd . '\%n'
  let cmd = cmd . 'Author-date: \%aI'
  let cmd = cmd . '\%n\%n'
  let cmd = cmd . '\%B" '
  let cmd = cmd . shellescape(commit_hash)
  execute cmd

  " Move the cursor to the top of the new buffer for clean viewing.
  1
endfunction

