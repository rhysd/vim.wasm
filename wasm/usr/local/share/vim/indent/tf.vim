if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetTFIndent()
setlocal indentkeys-=0{,0} indentkeys-=0# indentkeys-=:
setlocal indentkeys+==/endif,=/then,=/else,=/done,0;
if exists("*GetTFIndent")
finish
endif
function GetTFIndent()
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let ind = indent(lnum)
let line = getline(lnum)
if line !~ '\\$'
return 0
endif
if line =~ '\(/def.*\\\|/for.*\(%;\s*\)\@\<!\\\)$'
let ind = ind + shiftwidth()
elseif line =~ '\(/if\|/else\|/then\)'
if line !~ '/endif'
let ind = ind + shiftwidth()
endif
elseif line =~ '/while'
if line !~ '/done'
let ind = ind + shiftwidth()
endif
endif
let line = getline(v:lnum)
if line =~ '\(/else\|/endif\|/then\)'
if line !~ '/if'
let ind = ind - shiftwidth()
endif
elseif line =~ '/done'
if line !~ '/while'
let ind = ind - shiftwidth()
endif
endif
if line =~ '^\s*;'
let ind = 0
endif
return ind
endfunction
