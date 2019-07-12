if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo&vim
setlocal comments=b:%
setlocal formatoptions-=t formatoptions+=rol
if !exists("b:match_words")
let b:match_ignorecase = 0
let b:match_words = '<<:>>,\<begin\>:\<end\>,\<save\>:\<restore\>,\<gsave\>:\<grestore\>'
endif
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "PostScript Files (*.ps)\t*.ps\n" .
\ "EPS Files (*.eps)\t*.eps\n" .
\ "All Files (*.*)\t*.*\n"
endif
let b:undo_ftplugin = "setlocal comments< formatoptions<"
\ . "| unlet! b:browsefiler b:match_ignorecase b:match_words"
let &cpo = s:cpo_save
unlet s:cpo_save
