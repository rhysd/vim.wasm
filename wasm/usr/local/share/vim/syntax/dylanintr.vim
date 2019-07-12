if exists("b:current_syntax")
finish
endif
syn case ignore
syn region	dylanintrInfo		matchgroup=Statement start="^" end=":" oneline
syn match	dylanintrInterface	"define interface"
syn match	dylanintrClass		"<.*>"
syn region	dylanintrType		start=+"+ skip=+\\\\\|\\"+ end=+"+
syn region	dylanintrIncluded	contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match	dylanintrIncluded	contained "<[^>]*>"
syn match	dylanintrInclude	"^\s*#\s*include\>\s*["<]" contains=intrIncluded
hi def link dylanintrInfo		Special
hi def link dylanintrInterface	Operator
hi def link dylanintrMods		Type
hi def link dylanintrClass		StorageClass
hi def link dylanintrType		Type
hi def link dylanintrIncluded	String
hi def link dylanintrInclude	Include
let b:current_syntax = "dylanintr"
