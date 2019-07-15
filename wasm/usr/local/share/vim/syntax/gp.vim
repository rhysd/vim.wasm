if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syntax keyword gpStatement	break return next
syntax keyword gpConditional	if
syntax keyword gpRepeat		until while for fordiv forell forprime 
syntax keyword gpRepeat		forsubgroup forstep forvec
syntax keyword gpScope		my local global
syntax keyword gpInterfaceKey	breakloop colors compatible
syntax keyword gpInterfaceKey	datadir debug debugfiles debugmem 
syntax keyword gpInterfaceKey	echo factor_add_primes factor_proven format 
syntax keyword gpInterfaceKey	graphcolormap graphcolors
syntax keyword gpInterfaceKey	help histfile histsize 
syntax keyword gpInterfaceKey	lines linewrap log logfile new_galois_format
syntax keyword gpInterfaceKey	output parisize path prettyprinter primelimit
syntax keyword gpInterfaceKey	prompt prompt_cont psfile 
syntax keyword gpInterfaceKey	readline realprecision recover 
syntax keyword gpInterfaceKey	secure seriesprecision simplify strictmatch
syntax keyword gpInterfaceKey	TeXstyle timer
syntax match gpInterface	"^\s*\\[a-z].*"
syntax keyword gpInterface	default
syntax keyword gpInput		read input
syntax match gpFunRegion "^\s*[a-zA-Z][_a-zA-Z0-9]*(.*)\s*=\s*[^ \t=]"me=e-1 contains=gpFunction,gpArgs
syntax match gpFunRegion "^\s*[a-zA-Z][_a-zA-Z0-9]*(.*)\s*=\s*$" contains=gpFunction,gpArgs
syntax match gpArgs contained "[a-zA-Z][_a-zA-Z0-9]*"
syntax match gpFunction contained "^\s*[a-zA-Z][_a-zA-Z0-9]*("me=e-1
syntax match  gpSpecial contained "\\[ent\\]"
syntax region gpString  start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=gpSpecial
syntax region gpComment	start="/\*"  end="\*/" contains=gpTodo
syntax match  gpComment "\\\\.*" contains=gpTodo
syntax keyword gpTodo contained	TODO
syntax sync ccomment gpComment minlines=10
syntax region gpParen		transparent start='(' end=')' contains=ALLBUT,gpParenError,gpTodo,gpFunction,gpArgs,gpSpecial
syntax match gpParenError	")"
syntax match gpInParen contained "[{}]"
hi def link gpConditional		Conditional
hi def link gpRepeat		Repeat
hi def link gpError		Error
hi def link gpParenError		gpError
hi def link gpInParen		gpError
hi def link gpStatement		Statement
hi def link gpString		String
hi def link gpComment		Comment
hi def link gpInterface		Type
hi def link gpInput		Type
hi def link gpInterfaceKey		Statement
hi def link gpFunction		Function
hi def link gpScope		Type
hi def link gpSpecial		Special
hi def link gpTodo			Todo
hi def link gpArgs			Type
let b:current_syntax = "gp"
let &cpo = s:cpo_save
unlet s:cpo_save
