if exists("b:current_syntax")
finish
endif
syn keyword	confTodo	contained TODO FIXME XXX
syn match	confComment	"^#.*" contains=confTodo
syn match	confComment	"\s#.*"ms=s+1 contains=confTodo
syn region	confString	start=+"+ skip=+\\\\\|\\"+ end=+"+ oneline
syn region	confString	start=+'+ skip=+\\\\\|\\'+ end=+'+ oneline
hi def link confComment	Comment
hi def link confTodo	Todo
hi def link confString	String
let b:current_syntax = "conf"
