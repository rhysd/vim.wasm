if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetMmaIndent()
setlocal indentkeys+=0[,0],0(,0)
setlocal nosi "turn off smart indent so we don't over analyze } blocks
if exists("*GetMmaIndent")
finish
endif
function GetMmaIndent()
if v:lnum == 0
return 0
endif
let lnum = prevnonblank(v:lnum - 1)
let ind = indent(v:lnum)
let lnum = v:lnum
if getline(v:lnum-1) =~ '\\\@<!\%(\[[^\]]*\|([^)]*\|{[^}]*\)$' && getline(v:lnum) !~ '\s\+[\[({]'
let ind = ind+shiftwidth()
endif
if getline(v:lnum) =~ '[^[]*]\s*$'
call search(']','bW')
let ind = indent(searchpair('\[','',']','bWn'))
elseif getline(v:lnum) =~ '[^(]*)$'
call search(')','bW')
let ind = indent(searchpair('(','',')','bWn'))
elseif getline(v:lnum) =~ '[^{]*}'
call search('}','bW')
let ind = indent(searchpair('{','','}','bWn'))
endif
return ind
endfunction
