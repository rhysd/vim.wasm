if exists("b:current_syntax")
finish
endif
syn case	ignore
syn match	simulaComment		"^%.*$" contains=simulaTodo
syn region	simulaComment		start="!\|\<comment\>" end=";" contains=simulaTodo
syn region	simulaComment		start="\<end\>"lc=3 matchgroup=Statement end=";\|\<\(end\|else\|when\|otherwise\)\>"
syn match	simulaCharError		"'.\{-2,}'"
syn match	simulaCharacter		"'.'"
syn match	simulaCharacter		"'!\d\{-}!'" contains=simulaSpecialChar
syn match	simulaString		'".\{-}"' contains=simulaSpecialChar,simulaTodo
syn keyword	simulaBoolean		true false
syn keyword	simulaCompound		begin end
syn keyword	simulaConditional	else if otherwise then until when
syn keyword	simulaConstant		none notext
syn keyword	simulaFunction		procedure
syn keyword	simulaOperator		eq eqv ge gt imp in is le lt ne new not qua
syn keyword	simulaRepeat		while for
syn keyword	simulaReserved		activate after at before delay go goto label prior reactivate switch to
syn keyword	simulaStatement		do inner inspect step this
syn keyword	simulaStorageClass	external hidden name protected value
syn keyword	simulaStructure		class
syn keyword	simulaType		array boolean character integer long real short text virtual
syn match	simulaAssigned		"\<\h\w*\s*\((.*)\)\=\s*:\(=\|-\)"me=e-2
syn match	simulaOperator		"[&:=<>+\-*/]"
syn match	simulaOperator		"\<and\(\s\+then\)\=\>"
syn match	simulaOperator		"\<or\(\s\+else\)\=\>"
syn match	simulaReferenceType	"\<ref\s*(.\{-})"
syn match	simulaSemicolon		";"
syn match	simulaSpecial		"[(),.]"
syn match	simulaSpecialCharErr	"!\d\{-4,}!" contained
syn match	simulaSpecialCharErr	"!!" contained
syn match	simulaSpecialChar	"!\d\{-}!" contains=simulaSpecialCharErr contained
syn match	simulaTodo		"xxx\+" contained
syn match	simulaNumber		"-\=\<\d\+\>"
syn match	simulaReal		"-\=\<\d\+\(\.\d\+\)\=\(&&\=[+-]\=\d\+\)\=\>"
syn match	simulaReal		"-\=\.\d\+\(&&\=[+-]\=\d\+\)\=\>"
hi def link simulaAssigned		Identifier
hi def link simulaBoolean		Boolean
hi def link simulaCharacter		Character
hi def link simulaCharError		Error
hi def link simulaComment		Comment
hi def link simulaCompound		Statement
hi def link simulaConditional		Conditional
hi def link simulaConstant		Constant
hi def link simulaFunction		Function
hi def link simulaNumber			Number
hi def link simulaOperator		Operator
hi def link simulaReal			Float
hi def link simulaReferenceType		Type
hi def link simulaRepeat			Repeat
hi def link simulaReserved		Error
hi def link simulaSemicolon		Statement
hi def link simulaSpecial		Special
hi def link simulaSpecialChar		SpecialChar
hi def link simulaSpecialCharErr		Error
hi def link simulaStatement		Statement
hi def link simulaStorageClass		StorageClass
hi def link simulaString			String
hi def link simulaStructure		Structure
hi def link simulaTodo			Todo
hi def link simulaType			Type
let b:current_syntax = "simula"
