if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentkeys=o,O,0=endif,0=ENDIF,0=endelse,0=ENDELSE,0=endwhile,0=ENDWHILE,0=endfor,0=ENDFOR,0=endrep,0=ENDREP
setlocal indentexpr=GetIdlangIndent(v:lnum)
if exists("*GetIdlangIndent")
finish
endif
function GetIdlangIndent(lnum)
let pnum = prevnonblank(v:lnum-1)
if pnum == 0
return 0
endif
let pnum2 = prevnonblank(pnum-1)
let curind = indent(pnum)
if getline(pnum) =~ '\$\s*\(;.*\)\=$'
if getline(pnum2) !~ '\$\s*\(;.*\)\=$'
let curind = curind+shiftwidth()
endif
else
if getline(pnum2) =~ '\$\s*\(;.*\)\=$'
let curind = curind-shiftwidth()
endif
endif
if getline(v:lnum) =~? '^\s*\(endif\|endelse\|endwhile\|endfor\|endrep\)\>'
if getline(pnum) =~? 'begin\>'
elseif indent(v:lnum) > curind-shiftwidth()
let curind = curind-shiftwidth()
else
return -1
endif
elseif getline(pnum) =~? 'begin\>'
if indent(v:lnum) < curind+shiftwidth()
let curind = curind+shiftwidth()
else
return -1
endif
endif
return curind
endfunction
