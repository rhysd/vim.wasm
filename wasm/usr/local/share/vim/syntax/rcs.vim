if exists("b:current_syntax")
finish
endif
syn match rcsEOFError   ".\%$" containedin=ALL
syn keyword rcsKeyword  head branch access symbols locks strict
syn keyword rcsKeyword  comment expand date author state branches
syn keyword rcsKeyword  next desc log
syn keyword rcsKeyword  text nextgroup=rcsTextStr skipwhite skipempty
syn match rcsNumber "\<[0-9.]\+\>" display
if exists("rcs_folding") && has("folding")
syn region rcsString  matchgroup=rcsString start="@" end="@" skip="@@" fold contains=rcsSpecial
syn region rcsTextStr matchgroup=rcsTextStr start="@" end="@" skip="@@" fold contained contains=rcsSpecial,rcsDiffLines
else
syn region rcsString  matchgroup=rcsString start="@" end="@" skip="@@" contains=rcsSpecial
syn region rcsTextStr matchgroup=rcsTextStr start="@" end="@" skip="@@" contained contains=rcsSpecial,rcsDiffLines
endif
syn match rcsSpecial    "@@" contained
syn match rcsDiffLines  "[da]\d\+ \d\+$" contained
syn sync clear
if exists("rcs_folding") && has("folding")
syn sync fromstart
else
syn sync match rcsSync    grouphere rcsString "[0-9.]\+\(\s\|\n\)\+log\(\s\|\n\)\+@"me=e-1
syn sync match rcsSync    grouphere rcsTextStr "@\(\s\|\n\)\+text\(\s\|\n\)\+@"me=e-1
endif
hi def link rcsKeyword     Keyword
hi def link rcsNumber      Identifier
hi def link rcsString      String
hi def link rcsTextStr     String
hi def link rcsSpecial     Special
hi def link rcsDiffLines   Special
hi def link rcsEOFError    Error
let b:current_syntax = "rcs"
