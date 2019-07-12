if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal nosmartindent
setlocal noautoindent
setlocal indentexpr=GetTeraTermIndent(v:lnum)
setlocal indentkeys=!^F,o,O,e
setlocal indentkeys+==elseif,=endif,=loop,=next,=enduntil,=endwhile
if exists("*GetTeraTermIndent")
finish
endif
function! GetTeraTermIndent(lnum)
let l:prevlnum = prevnonblank(a:lnum-1)
if l:prevlnum == 0
return 0
endif
let l:prevl = substitute(getline(l:prevlnum), ';.*$', '', '')
let l:thisl = substitute(getline(a:lnum), ';.*$', '', '')
let l:previ = indent(l:prevlnum)
let l:ind = l:previ
if l:prevl =~ '^\s*if\>.*\<then\>'
let l:ind += shiftwidth()
endif
if l:prevl =~ '^\s*\%(elseif\|else\|do\|until\|while\|for\)\>'
let l:ind += shiftwidth()
endif
if l:thisl =~ '^\s*\%(elseif\|else\|endif\|enduntil\|endwhile\|loop\|next\)\>'
let l:ind -= shiftwidth()
endif
return l:ind
endfunction
