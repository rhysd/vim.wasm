if exists("b:current_syntax")
finish
endif
runtime! syntax/c.vim
unlet b:current_syntax
syn keyword	chStatement	new delete this foreach
syn keyword	chAccess	public private
syn keyword	chStorageClass	__declspec(global) __declspec(local)
syn keyword	chStructure	class
syn keyword	chType		string_t array
hi def link chAccess		chStatement
hi def link chExceptions		Exception
hi def link chStatement		Statement
hi def link chType			Type
hi def link chStructure		Structure
let b:current_syntax = "ch"
