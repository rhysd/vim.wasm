if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let b:undo_ftplugin = "setl et< sts< fo< com< cms< inc<"
setlocal noexpandtab softtabstop=0
setlocal fo-=t fo+=croql
setlocal com=sO:#\ -,mO:#\ \ ,b:#
setlocal commentstring=#\ %s
let &l:include = '^\s*include'
if exists("loaded_matchit")
let b:match_words = '^ *ifn\=\(eq\|def\)\>:^ *else\(\s\+ifn\=\(eq\|def\)\)\=\>:^ *endif\>,\<define\>:\<endef\>,^!\s*if\(n\=def\)\=\>:^!\s*else\(if\(n\=def\)\=\)\=\>:^!\s*endif\>'
endif
