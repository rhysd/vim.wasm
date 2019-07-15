if exists("b:current_syntax")
finish
endif
syn keyword slStatement	break return continue
syn keyword slConditional	if else
syn keyword slRepeat		while for
syn keyword slRepeat		illuminance illuminate solar
syn keyword slTodo contained	TODO FIXME XXX
syn match slSpecial contained	"\\[0-9][0-9][0-9]\|\\."
syn region slString		start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=slSpecial
syn match slCharacter		"'[^\\]'"
syn match slSpecialCharacter	"'\\.'"
syn match slSpecialCharacter	"'\\[0-9][0-9]'"
syn match slSpecialCharacter	"'\\[0-9][0-9][0-9]'"
syn region slParen		transparent start='(' end=')' contains=ALLBUT,slParenError,slIncluded,slSpecial,slTodo,slUserLabel
syn match slParenError		")"
syn match slInParen contained	"[{}]"
syn case ignore
syn match slNumber		"\<[0-9]\+\(u\=l\=\|lu\|f\)\>"
syn match slFloat		"\<[0-9]\+\.[0-9]*\(e[-+]\=[0-9]\+\)\=[fl]\=\>"
syn match slFloat		"\.[0-9]\+\(e[-+]\=[0-9]\+\)\=[fl]\=\>"
syn match slFloat		"\<[0-9]\+e[-+]\=[0-9]\+[fl]\=\>"
syn match slNumber		"\<0x[0-9a-f]\+\(u\=l\=\|lu\)\>"
syn case match
if exists("sl_comment_strings")
syntax match slCommentSkip	contained "^\s*\*\($\|\s\+\)"
syntax region slCommentString	contained start=+"+ skip=+\\\\\|\\"+ end=+"+ end=+\*/+me=s-1 contains=slSpecial,slCommentSkip
syntax region slComment2String	contained start=+"+ skip=+\\\\\|\\"+ end=+"+ end="$" contains=slSpecial
syntax region slComment	start="/\*" end="\*/" contains=slTodo,slCommentString,slCharacter,slNumber
else
syn region slComment		start="/\*" end="\*/" contains=slTodo
endif
syntax match slCommentError	"\*/"
syn keyword slOperator	sizeof
syn keyword slType		float point color string vector normal matrix void
syn keyword slStorageClass	varying uniform extern
syn keyword slStorageClass	light surface volume displacement transformation imager
syn keyword slVariable	Cs Os P dPdu dPdv N Ng u v du dv s t
syn keyword slVariable L Cl Ol E I ncomps time Ci Oi
syn keyword slVariable Ps alpha
syn keyword slVariable dtime dPdtime
syn sync ccomment slComment minlines=10
hi def link slLabel	Label
hi def link slUserLabel	Label
hi def link slConditional	Conditional
hi def link slRepeat	Repeat
hi def link slCharacter	Character
hi def link slSpecialCharacter slSpecial
hi def link slNumber	Number
hi def link slFloat	Float
hi def link slParenError	slError
hi def link slInParen	slError
hi def link slCommentError	slError
hi def link slOperator	Operator
hi def link slStorageClass	StorageClass
hi def link slError	Error
hi def link slStatement	Statement
hi def link slType		Type
hi def link slCommentError	slError
hi def link slCommentString slString
hi def link slComment2String slString
hi def link slCommentSkip	slComment
hi def link slString	String
hi def link slComment	Comment
hi def link slSpecial	SpecialChar
hi def link slTodo	Todo
hi def link slVariable	Identifier
let b:current_syntax = "sl"
