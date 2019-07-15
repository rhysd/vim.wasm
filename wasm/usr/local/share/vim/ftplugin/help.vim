if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo&vim
let b:undo_ftplugin = "setl fo< tw< cole< cocu< keywordprg<"
setlocal formatoptions+=tcroql textwidth=78 keywordprg=:help
if has("conceal")
setlocal cole=2 cocu=nc
endif
let &cpo = s:cpo_save
unlet s:cpo_save
