if exists("b:current_syntax")
finish
endif
runtime! syntax/html.vim
unlet b:current_syntax
runtime! syntax/tt2.vim
unlet b:current_syntax
syn cluster htmlPreProc add=@tt2_top_cluster
let b:current_syntax = "tt2html"
