if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword sindacmpUnit     celsius fahrenheit
syn match  sindacmpTitle       "Steady State Temperature Comparison"
syn match  sindacmpLabel       "File  [1-6] is"
syn match  sindacmpHeader      "^ *Node\( *File  \d\)* *Node Description"
syn match  sindacmpInteger     "^ *-\=\<[0-9]*\>"
syn match  sindacmpFloat       "-\=\<[0-9]*\.[0-9]*"
hi def link sindacmpTitle		     Type
hi def link sindacmpUnit		     PreProc
hi def link sindacmpLabel		     Statement
hi def link sindacmpHeader		     sindaHeader
hi def link sindacmpInteger	     Number
hi def link sindacmpFloat		     Special
let b:current_syntax = "sindacmp"
