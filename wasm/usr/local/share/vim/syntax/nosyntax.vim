if !has("syntax")
finish
endif
au! Syntax
augroup syntaxset
au!
au BufEnter * syn clear
au BufEnter * if exists("b:current_syntax") | unlet b:current_syntax | endif
doautoall syntaxset BufEnter *
au!
augroup END
if exists("syntax_on")
unlet syntax_on
endif
if exists("syntax_manual")
unlet syntax_manual
endif
