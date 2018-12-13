" Plugin to format network manager logs

setlocal foldmethod=marker

if exists("loaded_netman")
    finish
endif

let loaded_netman = 1
let s:highlight_list = []
let s:activated_hl = {}
let s:loaded_data = 0
let s:data_file = expand('<sfile>:p:r').'.conf'

function! s:LoadHighlights()
    if !s:loaded_data
        if filereadable(s:data_file)
            let names = ['NM', 'ctermfg=', 'ctermbg=']
            for line in readfile(s:data_file)
                let fields = split(line, ',', 1)
                let s:highlight_list += [fields]
                if len(fields) == 4 && fields[0] =~ '^\d\+$'
                    let cmd = range(3)
                    call map(cmd, 'names[v:val].fields[v:val]')
                    call filter(cmd, 'v:val!~''=$''')
                    execute 'silent highlight '.join(cmd)
                endif
            endfor
            let s:loaded_data = 1
        endif
        if !s:loaded_data
            echom 'Error: Could not read highlight data from '.s:data_file
        endif
    endif
endfunction

function! NMSetFolding()
    echom "NMSetFolding"
    %s/+\([a-zA-Z]\)/{{{\1/
    %s/-\([a-zA-Z]\)/}}}\1/
endfunction

function! NMSetHighlight()
    echom "NMSetHighlight"
    " Create highlight group
    call s:LoadHighlights()
    " create match
    for item in s:highlight_list
        let id = matchadd('NM'.item[0],item[3],-1)
        echom "adding item ".join([item[3],id]," ")
        let s:activated_hl = {item[3]:id}
    endfor
endfunction

function! NMUnsetHighlight()
    echom "NMUnsetHighlight"
    " delete every highlight of the list
    for item in items(s:activated_hl)
        call matchdelete(item[1])
        unlet s:activated_hl[item[0]]
    endfor
    let b:highlight_list = []
endfunction
