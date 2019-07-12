if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn case ignore
syn match blankInstruction "{[:;,\.+\-*$#@/\\`'"!\|><{}\[\]()?xspo\^&\~=_%]}"
syn match blankString "\~[^}]"
syn match blankNumber "\[[0-9]\+\]"
syn case match
hi def link blankInstruction      Statement
hi def link blankNumber	       Number
hi def link blankString	       String
let b:current_syntax = "blank"
let &cpo = s:cpo_save
unlet s:cpo_save
