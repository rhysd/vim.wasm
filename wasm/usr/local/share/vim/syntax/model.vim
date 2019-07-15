if exists("b:current_syntax")
finish
endif
syn keyword modelKeyword abs and array boolean by case cdnl char copied dispose
syn keyword modelKeyword div do dynamic else elsif end entry external FALSE false
syn keyword modelKeyword fi file for formal fortran global if iff ift in integer include
syn keyword modelKeyword inline is lbnd max min mod new NIL nil noresult not notin od of
syn keyword modelKeyword or procedure public read readln readonly record recursive rem rep
syn keyword modelKeyword repeat res result return set space string subscript such then TRUE
syn keyword modelKeyword true type ubnd union until varies while width
syn keyword modelBlock beginproc endproc
syn region modelComment start="\$" end="\$" end="$"
syn region modelString start=+"+ end=+"+
syn match modelString "'."
hi def link modelKeyword	Statement
hi def link modelBlock		PreProc
hi def link modelComment	Comment
hi def link modelString		String
let b:current_syntax = "model"
