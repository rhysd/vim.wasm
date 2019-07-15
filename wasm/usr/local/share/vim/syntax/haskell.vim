if exists("b:current_syntax")
finish
endif
syn match ConId "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=\<[A-Z][a-zA-Z0-9_']*\>" contains=@NoSpell
syn match VarId "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=\<[a-z][a-zA-Z0-9_']*\>" contains=@NoSpell
syn match hsVarSym "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=[-!#$%&\*\+/<=>\?@\\^|~.][-!#$%&\*\+/<=>\?@\\^|~:.]*"
syn match hsConSym "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=:[-!#$%&\*\+./<=>\?@\\^|~:]*"
syn match hsVarSym "`\(\<[A-Z][a-zA-Z0-9_']*\.\)\=[a-z][a-zA-Z0-9_']*`"
syn match hsConSym "`\(\<[A-Z][a-zA-Z0-9_']*\.\)\=[A-Z][a-zA-Z0-9_']*`"
syn match hsDelimiter  "(\|)\|\[\|\]\|,\|;\|_\|{\|}"
syn match   hsSpecialChar	contained "\\\([0-9]\+\|o[0-7]\+\|x[0-9a-fA-F]\+\|[\"\\'&\\abfnrtv]\|^[A-Z^_\[\\\]]\)"
syn match   hsSpecialChar	contained "\\\(NUL\|SOH\|STX\|ETX\|EOT\|ENQ\|ACK\|BEL\|BS\|HT\|LF\|VT\|FF\|CR\|SO\|SI\|DLE\|DC1\|DC2\|DC3\|DC4\|NAK\|SYN\|ETB\|CAN\|EM\|SUB\|ESC\|FS\|GS\|RS\|US\|SP\|DEL\)"
syn match   hsSpecialCharError	contained "\\&\|'''\+"
syn region  hsString		start=+"+  skip=+\\\\\|\\"+  end=+"+  contains=hsSpecialChar,@NoSpell
syn match   hsCharacter		"[^a-zA-Z0-9_']'\([^\\]\|\\[^']\+\|\\'\)'"lc=1 contains=hsSpecialChar,hsSpecialCharError
syn match   hsCharacter		"^'\([^\\]\|\\[^']\+\|\\'\)'" contains=hsSpecialChar,hsSpecialCharError
syn match   hsNumber		"\v<[0-9]%(_*[0-9])*>|<0[xX]_*[0-9a-fA-F]%(_*[0-9a-fA-F])*>|<0[oO]_*%(_*[0-7])*>|<0[bB]_*[01]%(_*[01])*>"
syn match   hsFloat		"\v<[0-9]%(_*[0-9])*\.[0-9]%(_*[0-9])*%(_*[eE][-+]?[0-9]%(_*[0-9])*)?>|<[0-9]%(_*[0-9])*_*[eE][-+]?[0-9]%(_*[0-9])*>|<0[xX]_*[0-9a-fA-F]%(_*[0-9a-fA-F])*\.[0-9a-fA-F]%(_*[0-9a-fA-F])*%(_*[pP][-+]?[0-9]%(_*[0-9])*)?>|<0[xX]_*[0-9a-fA-F]%(_*[0-9a-fA-F])*_*[pP][-+]?[0-9]%(_*[0-9])*>"
syn match hsModule		"\<module\>"
syn match hsImport		"\<import\>.*"he=s+6 contains=hsImportMod,hsLineComment,hsBlockComment,@NoSpell
syn match hsImportMod		contained "\<\(as\|qualified\|hiding\)\>" contains=@NoSpell
syn match hsInfix		"\<\(infix\|infixl\|infixr\)\>"
syn match hsStructure		"\<\(class\|data\|deriving\|instance\|default\|where\)\>"
syn match hsTypedef		"\<\(type\|newtype\)\>"
syn match hsStatement		"\<\(do\|case\|of\|let\|in\)\>"
syn match hsConditional		"\<\(if\|then\|else\)\>"
if exists("hs_highlight_boolean")
syn match hsBoolean "\<\(True\|False\)\>"
endif
if exists("hs_highlight_types")
syn match hsType "\<\(Int\|Integer\|Char\|Bool\|Float\|Double\|IO\|Void\|Addr\|Array\|String\)\>"
endif
if exists("hs_highlight_more_types")
syn match hsType "\<\(Maybe\|Either\|Ratio\|Complex\|Ordering\|IOError\|IOResult\|ExitCode\)\>"
syn match hsMaybe    "\<Nothing\>"
syn match hsExitCode "\<\(ExitSuccess\)\>"
syn match hsOrdering "\<\(GT\|LT\|EQ\)\>"
endif
if exists("hs_highlight_debug")
syn match hsDebug "\<\(undefined\|error\|trace\)\>"
endif
syn match   hsLineComment      "---*\([^-!#$%&\*\+./<=>\?@\\^|~].*\)\?$" contains=@Spell
syn region  hsBlockComment     start="{-"  end="-}" contains=hsBlockComment,@Spell
syn region  hsPragma	       start="{-#" end="#-}"
if (!exists("hs_allow_hash_operator"))
syn match	cError		display "^\s*\(%:\|#\).*$"
endif
syn region	cPreCondit	start="^\s*\(%:\|#\)\s*\(if\|ifdef\|ifndef\|elif\)\>" skip="\\$" end="$" end="//"me=s-1 contains=cComment,cCppString,cCommentError
syn match	cPreCondit	display "^\s*\(%:\|#\)\s*\(else\|endif\)\>"
syn region	cCppOut		start="^\s*\(%:\|#\)\s*if\s\+0\+\>" end=".\@=\|$" contains=cCppOut2
syn region	cCppOut2	contained start="0" end="^\s*\(%:\|#\)\s*\(endif\>\|else\>\|elif\>\)" contains=cCppSkip
syn region	cCppSkip	contained start="^\s*\(%:\|#\)\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*\(%:\|#\)\s*endif\>" contains=cCppSkip
syn region	cIncluded	display contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match	cIncluded	display contained "<[^>]*>"
syn match	cInclude	display "^\s*\(%:\|#\)\s*include\>\s*["<]" contains=cIncluded
syn cluster	cPreProcGroup	contains=cPreCondit,cIncluded,cInclude,cDefine,cCppOut,cCppOut2,cCppSkip,cCommentStartError
syn region	cDefine		matchgroup=cPreCondit start="^\s*\(%:\|#\)\s*\(define\|undef\)\>" skip="\\$" end="$"
syn region	cPreProc	matchgroup=cPreCondit start="^\s*\(%:\|#\)\s*\(pragma\>\|line\>\|warning\>\|warn\>\|error\>\)" skip="\\$" end="$" keepend
syn region	cComment	matchgroup=cCommentStart start="/\*" end="\*/" contains=cCommentStartError,cSpaceError contained
syntax match	cCommentError	display "\*/" contained
syntax match	cCommentStartError display "/\*"me=e-1 contained
syn region	cCppString	start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=cSpecial contained
hi def link hsModule			  hsStructure
hi def link hsImport			  Include
hi def link hsImportMod			  hsImport
hi def link hsInfix			  PreProc
hi def link hsStructure			  Structure
hi def link hsStatement			  Statement
hi def link hsConditional			  Conditional
hi def link hsSpecialChar			  SpecialChar
hi def link hsTypedef			  Typedef
hi def link hsVarSym			  hsOperator
hi def link hsConSym			  hsOperator
hi def link hsOperator			  Operator
if exists("hs_highlight_delimiters")
hi def link hsDelimiter			  Delimiter
endif
hi def link hsSpecialCharError		  Error
hi def link hsString			  String
hi def link hsCharacter			  Character
hi def link hsNumber			  Number
hi def link hsFloat			  Float
hi def link hsConditional			  Conditional
hi def link hsLiterateComment		  hsComment
hi def link hsBlockComment		  hsComment
hi def link hsLineComment			  hsComment
hi def link hsComment			  Comment
hi def link hsPragma			  SpecialComment
hi def link hsBoolean			  Boolean
hi def link hsType			  Type
hi def link hsMaybe			  hsEnumConst
hi def link hsOrdering			  hsEnumConst
hi def link hsEnumConst			  Constant
hi def link hsDebug			  Debug
hi def link cCppString		hsString
hi def link cCommentStart		hsComment
hi def link cCommentError		hsError
hi def link cCommentStartError	hsError
hi def link cInclude		Include
hi def link cPreProc		PreProc
hi def link cDefine		Macro
hi def link cIncluded		hsString
hi def link cError			Error
hi def link cPreCondit		PreCondit
hi def link cComment		Comment
hi def link cCppSkip		cCppOut
hi def link cCppOut2		cCppOut
hi def link cCppOut		Comment
let b:current_syntax = "haskell"
