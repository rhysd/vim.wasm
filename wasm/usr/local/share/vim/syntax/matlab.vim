if exists("b:current_syntax")
finish
endif
syn keyword matlabStatement		return
syn keyword matlabLabel			case switch
syn keyword matlabConditional		else elseif end if otherwise
syn keyword matlabRepeat		do for while
syn keyword matlabExceptions		try catch
syn keyword matlabOO			classdef properties events methods
syn keyword matlabTodo			contained  TODO
syn keyword matlabScope			global persistent
syn match matlabArithmeticOperator	"[-+]"
syn match matlabArithmeticOperator	"\.\=[*/\\^]"
syn match matlabRelationalOperator	"[=~]="
syn match matlabRelationalOperator	"[<>]=\="
syn match matlabLogicalOperator		"[&|~]"
syn match matlabLineContinuation	"\.\{3}"
syn region matlabString			start=+'+ end=+'+	oneline skip=+''+
syn region matlabStringArray		start=+"+ end=+"+	oneline skip=+""+
syn match matlabTab			"\t"
syn match matlabNumber		"\<\d\+[ij]\=\>"
syn match matlabFloat		"\<\d\+\(\.\d*\)\=\([edED][-+]\=\d\+\)\=[ij]\=\>"
syn match matlabFloat		"\.\d\+\([edED][-+]\=\d\+\)\=[ij]\=\>"
syn match matlabDelimiter		"[][]"
syn match matlabTransposeOperator	"[])a-zA-Z0-9.]'"lc=1
syn match matlabSemicolon		";"
syn match matlabComment			"%.*$"	contains=matlabTodo,matlabTab
syn match matlabComment			"\.\.\..*$"	contains=matlabTodo,matlabTab
syn region matlabMultilineComment	start=+%{+ end=+%}+ contains=matlabTodo,matlabTab
syn match matlabCellComment     "^%%.*$"
syn keyword matlabOperator		break zeros default margin round ones rand
syn keyword matlabOperator		ceil floor size clear zeros eye mean std cov
syn keyword matlabFunction		error eval function
syn keyword matlabImplicit		abs acos atan asin cos cosh exp log prod sum
syn keyword matlabImplicit		log10 max min sign sin sinh sqrt tan reshape
syn match matlabError	"-\=\<\d\+\.\d\+\.[^*/\\^]"
syn match matlabError	"-\=\<\d\+\.\d\+[eEdD][-+]\=\d\+\.\([^*/\\^]\)"
hi def link matlabTransposeOperator	matlabOperator
hi def link matlabOperator			Operator
hi def link matlabLineContinuation		Special
hi def link matlabLabel			Label
hi def link matlabConditional		Conditional
hi def link matlabExceptions		Conditional
hi def link matlabRepeat			Repeat
hi def link matlabTodo			Todo
hi def link matlabString			String
hi def link matlabStringArray			String
hi def link matlabDelimiter		Identifier
hi def link matlabTransposeOther		Identifier
hi def link matlabNumber			Number
hi def link matlabFloat			Float
hi def link matlabFunction			Function
hi def link matlabError			Error
hi def link matlabImplicit			matlabStatement
hi def link matlabStatement		Statement
hi def link matlabOO			Statement
hi def link matlabSemicolon		SpecialChar
hi def link matlabComment			Comment
hi def link matlabMultilineComment		Comment
hi def link matlabCellComment          Todo
hi def link matlabScope			Type
hi def link matlabArithmeticOperator	matlabOperator
hi def link matlabRelationalOperator	matlabOperator
hi def link matlabLogicalOperator		matlabOperator
let b:current_syntax = "matlab"
