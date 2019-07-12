if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo&vim
setlocal fo-=t fo+=croql
setlocal com=:--
setlocal cms=--%s
setlocal suffixesadd=.lua
if exists("loaded_matchit")
let b:match_ignorecase = 0
let b:match_words =
\ '\<\%(do\|function\|if\)\>:' .
\ '\<\%(return\|else\|elseif\)\>:' .
\ '\<end\>,' .
\ '\<repeat\>:\<until\>'
endif " exists("loaded_matchit")
let &cpo = s:cpo_save
unlet s:cpo_save
let b:undo_ftplugin = "setlocal fo< com< cms< suffixesadd<"
