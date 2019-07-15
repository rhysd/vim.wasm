if exists("b:current_syntax")
finish
endif
syn match xxdAddress			"^[0-9a-f]\+:"		contains=xxdSep
syn match xxdSep	contained	":"
syn match xxdAscii				"  .\{,16\}\r\=$"hs=s+2	contains=xxdDot
syn match xxdDot	contained	"[.\r]"
if !exists("skip_xxd_syntax_inits")
hi def link xxdAddress	Constant
hi def link xxdSep		Identifier
hi def link xxdAscii	Statement
endif
let b:current_syntax = "xxd"
