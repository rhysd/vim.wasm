if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn match viminfoError "^[^\t].*"
syn match viminfoStatement "^[/&$@:?=%!<]"
syn match viminfoStatement "^[-'>"]."
syn match viminfoStatement +^"".+
syn match viminfoStatement "^\~[/&]"
syn match viminfoStatement "^\~[hH]"
syn match viminfoStatement "^\~[mM][sS][lL][eE]\d\+\~\=[/&]"
syn match viminfoOption "^\*.*=" contains=viminfoOptionName
syn match viminfoOptionName "\*\a*"ms=s+1 contained
syn match viminfoComment "^#.*"
syn match viminfoNew "^|.*"
hi def link viminfoComment	Comment
hi def link viminfoError	Error
hi def link viminfoStatement	Statement
hi def link viminfoNew		String
let b:current_syntax = "viminfo"
let &cpo = s:cpo_save
unlet s:cpo_save
