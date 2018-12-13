" Plugin to format network manager logs

setlocal foldmethod=marker

if exists("loaded_netman")
    finish
endif

let loaded_netman = 1
let s:loaded_data = 0
let s:data_file = expand('<sfile>:p:r').'.conf'
let s:highlight_list = []

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

function! NMFolding()
    %s/ +\([a-zA-Z]\)/ {{{\1/
    %s/ -\([a-zA-Z]\)/ }}}\1/
endfunction

function! NMSetHighlight()
    echom "NMSetHighlight"
    if(!exists('b:activated_hl'))
        let b:activated_hl = {}
    endif
    " Create highlight group
    call s:LoadHighlights()
    " create match
    for item in s:highlight_list
        let id = matchadd('NM'.item[0],"\\v.*".item[3].".*$",-1)
        let b:activated_hl[item[3]] = id
    endfor
endfunction

function! NMUnsetHighlight()
    echom "NMUnsetHighlight"
    if(!exists('b:activated_hl'))
        let b:activated_hl = {}
    endif
    " delete every highlight of the list
    for item in items(b:activated_hl)
        call matchdelete(item[1])
        unlet b:activated_hl[item[0]]
    endfor
endfunction

function! NMToggleHighlight()
    if (!exists('b:activated_hl') || (len(b:activated_hl) == 0)) 
        call NMSetHighlight()
    else
        call NMUnsetHighlight()
    endif
endfunction
nnoremap ,hl :call NMToggleHighlight()<cr>
