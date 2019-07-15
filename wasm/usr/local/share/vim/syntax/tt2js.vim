if exists("b:current_syntax")
finish
endif
runtime! syntax/javascript.vim
unlet b:current_syntax
runtime! syntax/tt2.vim
unlet b:current_syntax
syn cluster javascriptPreProc add=@tt2_top_cluster
let b:current_syntax = "tt2js"
