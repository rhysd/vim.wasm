if exists("b:current_syntax")
finish
endif
syn case ignore
syn match  apOption	/^\s*[^ \t#<=]*/
syn match  apComment	/^\s*#.*$/
syn region apTag	start=/</ end=/>/ contains=apTagOption,apTagError
syn match  apTagOption	contained / [-\/_\.:*a-zA-Z0-9]\+/ms=s+1
syn match  apTagError	contained /[^>]</ms=s+1
hi def link apComment	Comment
hi def link apOption	Keyword
hi def link apTag		Special
hi def link apTagOption	Identifier
hi def link apTagError	Error
let b:current_syntax = "apachestyle"
