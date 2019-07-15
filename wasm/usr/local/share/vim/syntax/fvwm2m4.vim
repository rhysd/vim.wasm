if exists('b:current_syntax')
finish
endif
if !exists('main_syntax')
let main_syntax = 'fvwm2m4'
endif
runtime! syntax/m4.vim
unlet b:current_syntax
runtime! syntax/fvwm.vim
unlet b:current_syntax
let b:current_syntax = 'fvwm2m4'
if main_syntax == 'fvwm2m4'
unlet main_syntax
endif
