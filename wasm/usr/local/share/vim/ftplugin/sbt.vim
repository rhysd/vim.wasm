if exists('b:did_ftplugin') || &cp
finish
endif
let b:did_ftplugin = 1
runtime! ftplugin/scala.vim
