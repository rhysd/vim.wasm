if exists("b:current_syntax")
finish
endif
runtime! syntax/c.vim
let b:current_syntax = "xs"
