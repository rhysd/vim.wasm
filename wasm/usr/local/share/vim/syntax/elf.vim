if exists("b:current_syntax")
finish
endif
syn case ignore
syn region elfEnvironment transparent matchgroup=Special start="{" matchgroup=Special end="}" contains=ALLBUT,elfBraceError
syn match elfBraceError "}"
syn keyword elfSpecial endmacro
syn region elfSpecial transparent matchgroup=Special start="^\(\(macro\)\|\(set\)\) \S\+$" matchgroup=Special end="^\(\(endmacro\)\|\(endset\)\)$" contains=ALLBUT,elfBraceError
syn keyword elfPPCom define include
syn keyword elfKeyword  false true null
syn keyword elfKeyword	var format object function endfunction
syn keyword elfConditional if else case of endcase for to next while until return goto
syn match elfMacro "[0-9_A-Za-z]\+@"
syn region elfString start=+"+  skip=+\\\\\|\\"+  end=+"+
syn match elfNumber "-\=\<[0-9]*\.\=[0-9_]\>"
syn region elfComment start="/\*"  end="\*/"
syn match elfComment  "\'.*$"
syn sync ccomment elfComment
syn match elfParens "[\[\]()]"
syn match elfPunct "[,;]"
hi def link elfComment Comment
hi def link elfPPCom Include
hi def link elfKeyword Keyword
hi def link elfSpecial Special
hi def link elfEnvironment Special
hi def link elfBraceError Error
hi def link elfConditional Conditional
hi def link elfMacro Function
hi def link elfNumber Number
hi def link elfString String
hi def link elfParens Delimiter
hi def link elfPunct Delimiter
let b:current_syntax = "elf"
