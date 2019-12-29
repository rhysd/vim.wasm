if exists("b:did_indent")
finish
endif
unlet! b:is_sh
unlet! b:is_kornshell
let b:is_bash = 1
runtime! indent/sh.vim
