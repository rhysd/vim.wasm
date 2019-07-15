if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentkeys+==~if,=~else,=~endif,=~endfor,=~endwhile
setlocal indentkeys+==~do,=~until,=~while,=~repeat,=~for,=~loop
setlocal indentkeys+==~sub,=~endsub
setlocal indentexpr=HamGetFreeIndent()
if exists("*HamGetFreeIndent")
finish
endif
function HamGetIndent(lnum)
let ind = indent(a:lnum)
let prevline=getline(a:lnum)
if prevline =~? '^\s*\<\(if\|else\%(if\)\?\|for\|repeat\|do\|while\|sub\)\>' 
let ind = ind + shiftwidth()
endif
let line = getline(v:lnum)
if line =~? '^\s*\(else\|elseif\|loop\|until\|end\%(if\|while\|for\|sub\)\)\>'
let ind = ind - shiftwidth()
endif
return ind
endfunction
function HamGetFreeIndent()
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let ind=HamGetIndent(lnum)
return ind
endfunction
