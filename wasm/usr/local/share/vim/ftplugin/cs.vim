if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:keepcpo= &cpo
set cpo&vim
setlocal fo-=t fo+=croql
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,:///,://
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "C# Source Files (*.cs)\t*.cs\n" .
\ "All Files (*.*)\t*.*\n"
endif
let &cpo = s:keepcpo
unlet s:keepcpo
