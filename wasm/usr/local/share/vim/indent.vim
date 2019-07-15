if exists("did_indent_on")
finish
endif
let did_indent_on = 1
augroup filetypeindent
au FileType * call s:LoadIndent()
func! s:LoadIndent()
if exists("b:undo_indent")
exe b:undo_indent
unlet! b:undo_indent b:did_indent
endif
let s = expand("<amatch>")
if s != ""
if exists("b:did_indent")
unlet b:did_indent
endif
for name in split(s, '\.')
exe 'runtime! indent/' . name . '.vim'
endfor
endif
endfunc
augroup END
