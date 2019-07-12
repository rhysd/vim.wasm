if exists("b:current_syntax")
finish
endif
syn keyword promelaStatement	proctype if else while chan do od fi break goto unless
syn keyword promelaStatement	active assert label atomic
syn keyword promelaFunctions	skip timeout run
syn keyword promelaTodo         contained TODO
syn keyword promelaType			bit bool byte short int
syn match promelaOperator	"!"
syn match promelaOperator	"?"
syn match promelaOperator	"->"
syn match promelaOperator	"="
syn match promelaOperator	"+"
syn match promelaOperator	"*"
syn match promelaOperator	"/"
syn match promelaOperator	"-"
syn match promelaOperator	"<"
syn match promelaOperator	">"
syn match promelaOperator	"<="
syn match promelaOperator	">="
syn match promelaSpecial	"\["
syn match promelaSpecial	"\]"
syn match promelaSpecial	";"
syn match promelaSpecial	"::"
syn region promelaComment start="/\*" end="\*/" contains=promelaTodo,@Spell
syn match  promelaComment "//.*" contains=promelaTodo,@Spell
hi def link promelaStatement    Statement
hi def link promelaType	        Type
hi def link promelaComment      Comment
hi def link promelaOperator	    Type
hi def link promelaSpecial      Special
hi def link promelaFunctions    Special
hi def link promelaString		String
hi def link promelaTodo	        Todo
let b:current_syntax = "promela"
