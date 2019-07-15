if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword takcmpUnit     celsius fahrenheit
syn match  takcmpTitle       "Steady State Temperature Comparison"
syn match  takcmpLabel       "Run Date:"
syn match  takcmpLabel       "Run Time:"
syn match  takcmpLabel       "Temp. File \d Units:"
syn match  takcmpLabel       "Filename:"
syn match  takcmpLabel       "Output Units:"
syn match  takcmpHeader      "^ *Node\( *File  \d\)* *Node Description"
syn match  takcmpDate        "\d\d\/\d\d\/\d\d"
syn match  takcmpTime        "\d\d:\d\d:\d\d"
syn match  takcmpInteger     "^ *-\=\<[0-9]*\>"
syn match  takcmpFloat       "-\=\<[0-9]*\.[0-9]*"
hi def link takcmpTitle		   Type
hi def link takcmpUnit		   PreProc
hi def link takcmpLabel		   Statement
hi def link takcmpHeader		   takHeader
hi def link takcmpDate		   Identifier
hi def link takcmpTime		   Identifier
hi def link takcmpInteger		   Number
hi def link takcmpFloat		   Special
let b:current_syntax = "takcmp"
