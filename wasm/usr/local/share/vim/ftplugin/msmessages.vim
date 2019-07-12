if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo-=C
let b:undo_ftplugin = "setl fo< com< cms< | unlet! b:browsefilter"
setlocal fo-=ct fo+=roql
setlocal comments=:;,:;//,:;\ //,s:;\ /*\ ,m:;\ \ *\ ,e:;\ \ */
setlocal commentstring=;\ //\ %s
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "MS Message Files (*.mc)\t*.mc\n" .
\ "Resource Files (*.rc)\t*.rc\n" .
\ "All Files (*.*)\t*.*\n"
endif
let &cpo = s:cpo_save
unlet s:cpo_save
