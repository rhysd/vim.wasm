if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentkeys+==~begin,=~block,=~case,=~cleanup,=~define,=~end,=~else,=~elseif,=~exception,=~for,=~finally,=~if,=~otherwise,=~select,=~unless,=~while
setlocal indentexpr=DylanGetIndent()
if exists("*DylanGetIndent")
finish
endif
function DylanGetIndent()
let cline = getline(v:lnum)
if cline =~ '^/\[/\*]'
return 0
endif
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let prevline=getline(lnum)
let ind = indent(lnum)
let chg = 0
if prevline =~ '^\s*//'
return ind
endif
if prevline =~? '\(^\s*\(begin\|block\|case\|define\|else\|elseif\|for\|finally\|if\|select\|unless\|while\)\|\s*\S*\s*=>$\)'
let chg = shiftwidth()
elseif prevline =~? '^\s*local'
let chg = shiftwidth() + 6
elseif prevline =~? '^\s*let.*[^;]\s*$'
let chg = shiftwidth()
elseif prevline =~ '^.*(\s*[^)]*\((.*)\)*[^)]*$'
return = match( prevline, '(.*\((.*)\|[^)]\)*.*$') + 1
elseif prevline =~ '^[^(]*)\s*$'
let curr_line = prevnonblank(lnum - 1)
while curr_line >= 0
let str = getline(curr_line)
if str !~ '^.*(\s*[^)]*\((.*)\)*[^)]*$'
let curr_line = prevnonblank(curr_line - 1)
else
break
endif
endwhile
if curr_line < 0
return -1
endif
let ind = indent(curr_line)
let curr_str = getline(curr_line)
if curr_str =~? '^\s*\(begin\|block\|case\|define\|else\|elseif\|for\|finally\|if\|select\|unless\|while\)'
let chg = shiftwidth()
endif
endif
if cline =~? '^\s*\(cleanup\|end\|else\|elseif\|exception\|finally\|otherwise\)'
let chg = chg - shiftwidth()
endif
return ind + chg
endfunction
