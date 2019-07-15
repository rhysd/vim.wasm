if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal autoindent
setlocal indentexpr=GetIshdIndent(v:lnum)
setlocal indentkeys&
setlocal indentkeys+==else,=elseif,=endif,=end,=begin,<:>
let b:undo_indent = "setl ai< indentexpr< indentkeys<"
if exists("*GetIshdIndent")
finish
endif
fun! GetIshdIndent(lnum)
let this_line = getline(a:lnum)
let LABELS_OR_PREPROC = '^\s*\(\<\k\+\>:\s*$\|#.*\)'
let LABELS_OR_PREPROC_EXCEPT = '^\s*\<default\+\>:'
if this_line =~ LABELS_OR_PREPROC && this_line !~ LABELS_OR_PREPROC_EXCEPT
return 0
endif
let lnum = a:lnum
while lnum > 0
let lnum = prevnonblank(lnum - 1)
let previous_line = getline(lnum)
if previous_line !~ LABELS_OR_PREPROC || previous_line =~ LABELS_OR_PREPROC_EXCEPT
break
endif
endwhile
if lnum == 0
return 0
endif
let ind = indent(lnum)
if previous_line =~ '^\s*\<\(function\|begin\|switch\|case\|default\|if.\{-}then\|else\|elseif\|while\|repeat\)\>'
let ind = ind + shiftwidth()
endif
if this_line =~ '^\s*\<endswitch\>'
let ind = ind - 2 * shiftwidth()
elseif this_line =~ '^\s*\<\(begin\|end\|endif\|endwhile\|else\|elseif\|until\)\>'
let ind = ind - shiftwidth()
elseif this_line =~ '^\s*\<\(case\|default\)\>'
if previous_line !~ '^\s*\<switch\>'
let ind = ind - shiftwidth()
endif
endif
return ind
endfun
