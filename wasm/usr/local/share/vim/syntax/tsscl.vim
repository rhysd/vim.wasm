if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword tssclCommand  begin radk list heatrates attr draw
syn keyword tssclKeyword   cells rays error nodes levels objects cpu
syn keyword tssclKeyword   units length positions energy time unit solar
syn keyword tssclKeyword   solar_constant albedo planet_power
syn keyword tssclEnd    exit
syn keyword tssclUnits  cm feet meters inches
syn keyword tssclUnits  Celsius Kelvin Fahrenheit Rankine
syn match  tssclString    /"[^"]\+"/ contains=ALLBUT,tssInteger,tssclKeyword,tssclCommand,tssclEnd,tssclUnits
syn match  tssclComment     "#.*$"
syn match  tssclOper      "||\||\|&&\|&\|!=\|!\|>=\|<=\|>\|<\|+\|-\|^\|\*\*\|\*\|/\|%\|==\|=\|\." skipwhite
syn match  tssclDirective "\*ADD"
syn match  tssclDirective "\*ARITHMETIC \+\(ON\|OFF\)"
syn match  tssclDirective "\*CLOSE"
syn match  tssclDirective "\*CPU"
syn match  tssclDirective "\*DEFINE"
syn match  tssclDirective "\*ECHO"
syn match  tssclConditional "\*ELSE"
syn match  tssclConditional "\*END \+\(IF\|WHILE\)"
syn match  tssclDirective "\*EXIT"
syn match  tssclConditional "\*IF"
syn match  tssclDirective "\*LIST"
syn match  tssclDirective "\*OPEN"
syn match  tssclDirective "\*PROMPT"
syn match  tssclDirective "\*READ"
syn match  tssclDirective "\*REWIND"
syn match  tssclDirective "\*STOP"
syn match  tssclDirective "\*STRCMP"
syn match  tssclDirective "\*SYSTEM"
syn match  tssclDirective "\*UNDEFINE"
syn match  tssclConditional "\*WHILE"
syn match  tssclDirective "\*WRITE"
syn match  tssclContChar  "-$"
syn match  tssclQualifier "/[^/ ]\+"hs=s+1
syn match  tssclSymbol    "'\S\+'"
syn match  tssclInteger     "-\=\<[0-9]*\>"
syn match  tssclFloat       "-\=\<[0-9]*\.[0-9]*"
syn match  tssclScientific  "-\=\<[0-9]*\.[0-9]*E[-+]\=[0-9]\+\>"
hi def link tssclCommand		Statement
hi def link tssclKeyword		Special
hi def link tssclEnd		Macro
hi def link tssclUnits		Special
hi def link tssclComment		Comment
hi def link tssclDirective		Statement
hi def link tssclConditional	Conditional
hi def link tssclContChar		Macro
hi def link tssclQualifier		Typedef
hi def link tssclSymbol		Identifier
hi def link tssclSymbol2		Symbol
hi def link tssclString		String
hi def link tssclOper		Operator
hi def link tssclInteger		Number
hi def link tssclFloat		Number
hi def link tssclScientific	Number
let b:current_syntax = "tsscl"
