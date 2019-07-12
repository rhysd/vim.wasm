if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword aveStatement	if then elseif else end break exit return
syn keyword aveStatement	for each in continue while
syn region aveString		start=+"+ end=+"+
syn match  aveNumber		"[+-]\=\<[0-9]\+\>"
syn keyword aveOperator		or and max min xor mod by
syn match aveOperator		"[^\.]not[^a-zA-Z]"
syn keyword aveFixVariables	av nil self false true nl tab cr tab
syn match globalVariables	"_[a-zA-Z][a-zA-Z0-9]*"
syn match aveVariables		"[a-zA-Z][a-zA-Z0-9_]*"
syn match aveConst		"#[A-Z][A-Z_]+"
syn match aveComment	"'.*"
syn match aveTypos	"=="
syn match aveTypos	"!="
hi def link aveStatement		Statement
hi def link aveString		String
hi def link aveNumber		Number
hi def link aveFixVariables	Special
hi def link aveVariables		Identifier
hi def link globalVariables	Special
hi def link aveConst		Special
hi def link aveClassMethods	Function
hi def link aveOperator		Operator
hi def link aveComment		Comment
hi def link aveTypos		Error
let b:current_syntax = "ave"
