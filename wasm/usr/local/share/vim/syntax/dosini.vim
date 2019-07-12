if exists("b:current_syntax")
finish
endif
syn case ignore
syn match  dosiniLabel    "^.\{-}\ze\s*=" nextgroup=dosiniNumber,dosiniValue
syn match  dosiniValue    "=\zs.*"
syn match  dosiniNumber   "=\zs\s*\d\+\s*$"
syn match  dosiniNumber   "=\zs\s*\d*\.\d\+\s*$"
syn match  dosiniNumber   "=\zs\s*\d\+e[+-]\=\d\+\s*$"
syn region dosiniHeader   start="^\s*\[" end="\]"
syn match  dosiniComment  "^[#;].*$"
hi def link dosiniNumber   Number
hi def link dosiniHeader   Special
hi def link dosiniComment  Comment
hi def link dosiniLabel    Type
hi def link dosiniValue    String
let b:current_syntax = "dosini"
