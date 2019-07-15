if !exists("main_syntax")
if exists("b:current_syntax")
finish
endif
let main_syntax = 'json'
endif
syntax match   jsonNoise           /\%(:\|,\)/
syn match  jsonStringMatch /"\([^"]\|\\\"\)\+"\ze[[:blank:]\r\n]*[,}\]]/ contains=jsonString
if has('conceal')
syn region  jsonString oneline matchgroup=jsonQuote start=/"/  skip=/\\\\\|\\"/  end=/"/ concealends contains=jsonEscape contained
else
syn region  jsonString oneline matchgroup=jsonQuote start=/"/  skip=/\\\\\|\\"/  end=/"/ contains=jsonEscape contained
endif
syn region  jsonStringSQError oneline  start=+'+  skip=+\\\\\|\\"+  end=+'+
syn match  jsonKeywordMatch /"\([^"]\|\\\"\)\+"[[:blank:]\r\n]*\:/ contains=jsonKeyword
if has('conceal')
syn region  jsonKeyword matchgroup=jsonQuote start=/"/  end=/"\ze[[:blank:]\r\n]*\:/ concealends contained
else
syn region  jsonKeyword matchgroup=jsonQuote start=/"/  end=/"\ze[[:blank:]\r\n]*\:/ contained
endif
syn match   jsonEscape    "\\["\\/bfnrt]" contained
syn match   jsonEscape    "\\u\x\{4}" contained
syn match   jsonNumber    "-\=\<\%(0\|[1-9]\d*\)\%(\.\d\+\)\=\%([eE][-+]\=\d\+\)\=\>\ze[[:blank:]\r\n]*[,}\]]"
if (!exists("g:vim_json_warnings") || g:vim_json_warnings==1)
syn match   jsonNoQuotesError  "\<[[:alpha:]][[:alnum:]]*\>"
syn match   jsonTripleQuotesError  /"""/
syn match   jsonNumError  "-\=\<0\d\.\d*\>"
syn match   jsonNumError  "\:\@<=[[:blank:]\r\n]*\zs\.\d\+"
syn match   jsonCommentError  "//.*"
syn match   jsonCommentError  "\(/\*\)\|\(\*/\)"
syn match   jsonSemicolonError  ";"
syn match   jsonTrailingCommaError  ",\_s*[}\]]"
syn match   jsonMissingCommaError /\("\|\]\|\d\)\zs\_s\+\ze"/
syn match   jsonMissingCommaError /\(\]\|\}\)\_s\+\ze"/ "arrays/objects as values
syn match   jsonMissingCommaError /}\_s\+\ze{/ "objects as elements in an array
syn match   jsonMissingCommaError /\(true\|false\)\_s\+\ze"/ "true/false as value
endif
syn match  jsonPadding "\%^[[:blank:]\r\n]*[_$[:alpha:]][_$[:alnum:]]*[[:blank:]\r\n]*("
syn match  jsonPadding ");[[:blank:]\r\n]*\%$"
syn match  jsonBoolean /\(true\|false\)\(\_s\+\ze"\)\@!/
syn keyword  jsonNull      null
syn region  jsonFold matchgroup=jsonBraces start="{" end=/}\(\_s\+\ze\("\|{\)\)\@!/ transparent fold
syn region  jsonFold matchgroup=jsonBraces start="\[" end=/]\(\_s\+\ze"\)\@!/ transparent fold
hi def link jsonPadding         Operator
hi def link jsonString          String
hi def link jsonTest          Label
hi def link jsonEscape          Special
hi def link jsonNumber          Number
hi def link jsonBraces          Delimiter
hi def link jsonNull            Function
hi def link jsonBoolean         Boolean
hi def link jsonKeyword         Label
if (!exists("g:vim_json_warnings") || g:vim_json_warnings==1)
hi def link jsonNumError        Error
hi def link jsonCommentError    Error
hi def link jsonSemicolonError  Error
hi def link jsonTrailingCommaError     Error
hi def link jsonMissingCommaError      Error
hi def link jsonStringSQError        	Error
hi def link jsonNoQuotesError        	Error
hi def link jsonTripleQuotesError     	Error
endif
hi def link jsonQuote           Quote
hi def link jsonNoise           Noise
let b:current_syntax = "json"
if main_syntax == 'json'
unlet main_syntax
endif
