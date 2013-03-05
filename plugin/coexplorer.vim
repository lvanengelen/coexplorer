let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_coexplorer')
    finish
endif
let g:loaded_coexplorer = 1

func! s:SetupMappings()
    call s:CheckedMap('nm', '<leader>cs', '<Plug>CoExp_OpenView')
    call s:CheckedMap('nm', '<leader>cc', '<Plug>CoExp_CloseView')

    " Expose script functions through mappings.
    nn <silent> <script> <Plug>CoExp_OpenView
      \ :call <SID>OpenView()<CR>
    nn <silent> <script> <Plug>CoExp_CloseView
      \ :call <SID>CloseView()<CR>
endfunc

func! s:SetupCommands()
    " Expose script functions through commands.
    com! CoExp call s:ToggleView()
endfunc

func! s:OpenView()
    if exists('t:CoExp_view')
        return
    endif

    let t:CoExp_view = coexplorer#NewView()

    nn <buffer> <silent> <CR> :call t:CoExp_view.openFile()<CR>
    nn <buffer> <silent> q    :call t:CoExp_view.close()<CR>

    com -buffer CoExpClose :call t:CoExp_view.close()

	au BufDelete <buffer> unlet t:CoExp_view
endfunc

func! s:CloseView()
    if exists('t:CoExp_view')
        call t:CoExp_view.close()
    endif
endfunc

func! s:ToggleView()
    if exists('t:CoExp_view')
        call s:CloseView()
    else
        call s:OpenView()
    endif
endfunc

func! s:CheckedMap(cmd, keys, target)
    if !mapcheck(a:keys) && !hasmapto(a:target)
        sil exe a:cmd . ' ' . a:keys . ' ' . a:target
    endif
endfunc

call s:SetupMappings()
call s:SetupCommands()

let &cpo = s:save_cpo
