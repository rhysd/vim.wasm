if exists('b:did_ftplugin') || &cp
finish
endif
let b:did_ftplugin = 1
setlocal formatoptions-=t formatoptions+=croqnl
silent! setlocal formatoptions+=j
if get(g:, 'scala_scaladoc_indent', 0)
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s2:/**,mb:*,ex:*/,s1:/*,mb:*,ex:*/,://
else
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/**,mb:*,ex:*/,s1:/*,mb:*,ex:*/,://
endif
setlocal commentstring=//\ %s
setlocal shiftwidth=2 softtabstop=2 expandtab
setlocal include='^\s*import'
setlocal includeexpr='substitute(v:fname,"\\.","/","g")'
setlocal path+=src/main/scala,src/test/scala
setlocal suffixesadd=.scala
