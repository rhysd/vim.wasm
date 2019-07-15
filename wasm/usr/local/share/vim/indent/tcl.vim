if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetTclIndent()
setlocal indentkeys=0{,0},!^F,o,O,0]
setlocal nosmartindent
if exists("*GetTclIndent")
finish
endif
function s:prevnonblanknoncomment(lnum)
let lnum = prevnonblank(a:lnum)
while lnum > 0
let line = getline(lnum)
if line !~ '^\s*\(#\|$\)'
break
endif
let lnum = prevnonblank(lnum - 1)
endwhile
return lnum
endfunction
function s:ends_with_backslash(lnum)
let line = getline(a:lnum)
if line =~ '\\\s*$'
return 1
else
return 0
endif
endfunction 
function s:count_braces(lnum, count_open)
let n_open = 0
let n_close = 0
let line = getline(a:lnum)
let pattern = '[{}]'
let i = match(line, pattern)
while i != -1
if synIDattr(synID(a:lnum, i + 1, 0), 'name') !~ 'tcl\%(Comment\|String\)'
if line[i] == '{'
let n_open += 1
elseif line[i] == '}'
if n_open > 0
let n_open -= 1
else
let n_close += 1
endif
endif
endif
let i = match(line, pattern, i + 1)
endwhile
return a:count_open ? n_open : n_close
endfunction
function GetTclIndent()
let line = getline(v:lnum)
let pnum = s:prevnonblanknoncomment(v:lnum - 1)
if pnum == 0
return 0
endif
let pnum2 = s:prevnonblanknoncomment(pnum-1)
let ind = indent(pnum)
if s:count_braces(pnum, 1) > 0
let ind += shiftwidth()
else
let slash1 = s:ends_with_backslash(pnum)
let slash2 = s:ends_with_backslash(pnum2)
if slash1 && !slash2
let ind += shiftwidth()
elseif !slash1 && slash2
let ind -= shiftwidth()
endif
endif
if line =~ '^\s*}'
let ind -= shiftwidth()
endif
return ind
endfunction
