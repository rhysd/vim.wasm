if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1
let s:save_cpo = &cpo
set cpo-=C
setlocal commentstring=<!--%s-->
setlocal comments=s:<!--,m:\ \ \ \ \ ,e:-->
setlocal formatoptions-=t
if !exists("g:ft_dtd_autocomment") || (g:ft_dtd_autocomment == 1)
setlocal formatoptions+=croql
endif
if exists("loaded_matchit")
let b:match_words = '<!--:-->,<!:>'
endif
if has("gui_win32")
let  b:browsefilter="DTD Files (*.dtd)\t*.dtd\n" .
\	"XML Files (*.xml)\t*.xml\n" .
\	"All Files (*.*)\t*.*\n"
endif
let b:undo_ftplugin = "setlocal commentstring< comments< formatoptions<" .
\     " | unlet! b:matchwords b:browsefilter"
let &cpo = s:save_cpo
unlet s:save_cpo
