if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo-=C
setlocal comments=:#
setlocal commentstring=#%s
setlocal formatoptions+=croql
if has("gui_win32")
let b:browsefilter = "Tcl Source Files (.tcl)\t*.tcl\n" .
\ "Tcl Test Files (.test)\t*.test\n" .
\ "All Files (*.*)\t*.*\n"
endif
let b:undo_ftplugin = "setlocal fo< com< cms< inc< inex< def< isf< kp<" .
\	      " | unlet! b:browsefilter"
let &cpo = s:cpo_save
unlet s:cpo_save
