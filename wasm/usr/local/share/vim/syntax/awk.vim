if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn keyword awkStatement	break continue delete exit
syn keyword awkStatement	function getline next
syn keyword awkStatement	print printf return
syn keyword awkStatement	switch nextfile
syn keyword awkStatement	func
syn keyword awkFunction	atan2 cos exp int intdiv log rand sin sqrt srand
syn keyword awkFunction	asort asort1 gensub gsub index length match 
syn keyword awkFunction	patsplit split sprintf strtonum sub substr
syn keyword awkFunction	tolower toupper
syn keyword awkFunction	close fflush system
syn keyword awkFunction	mktime strftime systime
syn keyword awkFunction	and compl lshift or rshift xor
syn keyword awkFunction	isarray typeof
syn keyword awkFunction	bindtextdomain dcgettext dcngetext
syn keyword awkConditional	if else
syn keyword awkRepeat	while for do
syn keyword awkTodo	contained TODO
syn keyword awkPatterns	BEGIN END BEGINFILE ENDFILE
syn keyword awkVariables        BINMODE CONVFMT FIELDWIDTHS FPAT FS
syn keyword awkVariables	IGNORECASE LINT OFMT OFS ORS PREC
syn keyword awkVariables	ROUNDMODE RS SUBSEP TEXTDOMAIN
syn keyword awkVariables	ARGC ARGV ARGIND ENVIRON ERRNO FILENAME
syn keyword awkVariables	FNR NF FUNCTAB NR PROCINFO RLENGTH RSTART 
syn keyword awkVariables	RT SYMTAB
syn match   awkOperator		"+\|-\|\*\|/\|%\|="
syn match   awkOperator		"+=\|-=\|\*=\|/=\|%="
syn match   awkOperator		"\^\|\^="
syn match   awkSpecialCharacter display contained "\\[0-7]\{1,3\}"
syn match   awkSpecialCharacter display contained "\\x[0-9A-Fa-f]\+"
syn match   awkFieldVars	"\$\d\+"
syn region	awkParen	transparent start="(" end=")" contains=ALLBUT,awkParenError,awkSpecialCharacter,awkArrayElement,awkArrayArray,awkTodo,awkRegExp,awkBrktRegExp,awkBrackets,awkCharClass,awkComment
syn match	awkParenError	display ")"
syn sync ccomment awkParen maxlines=64
syn region  awkSearch	oneline start="^[ \t]*/"ms=e start="\(,\|!\=\~\)[ \t]*/"ms=e skip="\\\\\|\\/" end="/" contains=awkBrackets,awkRegExp,awkSpecialCharacter
syn region  awkBrackets	contained start="\[\^\]\="ms=s+2 start="\[[^\^]"ms=s+1 end="\]"me=e-1 contains=awkBrktRegExp,awkCharClass
syn region  awkSearch	oneline start="[ \t]*/"hs=e skip="\\\\\|\\/" end="/" contains=awkBrackets,awkRegExp,awkSpecialCharacter
syn match   awkCharClass	contained "\[:[^:\]]*:\]"
syn match   awkBrktRegExp	contained "\\.\|.\-[^]]"
syn match   awkRegExp	contained "/\^"ms=s+1
syn match   awkRegExp	contained "\$/"me=e-1
syn match   awkRegExp	contained "[?.*{}|+]"
syn region  awkString	start=+"+  skip=+\\\\\|\\"+  end=+"+  contains=@Spell,awkSpecialCharacter,awkSpecialPrintf
syn match   awkSpecialCharacter contained "\\."
syn match   awkSpecialPrintf	contained "%[-+ #]*\d*\.\=\d*[cdefgiosuxEGX%]"
syn match  awkNumber		display "[+-]\=\<\d\+\>"
syn match  awkFloat		display "[+-]\=\<\d\+\.\d+\>"
syn match  awkFloat		display "[+-]\=\<.\d+\>"
syn case ignore
syn match  awkFloat	display "\<\d\+\.\d*\(e[-+]\=\d\+\)\=\>"
syn match  awkFloat	display "\.\d\+\(e[-+]\=\d\+\)\=\>"
syn match  awkFloat	display "\<\d\+e[-+]\=\d\+\>"
syn case match
syn match   awkExpression	"==\|>=\|=>\|<=\|=<\|\!="
syn match   awkExpression	"\~\|\!\~"
syn match   awkExpression	"?\|:"
syn keyword awkExpression	in
syn match  awkBoolLogic	"||\|&&\|\!"
syn match  awkSemicolon	";"
syn match  awkComma		","
syn match  awkComment	"#.*" contains=@Spell,awkTodo
syn match  awkLineSkip	"\\$"
syn match  awkArrayArray	contained "[^][, \t]\+\["me=e-1
syn match  awkArrayElement      contained "[^][, \t]\+"
syn region awkArray		transparent start="\[" end="\]" contains=awkArray,awkArrayElement,awkArrayArray,awkNumber,awkFloat
syn sync ccomment awkArray maxlines=10
hi def link awkConditional	Conditional
hi def link awkFunction		Function
hi def link awkRepeat		Repeat
hi def link awkStatement	Statement
hi def link awkString		String
hi def link awkSpecialPrintf	Special
hi def link awkSpecialCharacter	Special
hi def link awkSearch		String
hi def link awkBrackets		awkRegExp
hi def link awkBrktRegExp	awkNestRegExp
hi def link awkCharClass	awkNestRegExp
hi def link awkNestRegExp	Keyword
hi def link awkRegExp		Special
hi def link awkNumber		Number
hi def link awkFloat		Float
hi def link awkFileIO		Special
hi def link awkOperator		Special
hi def link awkExpression	Special
hi def link awkBoolLogic	Special
hi def link awkPatterns		Special
hi def link awkVariables	Special
hi def link awkFieldVars	Special
hi def link awkLineSkip		Special
hi def link awkSemicolon	Special
hi def link awkComma		Special
hi def link awkIdentifier	Identifier
hi def link awkComment		Comment
hi def link awkTodo		Todo
hi def link awkArrayArray	awkArray
hi def link awkArrayElement	Special
hi def link awkParenError	awkError
hi def link awkInParen		awkError
hi def link awkError		Error
let b:current_syntax = "awk"
let &cpo = s:cpo_save
unlet s:cpo_save
