if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal nolisp " Make sure lisp indenting doesn't supersede us.
setlocal indentexpr=GetPoVRayIndent()
setlocal indentkeys+==else,=end,0]
if exists("*GetPoVRayIndent")
finish
endif
function! s:MatchCount(line, rexp)
let str = getline(a:line)
let i = 0
let n = 0
while i >= 0
let i = matchend(str, a:rexp, i)
if i >= 0 && synIDattr(synID(a:line, i, 0), "name") !~? "string\|comment"
let n = n + 1
endif
endwhile
return n
endfunction
function GetPoVRayIndent()
if synIDattr(synID(v:lnum, indent(v:lnum)+1, 0), "name") =~? "string\|comment"
return -1
endif
let plnum = prevnonblank(v:lnum - 1)
let plind = indent(plnum)
while plnum > 0 && synIDattr(synID(plnum, plind+1, 0), "name") =~? "comment"
let plnum = prevnonblank(plnum - 1)
let plind = indent(plnum)
endwhile
if plnum == 0
return 0
endif
let chg = 0
let chg = chg + s:MatchCount(plnum, '[[{(]')
let chg = chg + s:MatchCount(plnum, '#\s*\%(if\|ifdef\|ifndef\|switch\|while\|macro\|else\)\>')
let chg = chg - s:MatchCount(plnum, '#\s*end\>')
let chg = chg - s:MatchCount(plnum, '[]})]')
let chg = chg - s:MatchCount(plnum, '#\s*\%(if\|ifdef\|ifndef\|switch\)\>.*#\s*else\>')
let chg = chg > 0 ? chg : 0
let cur = s:MatchCount(v:lnum, '^\s*\%(#\s*\%(end\|else\)\>\|[]})]\)')
if cur > 0
let final = plind + (chg - cur) * shiftwidth()
else
let final = plind + chg * shiftwidth()
endif
return final < 0 ? 0 : final
endfunction
