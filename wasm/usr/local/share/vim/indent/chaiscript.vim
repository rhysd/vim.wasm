if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetChaiScriptIndent()
setlocal autoindent
if exists("*GetChaiScriptIndent")
finish
endif
function! GetChaiScriptIndent()
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let ind = indent(lnum)
let flag = 0
let prevline = getline(lnum)
if prevline =~ '^.*{.*'
let ind = ind + shiftwidth()
let flag = 1
endif
if flag == 1 && prevline =~ '.*{.*}.*'
let ind = ind - shiftwidth()
endif
if getline(v:lnum) =~ '^\s*\%(}\)'
let ind = ind - shiftwidth()
endif
return ind
endfunction
