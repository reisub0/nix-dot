if PlagCheck('yoink')
    let g:yoinkIncludeDeleteOperations=1
    nmap <c-n> <plug>(YoinkPostPasteSwapBack)
    nmap <c-p> <plug>(YoinkPostPasteSwapForward)

    nmap p <plug>(YoinkPaste_p)
    nmap P <plug>(YoinkPaste_P)
endif
