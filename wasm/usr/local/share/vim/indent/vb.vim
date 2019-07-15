if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal autoindent
setlocal indentexpr=VbGetIndent(v:lnum)
setlocal indentkeys&
setlocal indentkeys+==~else,=~elseif,=~end,=~wend,=~case,=~next,=~select,=~loop,<:>
let b:undo_indent = "set ai< indentexpr< indentkeys<"
if exists("*VbGetIndent")
finish
endif
fun! VbGetIndent(lnum)
let this_line = getline(a:lnum)
let LABELS_OR_PREPROC = '^\s*\(\<\k\+\>:\s*$\|#.*\)'
if this_line =~? LABELS_OR_PREPROC
return 0
endif
let lnum = a:lnum
while lnum > 0
let lnum = prevnonblank(lnum - 1)
let previous_line = getline(lnum)
if previous_line !~? LABELS_OR_PREPROC
break
endif
endwhile
if lnum == 0
return 0
endif
let ind = indent(lnum)
if previous_line =~? '^\s*\<\(begin\|\%(\%(private\|public\|friend\)\s\+\)\=\%(function\|sub\|property\)\|select\|case\|default\|if\|else\|elseif\|do\|for\|while\|enum\|with\)\>'
let ind = ind + shiftwidth()
endif
if this_line =~? '^\s*\<end\>\s\+\<select\>'
if previous_line !~? '^\s*\<select\>'
let ind = ind - 2 * shiftwidth()
else
let ind = ind - shiftwidth()
endif
elseif this_line =~? '^\s*\<\(end\|else\|elseif\|until\|loop\|next\|wend\)\>'
let ind = ind - shiftwidth()
elseif this_line =~? '^\s*\<\(case\|default\)\>'
if previous_line !~? '^\s*\<select\>'
let ind = ind - shiftwidth()
endif
endif
return ind
endfun
