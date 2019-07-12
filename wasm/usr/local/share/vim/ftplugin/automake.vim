if exists("b:did_ftplugin")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
runtime! ftplugin/make.vim ftplugin/make_*.vim ftplugin/make/*.vim
let &cpo = s:cpo_save
unlet s:cpo_save
