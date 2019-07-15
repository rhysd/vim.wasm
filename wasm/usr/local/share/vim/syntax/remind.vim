if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword remindCommands	REM OMIT SET FSET UNSET
syn keyword remindExpiry	UNTIL FROM SCANFROM SCAN WARN SCHED THROUGH
syn keyword remindTag		PRIORITY TAG
syn keyword remindTimed		AT DURATION
syn keyword remindMove		ONCE SKIP BEFORE AFTER
syn keyword remindSpecial	INCLUDE INC BANNER PUSH-OMIT-CONTEXT PUSH CLEAR-OMIT-CONTEXT CLEAR POP-OMIT-CONTEXT POP COLOR
syn keyword remindRun		MSG MSF RUN CAL SATISFY SPECIAL PS PSFILE SHADE MOON
syn keyword remindConditional	IF ELSE ENDIF IFTRIG
syn keyword remindDebug		DEBUG DUMPVARS DUMP ERRMSG FLUSH PRESERVE
syn match remindComment		"#.*$"
syn region remindString		start=+'+ end=+'+ skip=+\\\\\|\\'+ oneline
syn region remindString		start=+"+ end=+"+ skip=+\\\\\|\\"+ oneline
syn match remindVar		"\$[_a-zA-Z][_a-zA-Z0-9]*"
syn match remindSubst		"%[^ ]"
syn match remindAdvanceNumber	"\(\*\|+\|-\|++\|--\)[0-9]\+"
syn match remindDateSeparators	"[/:@\.-]" contained
syn match remindTimes		"[0-9]\{1,2}[:\.][0-9]\{1,2}" contains=remindDateSeparators
syn match remindDates		"'[0-9]\{4}[/-][0-9]\{1,2}[/-][0-9]\{1,2}\(@[0-9]\{1,2}[:\.][0-9]\{1,2}\)\?'" contains=remindDateSeparators
syn match remindWarning		display excludenl "\S\s\+$"ms=s+1
hi def link remindCommands		Function
hi def link remindExpiry		Repeat
hi def link remindTag		Label
hi def link remindTimed		Statement
hi def link remindMove		Statement
hi def link remindSpecial		Include
hi def link remindRun		Function
hi def link remindConditional	Conditional
hi def link remindComment		Comment
hi def link remindTimes		String
hi def link remindString		String
hi def link remindDebug		Debug
hi def link remindVar		Identifier
hi def link remindSubst		Constant
hi def link remindAdvanceNumber	Number
hi def link remindDateSeparators	Comment
hi def link remindDates		String
hi def link remindWarning		Error
let b:current_syntax = "remind"
