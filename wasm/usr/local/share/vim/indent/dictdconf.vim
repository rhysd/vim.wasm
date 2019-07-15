if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentkeys=0{,0},!^F,o,O cinwords= autoindent smartindent
setlocal nosmartindent
inoremap <buffer> # X#
