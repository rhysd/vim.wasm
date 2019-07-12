if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetLuaIndent()
setlocal indentkeys+=0=end,0=until
setlocal autoindent
if exists("*GetLuaIndent")
finish
endif
function! GetLuaIndent()
let prevlnum = prevnonblank(v:lnum - 1)
if prevlnum == 0
return 0
endif
let ind = indent(prevlnum)
let prevline = getline(prevlnum)
let midx = match(prevline, '^\s*\%(if\>\|for\>\|while\>\|repeat\>\|else\>\|elseif\>\|do\>\|then\>\)')
if midx == -1
let midx = match(prevline, '{\s*$')
if midx == -1
let midx = match(prevline, '\<function\>\s*\%(\k\|[.:]\)\{-}\s*(')
endif
endif
if midx != -1
if synIDattr(synID(prevlnum, midx + 1, 1), "name") != "luaComment" && prevline !~ '\<end\>\|\<until\>'
let ind = ind + shiftwidth()
endif
endif
let midx = match(getline(v:lnum), '^\s*\%(end\>\|else\>\|elseif\>\|until\>\|}\)')
if midx != -1 && synIDattr(synID(v:lnum, midx + 1, 1), "name") != "luaComment"
let ind = ind - shiftwidth()
endif
return ind
endfunction
