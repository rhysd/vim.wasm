if exists("b:current_syntax")
finish
endif
syn case ignore
syn region esterelModule					start=/module/		end=/end module/	contains=ALLBUT,esterelModule
syn region esterelLoop						start=/loop/		end=/end loop/		contains=ALLBUT,esterelModule
syn region esterelAbort						start=/abort/		end=/when/			contains=ALLBUT,esterelModule
syn region esterelAbort						start=/weak abort/	end=/when/			contains=ALLBUT,esterelModule
syn region esterelEvery						start=/every/		end=/end every/		contains=ALLBUT,esterelModule
syn region esterelIf						start=/if/			end=/end if/		contains=ALLBUT,esterelModule
syn region esterelConcurrent	transparent start=/\[/			end=/\]/			contains=ALLBUT,esterelModule
syn region esterelIfThen					start=/if/			end=/then/			oneline
syn keyword esterelIO			input output inputoutput constant
syn keyword esterelBoolean		and or not xor xnor nor nand
syn keyword esterelExpressions	mod pre
syn keyword esterelStatement	nothing halt
syn keyword esterelStatement	module signal sensor end
syn keyword esterelStatement	every do loop abort weak
syn keyword esterelStatement	emit present await
syn keyword esterelStatement	pause when immediate
syn keyword esterelStatement	if then else case
syn keyword esterelStatement	var in  run  suspend
syn keyword esterelStatement	repeat times combine with
syn keyword esterelStatement	assert sustain
syn keyword esterelStatement	relation						
syn keyword esterelFunctions	function procedure task
syn keyword esterelSysCall		call trap exit exec
syn keyword esterelType 		integer float bolean
syn match esterelComment		"%.*$"
syn match esterelSpecial		":"
syn match esterelSpecial		"<="
syn match esterelSpecial		">="
syn match esterelSpecial		"+"
syn match esterelSpecial		"-"
syn match esterelSpecial		"="
syn match esterelSpecial		";"
syn match esterelSpecial		"/"
syn match esterelSpecial		"?"
syn match esterelOperator		"\["
syn match esterelOperator		"\]"
syn match esterelOperator		":="
syn match esterelOperator		"||"
syn match esterelStatement		"\<\(if\|else\)\>"
syn match esterelNone			"\<else\s\+if\>$"
syn match esterelNone			"\<else\s\+if\>\s"
hi def link esterelStatement		Statement
hi def link esterelType			Type
hi def link esterelComment		Comment
hi def link esterelBoolean		Number
hi def link esterelExpressions	Number
hi def link esterelIO			String
hi def link esterelOperator		Type
hi def link esterelSysCall		Type
hi def link esterelFunctions		Type
hi def link esterelSpecial		Special
let b:current_syntax = "esterel"
