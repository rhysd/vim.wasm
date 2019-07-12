if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal nosmartindent
setlocal indentexpr=GetJSONIndent()
setlocal indentkeys=0{,0},0),0[,0],!^F,o,O,e
if exists("*GetJSONIndent")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
let s:line_term = '\s*\%(\%(\/\/\).*\)\=$'
let s:block_regex = '\%({\)\s*\%(|\%([*@]\=\h\w*,\=\s*\)\%(,\s*[*@]\=\h\w*\)*|\)\=' . s:line_term
function s:IsInString(lnum, col)
return synIDattr(synID(a:lnum, a:col, 1), 'name') == 'jsonString'
endfunction
function s:PrevNonBlankNonString(lnum)
let lnum = prevnonblank(a:lnum)
while lnum > 0
let line = getline(lnum)
if !(s:IsInString(lnum, 1) && s:IsInString(lnum, strlen(line)))
break
endif
let lnum = prevnonblank(lnum - 1)
endwhile
return lnum
endfunction
function s:LineHasOpeningBrackets(lnum)
let open_0 = 0
let open_2 = 0
let open_4 = 0
let line = getline(a:lnum)
let pos = match(line, '[][(){}]', 0)
while pos != -1
let idx = stridx('(){}[]', line[pos])
if idx % 2 == 0
let open_{idx} = open_{idx} + 1
else
let open_{idx - 1} = open_{idx - 1} - 1
endif
let pos = match(line, '[][(){}]', pos + 1)
endwhile
return (open_0 > 0) . (open_2 > 0) . (open_4 > 0)
endfunction
function s:Match(lnum, regex)
let col = match(getline(a:lnum), a:regex) + 1
return col > 0 && !s:IsInString(a:lnum, col) ? col : 0
endfunction
function GetJSONIndent()
let vcol = col('.')
let line = getline(v:lnum)
let ind = -1
let col = matchend(line, '^\s*[]}]')
if col > 0 && !s:IsInString(v:lnum, col)
call cursor(v:lnum, col)
let bs = strpart('{}[]', stridx('}]', line[col - 1]) * 2, 2)
let pairstart = escape(bs[0], '[')
let pairend = escape(bs[1], ']')
let pairline = searchpair(pairstart, '', pairend, 'bW')
if pairline > 0 
let ind = indent(pairline)
else
let ind = virtcol('.') - 1
endif
return ind
endif
if s:IsInString(v:lnum, matchend(line, '^\s*') + 1)
return indent('.')
endif
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let line = getline(lnum)
let ind = indent(lnum)
if line =~ '[[({]'
let counts = s:LineHasOpeningBrackets(lnum)
if counts[0] == '1' || counts[1] == '1' || counts[2] == '1'
return ind + shiftwidth()
else
call cursor(v:lnum, vcol)
end
endif
return ind
endfunction
let &cpo = s:cpo_save
unlet s:cpo_save
