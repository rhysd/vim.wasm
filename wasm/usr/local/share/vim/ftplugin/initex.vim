if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:save_cpo = &cpo
set cpo&vim
let b:undo_ftplugin = "setl com< cms< define< include< sua<"
setlocal com=sO:%\ -,mO:%\ \ ,eO:%%,:%
setlocal cms=%%s
let &l:define='\\\([egx]\|char\|mathchar\|count\|dimen\|muskip\|skip\|toks\)\='
\ .	'def\|\\font\|\\\(future\)\=let'
let &l:include = '\\input'
setlocal suffixesadd=.tex
let &cpo = s:save_cpo
unlet s:save_cpo
