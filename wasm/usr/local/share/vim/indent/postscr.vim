if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=PostscrIndentGet(v:lnum)
setlocal indentkeys+=0],0=>>,0=%%,0=end,0=restore,0=grestore indentkeys-=:,0#,e
if exists("*PostscrIndentGet")
finish
endif
function! PostscrIndentGet(lnum)
let lnum = a:lnum - 1
while lnum != 0
let lnum = prevnonblank(lnum)
if getline(lnum) !~ '^\s*%.*$'
break
endif
let lnum = lnum - 1
endwhile
if lnum == 0
return -1
endif
let ind = indent(lnum)
let pline = getline(lnum)
if pline =~ '\(begin\|<<\|g\=save\|{\|[\)\s*\(%.*\)\=$'
let ind = ind + shiftwidth()
endif
if pline =~ '\(end\|g\=restore\)\s*$'
let ind = ind - shiftwidth()
elseif getline(a:lnum) =~ '\(end\|>>\|g\=restore\|}\|]\)'
let ind = ind - shiftwidth()
elseif getline(a:lnum) =~ '^\s*%%'
let ind = 0
endif
if ind < 0
let ind = -1
endif
return ind
endfunction
