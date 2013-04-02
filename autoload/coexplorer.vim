let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_coexplorer_autoload')
    finish
endif
let g:loaded_coexplorer_autoload = 1

func! coexplorer#NewView()
    let view = { '_cache': [] }

    func! view.openFile()
        sil exe 'edit ' . self['_cache'][line('.') - 1][0]
    endfunc
    
    func! view.close()
        sil exe 'bw ' . self['_bufnr']
    endfunc

    func! view.recache()
        call self._startModify()

        let tmpfile = tempname()
        sil exe '! svn status -q > ' . tmpfile

        let self['_cache'] = []
        for line in readfile(tmpfile)
            let m = matchlist(line, '\v^(\S+)\s+(.*)$')

            if m != []
                if (isdirectory(m[2]) && m[2][-1] != '/')
                    let m[2] .= '/'
                endif

                call add(self['_cache'], [m[2], m[1]])
            endif
        endfor

        call delete(tmpfile)

        call self._endModify()
    endfunc

    func! view.refresh()
        call self._startModify()

        sil exe 'buf ' . self['_bufnr']
        sil 1,$d _

        let old_o = @o
        let @o = self._renderToString()
        sil put o
        let @o = old_o

        sil 1,1d

        call self._endModify()
    endfunc

    func! view._renderToString()
        let flagmap = {
        \   'A': 'added',
        \   'C': 'conflicted',
        \   'D': 'deleted',
        \   'I': 'ignored',
        \   'M': 'modified',
        \   'R': 'replaced',
        \   'X': 'external',
        \   '?': 'not versioned',
        \   '!': 'missing',
        \   '~': 'obstructed' }

        let output = ''
        for entry in self['_cache']
            let output .= printf('%-60s%-18s', entry[0], get(flagmap, entry[1][0]))
            let output .= "\n"
        endfor

        return output
    endfunc

    func! view._startModify()
        sil exe 'buf ' . self['_bufnr']
        setlocal modifiable
    endfunc

    func! view._endModify()
        sil exe 'buf ' . self['_bufnr']
        setlocal nomodifiable
    endfunc

    new

    let view['_bufnr'] = bufnr('')

    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    setlocal nonumber
    setlocal cursorline
    setlocal nomodifiable

    sil exe 'file Checkouts'

    call view.recache()
    call view.refresh()

    return view
endfunc

let &cpo = s:save_cpo
