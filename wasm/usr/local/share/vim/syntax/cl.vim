if exists("b:current_syntax")
finish
endif
setlocal iskeyword=@,48-57,_,-
syn case ignore
syn sync lines=300
syn match	clifError	"\<wend\>"
syn match	clifError	"\<elsif\>"
syn match	clifError	"\<else\>"
syn match	clifError	"\<endif\>"
syn match	clSpaceError	"\s\+$"
syn region	clLoop		transparent matchgroup=clWhile start="\<while\>" matchgroup=clWhile end="\<wend\>" contains=ALLBUT,clBreak,clProcedure
syn region	clIf		transparent matchgroup=clConditional start="\<if\>" matchgroup=clConditional end="\<endif\>"   contains=ALLBUT,clBreak,clProcedure
syn keyword	clTodo		contained	TODO BUG DEBUG FIX
syn match	clNeedsWork	contained	"NEED[S]*\s\s*WORK"
syn keyword	clDebug		contained	debug
syn match	clComment	"#.*$"		contains=clTodo,clNeedsWork,@Spell
syn region	clProcedure	oneline		start="^\s*[{}]" end="$"
syn match	clInclude	"^\s*include\s.*"
syn keyword	clSetOptions	transparent aauto abort align convert E fill fnum goback hangup justify null_exit output rauto rawprint rawdisplay repeat skip tab trim
syn match	clSet		"^\s*set\s.*" contains=clSetOptions,clDebug
syn match	clPreProc	"^\s*#P.*"
syn keyword	clConditional	else elsif
syn keyword	clWhile		continue endloop
syn region	clBreak		oneline start="^\s*break" end="$"
syn match	clOperator	"[!;|)(:.><+*=-]"
syn match	clNumber	"\<\d\+\(u\=l\=\|lu\|f\)\>"
syn region	clString	matchgroup=clQuote	start=+"+ end=+"+	skip=+\\"+ contains=@Spell
syn region	clString	matchgroup=clQuote	start=+'+ end=+'+	skip=+\\'+ contains=@Spell
syn keyword	clReserved	ERROR EXIT INTERRUPT LOCKED LREPLY MODE MCOL MLINE MREPLY NULL REPLY V1 V2 V3 V4 V5 V6 V7 V8 V9 ZERO BYPASS GOING_BACK AAUTO ABORT ABORT ALIGN BIGE CONVERT FNUM GOBACK HANGUP JUSTIFY NEXIT OUTPUT RAUTO RAWDISPLAY RAWPRINT REPEAT SKIP TAB TRIM LCOUNT PCOUNT PLINES SLINES SCOLS MATCH LMATCH
syn keyword	clFunction	asc asize chr name random slen srandom day getarg getcgi getenv lcase scat sconv sdel skey smult srep substr sword trim ucase match
syn keyword	clStatement	clear clear_eol clear_eos close copy create unique with where empty define define ldefine delay_form delete escape exit_block exit_do exit_process field fork format get getfile getnext getprev goto head join maintain message no_join on_eop on_key on_exit on_delete openin openout openapp pause popenin popenout popenio print put range read redisplay refresh restart_block screen select sleep text unlock write and not or do
hi def link clifError	Error
hi def link clSpaceError	Error
hi def link clWhile		Repeat
hi def link clConditional	Conditional
hi def link clDebug		Debug
hi def link clNeedsWork	Todo
hi def link clTodo		Todo
hi def link clComment	Comment
hi def link clProcedure	Procedure
hi def link clBreak		Procedure
hi def link clInclude	Include
hi def link clSetOption	Statement
hi def link clSet		Identifier
hi def link clPreProc	PreProc
hi def link clOperator	Operator
hi def link clNumber		Number
hi def link clString		String
hi def link clQuote		Delimiter
hi def link clReserved	Identifier
hi def link clFunction	Function
hi def link clStatement	Statement
let b:current_syntax = "cl"
