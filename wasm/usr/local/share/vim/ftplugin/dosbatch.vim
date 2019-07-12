if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo&vim
setlocal comments=b:rem,b:@rem,b:REM,b:@REM,:::
setlocal commentstring=::\ %s
setlocal formatoptions-=t formatoptions+=rol
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "DOS Batch Files (*.bat, *.cmd)\t*.bat;*.cmd\nAll Files (*.*)\t*.*\n"
endif
let b:undo_ftplugin = "setlocal comments< formatoptions<"
\ . "| unlet! b:browsefiler"
let &cpo = s:cpo_save
unlet s:cpo_save
