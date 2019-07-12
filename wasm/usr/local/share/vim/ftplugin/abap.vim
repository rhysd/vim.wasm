if (exists("b:did_ftplugin"))
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo&vim
setlocal softtabstop=2 shiftwidth=2
setlocal suffixesadd=.abap
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "ABAP Source Files (*.abap)\t*.abap\n" .
\ "All Files (*.*)\t*.*\n"
endif
let &cpo = s:cpo_save
unlet s:cpo_save
