if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
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
syn clear javaFuncDef
syn match javaFuncDef "[$_a-zA-Z][$_a-zA-Z0-9_. \[\]]*([^-+*/()]*)[ \t]*:" contains=javaType
syn keyword javaccPackages options DEBUG_PARSER DEBUG_LOOKAHEAD DEBUG_TOKEN_MANAGER
syn keyword javaccPackages COMMON_TOKEN_ACTION IGNORE_CASE CHOICE_AMBIGUITY_CHECK
syn keyword javaccPackages OTHER_AMBIGUITY_CHECK STATIC LOOKAHEAD ERROR_REPORTING
syn keyword javaccPackages USER_TOKEN_MANAGER  USER_CHAR_STREAM JAVA_UNICODE_ESCAPE
syn keyword javaccPackages UNICODE_INPUT JDK_VERSION
syn match javaccPackages "PARSER_END([^)]*)"
syn match javaccPackages "PARSER_BEGIN([^)]*)"
syn match javaccSpecToken "<EOF>"
syn match javaccSpecToken ".LOOKAHEAD("ms=s+1,me=e-1
syn match javaccToken "<[^> \t]*>"
syn keyword javaccActionToken TOKEN SKIP MORE SPECIAL_TOKEN
syn keyword javaccError DEBUG IGNORE_IN_BNF
hi def link javaccSpecToken Statement
hi def link javaccActionToken Type
hi def link javaccPackages javaScopeDecl
hi def link javaccToken String
hi def link javaccError Error
let b:current_syntax = "javacc"
let &cpo = s:cpo_save
unlet s:cpo_save
