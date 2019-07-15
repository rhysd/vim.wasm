if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal nolisp		" Make sure lisp indenting doesn't supersede us
setlocal autoindent	" indentexpr isn't much help otherwise
setlocal indentexpr=GetPythonIndent(v:lnum)
setlocal indentkeys+=<:>,=elif,=except
if exists("*GetPythonIndent")
finish
endif
let s:keepcpo= &cpo
set cpo&vim
let s:maxoff = 50	" maximum number of lines to look backwards for ()
function GetPythonIndent(lnum)
if getline(a:lnum - 1) =~ '\\$'
if a:lnum > 1 && getline(a:lnum - 2) =~ '\\$'
return indent(a:lnum - 1)
endif
return indent(a:lnum - 1) + (exists("g:pyindent_continue") ? eval(g:pyindent_continue) : (shiftwidth() * 2))
endif
if has('syntax_items')
\ && synIDattr(synID(a:lnum, 1, 1), "name") =~ "String$"
return -1
endif
let plnum = prevnonblank(v:lnum - 1)
if plnum == 0
return 0
endif
call cursor(plnum, 1)
let disable_parentheses_indenting = get(g:, "pyindent_disable_parentheses_indenting", 0)
if disable_parentheses_indenting == 1
let plindent = indent(plnum)
let plnumstart = plnum
else
let searchpair_stopline = 0
let searchpair_timeout = get(g:, 'pyindent_searchpair_timeout', 150)
let parlnum = searchpair('(\|{\|\[', '', ')\|}\|\]', 'nbW',
\ "line('.') < " . (plnum - s:maxoff) . " ? dummy :"
\ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
\ . " =~ '\\(Comment\\|Todo\\|String\\)$'",
\ searchpair_stopline, searchpair_timeout)
if parlnum > 0
let plindent = indent(parlnum)
let plnumstart = parlnum
else
let plindent = indent(plnum)
let plnumstart = plnum
endif
call cursor(a:lnum, 1)
let p = searchpair('(\|{\|\[', '', ')\|}\|\]', 'bW',
\ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :"
\ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
\ . " =~ '\\(Comment\\|Todo\\|String\\)$'",
\ searchpair_stopline, searchpair_timeout)
if p > 0
if p == plnum
let pp = searchpair('(\|{\|\[', '', ')\|}\|\]', 'bW',
\ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :"
\ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
\ . " =~ '\\(Comment\\|Todo\\|String\\)$'",
\ searchpair_stopline, searchpair_timeout)
if pp > 0
return indent(plnum) + (exists("g:pyindent_nested_paren") ? eval(g:pyindent_nested_paren) : shiftwidth())
endif
return indent(plnum) + (exists("g:pyindent_open_paren") ? eval(g:pyindent_open_paren) : (shiftwidth() * 2))
endif
if plnumstart == p
return indent(plnum)
endif
return plindent
endif
endif
let pline = getline(plnum)
let pline_len = strlen(pline)
if has('syntax_items')
if synIDattr(synID(plnum, pline_len, 1), "name") =~ "\\(Comment\\|Todo\\)$"
let min = 1
let max = pline_len
while min < max
let col = (min + max) / 2
if synIDattr(synID(plnum, col, 1), "name") =~ "\\(Comment\\|Todo\\)$"
let max = col
else
let min = col + 1
endif
endwhile
let pline = strpart(pline, 0, min - 1)
endif
else
let col = 0
while col < pline_len
if pline[col] == '#'
let pline = strpart(pline, 0, col)
break
endif
let col = col + 1
endwhile
endif
if pline =~ ':\s*$'
return plindent + shiftwidth()
endif
if getline(plnum) =~ '^\s*\(break\|continue\|raise\|return\|pass\)\>'
if indent(a:lnum) > indent(plnum) - shiftwidth()
return indent(plnum) - shiftwidth()
endif
return -1
endif
if getline(a:lnum) =~ '^\s*\(except\|finally\)\>'
let lnum = a:lnum - 1
while lnum >= 1
if getline(lnum) =~ '^\s*\(try\|except\)\>'
let ind = indent(lnum)
if ind >= indent(a:lnum)
return -1	" indent is already less than this
endif
return ind	" line up with previous try or except
endif
let lnum = lnum - 1
endwhile
return -1		" no matching "try"!
endif
if getline(a:lnum) =~ '^\s*\(elif\|else\)\>'
if getline(plnumstart) =~ '^\s*\(for\|if\|try\)\>'
return plindent
endif
if indent(a:lnum) <= plindent - shiftwidth()
return -1
endif
return plindent - shiftwidth()
endif
if parlnum > 0
return plindent
endif
return -1
endfunction
let &cpo = s:keepcpo
unlet s:keepcpo
