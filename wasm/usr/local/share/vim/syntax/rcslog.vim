if exists("b:current_syntax")
finish
endif
syn match rcslogRevision	"^revision.*$"
syn match rcslogFile		"^RCS file:.*"
syn match rcslogDate		"^date: .*$"
hi def link rcslogFile		Type
hi def link rcslogRevision	Constant
hi def link rcslogDate		Identifier
let b:current_syntax = "rcslog"
