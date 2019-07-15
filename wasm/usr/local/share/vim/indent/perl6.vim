if exists("b:did_indent")
finish
endif
let b:did_indent = 1
let b:indent_use_syntax = has("syntax")
setlocal indentexpr=GetPerl6Indent()
setlocal indentkeys&
setlocal indentkeys+=0=,0),0],0>,0»,0=or,0=and
if !b:indent_use_syntax
setlocal indentkeys+=0=EO
endif
let s:cpo_save = &cpo
set cpo-=C
function! GetPerl6Indent()
let cline = getline(v:lnum)
if cline =~ '^\s*=\L\@!'
return 0
endif
if cline =~ '^#'
return 0
endif
let csynid = ''
if b:indent_use_syntax
let csynid = synIDattr(synID(v:lnum,1,0),"name")
endif
if csynid =~ "^p6Pod"
return indent(v:lnum)
endif
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let line = getline(lnum)
let ind = indent(lnum)
if b:indent_use_syntax
let skippin = 2
while skippin
let synid = synIDattr(synID(lnum,1,0),"name")
if (synid =~ "^p6Pod" || synid =~ "p6Comment")
let lnum = prevnonblank(lnum - 1)
if lnum == 0
return 0
endif
let line = getline(lnum)
let ind = indent(lnum)
let skippin = 1
else
let skippin = 0
endif
endwhile
endif
if line =~ '[<«\[{(]\s*\(#[^)}\]»>]*\)\=$'
let ind = ind + shiftwidth()
endif
if cline =~ '^\s*[)}\]»>]'
let ind = ind - shiftwidth()
endif
if cline =~ '^\s*\(or\|and\)\>'
if line !~ '^\s*\(or\|and\)\>'
let ind = ind + shiftwidth()
endif
elseif line =~ '^\s*\(or\|and\)\>'
let ind = ind - shiftwidth()
endif
return ind
endfunction
let &cpo = s:cpo_save
unlet s:cpo_save
