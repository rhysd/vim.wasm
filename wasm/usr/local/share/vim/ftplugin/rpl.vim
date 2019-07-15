if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
setlocal fo-=t fo+=croql
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
let b:undo_ftplugin = "setlocal fo< comments<"
