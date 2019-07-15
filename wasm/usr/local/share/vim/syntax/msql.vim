if exists("b:current_syntax")
finish
endif
if !exists("main_syntax")
let main_syntax = 'msql'
endif
runtime! syntax/html.vim
unlet b:current_syntax
syn cluster htmlPreproc add=msqlRegion
syn case match
syn keyword msqlIntVar ERRMSG contained
syn keyword msqlEnvVar SERVER_SOFTWARE SERVER_NAME SERVER_URL GATEWAY_INTERFACE contained
syn keyword msqlEnvVar SERVER_PROTOCOL SERVER_PORT REQUEST_METHOD PATH_INFO  contained
syn keyword msqlEnvVar PATH_TRANSLATED SCRIPT_NAME QUERY_STRING REMOTE_HOST contained
syn keyword msqlEnvVar REMOTE_ADDR AUTH_TYPE REMOTE_USER CONTEN_TYPE  contained
syn keyword msqlEnvVar CONTENT_LENGTH HTTPS HTTPS_KEYSIZE HTTPS_SECRETKEYSIZE  contained
syn keyword msqlEnvVar HTTP_ACCECT HTTP_USER_AGENT HTTP_IF_MODIFIED_SINCE  contained
syn keyword msqlEnvVar HTTP_FROM HTTP_REFERER contained
syn include @msqlLite <sfile>:p:h/lite.vim
syn region msqlRegion matchgroup=Delimiter start="<!$" start="<![^!->D]" end=">" contains=@msqlLite,msql.*
if exists("msql_minlines")
exec "syn sync minlines=" . msql_minlines
else
syn sync minlines=100
endif
hi def link msqlComment		Comment
hi def link msqlString		String
hi def link msqlNumber		Number
hi def link msqlFloat		Float
hi def link msqlIdentifier	Identifier
hi def link msqlGlobalIdentifier	Identifier
hi def link msqlIntVar		Identifier
hi def link msqlEnvVar		Identifier
hi def link msqlFunctions		Function
hi def link msqlRepeat		Repeat
hi def link msqlConditional	Conditional
hi def link msqlStatement		Statement
hi def link msqlType		Type
hi def link msqlInclude		Include
hi def link msqlDefine		Define
hi def link msqlSpecialChar	SpecialChar
hi def link msqlParentError	Error
hi def link msqlTodo		Todo
hi def link msqlOperator		Operator
hi def link msqlRelation		Operator
let b:current_syntax = "msql"
if main_syntax == 'msql'
unlet main_syntax
endif
