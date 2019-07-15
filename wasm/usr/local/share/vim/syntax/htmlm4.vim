if exists("b:current_syntax")
finish
endif
if !exists("main_syntax")
let main_syntax='htmlm4'
endif
runtime! syntax/html.vim
unlet b:current_syntax
syn case match
runtime! syntax/m4.vim
unlet b:current_syntax
syn cluster htmlPreproc add=@m4Top
syn cluster m4StringContents add=htmlTag,htmlEndTag
let b:current_syntax = "htmlm4"
if main_syntax == 'htmlm4'
unlet main_syntax
endif
