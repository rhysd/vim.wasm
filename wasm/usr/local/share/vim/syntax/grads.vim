if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword gradsStatement	if else endif break exit return
syn keyword gradsStatement	while endwhile say prompt pull function
syn keyword gradsStatement subwrd sublin substr read write close
syn region gradsString		start=+'+ end=+'+
syn match  gradsNumber		"[+-]\=\<[0-9]\+\>"
syn keyword gradsFixVariables	lat lon lev result rec rc
syn match gradsglobalVariables	"_[a-zA-Z][a-zA-Z0-9]*"
syn match gradsVariables		"[a-zA-Z][a-zA-Z0-9]*"
syn match gradsConst		"#[A-Z][A-Z_]+"
syn match gradsComment	"\*.*"
hi def link gradsStatement		Statement
hi def link gradsString		String
hi def link gradsNumber		Number
hi def link gradsFixVariables	Special
hi def link gradsVariables		Identifier
hi def link gradsglobalVariables	Special
hi def link gradsConst		Special
hi def link gradsClassMethods	Function
hi def link gradsOperator		Operator
hi def link gradsComment		Comment
hi def link gradsTypos		Error
let b:current_syntax = "grads"
