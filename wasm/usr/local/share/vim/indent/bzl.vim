if exists('b:did_indent')
finish
endif
if !exists('*GetPythonIndent')
runtime! indent/python.vim
endif
let b:did_indent = 1
if !get(g:, 'no_google_python_indent')
setlocal indentexpr=GetBzlIndent(v:lnum)
endif
if exists('*GetBzlIndent')
finish
endif
let s:save_cpo = &cpo
set cpo-=C
let s:maxoff = 50
function GetBzlIndent(lnum) abort
let l:use_recursive_indent = !get(g:, 'no_google_python_recursive_indent')
if l:use_recursive_indent
if exists('g:pyindent_nested_paren')
let l:pyindent_nested_paren = g:pyindent_nested_paren
endif
if exists('g:pyindent_open_paren')
let l:pyindent_open_paren = g:pyindent_open_paren
endif
let g:pyindent_nested_paren = 'shiftwidth() * 2'
let g:pyindent_open_paren = 'shiftwidth() * 2'
endif
let l:indent = -1
call cursor(a:lnum, 1)
let [l:par_line, l:par_col] = searchpairpos('(\|{\|\[', '', ')\|}\|\]', 'bW',
\ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :" .
\ " synIDattr(synID(line('.'), col('.'), 1), 'name')" .
\ " =~ '\\(Comment\\|String\\)$'")
if l:par_line > 0
call cursor(l:par_line, 1)
if l:par_col != col('$') - 1
let l:indent = l:par_col
endif
endif
if l:indent == -1
let l:indent = GetPythonIndent(a:lnum)
endif
if l:use_recursive_indent
if exists('l:pyindent_nested_paren')
let g:pyindent_nested_paren = l:pyindent_nested_paren
else
unlet g:pyindent_nested_paren
endif
if exists('l:pyindent_open_paren')
let g:pyindent_open_paren = l:pyindent_open_paren
else
unlet g:pyindent_open_paren
endif
endif
return l:indent
endfunction
let &cpo = s:save_cpo
unlet s:save_cpo
