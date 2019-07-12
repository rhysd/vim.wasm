if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal autoindent
setlocal indentkeys+==~end,=~case,=~if,=~then,=~else,=~do,=~until,=~while,=~repeat,=~select,=~default,=~for,=~start,=~next,=~step,<<>,<>>
setlocal indentexpr=RplGetFreeIndent()
if exists("*RplGetFreeIndent")
finish
endif
let b:undo_indent = "set ai< indentkeys< indentexpr<"
function RplGetIndent(lnum)
let ind = indent(a:lnum)
let prevline=getline(a:lnum)
let prevstat=substitute(prevline, '!.*$', '', '')
if prevstat =~? '\<\(if\|iferr\|do\|while\)\>' && prevstat =~? '\<end\>'
elseif prevstat =~? '\(^\|\s\+\)<<\($\|\s\+\)' && prevstat =~? '\s\+>>\($\|\s\+\)'
elseif prevstat =~? '\<\(if\|iferr\|then\|else\|elseif\|select\|case\|do\|until\|while\|repeat\|for\|start\|default\)\>' || prevstat =~? '\(^\|\s\+\)<<\($\|\s\+\)'
let ind = ind + shiftwidth()
endif
let line = getline(v:lnum)
if line =~? '^\s*\(then\|else\|elseif\|until\|repeat\|next\|step\|default\|end\)\>'
let ind = ind - shiftwidth()
elseif line =~? '^\s*>>\($\|\s\+\)'
let ind = ind - shiftwidth()
endif
return ind
endfunction
function RplGetFreeIndent()
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let ind=RplGetIndent(lnum)
return ind
endfunction
