if exists('b:did_indent')
finish
endif
let b:did_indent = 1
setlocal nolisp
setlocal autoindent
setlocal indentexpr=GoIndent(v:lnum)
setlocal indentkeys+=<:>,0=},0=)
if exists('*GoIndent')
finish
endif
function! GoIndent(lnum)
let l:prevlnum = prevnonblank(a:lnum-1)
if l:prevlnum == 0
return 0
endif
let l:prevl = substitute(getline(l:prevlnum), '//.*$', '', '')
let l:thisl = substitute(getline(a:lnum), '//.*$', '', '')
let l:previ = indent(l:prevlnum)
let l:ind = l:previ
if l:prevl =~ '[({]\s*$'
let l:ind += shiftwidth()
endif
if l:prevl =~# '^\s*\(case .*\|default\):$'
let l:ind += shiftwidth()
endif
if l:thisl =~ '^\s*[)}]'
let l:ind -= shiftwidth()
endif
if l:thisl =~# '^\s*\(case .*\|default\):$'
let l:ind -= shiftwidth()
endif
return l:ind
endfunction
