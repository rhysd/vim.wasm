if exists("b:did_ftplugin") | finish | endif
let s:save_cpo = &cpo
set cpo-=C
let s:undo_ftplugin = ""
let s:browsefilter = "XML Files (*.xml)\t*.xml\n" .
\	     "All Files (*.*)\t*.*\n"
runtime! ftplugin/xml.vim ftplugin/xml_*.vim ftplugin/xml/*.vim
let b:did_ftplugin = 1
if exists("b:undo_ftplugin")
let s:undo_ftplugin = b:undo_ftplugin
endif
if exists("b:browsefilter")
let s:browsefilter = b:browsefilter
endif
if has("gui_win32")
let  b:browsefilter="SGML Files (*.sgml,*.sgm)\t*.sgm*\n" . s:browsefilter
endif
let b:undo_ftplugin = "unlet! b:browsefilter | " . s:undo_ftplugin
let &cpo = s:save_cpo
unlet s:save_cpo
