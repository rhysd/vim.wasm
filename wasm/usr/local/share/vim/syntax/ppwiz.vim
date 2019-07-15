if exists("b:current_syntax")
finish
endif
syn case ignore
if !exists("ppwiz_highlight_defs")
let ppwiz_highlight_defs = 1
endif
if !exists("ppwiz_with_html")
let ppwiz_with_html = 1
endif
syn match   ppwizComment  "^;.*$"
syn match   ppwizComment  ";;.*$"
if ppwiz_with_html > 0
syn region ppwizHTML  start="<" end=">" contains=ppwizArg,ppwizMacro
syn match  ppwizHTML  "\&\w\+;"
endif
if ppwiz_highlight_defs == 1
syn match  ppwizDef   "^\s*\#\S\+\s\+\S\+" contains=ALL
syn match  ppwizDef   "^\s*\#\(if\|else\|endif\)" contains=ALL
syn match  ppwizDef   "^\s*\#\({\|break\|continue\|}\)" contains=ALL
else
syn region ppwizDef   start="^\s*\#" end="[^\\]$" end="^$" keepend contains=ppwizCont
endif
syn match   ppwizError    "\s.\\$"
syn match   ppwizCont     "\s\([+\-%]\|\)\\$"
syn region  ppwizMacro    start="<\$" end=">" contains=@ppwizArgVal,ppwizCont
syn region  ppwizArg      start="{" end="}" contains=ppwizEqual,ppwizString
syn match   ppwizEqual    "=" contained
syn match   ppwizOperator "<>\|=\|<\|>" contained
syn region  ppwizStdVar   start="<?[^?]" end=">" contains=@ppwizArgVal
syn region  ppwizRexxVar  start="<??" end=">" contains=@ppwizArgVal
syn region  ppwizString   start=+"+ end=+"+ contained contains=ppwizMacro,ppwizArg,ppwizHTML,ppwizCont,ppwizStdVar,ppwizRexxVar
syn region  ppwizString   start=+'+ end=+'+ contained contains=ppwizMacro,ppwizArg,ppwizHTML,ppwizCont,ppwizStdVar,ppwizRexxVar
syn match   ppwizInteger  "\d\+" contained
syn cluster ppwizArgVal add=ppwizString,ppwizInteger
hi def link ppwizSpecial  Special
hi def link ppwizEqual    ppwizSpecial
hi def link ppwizOperator ppwizSpecial
hi def link ppwizComment  Comment
hi def link ppwizDef      PreProc
hi def link ppwizMacro    Statement
hi def link ppwizArg      Identifier
hi def link ppwizStdVar   Identifier
hi def link ppwizRexxVar  Identifier
hi def link ppwizString   Constant
hi def link ppwizInteger  Constant
hi def link ppwizCont     ppwizSpecial
hi def link ppwizError    Error
hi def link ppwizHTML     Type
let b:current_syntax = "ppwiz"
