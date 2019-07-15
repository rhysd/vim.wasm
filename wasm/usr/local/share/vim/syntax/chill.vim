if exists("b:current_syntax")
finish
endif
syn keyword	chillStatement	goto GOTO return RETURN returns RETURNS
syn keyword	chillLabel		CASE case ESAC esac
syn keyword	chillConditional	if IF else ELSE elsif ELSIF switch SWITCH THEN then FI fi
syn keyword	chillLogical	NOT not
syn keyword	chillRepeat	while WHILE for FOR do DO od OD TO to
syn keyword	chillProcess	START start STACKSIZE stacksize PRIORITY priority THIS this STOP stop
syn keyword	chillBlock		PROC proc PROCESS process
syn keyword	chillSignal	RECEIVE receive SEND send NONPERSISTENT nonpersistent PERSISTENT peristent SET set EVER ever
syn keyword	chillTodo		contained TODO FIXME XXX
syn match	chillSpecial	contained "\\x\x\+\|\\\o\{1,3\}\|\\.\|\\$"
syn region	chillString	start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=chillSpecial
syn match	chillCharacter	"'[^\\]'"
syn match	chillSpecialCharacter "'\\.'"
syn match	chillSpecialCharacter "'\\\o\{1,3\}'"
if exists("chill_space_errors")
syn match	chillSpaceError	"\s*$"
syn match	chillSpaceError	" \+\t"me=e-1
endif
syn cluster	chillParenGroup	contains=chillParenError,chillIncluded,chillSpecial,chillTodo,chillUserCont,chillUserLabel,chillBitField
syn region	chillParen		transparent start='(' end=')' contains=ALLBUT,@chillParenGroup
syn match	chillParenError	")"
syn match	chillInParen	contained "[{}]"
syn case ignore
syn match	chillNumber		"\<\d\+\(u\=l\=\|lu\|f\)\>"
syn match	chillFloat		"\<\d\+\.\d*\(e[-+]\=\d\+\)\=[fl]\=\>"
syn match	chillFloat		"\.\d\+\(e[-+]\=\d\+\)\=[fl]\=\>"
syn match	chillFloat		"\<\d\+e[-+]\=\d\+[fl]\=\>"
syn match	chillNumber		"\<0x\x\+\(u\=l\=\|lu\)\>"
syn case match
syn match	chillOctalError	"\<0\o*[89]"
if exists("chill_comment_strings")
syntax match	chillCommentSkip	contained "^\s*\*\($\|\s\+\)"
syntax region chillCommentString	contained start=+"+ skip=+\\\\\|\\"+ end=+"+ end=+\*/+me=s-1 contains=chillSpecial,chillCommentSkip
syntax region chillComment2String	contained start=+"+ skip=+\\\\\|\\"+ end=+"+ end="$" contains=chillSpecial
syntax region chillComment	start="/\*" end="\*/" contains=chillTodo,chillCommentString,chillCharacter,chillNumber,chillFloat,chillSpaceError
syntax match  chillComment	"//.*" contains=chillTodo,chillComment2String,chillCharacter,chillNumber,chillSpaceError
else
syn region	chillComment	start="/\*" end="\*/" contains=chillTodo,chillSpaceError
syn match	chillComment	"//.*" contains=chillTodo,chillSpaceError
endif
syntax match	chillCommentError	"\*/"
syn keyword	chillOperator	SIZE size
syn keyword	chillType		dcl DCL int INT char CHAR bool BOOL REF ref LOC loc INSTANCE instance
syn keyword	chillStructure	struct STRUCT enum ENUM newmode NEWMODE synmode SYNMODE
syn keyword	chillBlock		PROC proc END end
syn keyword	chillScope		GRANT grant SEIZE seize
syn keyword	chillEDML		select SELECT delete DELETE update UPDATE in IN seq SEQ WHERE where INSERT insert include INCLUDE exclude EXCLUDE
syn keyword	chillBoolConst	true TRUE false FALSE
syn region	chillPreCondit	start="^\s*#\s*\(if\>\|ifdef\>\|ifndef\>\|elif\>\|else\>\|endif\>\)" skip="\\$" end="$" contains=chillComment,chillString,chillCharacter,chillNumber,chillCommentError,chillSpaceError
syn region	chillIncluded	contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match	chillIncluded	contained "<[^>]*>"
syn match	chillInclude	"^\s*#\s*include\>\s*["<]" contains=chillIncluded
syn cluster	chillPreProcGroup	contains=chillPreCondit,chillIncluded,chillInclude,chillDefine,chillInParen,chillUserLabel
syn region	chillDefine		start="^\s*#\s*\(define\>\|undef\>\)" skip="\\$" end="$" contains=ALLBUT,@chillPreProcGroup
syn region	chillPreProc	start="^\s*#\s*\(pragma\>\|line\>\|warning\>\|warn\>\|error\>\)" skip="\\$" end="$" contains=ALLBUT,@chillPreProcGroup
syn cluster	chillMultiGroup	contains=chillIncluded,chillSpecial,chillTodo,chillUserCont,chillUserLabel,chillBitField
syn region	chillMulti		transparent start='?' end=':' contains=ALLBUT,@chillMultiGroup
syn match	chillUserCont	"^\s*\I\i*\s*:$" contains=chillUserLabel
syn match	chillUserCont	";\s*\I\i*\s*:$" contains=chillUserLabel
syn match	chillUserCont	"^\s*\I\i*\s*:[^:]"me=e-1 contains=chillUserLabel
syn match	chillUserCont	";\s*\I\i*\s*:[^:]"me=e-1 contains=chillUserLabel
syn match	chillUserLabel	"\I\i*" contained
syn match	chillBitField	"^\s*\I\i*\s*:\s*[1-9]"me=e-1
syn match	chillBitField	";\s*\I\i*\s*:\s*[1-9]"me=e-1
syn match	chillBracket	contained "[<>]"
if !exists("chill_minlines")
let chill_minlines = 15
endif
exec "syn sync ccomment chillComment minlines=" . chill_minlines
hi def link chillLabel	Label
hi def link chillUserLabel	Label
hi def link chillConditional	Conditional
hi def link chillRepeat	Repeat
hi def link chillProcess	Repeat
hi def link chillSignal	Repeat
hi def link chillCharacter	Character
hi def link chillSpecialCharacter chillSpecial
hi def link chillNumber	Number
hi def link chillFloat	Float
hi def link chillOctalError	chillError
hi def link chillParenError	chillError
hi def link chillInParen	chillError
hi def link chillCommentError	chillError
hi def link chillSpaceError	chillError
hi def link chillOperator	Operator
hi def link chillStructure	Structure
hi def link chillBlock	Operator
hi def link chillScope	Operator
hi def link chillEDML	PreProc
hi def link chillBoolConst	Constant
hi def link chillLogical	Constant
hi def link chillStorageClass	StorageClass
hi def link chillInclude	Include
hi def link chillPreProc	PreProc
hi def link chillDefine	Macro
hi def link chillIncluded	chillString
hi def link chillError	Error
hi def link chillStatement	Statement
hi def link chillPreCondit	PreCondit
hi def link chillType	Type
hi def link chillCommentError	chillError
hi def link chillCommentString chillString
hi def link chillComment2String chillString
hi def link chillCommentSkip	chillComment
hi def link chillString	String
hi def link chillComment	Comment
hi def link chillSpecial	SpecialChar
hi def link chillTodo	Todo
hi def link chillBlock	Statement
hi def link chillBracket	Delimiter
let b:current_syntax = "chill"
