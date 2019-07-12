if exists("b:current_syntax")
finish
endif
syn match	qfFileName	"^[^|]*" nextgroup=qfSeparator
syn match	qfSeparator	"|" nextgroup=qfLineNr contained
syn match	qfLineNr	"[^|]*" contained contains=qfError
syn match	qfError		"error" contained
hi def link qfFileName	Directory
hi def link qfLineNr	LineNr
hi def link qfError	Error
let b:current_syntax = "qf"
