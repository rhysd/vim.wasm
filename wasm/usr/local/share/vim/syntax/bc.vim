if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword bcKeyword if else while for break continue return limits halt quit
syn keyword bcKeyword define
syn keyword bcKeyword length read sqrt print
syn keyword bcType auto
syn keyword bcConstant scale ibase obase last
syn keyword bcConstant BC_BASE_MAX BC_DIM_MAX BC_SCALE_MAX BC_STRING_MAX
syn keyword bcConstant BC_ENV_ARGS BC_LINE_LENGTH
syn match bcIdentifier		"[a-z_][a-z0-9_]*"
syn match bcString		"\"[^"]*\"" contains=@Spell
syn match bcNumber		"[0-9]\+"
syn match bcComment		"\#.*" contains=@Spell
syn region bcComment		start="/\*" end="\*/" contains=@Spell
syn cluster bcAll contains=bcList,bcIdentifier,bcNumber,bcKeyword,bcType,bcConstant,bcString,bcParentError
syn region bcList		matchgroup=Delimiter start="(" skip="|.\{-}|" matchgroup=Delimiter end=")" contains=@bcAll
syn region bcList		matchgroup=Delimiter start="\[" skip="|.\{-}|" matchgroup=Delimiter end="\]" contains=@bcAll
syn match bcParenError			"]"
syn match bcParenError			")"
syn case match
hi def link bcKeyword		Statement
hi def link bcType		Type
hi def link bcConstant		Constant
hi def link bcNumber		Number
hi def link bcComment		Comment
hi def link bcString		String
hi def link bcSpecialChar		SpecialChar
hi def link bcParenError		Error
let b:current_syntax = "bc"
