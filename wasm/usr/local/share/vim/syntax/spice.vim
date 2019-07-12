if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword	spiceTodo	contained TODO
syn match spiceComment  "^ \=\*.*$" contains=@Spell
syn match spiceComment  "\$.*$" contains=@Spell
syn match spiceNumber  "\<[0-9]\+\.[0-9]*\(e[-+]\=[0-9]\+\)\=\(meg\=\|[afpnumkg]\)\="
syn match spiceNumber  "\.[0-9]\+\(e[-+]\=[0-9]\+\)\=\(meg\=\|[afpnumkg]\)\="
syn match spiceNumber  "\<[0-9]\+\(e[-+]\=[0-9]\+\)\=\(meg\=\|[afpnumkg]\)\="
syn match   spiceWrapLineOperator       "\\$"
syn match   spiceWrapLineOperator       "^+"
syn match   spiceStatement      "^ \=\.\I\+"
syn region  spiceParen transparent matchgroup=spiceOperator start="(" end=")" contains=ALLBUT,spiceParenError
syn region  spiceSinglequote matchgroup=spiceOperator start=+'+ end=+'+
syn match spiceParenError ")"
syn sync minlines=50
hi def link spiceTodo		Todo
hi def link spiceWrapLineOperator	spiceOperator
hi def link spiceSinglequote	spiceExpr
hi def link spiceExpr		Function
hi def link spiceParenError	Error
hi def link spiceStatement		Statement
hi def link spiceNumber		Number
hi def link spiceComment		Comment
hi def link spiceOperator		Operator
let b:current_syntax = "spice"
