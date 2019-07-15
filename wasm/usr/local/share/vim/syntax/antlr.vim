if exists("b:current_syntax")
finish
endif
runtime! syntax/java.vim
unlet b:current_syntax
syn match	javaParen "--"
syn match	javaParenError "--"
syn match	javaInParen "--"
syn match	javaError2 "--"
syn clear	javaParen
syn clear	javaParenError
syn clear	javaInParen
syn clear	javaError2
syn keyword antlrPackages options language buildAST
syn match antlrPackages "PARSER_END([^)]*)"
syn match antlrPackages "PARSER_BEGIN([^)]*)"
syn match antlrSpecToken "<EOF>"
syn match antlrSpecToken ".LOOKAHEAD("ms=s+1,me=e-1
syn match antlrSep "[|:]\|\.\."
syn keyword antlrActionToken TOKEN SKIP MORE SPECIAL_TOKEN
syn keyword antlrError DEBUG IGNORE_IN_BNF
hi def link antlrSep Statement
hi def link antlrPackages Statement
let b:current_syntax = "antlr"
