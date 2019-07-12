if exists("b:did_indent")
finish
endif
runtime! indent/sh.vim          " will set b:did_indent
setlocal indentexpr=GetConfigIndent()
setlocal indentkeys=!^F,o,O,=then,=do,=else,=elif,=esac,=fi,=fin,=fil,=done
setlocal nosmartindent
if exists("*GetConfigIndent")
finish
endif
function s:GetOffsetOf(line, regexp)
let end = matchend(a:line, a:regexp)
let width = 0
let i = 0
while i < end
if a:line[i] != "\t"
let width = width + 1
else
let width = width + &ts - (width % &ts)
endif
let i = i + 1
endwhile
return width
endfunction
function GetConfigIndent()
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let ind = GetShIndent()
let line = getline(lnum)
if line =~ '\\\@<!([^)]*$'
let ind = s:GetOffsetOf(line, '\\\@!(')
endif
if line =~ '\[[^]]*$'
let ind = s:GetOffsetOf(line, '\[')
endif
if line =~ '[^(]\+\\\@<!)$'
call search(')', 'bW')
let lnum = searchpair('\\\@<!(', '', ')', 'bWn')
let ind = indent(lnum)
endif
if line =~ '[^[]\+]$'
call search(']', 'bW')
let lnum = searchpair('\[', '', ']', 'bWn')
let ind = indent(lnum)
endif
return ind
endfunction
