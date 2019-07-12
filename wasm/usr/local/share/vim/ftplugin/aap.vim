if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let b:undo_ftplugin = "setl fo< com< et<"
setlocal fo-=t fo+=croql
setlocal comments=s:#\ -,m:#\ \ ,e:#,n:#,fb:-
setlocal expandtab
