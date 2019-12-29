if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal nolisp		" Make sure lisp indenting doesn't supersede us
setlocal autoindent	" indentexpr isn't much help otherwise
setlocal indentexpr=GetMesonIndent(v:lnum)
setlocal indentkeys+==elif,=else,=endforeach,=endif,0)
if exists("*GetMesonIndent")
finish
endif
let s:keepcpo= &cpo
set cpo&vim
let s:maxoff = 50	" maximum number of lines to look backwards for ()
function GetMesonIndent(lnum)
echom getline(line("."))
if getline(a:lnum - 1) =~ '\\$'
if a:lnum > 1 && getline(a:lnum - 2) =~ '\\$'
return indent(a:lnum - 1)
endif
return indent(a:lnum - 1) + (exists("g:mesonindent_continue") ? eval(g:mesonindent_continue) : (shiftwidth() * 2))
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
let parlnum = searchpair('(\|{\|\[', '', ')\|}\|\]', 'nbW',
\ "line('.') < " . (plnum - s:maxoff) . " ? dummy :"
\ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
\ . " =~ '\\(Comment\\|Todo\\|String\\)$'")
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
\ . " =~ '\\(Comment\\|Todo\\|String\\)$'")
if p > 0
if p == plnum
let pp = searchpair('(\|{\|\[', '', ')\|}\|\]', 'bW',
\ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :"
\ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
\ . " =~ '\\(Comment\\|Todo\\|String\\)$'")
if pp > 0
return indent(plnum) + (exists("g:pyindent_nested_paren") ? eval(g:pyindent_nested_paren) : shiftwidth())
endif
return indent(plnum) + (exists("g:pyindent_open_paren") ? eval(g:pyindent_open_paren) : shiftwidth())
endif
if plnumstart == p
return indent(plnum)
endif
return plindent
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
if getline(plnum) =~ '^\s*\(endif\|endforeach\)\>\s*'
return -1
endif
if pline =~ '^\s*\(foreach\|if\|else\|elif\)\>\s*'
return plindent + shiftwidth()
endif
if getline(a:lnum) =~ '^\s*\(else\|elif\|endif\|endforeach\)'
if getline(plnumstart) =~ '^\s*\(foreach\|if\)\>\s*'
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
