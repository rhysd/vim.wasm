if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword ibasicStatement	beep bload bsave call absolute chain chdir circle
syn keyword ibasicStatement	clear close cls color com common const data
syn keyword ibasicStatement	loop draw end environ erase error exit field
syn keyword ibasicStatement	files function get gosub goto
syn keyword ibasicStatement	input input# ioctl key kill let line locate
syn keyword ibasicStatement	lock unlock lprint using lset mkdir name
syn keyword ibasicStatement	on error open option base out paint palette pcopy
syn keyword ibasicStatement	pen play pmap poke preset print print# using pset
syn keyword ibasicStatement	put randomize read redim reset restore resume
syn keyword ibasicStatement	return rmdir rset run seek screen
syn keyword ibasicStatement	shared shell sleep sound static stop strig sub
syn keyword ibasicStatement	swap system timer troff tron type unlock
syn keyword ibasicStatement	view wait width window write
syn keyword ibasicStatement	date$ mid$ time$
syn match	ibasicIdentifier			"\<[a-zA-Z_][a-zA-Z0-9_]*\>"
syn match	ibasicGenericFunction	"\<[a-zA-Z_][a-zA-Z0-9_]*\>\s*("me=e-1,he=e-1
syn keyword ibasicBuiltInFunction	abs asc atn cdbl cint clng cos csng csrlin cvd cvdmbf
syn keyword ibasicBuiltInFunction	cvi cvl cvs cvsmbf eof erdev erl err exp fileattr
syn keyword ibasicBuiltInFunction	fix fre freefile inp instr lbound len loc lof
syn keyword ibasicBuiltInFunction	log lpos mod peek pen point pos rnd sadd screen seek
syn keyword ibasicBuiltInFunction	setmem sgn sin spc sqr stick strig tab tan ubound
syn keyword ibasicBuiltInFunction	val valptr valseg varptr varseg
syn keyword ibasicBuiltInFunction	chr\$ command$ date$ environ$ erdev$ hex$ inkey$
syn keyword ibasicBuiltInFunction	input$ ioctl$ lcases$ laft$ ltrim$ mid$ mkdmbf$ mkd$
syn keyword ibasicBuiltInFunction	mki$ mkl$ mksmbf$ mks$ oct$ right$ rtrim$ space$
syn keyword ibasicBuiltInFunction	str$ string$ time$ ucase$ varptr$
syn keyword ibasicTodo contained	TODO
syn cluster	ibasicFunctionCluster	contains=ibasicBuiltInFunction,ibasicGenericFunction
syn keyword Conditional	if else then elseif endif select case endselect
syn keyword Repeat	for do while next enddo endwhile wend
syn keyword ibasicTypeSpecifier	single double defdbl defsng
syn keyword ibasicTypeSpecifier	int integer uint uinteger int64 uint64 defint deflng
syn keyword ibasicTypeSpecifier	byte char string istring defstr
syn keyword ibasicDefine	dim def declare
syn cluster	ibasicParenGroup	contains=ibasicParenError,ibasicIncluded,ibasicSpecial,ibasicTodo,ibasicUserCont,ibasicUserLabel,ibasicBitField
syn region	ibasicParen		transparent start='(' end=')' contains=ALLBUT,@bParenGroup
syn match	ibasicParenError	")"
syn match	ibasicInParen	contained "[{}]"
syn region	ibasicHex		start="&h" end="\W"
syn region	ibasicHexError	start="&h\x*[g-zG-Z]" end="\W"
syn match	ibasicInteger	"\<\d\+\(u\=l\=\|lu\|f\)\>"
syn match	ibasicFloat		"\<\d\+\.\d*\(e[-+]\=\d\+\)\=[fl]\=\>"
syn match	ibasicFloat		"\.\d\+\(e[-+]\=\d\+\)\=[fl]\=\>"
syn match	ibasicFloat		"\<\d\+e[-+]\=\d\+[fl]\=\>"
syn match	ibasicIdentifier	"\<[a-zA-Z_][a-zA-Z0-9_]*\>"
syn match	ibasicFunction	"\<[a-zA-Z_][a-zA-Z0-9_]*\>\s*("me=e-1,he=e-1
syn case match
syn match	ibasicOctalError	"\<0\o*[89]"
syn region	ibasicString		start='"' end='"' contains=ibasicSpecial,ibasicTodo
syn region	ibasicString		start="'" end="'" contains=ibasicSpecial,ibasicTodo
syn match	ibasicSpecial	contained "\\."
syn region  ibasicComment	start="^rem" end="$" contains=ibasicSpecial,ibasicTodo
syn region  ibasicComment	start=":\s*rem" end="$" contains=ibasicSpecial,ibasicTodo
syn region	ibasicComment	start="\s*'" end="$" contains=ibasicSpecial,ibasicTodo
syn region	ibasicComment	start="^'" end="$" contains=ibasicSpecial,ibasicTodo
syn match	ibasicLabel		"^\d"
syn region  ibasicLineNumber	start="^\d" end="\s"
syn region	ibasicPreCondit	start="^\s*#\s*\(if\>\|ifdef\>\|ifndef\>\|elif\>\|else\>\|endif\>\)" skip="\\$" end="$" contains=ibasicString,ibasicCharacter,ibasicNumber,ibasicCommentError,ibasicSpaceError
syn match	ibasicInclude	"^\s*#\s*include\s*"
syn cluster ibasicNumber contains=ibasicHex,ibasicInteger,ibasicFloat
syn cluster	ibasicError	contains=ibasicHexError
syn match   ibasicFilenumber  "#\d\+"
syn match	ibasicMathOperator	"[\+\-\=\|\*\/\>\<\%\()[\]]" contains=ibasicParen
hi def link ibasicLabel			Label
hi def link ibasicConditional		Conditional
hi def link ibasicRepeat		Repeat
hi def link ibasicHex			Number
hi def link ibasicInteger		Number
hi def link ibasicFloat			Number
hi def link ibasicError			Error
hi def link ibasicHexError		Error
hi def link ibasicStatement		Statement
hi def link ibasicString		String
hi def link ibasicComment		Comment
hi def link ibasicLineNumber		Comment
hi def link ibasicSpecial		Special
hi def link ibasicTodo			Todo
hi def link ibasicGenericFunction	Function
hi def link ibasicBuiltInFunction	Function
hi def link ibasicTypeSpecifier		Type
hi def link ibasicDefine		Type
hi def link ibasicInclude		Include
hi def link ibasicIdentifier		Identifier
hi def link ibasicFilenumber		ibasicTypeSpecifier
hi def link ibasicMathOperator		Operator
let b:current_syntax = "ibasic"
