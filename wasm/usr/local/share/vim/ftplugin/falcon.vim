if (exists("b:did_ftplugin"))
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo&vim
setlocal softtabstop=4 shiftwidth=4 fileencoding=utf-8
setlocal suffixesadd=.fal,.ftd
if exists("loaded_matchit") && !exists("b:match_words")
let b:match_ignorecase = 0
let b:match_words =
\ '\<\%(if\|case\|while\|until\|for\|do\|class\)\>=\@!' .
\ ':' .
\ '\<\%(else\|elsif\|when\)\>' .
\ ':' .
\ '\<end\>' .
\ ',{:},\[:\],(:)'
endif
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "Falcon Source Files (*.fal *.ftd)\t*.fal;*.ftd\n" .
\ "All Files (*.*)\t*.*\n"
endif
let b:undo_ftplugin = "setlocal tabstop< shiftwidth< expandtab< fileencoding<"
\ . " suffixesadd< comments<"
\ . "| unlet! b:browsefiler"
let &cpo = s:cpo_save
unlet s:cpo_save
