if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
runtime! syntax/xml.vim
unlet b:current_syntax
syn include @javascriptTop syntax/javascript.vim
unlet b:current_syntax
syn region xblJavascript
\ matchgroup=xmlCdataStart start=+<!\[CDATA\[+
\ matchgroup=xmlCdataEnd end=+]]>+
\ contains=@javascriptTop keepend extend
let b:current_syntax = "xbl"
let &cpo = s:cpo_save
unlet s:cpo_save
