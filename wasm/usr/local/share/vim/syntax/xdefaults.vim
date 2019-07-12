if exists("b:current_syntax")
finish
endif
syn case match
if !exists("xdefaults_no_colon_errors")
syntax match xdefaultsErrorLine "^\s*[a-zA-Z.*]\+\s\+[^: 	]\+"
endif
syn match   xdefaultsLabel   +^[^:]\{-}:+he=e-1                       contains=xdefaultsPunct,xdefaultsSpecial,xdefaultsLineEnd
syn region  xdefaultsValue   keepend start=+:+lc=1 skip=+\\+ end=+$+ contains=xdefaultsSpecial,xdefaultsLabel,xdefaultsLineEnd
syn match   xdefaultsSpecial	contained +#override+
syn match   xdefaultsSpecial	contained +#augment+
syn match   xdefaultsPunct	contained +[.*:]+
syn match   xdefaultsLineEnd	contained +\\$+
syn match   xdefaultsLineEnd	contained +\\n\\$+
syn match   xdefaultsLineEnd	contained +\\n$+
syn match   xdefaultsComment "^!.*$"                     contains=xdefaultsTodo,@Spell
syn match   xdefaultsCommentH		"^#.*$"
syn region  xdefaultsComment start="/\*" end="\*/"       contains=xdefaultsTodo,@Spell
syntax match xdefaultsCommentError	"\*/"
syn keyword xdefaultsTodo contained TODO FIXME XXX display
syn region	xdefaultsPreProc	start="^\s*#\s*\(if\|ifdef\|ifndef\|elif\|else\|endif\)\>" skip="\\$" end="$" contains=xdefaultsSymbol
if !exists("xdefaults_no_if0")
syn region	xdefaultsCppOut		start="^\s*#\s*if\s\+0\>" end=".\|$" contains=xdefaultsCppOut2
syn region	xdefaultsCppOut2	contained start="0" end="^\s*#\s*\(endif\>\|else\>\|elif\>\)" contains=xdefaultsCppSkip
syn region	xdefaultsCppSkip	contained start="^\s*#\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*#\s*endif\>" contains=xdefaultsCppSkip
endif
syn region	xdefaultsIncluded	contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match	xdefaultsIncluded	contained "<[^>]*>"
syn match	xdefaultsInclude	"^\s*#\s*include\>\s*["<]" contains=xdefaultsIncluded
syn cluster	xdefaultsPreProcGroup	contains=xdefaultsPreProc,xdefaultsIncluded,xdefaultsInclude,xdefaultsDefine,xdefaultsCppOut,xdefaultsCppOut2,xdefaultsCppSkip
syn region	xdefaultsDefine		start="^\s*#\s*\(define\|undef\)\>" skip="\\$" end="$" contains=ALLBUT,@xdefaultsPreProcGroup,xdefaultsCommentH,xdefaultsErrorLine,xdefaultsLabel,xdefaultsValue
syn region	xdefaultsPreProc	start="^\s*#\s*\(pragma\>\|line\>\|warning\>\|warn\>\|error\>\)" skip="\\$" end="$" keepend contains=ALLBUT,@xdefaultsPreProcGroup,xdefaultsCommentH,xdefaultsErrorLine,xdefaultsLabel,xdefaultsValue
syn keyword xdefaultsSymbol contained SERVERHOST
syn match   xdefaultsSymbol contained "SRVR_[a-zA-Z0-9_]\+"
syn keyword xdefaultsSymbol contained HOST
syn keyword xdefaultsSymbol contained DISPLAY_NUM
syn keyword xdefaultsSymbol contained CLIENTHOST
syn match   xdefaultsSymbol contained "CLNT_[a-zA-Z0-9_]\+"
syn keyword xdefaultsSymbol contained RELEASE
syn keyword xdefaultsSymbol contained REVISION
syn keyword xdefaultsSymbol contained VERSION
syn keyword xdefaultsSymbol contained VENDOR
syn match   xdefaultsSymbol contained "VNDR_[a-zA-Z0-9_]\+"
syn match   xdefaultsSymbol contained "EXT_[a-zA-Z0-9_]\+"
syn keyword xdefaultsSymbol contained NUM_SCREENS
syn keyword xdefaultsSymbol contained SCREEN_NUM
syn keyword xdefaultsSymbol contained BITS_PER_RGB
syn keyword xdefaultsSymbol contained CLASS
syn keyword xdefaultsSymbol contained StaticGray GrayScale StaticColor PseudoColor TrueColor DirectColor
syn match   xdefaultsSymbol contained "CLASS_\(StaticGray\|GrayScale\|StaticColor\|PseudoColor\|TrueColor\|DirectColor\)"
syn keyword xdefaultsSymbol contained COLOR
syn match   xdefaultsSymbol contained "CLASS_\(StaticGray\|GrayScale\|StaticColor\|PseudoColor\|TrueColor\|DirectColor\)_[0-9]\+"
syn keyword xdefaultsSymbol contained HEIGHT
syn keyword xdefaultsSymbol contained WIDTH
syn keyword xdefaultsSymbol contained PLANES
syn keyword xdefaultsSymbol contained X_RESOLUTION
syn keyword xdefaultsSymbol contained Y_RESOLUTION
hi def link xdefaultsLabel		Type
hi def link xdefaultsValue		Constant
hi def link xdefaultsComment	Comment
hi def link xdefaultsCommentH	xdefaultsComment
hi def link xdefaultsPreProc	PreProc
hi def link xdefaultsInclude	xdefaultsPreProc
hi def link xdefaultsCppSkip	xdefaultsCppOut
hi def link xdefaultsCppOut2	xdefaultsCppOut
hi def link xdefaultsCppOut	Comment
hi def link xdefaultsIncluded	String
hi def link xdefaultsDefine	Macro
hi def link xdefaultsSymbol	Statement
hi def link xdefaultsSpecial	Statement
hi def link xdefaultsErrorLine	Error
hi def link xdefaultsCommentError	Error
hi def link xdefaultsPunct		Normal
hi def link xdefaultsLineEnd	Special
hi def link xdefaultsTodo		Todo
let b:current_syntax = "xdefaults"
