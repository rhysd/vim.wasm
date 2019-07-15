if exists("b:current_syntax")
finish
endif
runtime! syntax/xml.vim
let b:current_syntax = "svg"
