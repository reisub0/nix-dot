function! LCMapper()
    nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
    nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
    nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
    nnoremap <silent> <F1> :call LanguageClient_contextMenu()<CR>
endfunction

function! LCUnMapper()
    nunmap K
    nunmap gd
    nunmap <F2>
    nunmap <F1>
endfunction

if PlagCheck('LanguageClient-neovim')
    set hidden
    let g:LanguageClient_serverCommands = {
        \ 'c': ['clangd'],
        \ 'python': ['pyls'],
        \ 'bash': ['bash-lanuguage-server'],
        \ 'sh': ['bash-lanuguage-server'],
        \ 'go': ['go-langserver'],
        \ 'dart': ['dart_language_server'],
        \ 'rust': ['rustup', 'run', 'stable', 'rls'],
        \ }
        " \ 'c': ['cquery'],
        " \ 'cpp': ['cquery', '--log-file=/tmp/cq.log'],
        " \ 'javascript': ['javascript-typescript-stdio'],
        " \ 'javascript.jsx': ['javascript-typescript-stdio'],
    let g:LanguageClient_loadSettings = 1

    let g:LanguageClient_selectionUI = 'fzf'
    let g:LanguageClient_settingsPath = '/home/g/.config/nvim/settings.json'
    " nnoremap <silent> * :call LanguageClient_textDocument_references()<CR>
    set formatexpr='LanguageClient_textDocument_rangeFormatting()'
    augroup LanguageClient_config
        autocmd!
        autocmd User LanguageClientStarted call LCMapper()
        autocmd User LanguageClientStopped call LCUnMapper()
    augroup end
endif
