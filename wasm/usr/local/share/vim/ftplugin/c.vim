if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo-=C
let b:undo_ftplugin = "setl fo< com< ofu< | if has('vms') | setl isk< | endif"
setlocal fo-=t fo+=croql
if exists('&ofu')
setlocal ofu=ccomplete#Complete
endif
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
if has("vms")
setlocal iskeyword+=$
endif
let b:match_words = '^\s*#\s*if\(\|def\|ndef\)\>:^\s*#\s*elif\>:^\s*#\s*else\>:^\s*#\s*endif\>'
let b:match_skip = 's:comment\|string\|character\|special'
if (has("gui_win32") || has("gui_gtk")) && !exists("b:browsefilter")
if &ft == "cpp"
let b:browsefilter = "C++ Source Files (*.cpp *.c++)\t*.cpp;*.c++\n" .
\ "C Header Files (*.h)\t*.h\n" .
\ "C Source Files (*.c)\t*.c\n" .
\ "All Files (*.*)\t*.*\n"
elseif &ft == "ch"
let b:browsefilter = "Ch Source Files (*.ch *.chf)\t*.ch;*.chf\n" .
\ "C Header Files (*.h)\t*.h\n" .
\ "C Source Files (*.c)\t*.c\n" .
\ "All Files (*.*)\t*.*\n"
else
let b:browsefilter = "C Source Files (*.c)\t*.c\n" .
\ "C Header Files (*.h)\t*.h\n" .
\ "Ch Source Files (*.ch *.chf)\t*.ch;*.chf\n" .
\ "C++ Source Files (*.cpp *.c++)\t*.cpp;*.c++\n" .
\ "All Files (*.*)\t*.*\n"
endif
endif
let &cpo = s:cpo_save
unlet s:cpo_save
