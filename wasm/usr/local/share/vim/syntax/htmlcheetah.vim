if exists("b:current_syntax")
finish
endif
if !exists("main_syntax")
let main_syntax = 'html'
endif
runtime! syntax/cheetah.vim
runtime! syntax/html.vim
unlet b:current_syntax
syntax cluster htmlPreproc add=cheetahPlaceHolder
syntax cluster htmlString add=cheetahPlaceHolder
let b:current_syntax = "htmlcheetah"
