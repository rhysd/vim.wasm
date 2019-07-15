if exists("b:current_syntax")
finish
endif
let s:keepcpo= &cpo
set cpo&vim
syn keyword taskdataKey		description due end entry imask mask parent
syn keyword taskdataKey		priority project recur start status tags uuid
syn match taskdataKey		"annotation_\d\+"
syn match taskdataUndo		"^time.*$"
syn match taskdataUndo		"^\(old \|new \|---\)"
syn region taskdataString	matchgroup=Normal start=+"+ end=+"+
\	contains=taskdataEncoded,taskdataUUID,@Spell
syn match taskdataEncoded	"&\a\+;" contained
syn match taskdataUUID		"\x\{8}-\(\x\{4}-\)\{3}\x\{12}" contained
hi def link taskdataEncoded	Function
hi def link taskdataKey		Statement
hi def link taskdataString 	String
hi def link taskdataUUID 	Special
hi def link taskdataUndo 	Type
let b:current_syntax = "taskdata"
let &cpo = s:keepcpo
unlet s:keepcpo
