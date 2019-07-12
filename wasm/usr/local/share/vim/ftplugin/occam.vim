if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:keepcpo= &cpo
set cpo&vim
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal formatoptions-=t formatoptions+=cql
setlocal comments+=:--
setlocal textwidth=78
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "All Occam Files (*.occ *.inc)\t*.occ;*.inc\n" .
\ "Occam Include Files (*.inc)\t*.inc\n" .
\ "Occam Source Files (*.occ)\t*.occ\n" .
\ "All Files (*.*)\t*.*\n"
endif
let b:undo_ftplugin = "setlocal shiftwidth< softtabstop< expandtab<"
\ . " formatoptions< comments< textwidth<"
\ . "| unlet! b:browsefiler"
let &cpo = s:keepcpo
unlet s:keepcpo
