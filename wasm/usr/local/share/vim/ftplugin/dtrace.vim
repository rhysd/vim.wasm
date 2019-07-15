if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo-=C
let b:undo_ftplugin = "setl fo< com< cms< isk<"
setlocal fo-=t fo+=croql
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/
setlocal commentstring=/*%s*/
setlocal iskeyword+=@,$
let b:match_words = &matchpairs
let b:match_skip = 's:comment\|string\|character'
let &cpo = s:cpo_save
unlet s:cpo_save
