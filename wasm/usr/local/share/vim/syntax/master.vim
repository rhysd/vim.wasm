if exists("b:current_syntax")
finish
endif
syn case match
syn keyword masterKeyword	FILENAME SUFFIX SEGNAME SEGTYPE PARENT FIELDNAME
syn keyword masterKeyword	FIELD ALIAS USAGE INDEX MISSING ON
syn keyword masterKeyword	FORMAT CRFILE CRKEY
syn keyword masterDefine	DEFINE DECODE EDIT
syn region  masterString	start=+"+  end=+"+
syn region  masterString	start=+'+  end=+'+
syn match   masterComment	"\$.*"
hi def link masterKeyword Keyword
hi def link masterComment Comment
hi def link masterString  String
let b:current_syntax = "master"
