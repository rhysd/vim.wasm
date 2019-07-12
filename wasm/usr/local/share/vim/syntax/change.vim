if exists("b:current_syntax")
finish
endif
syn region changeFromMaterial start="^@x.*$"ms=e+1 end="^@y.*$"me=s-1
syn region changeToMaterial start="^@y.*$"ms=e+1 end="^@z.*$"me=s-1
hi def link changeFromMaterial String
hi def link changeToMaterial Statement
let b:current_syntax = "change"
