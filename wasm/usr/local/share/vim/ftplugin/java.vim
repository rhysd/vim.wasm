if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1
let s:save_cpo = &cpo
set cpo-=C
set suffixes+=.class
setlocal includeexpr=substitute(v:fname,'\\.','/','g')
setlocal suffixesadd=.java
if exists("g:ftplugin_java_source_path")
let &l:path=g:ftplugin_java_source_path . ',' . &l:path
endif
setlocal formatoptions-=t formatoptions+=croql
setlocal comments& comments^=sO:*\ -,mO:*\ \ ,exO:*/
setlocal commentstring=//%s
if has("gui_win32")
let  b:browsefilter="Java Files (*.java)\t*.java\n" .
\	"Properties Files (*.prop*)\t*.prop*\n" .
\	"Manifest Files (*.mf)\t*.mf\n" .
\	"All Files (*.*)\t*.*\n"
endif
let b:undo_ftplugin = "setlocal suffixes< suffixesadd<" .
\     " formatoptions< comments< commentstring< path< includeexpr<" .
\     " | unlet! b:browsefilter"
let &cpo = s:save_cpo
unlet s:save_cpo
