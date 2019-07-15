if exists("b:did_ftplugin") | finish | endif
let s:save_cpo = &cpo
set cpo-=C
let s:undo_ftplugin = ""
let s:browsefilter = "csh Files (*.csh)\t*.csh\n" .
\	     "All Files (*.*)\t*.*\n"
runtime! ftplugin/csh.vim ftplugin/csh_*.vim ftplugin/csh/*.vim
let b:did_ftplugin = 1
if exists("b:undo_ftplugin")
let s:undo_ftplugin = b:undo_ftplugin
endif
if exists("b:browsefilter")
let s:browsefilter = b:browsefilter
endif
if has("gui_win32")
let  b:browsefilter="tcsh Scripts (*.tcsh)\t*.tcsh\n" . s:browsefilter
endif
let b:undo_ftplugin = "unlet! b:browsefilter | " . s:undo_ftplugin
let &cpo = s:save_cpo
unlet s:save_cpo
