if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetPrologIndent()
setlocal indentkeys-=:,0#
setlocal indentkeys+=0%,-,0;,>,0)
function! GetPrologIndent()
let pnum = prevnonblank(v:lnum - 1)
if pnum == 0
return 0
endif
let line = getline(v:lnum)
let pline = getline(pnum)
let ind = indent(pnum)
if pline =~ '^\s*%'
return ind
endif
if pline =~ '^\s*/\*'
return ind + 1
endif
if pline =~ '^\s*\*/'
return ind - 1
endif
if pline =~ '\%(:-\|-->\)\s*\(%.*\)\?$'
let ind = ind + shiftwidth()
elseif pline =~ '\.\s*\(%.*\)\?$'
let ind = ind - shiftwidth()
endif
if pline =~ '^\s*\([(;]\|->\)'
let ind = ind + shiftwidth()
endif
if line =~ '^\s*\([);]\|->\)'
let ind = ind - shiftwidth()
endif
return ind
endfunction
