if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword tssopParam  ir_eps ir_trans ir_spec ir_tspec ir_refract
syn keyword tssopParam  sol_eps sol_trans sol_spec sol_tspec sol_refract
syn keyword tssopParam  color
syn keyword tssopArgs   white red blue green yellow orange violet pink
syn keyword tssopArgs   turquoise grey black
syn match  tssopComment       /comment \+= \+".*"/ contains=tssopParam,tssopCommentString
syn match  tssopCommentString /".*"/ contained
syn match  tssopProp	    "property "
syn match  tssopProp	    "edit/optic "
syn match  tssopPropName    "^property \S\+" contains=tssopProp
syn match  tssopPropName    "^edit/optic \S\+$" contains=tssopProp
syn match  tssopInteger     "-\=\<[0-9]*\>"
syn match  tssopFloat       "-\=\<[0-9]*\.[0-9]*"
syn match  tssopScientific  "-\=\<[0-9]*\.[0-9]*E[-+]\=[0-9]\+\>"
hi def link tssopParam		Statement
hi def link tssopProp		Identifier
hi def link tssopArgs		Special
hi def link tssopComment		Statement
hi def link tssopCommentString	Comment
hi def link tssopPropName		Typedef
hi def link tssopInteger		Number
hi def link tssopFloat		Float
hi def link tssopScientific	Float
let b:current_syntax = "tssop"
