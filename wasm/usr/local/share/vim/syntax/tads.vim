if exists("b:current_syntax")
finish
endif
syn keyword tadsStatement	goto break return continue pass
syn keyword tadsLabel		case default
syn keyword tadsConditional	if else switch
syn keyword tadsRepeat		while for do
syn keyword tadsStorageClass	local compoundWord formatstring specialWords
syn keyword tadsBoolean		nil true
syn keyword tadsKeyword		replace modify
syn keyword tadsKeyword		global self inherited
syn keyword tadsKeyword		cvtstr cvtnum caps lower upper substr
syn keyword tadsKeyword		say length
syn keyword tadsKeyword		setit setscore
syn keyword tadsKeyword		datatype proptype
syn keyword tadsKeyword		car cdr
syn keyword tadsKeyword		defined isclass
syn keyword tadsKeyword		find firstobj nextobj
syn keyword tadsKeyword		getarg argcount
syn keyword tadsKeyword		input yorn askfile
syn keyword tadsKeyword		rand randomize
syn keyword tadsKeyword		restart restore quit save undo
syn keyword tadsException	abort exit exitobj
syn keyword tadsTodo contained	TODO FIXME XXX
syn match tadsSpecial contained	"\\."
syn region tadsDoubleString		start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=tadsSpecial,tadsEmbedded
syn region tadsSingleString		start=+'+ skip=+\\\\\|\\'+ end=+'+ contains=tadsSpecial
syn region tadsEmbedded contained       start="<<" end=">>" contains=tadsKeyword
syn region tadsBrace		transparent start='{' end='}' contains=ALLBUT,tadsBraceError,tadsIncluded,tadsSpecial,tadsTodo
syn match tadsBraceError		"}"
syn case ignore
syn match tadsNumber		"\<[0-9]\+\>"
syn match tadsNumber		"\<0x[0-9a-f]\+\>"
syn match tadsIdentifier	"\<[a-z][a-z0-9_$]*\>"
syn case match
syn match tadsOctalError		"\<0[0-7]*[89]"
syn region tadsComment		start="/\*" end="\*/" contains=tadsTodo
syn match tadsComment		"//.*" contains=tadsTodo
syntax match tadsCommentError	"\*/"
syn region tadsPreCondit	start="^\s*#\s*\(if\>\|ifdef\>\|ifndef\>\|elif\>\|else\>\|endif\>\)" skip="\\$" end="$" contains=tadsComment,tadsString,tadsNumber,tadsCommentError
syn region tadsIncluded contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match tadsIncluded contained "<[^>]*>"
syn match tadsInclude		"^\s*#\s*include\>\s*["<]" contains=tadsIncluded
syn region tadsDefine		start="^\s*#\s*\(define\>\|undef\>\)" skip="\\$" end="$" contains=ALLBUT,tadsPreCondit,tadsIncluded,tadsInclude,tadsDefine,tadsInBrace,tadsIdentifier
syn region tadsPreProc start="^\s*#\s*\(pragma\>\|line\>\|warning\>\|warn\>\|error\>\)" skip="\\$" end="$" contains=ALLBUT,tadsPreCondit,tadsIncluded,tadsInclude,tadsDefine,tadsInParen,tadsIdentifier
syn match tadsClassDef		"\<class\>[^/]*" contains=tadsObjectDef,tadsClass
syn match tadsClass contained   "\<class\>"
syn match tadsObjectDef "\<[a-zA-Z][a-zA-Z0-9_$]*\s*:\s*[a-zA-Z0-9_$]\+\(\s*,\s*[a-zA-Z][a-zA-Z0-9_$]*\)*\(\s*;\)\="
syn keyword tadsFunction contained function
syn match tadsFunctionDef	 "\<[a-zA-Z][a-zA-Z0-9_$]*\s*:\s*function[^{]*" contains=tadsFunction
if !exists("tads_minlines")
let tads_minlines = 15
endif
exec "syn sync ccomment tadsComment minlines=" . tads_minlines
if !exists("tads_sync_dist")
let tads_sync_dist = 100
endif
execute "syn sync maxlines=" . tads_sync_dist
hi def link tadsFunctionDef Function
hi def link tadsFunction  Structure
hi def link tadsClass     Structure
hi def link tadsClassDef  Identifier
hi def link tadsObjectDef Identifier
hi def link tadsOperator	Operator
hi def link tadsStructure	Structure
hi def link tadsTodo	Todo
hi def link tadsLabel	Label
hi def link tadsConditional	Conditional
hi def link tadsRepeat	Repeat
hi def link tadsException	Exception
hi def link tadsStatement	Statement
hi def link tadsStorageClass	StorageClass
hi def link tadsKeyWord   Keyword
hi def link tadsSpecial	SpecialChar
hi def link tadsNumber	Number
hi def link tadsBoolean	Boolean
hi def link tadsDoubleString	tadsString
hi def link tadsSingleString	tadsString
hi def link tadsOctalError	tadsError
hi def link tadsCommentError	tadsError
hi def link tadsBraceError	tadsError
hi def link tadsInBrace	tadsError
hi def link tadsError	Error
hi def link tadsInclude	Include
hi def link tadsPreProc	PreProc
hi def link tadsDefine	Macro
hi def link tadsIncluded	tadsString
hi def link tadsPreCondit	PreCondit
hi def link tadsString	String
hi def link tadsComment	Comment
let b:current_syntax = "tads"
