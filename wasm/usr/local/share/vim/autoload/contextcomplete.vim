let s:keepcpo= &cpo
set cpo&vim
function! contextcomplete#Complete(findstart, base)
if a:findstart == 1
if len(synstack(line('.'), 1)) > 0 &&
\ synIDattr(synstack(line('.'), 1)[0], "name") ==# 'contextMPGraphic'
return syntaxcomplete#Complete(a:findstart, a:base)
else
return -3
endif
else
return syntaxcomplete#Complete(a:findstart, a:base)
endif
endfunction
let &cpo = s:keepcpo
unlet s:keepcpo
