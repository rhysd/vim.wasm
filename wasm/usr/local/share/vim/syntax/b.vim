if exists("b:current_syntax")
finish
endif
syn keyword bStatement	        MACHINE MODEL SEES OPERATIONS INCLUDES DEFINITIONS CONSTRAINTS CONSTANTS VARIABLES CONCRETE_CONSTANTS CONCRETE_VARIABLES ABSTRACT_CONSTANTS ABSTRACT_VARIABLES HIDDEN_CONSTANTS HIDDEN_VARIABLES ASSERT ASSERTIONS  EXTENDS IMPLEMENTATION REFINEMENT IMPORTS USES INITIALISATION INVARIANT PROMOTES PROPERTIES REFINES SETS VALUES VARIANT VISIBLE_CONSTANTS VISIBLE_VARIABLES THEORY XLS THEOREMS LOCAL_OPERATIONS
syn keyword bLabel		CASE IN EITHER OR CHOICE DO OF
syn keyword bConditional	IF ELSE SELECT ELSIF THEN WHEN
syn keyword bRepeat		WHILE FOR
syn keyword bOps		bool card conc closure closure1 dom first fnc front not or id inter iseq iseq1 iterate last max min mod perm pred prj1 prj2 ran rel rev seq seq1 size skip succ tail union
syn keyword bKeywords		LET VAR BE IN BEGIN END  POW POW1 FIN FIN1  PRE  SIGMA STRING UNION IS ANY WHERE
syn keyword bBoolean	TRUE FALSE bfalse btrue
syn keyword bConstant	PI MAXINT MININT User_Pass PatchProver PatchProverH0 PatchProverB0 FLAT ARI DED SUB RES
syn keyword bGuard binhyp band bnot bguard bsearch bflat bfresh bguardi bget bgethyp barith bgetresult bresult bgoal bmatch bmodr bnewv  bnum btest bpattern bprintf bwritef bsubfrm  bvrb blvar bcall bappend bclose
syn keyword bLogic	or not
syn match bLogic	"\(!\|#\|%\|&\|+->>\|+->\|-->>\|->>\|-->\|->\|/:\|/<:\|/<<:\|/=\|/\\\|/|\\\|::\|:\|;:\|<+\|<->\|<--\|<-\|<:\|<<:\|<<|\|<=>\|<|\|==\|=>\|>+>>\|>->\|>+>\|||\||->\)"
syn match bNothing      /:=/
syn keyword cTodo contained	TODO FIXME XXX
syn match bSpecial contained	"\\[0-7][0-7][0-7]\=\|\\."
syn region bString		start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=bSpecial
syn match bCharacter		"'[^\\]'"
syn match bSpecialCharacter	"'\\.'"
syn match bSpecialCharacter	"'\\[0-7][0-7]'"
syn match bSpecialCharacter	"'\\[0-7][0-7][0-7]'"
syn region bParen		transparent start='(' end=')' contains=ALLBUT,bParenError,bIncluded,bSpecial,bTodo,bUserLabel,bBitField
syn match bParenError		")"
syn match bInParen contained	"[{}]"
syn case ignore
syn match bNumber		"\<[0-9]\+\>"
syn case match
syn region bComment		start="/\*" end="\*/" contains=bTodo
syn match bComment		"//.*" contains=bTodo
syntax match bCommentError	"\*/"
syn keyword bType		INT INTEGER BOOL NAT NATURAL NAT1 NATURAL1
syn region bPreCondit	start="^\s*#\s*\(if\>\|ifdef\>\|ifndef\>\|elif\>\|else\>\|endif\>\)" skip="\\$" end="$" contains=bComment,bString,bCharacter,bNumber,bCommentError
syn region bIncluded contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match bIncluded contained "<[^>]*>"
syn match bInclude		"^\s*#\s*include\>\s*["<]" contains=bIncluded
syn region bDefine		start="^\s*#\s*\(define\>\|undef\>\)" skip="\\$" end="$" contains=ALLBUT,bPreCondit,bIncluded,bInclude,bDefine,bInParen
syn region bPreProc		start="^\s*#\s*\(pragma\>\|line\>\|warning\>\|warn\>\|error\>\)" skip="\\$" end="$" contains=ALLBUT,bPreCondit,bIncluded,bInclude,bDefine,bInParen
syn sync ccomment bComment minlines=10
hi def link bLabel	Label
hi def link bUserLabel	Label
hi def link bConditional	Conditional
hi def link bRepeat	Repeat
hi def link bLogic	Special
hi def link bCharacter	Character
hi def link bSpecialCharacter bSpecial
hi def link bNumber	Number
hi def link bFloat	Float
hi def link bOctalError	bError
hi def link bParenError	bError
hi def link bCommentError	bError
hi def link bBoolean	Identifier
hi def link bConstant	Identifier
hi def link bGuard	Identifier
hi def link bOperator	Operator
hi def link bKeywords	Operator
hi def link bOps		Identifier
hi def link bStructure	Structure
hi def link bStorageClass	StorageClass
hi def link bInclude	Include
hi def link bPreProc	PreProc
hi def link bDefine	Macro
hi def link bIncluded	bString
hi def link bError	Error
hi def link bStatement	Statement
hi def link bPreCondit	PreCondit
hi def link bType		Type
hi def link bCommentError	bError
hi def link bCommentString bString
hi def link bComment2String bString
hi def link bCommentSkip	bComment
hi def link bString	String
hi def link bComment	Comment
hi def link bSpecial	SpecialChar
hi def link bTodo		Todo
let b:current_syntax = "b"
