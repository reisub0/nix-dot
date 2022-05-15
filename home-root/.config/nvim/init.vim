set cindent
set cscopetag

" Now we set some defaults for the editor
set history=50                  " keep 50 lines of command line history
" set ruler                     " show the cursor position all the time
set showcmd     " display incomplete commands
set wildmenu        " display completion matches in a status line
set splitright
" set splitbelow
" set complete-=1
" set shada=""
set undofile
set undodir=~/.local/share/nvim/undo

" Protect large files from sourcing and other overhead.
if !exists("my_auto_commands_loaded")
    let my_auto_commands_loaded = 1

    " eventignore+=FileType (no syntax highlighting etc
    " assumes FileType always on)
    " noswapfile (save copy of file)
    " bufhidden=unload (save memory when other file is viewed)
    " buftype=nowrite (file is read-only)
    " undolevels=-1 (no undo possible)
    let g:LargeFile = 1024 * 1024 * 20
    augroup LargeFile
        autocmd BufReadPre * let f=expand("<afile>") | if getfsize(f) > g:LargeFile | set eventignore+=FileType | setlocal noswapfile bufhidden=unload undolevels=-1 | else | set eventignore-=FileType | endif
    augroup END
    autocmd BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") |     exe "normal! g`\"" | endif
    autocmd BufEnter * silent! lcd %:p:h
endif

set timeout     " time out for key codes
set timeoutlen=2000
" set cursorline

"set noshowmode
set ts=4
set shiftwidth=4
set softtabstop=4
set expandtab

set lazyredraw
set updatetime=300
set nu
set nuw=3
set scrolloff=4

set title
" set regexpengine=1

" syntax on

" In many terminal emulators the mouse works just fine.  By enabling it you
" can position the cursor, Visually select and scroll with the mouse.
set mouse=a

" Do incremental searching when it's possible to timeout
if has('reltime')
    set incsearch
    set hlsearch
    if has('nvim')
        set inccommand=nosplit
    endif
endif

" I like highlighting strings inside C comments.
" Revert with ":unlet c_comment_strings".
let c_comment_strings=1

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
" Revert with: ":delcommand DiffOrig".
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
endif

" Suffixes that get lower priority when doing tab completion for filenames.
" These are files we are not likely to want to edit or read.
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.png,.jpg
let g:mp="make\ -r\ -f\ ./makefile\ \%.out"

" autocmd TermOpen * setlocal laststatus=0
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

function! SourceLocal(relativePath)
  let root = expand('%:p:h')
  let fullPath = root . '/'. a:relativePath
  exec 'source ' . fullPath
endfunction

let g:nvim_config_root = stdpath('config')
let g:config_file_list = ['map.vim',
    \ 'plug.vim',
    \ 'pls.vim',
    \ 'plagin.vim',
    \ 'interface.vim',
    \ 'ft.vim'
    \ ]

for f in g:config_file_list
    execute 'source ' . g:nvim_config_root . '/' . f
endfor
