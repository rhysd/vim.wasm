if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn match	snnspatError	".*"
syn match	snnspatAccepted	"\([-+]\=\(\d\+\.\|\.\)\=\d\+\([Ee][-+]\=\d\+\)\=\)"
syn match	snnspatAccepted "\s"
syn match	snnspatBrac	"\[\s*\d\+\(\s\|\d\)*\]" contains=snnspatNumbers
syn match	snnspatNoHeader	"No\. of patterns\s*:\s*" contained
syn match	snnspatNoHeader	"No\. of input units\s*:\s*" contained
syn match	snnspatNoHeader	"No\. of output units\s*:\s*" contained
syn match	snnspatNoHeader	"No\. of variable input dimensions\s*:\s*" contained
syn match	snnspatNoHeader	"No\. of variable output dimensions\s*:\s*" contained
syn match	snnspatNoHeader	"Maximum input dimensions\s*:\s*" contained
syn match	snnspatNoHeader	"Maximum output dimensions\s*:\s*" contained
syn match	snnspatGen	"generated at.*" contained contains=snnspatNumbers
syn match	snnspatGen	"SNNS pattern definition file [Vv]\d\.\d" contained contains=snnspatNumbers
syn region	snnspatHeader	start="^SNNS" end="^\s*[-+\.]\=[0-9#]"me=e-2 contains=snnspatNoHeader,snnspatNumbers,snnspatGen,snnspatBrac
syn match	snnspatNumbers	"\d" contained
syn match	snnspatComment	"#.*$" contains=snnspatTodo
syn keyword	snnspatTodo	TODO XXX FIXME contained
hi def link snnspatGen		Statement
hi def link snnspatHeader		Error
hi def link snnspatNoHeader	Define
hi def link snnspatNumbers		Number
hi def link snnspatComment		Comment
hi def link snnspatError		Error
hi def link snnspatTodo		Todo
hi def link snnspatAccepted	NONE
hi def link snnspatBrac		NONE
let b:current_syntax = "snnspat"
let &cpo = s:cpo_save
unlet s:cpo_save
