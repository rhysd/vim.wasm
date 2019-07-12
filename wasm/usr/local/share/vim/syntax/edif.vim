if exists("b:current_syntax")
finish
endif
setlocal iskeyword=48-57,-,+,A-Z,a-z,_,&
syn region	edifList	matchgroup=Delimiter start="(" end=")" contains=edifList,edifKeyword,edifString,edifNumber
syn match       edifInStringError    /%/ contained
syn match       edifInString    /%\s*\d\+\s*%/ contained
syn region      edifString      start=/"/ end=/"/ contains=edifInString,edifInStringError contained
syn match       edifNumber      "\<[-+]\=[0-9]\+\>"
syn match       edifKeyword     "(\@<=\s*[a-zA-Z&][a-zA-Z_0-9]*\>" contained
syn match       edifError       ")"
syntax sync fromstart
hi def link edifInString		SpecialChar
hi def link edifKeyword		Keyword
hi def link edifNumber		Number
hi def link edifInStringError	edifError
hi def link edifError		Error
hi def link edifString		String
let b:current_syntax = "edif"
