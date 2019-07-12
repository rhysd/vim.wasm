if exists("b:current_syntax")
finish
endif
syn match abaqusComment	"^\*\*.*$"
syn match abaqusKeywordLine "^\*\h.*" contains=abaqusKeyword,abaqusParameter,abaqusValue display
syn match abaqusKeyword "^\*\h[^,]*" contained display
syn match abaqusParameter ",[^,=]\+"lc=1 contained display
syn match abaqusValue	"=\s*[^,]*"lc=1 contained display
syn match abaqusBadLine	"^\s\+\*.*" display
hi def link abaqusComment	Comment
hi def link abaqusKeyword	Statement
hi def link abaqusParameter	Identifier
hi def link abaqusValue	Constant
hi def link abaqusBadLine    Error
let b:current_syntax = "abaqus"
