if exists("b:current_syntax")
finish
endif
runtime! syntax/cynlib.vim
unlet b:current_syntax
syn keyword     cynppMacro      Always EndAlways
syn keyword     cynppMacro      Module EndModule
syn keyword     cynppMacro      Initial EndInitial
syn keyword     cynppMacro      Posedge Negedge Changed
syn keyword     cynppMacro      At
syn keyword     cynppMacro      Thread EndThread
syn keyword     cynppMacro      Instantiate
hi def link cLabel		Label
hi def link cynppMacro  Statement
let b:current_syntax = "cynpp"
