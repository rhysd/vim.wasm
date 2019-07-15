if exists("b:current_syntax")
finish
end
syn case match
syn sync fromstart
syn region chaiscriptString        start=+"+ end=+"+ skip=+\\\\\|\\"+ contains=chaiscriptSpecial,chaiscriptEval,@Spell
syn match  chaiscriptSpecial       contained "\\[\\abfnrtv\'\"]\|\\\d\{,3}" 
syn region chaiscriptEval          contained start="${" end="}" 
syn match  chaiscriptNumber        "\<\d\+\>"
syn match  chaiscriptFloat         "\<\d\+\.\d*\%(e[-+]\=\d\+\)\=\>"
syn match  chaiscriptFloat         "\.\d\+\%(e[-+]\=\d\+\)\=\>"
syn match  chaiscriptFloat         "\<\d\+e[-+]\=\d\+\>"
syn match  chaiscriptNumber        "\<0x\x\+\>"
syn match  chaiscriptNumber        "\<0b[01]\+\>"
syn keyword chaiscriptCond         if else
syn keyword chaiscriptRepeat       while for do
syn keyword chaiscriptStatement    break continue return
syn keyword chaiscriptExceptions   try catch throw
syn keyword chaiscriptKeyword      def true false attr
syn keyword chaiscriptType         fun var
syn keyword chaiscriptFunc         eval throw
syn region  chaiscriptFunc         matchgroup=chaiscriptFunc start="`" end="`"
syn match   chaiscriptOperator     "\.\."
syn match   chaiscriptOperator     ":"
syn match   chaiscriptComment      "//.*$" contains=@Spell
syn region  chaiscriptComment      matchgroup=chaiscriptComment start="/\*" end="\*/" contains=@Spell
hi def link chaiscriptExceptions	Exception
hi def link chaiscriptKeyword		Keyword
hi def link chaiscriptStatement		Statement
hi def link chaiscriptRepeat		Repeat
hi def link chaiscriptString		String
hi def link chaiscriptNumber		Number
hi def link chaiscriptFloat		Float
hi def link chaiscriptOperator		Operator
hi def link chaiscriptConstant		Constant
hi def link chaiscriptCond		Conditional
hi def link chaiscriptFunction		Function
hi def link chaiscriptComment		Comment
hi def link chaiscriptTodo		Todo
hi def link chaiscriptError		Error
hi def link chaiscriptSpecial		SpecialChar
hi def link chaiscriptFunc		Identifier
hi def link chaiscriptType		Type
hi def link chaiscriptEval	        Special
let b:current_syntax = "chaiscript"
