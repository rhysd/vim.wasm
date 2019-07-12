if exists("b:current_syntax")
finish
endif
syn case ignore
syn match  ecdComment	"^\s*#.*"
syn match  ecdAttr	"^\s*[a-zA-Z]\S*\s*[=].*$" contains=ecdAttrN,ecdAttrV
syn match  ecdAttrN	contained "^.*="me=e-1
syn match  ecdAttrV	contained "=.*$"ms=s+1
syn region ecdTag	start=+<+ end=+>+ contains=ecdTagN,ecdTagError
syn match  ecdTagN	contained +<[/\s]*[-a-zA-Z0-9_]\++ms=s+1
syn match  ecdTagError	contained "[^>]<"ms=s+1
hi def link ecdComment	Comment
hi def link ecdAttr	Type
hi def link ecdAttrN	Statement
hi def link ecdAttrV	Value
hi def link ecdTag		Function
hi def link ecdTagN	Statement
hi def link ecdTagError	Error
let b:current_syntax = "ecd"
