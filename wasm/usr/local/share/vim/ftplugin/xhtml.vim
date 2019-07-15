if exists("b:did_ftplugin") | finish | endif
let s:save_cpo = &cpo
set cpo-=C
let s:undo_ftplugin = ""
let s:browsefilter = "HTML Files (*.html, *.htm)\t*.html;*.htm\n" .
\	     "XML Files (*.xml)\t*.xml\n" .
\	     "All Files (*.*)\t*.*\n"
let s:match_words = ""
runtime! ftplugin/xml.vim ftplugin/xml_*.vim ftplugin/xml/*.vim
unlet b:did_ftplugin
if exists("b:undo_ftplugin")
let s:undo_ftplugin = b:undo_ftplugin
unlet b:undo_ftplugin
endif
if exists("b:browsefilter")
let s:browsefilter = b:browsefilter
unlet b:browsefilter
endif
if exists("b:match_words")
let s:match_words = b:match_words
unlet b:match_words
endif
runtime! ftplugin/html.vim ftplugin/html_*.vim ftplugin/html/*.vim
let b:did_ftplugin = 1
if exists("b:undo_ftplugin")
let s:undo_ftplugin = b:undo_ftplugin . " | " . s:undo_ftplugin
endif
if exists("b:browsefilter")
let s:browsefilter = b:browsefilter . s:browsefilter
endif
if exists("b:match_words")
let s:match_words = b:match_words . "," . s:match_words
endif
if exists("loaded_matchit")
let b:match_words = s:match_words
endif
if has("gui_win32")
let  b:browsefilter="XHTML files (*.xhtml, *.xhtm)\t*.xhtml;*.xhtm\n" . s:browsefilter
endif
let b:undo_ftplugin = "unlet! b:browsefilter b:match_words | " . s:undo_ftplugin
let &cpo = s:save_cpo
unlet s:save_cpo
