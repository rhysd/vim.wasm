if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal nosmartindent
setlocal noautoindent
setlocal indentexpr=GetDosBatchIndent(v:lnum)
setlocal indentkeys=!^F,o,O
setlocal indentkeys+=0=)
if exists("*GetDosBatchIndent")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
function! GetDosBatchIndent(lnum)
let l:prevlnum = prevnonblank(a:lnum-1)
if l:prevlnum == 0
return 0
endif
let l:prevl = substitute(getline(l:prevlnum), '\c^\s*\%(@\s*\)\?rem\>.*$', '', '')
let l:thisl = getline(a:lnum)
let l:previ = indent(l:prevlnum)
let l:ind = l:previ
if l:prevl =~? '^\s*@\=if\>.*(\s*$' ||
\ l:prevl =~? '\<do\>\s*(\s*$' ||
\ l:prevl =~? '\<else\>\s*\%(if\>.*\)\?(\s*$' ||
\ l:prevl =~? '^.*\(&&\|||\)\s*(\s*$'
let l:ind += shiftwidth()
endif
if l:thisl =~ '^\s*)'
let l:ind -= shiftwidth()
endif
return l:ind
endfunction
let &cpo = s:cpo_save
unlet s:cpo_save
