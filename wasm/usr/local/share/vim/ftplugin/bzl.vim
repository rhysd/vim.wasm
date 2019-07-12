if exists('b:did_ftplugin')
finish
endif
let s:save_expandtab = &l:expandtab
let s:save_shiftwidth = &l:shiftwidth
let s:save_softtabstop = &l:softtabstop
let s:save_tabstop = &l:tabstop
let s:save_cpo = &cpo
set cpo&vim
source $VIMRUNTIME/ftplugin/python.vim
setlocal comments=b:#,fb:-
let &l:expandtab = s:save_expandtab
let &l:shiftwidth = s:save_shiftwidth
let &l:softtabstop = s:save_softtabstop
let &l:tabstop = s:save_tabstop
setlocal formatoptions-=t
setlocal includeexpr=substitute(v:fname,'//','','')
if get(g:, 'ft_bzl_fold', 0)
setlocal foldmethod=syntax
setlocal foldtext=BzlFoldText()
endif
if exists('*BzlFoldText')
finish
endif
function BzlFoldText() abort
let l:start_num = nextnonblank(v:foldstart)
let l:end_num = prevnonblank(v:foldend)
if l:end_num <= l:start_num + 1
let l:content = ''
else
let l:content = '...'
for l:line in getline(l:start_num + 1, l:end_num - 1)
let l:content_match = matchstr(l:line, '\m\C^\s*name = \zs.*\ze,$')
if !empty(l:content_match)
let l:content = l:content_match
break
endif
endfor
endif
let l:start_text = getline(l:start_num)
let l:end_text = substitute(getline(l:end_num), '^\s*', '', '')
let l:text = l:start_text . ' ' . l:content . ' ' . l:end_text
let l:width = winwidth(0) - &foldcolumn - (&number ? &numberwidth : 0)
let l:lines_folded = ' ' . string(1 + v:foldend - v:foldstart) . ' lines'
let l:text = substitute(l:text, '\t', repeat(' ', &tabstop), 'g')
let l:text = strpart(l:text, 0, l:width - len(l:lines_folded))
let l:padding = repeat(' ', l:width - len(l:lines_folded) - len(l:text))
return l:text . l:padding . l:lines_folded
endfunction
let &cpo = s:save_cpo
unlet s:save_cpo
