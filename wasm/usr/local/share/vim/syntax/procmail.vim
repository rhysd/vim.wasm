if exists("b:current_syntax")
finish
endif
syn match   procmailComment      "#.*$" contains=procmailTodo
syn keyword   procmailTodo      contained Todo TBD
syn region  procmailString       start=+"+  skip=+\\"+  end=+"+
syn region  procmailString       start=+'+  skip=+\\'+  end=+'+
syn region procmailVarDeclRegion start="^\s*[a-zA-Z0-9_]\+\s*="hs=e-1 skip=+\\$+ end=+$+ contains=procmailVar,procmailVarDecl,procmailString
syn match procmailVarDecl contained "^\s*[a-zA-Z0-9_]\+"
syn match procmailVar "$[a-zA-Z0-9_]\+"
syn match procmailCondition contained "^\s*\*.*"
syn match procmailActionFolder contained "^\s*[-_a-zA-Z0-9/]\+"
syn match procmailActionVariable contained "^\s*$[a-zA-Z_]\+"
syn region procmailActionForward start=+^\s*!+ skip=+\\$+ end=+$+
syn region procmailActionPipe start=+^\s*|+ skip=+\\$+ end=+$+
syn region procmailActionNested start=+^\s*{+ end=+^\s*}+ contains=procmailRecipe,procmailComment,procmailVarDeclRegion
syn region procmailRecipe start=+^\s*:.*$+ end=+^\s*\($\|}\)+me=e-1 contains=procmailComment,procmailCondition,procmailActionFolder,procmailActionVariable,procmailActionForward,procmailActionPipe,procmailActionNested,procmailVarDeclRegion
hi def link procmailComment Comment
hi def link procmailTodo    Todo
hi def link procmailRecipe   Statement
hi def link procmailActionFolder	procmailAction
hi def link procmailActionVariable procmailAction
hi def link procmailActionForward	procmailAction
hi def link procmailActionPipe	procmailAction
hi def link procmailAction		Function
hi def link procmailVar		Identifier
hi def link procmailVarDecl	Identifier
hi def link procmailString String
let b:current_syntax = "procmail"
