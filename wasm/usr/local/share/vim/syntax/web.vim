if exists("b:current_syntax")
finish
endif
runtime! syntax/cweb.vim
unlet b:current_syntax
syntax include @webIncludedC <sfile>:p:h/pascal.vim
syntax match webIgnoredStuff "@[@']"
let b:current_syntax = "web"
