if exists("b:current_syntax")
finish
endif
syn case ignore
syn region  catalogString start=+"+ skip=+\\\\\|\\"+ end=+"+ keepend
syn region  catalogString start=+'+ skip=+\\\\\|\\'+ end=+'+ keepend
syn region  catalogComment      start=+--+   end=+--+ contains=catalogTodo
syn keyword catalogTodo		TODO FIXME XXX NOTE contained
syn keyword catalogKeyword	DOCTYPE OVERRIDE PUBLIC DTDDECL ENTITY CATALOG
hi def link catalogString		     String
hi def link catalogComment		     Comment
hi def link catalogTodo			     Todo
hi def link catalogKeyword		     Statement
let b:current_syntax = "catalog"
