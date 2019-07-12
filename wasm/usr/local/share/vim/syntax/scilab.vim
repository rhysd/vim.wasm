if exists("b:current_syntax")
finish
endif
syn keyword scilabStatement			abort clear clearglobal end exit global mode predef quit resume
syn keyword scilabStatement			return
syn keyword scilabFunction			function endfunction funptr
syn keyword scilabPredicate			null iserror isglobal
syn keyword scilabKeyword			typename
syn keyword scilabDebug				debug pause what where whereami whereis who whos
syn keyword scilabRepeat			for while break
syn keyword scilabConditional		if then else elseif
syn keyword scilabMultiplex			select case
syn match scilabConstant			"\(%\)[0-9A-Za-z?!#$]\+"
syn match scilabBoolean				"\(%\)[FTft]\>"
syn match scilabDelimiter			"[][;,()]"
syn match scilabComparison			"[=~]="
syn match scilabComparison			"[<>]=\="
syn match scilabComparison			"<>"
syn match scilabLogical				"[&|~]"
syn match scilabAssignment			"="
syn match scilabArithmetic			"[+-]"
syn match scilabArithmetic			"\.\=[*/\\]\.\="
syn match scilabArithmetic			"\.\=^"
syn match scilabRange				":"
syn match scilabMlistAccess			"\."
syn match scilabLineContinuation	"\.\{2,}"
syn match scilabTransposition		"[])a-zA-Z0-9?!_#$.]'"lc=1
syn keyword scilabTodo				TODO todo FIXME fixme TBD tbd	contained
syn match scilabComment				"//.*$"	contains=scilabTodo
syn match scilabNumber				"[0-9]\+\(\.[0-9]*\)\=\([DEde][+-]\=[0-9]\+\)\="
syn match scilabNumber				"\.[0-9]\+\([DEde][+-]\=[0-9]\+\)\="
syn region scilabString				start=+'+ skip=+''+ end=+'+		oneline
syn region scilabString				start=+"+ end=+"+				oneline
syn match scilabIdentifier			"\<[A-Za-z?!_#$][A-Za-z0-9?!_#$]*\>"
syn match scilabOverload			"%[A-Za-z0-9?!_#$]\+_[A-Za-z0-9?!_#$]\+"
hi def link scilabStatement				Statement
hi def link scilabFunction				Keyword
hi def link scilabPredicate				Keyword
hi def link scilabKeyword				Keyword
hi def link scilabDebug					Debug
hi def link scilabRepeat				Repeat
hi def link scilabConditional			Conditional
hi def link scilabMultiplex				Conditional
hi def link scilabConstant				Constant
hi def link scilabBoolean				Boolean
hi def link scilabDelimiter				Delimiter
hi def link scilabMlistAccess			Delimiter
hi def link scilabComparison			Operator
hi def link scilabLogical				Operator
hi def link scilabAssignment			Operator
hi def link scilabArithmetic			Operator
hi def link scilabRange					Operator
hi def link scilabLineContinuation		Underlined
hi def link scilabTransposition			Operator
hi def link scilabTodo					Todo
hi def link scilabComment				Comment
hi def link scilabNumber				Number
hi def link scilabString				String
hi def link scilabIdentifier			Identifier
hi def link scilabOverload				Special
let b:current_syntax = "scilab"
