if exists("b:current_syntax")
finish
endif
unlet! b:is_sh
unlet! b:is_kornshell
let b:is_bash = 1
runtime! syntax/sh.vim
let b:current_syntax = 'bash'
