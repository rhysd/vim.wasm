if exists("b:current_syntax")
finish
endif
syn case ignore
setlocal lisp
syn match	dylanSpecial		display contained "\\\(x\x\+\|\o\{1,3}\|.\|$\)"
syn keyword	dylanBlock		afterwards begin block cleanup end
syn keyword	dylanClassMods		abstract concrete primary inherited virtual
syn keyword	dylanException		exception handler signal
syn keyword	dylanParamDefs		method class function library macro interface
syn keyword	dylanSimpleDefs		constant variable generic primary
syn keyword	dylanOther		above below from by in instance local slot subclass then to
syn keyword	dylanConditional	if when select case else elseif unless finally otherwise then
syn keyword	dylanRepeat		begin for until while from to
syn keyword	dylanStatement		define let
syn keyword	dylanImport		use import export exclude rename create
syn keyword	dylanMiscMods		open sealed domain singleton sideways inline functional
syn match	dylanOperator		"\s[-!%&\*\+/=\?@\\^|~:]\+[-#!>%&:\*\+/=\?@\\^|~]*"
syn match	dylanOperator		"\(\<[A-Z][a-zA-Z0-9_']*\.\)\=:[-!#$%&\*\+./=\?@\\^|~:]*"
syn match	dylanNumber		"\<[0-9]\+\>\|\<0[xX][0-9a-fA-F]\+\>\|\<0[oO][0-7]\+\>"
syn match	dylanNumber		"\<[0-9]\+\.[0-9]\+\([eE][-+]\=[0-9]\+\)\=\>"
syn match	dylanBoolean		"#t\|#f"
syn match	dylanComment		"//.*"
syn region	dylanComment		start="/\*" end="\*/"
syn region	dylanString		start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=dySpecial
syn match	dylanCharacter		"'[^\\]'"
syn match	dylanConstant		"$\<[a-zA-Z0-9\-]\+\>"
syn match	dylanClass		"<\<[a-zA-Z0-9\-]\+\>>"
syn match	dylanVariable		"\*\<[a-zA-Z0-9\-]\+\>\*"
syn region	dylanPrecondit		start="^\s*#\s*\(if\>\|else\>\|endif\>\)" skip="\\$" end="$"
syn region	dylanHeader	start="^[Mm]odule:" end="^$"
hi def link dylanBlock		PreProc
hi def link dylanBoolean		Boolean
hi def link dylanCharacter		Character
hi def link dylanClass		Structure
hi def link dylanClassMods		StorageClass
hi def link dylanComment		Comment
hi def link dylanConditional	Conditional
hi def link dylanConstant		Constant
hi def link dylanException		Exception
hi def link dylanHeader		Macro
hi def link dylanImport		Include
hi def link dylanLabel		Label
hi def link dylanMiscMods		StorageClass
hi def link dylanNumber		Number
hi def link dylanOther		Keyword
hi def link dylanOperator		Operator
hi def link dylanParamDefs		Keyword
hi def link dylanPrecondit		PreCondit
hi def link dylanRepeat		Repeat
hi def link dylanSimpleDefs	Keyword
hi def link dylanStatement		Macro
hi def link dylanString		String
hi def link dylanVariable		Identifier
let b:current_syntax = "dylan"
