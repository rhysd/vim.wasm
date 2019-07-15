if exists("b:did_ftplugin")
finish
endif
runtime! ftplugin/sass.vim
setlocal comments=s1:/*,mb:*,ex:*/,://
