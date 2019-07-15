if exists("b:current_syntax")
finish
endif
syn match	ppdComment	"^\*%.*"
syn match	ppdDef		"\*[a-zA-Z0-9]\+"
syn match	ppdDefine	"\*[a-zA-Z0-9\-_]\+:"
syn match	ppdUI		"\*[a-zA-Z]*\(Open\|Close\)UI"
syn match	ppdUIGroup	"\*[a-zA-Z]*\(Open\|Close\)Group"
syn match	ppdGUIText	"/.*:"
syn match	ppdContraints	"^*UIConstraints:"
hi def link ppdComment		Comment
hi def link ppdDefine		Statement
hi def link ppdUI			Function
hi def link ppdUIGroup		Function
hi def link ppdDef			String
hi def link ppdGUIText		Type
hi def link ppdContraints		Special
let b:current_syntax = "ppd"
