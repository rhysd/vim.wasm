if exists("b:current_syntax")
finish
endif
syn case match
syn match rtfControlWord	"\\[a-z]\+[\-]\=[0-9]*"
syn match rtfNewControlWord	"\\\*\\[a-z]\+[\-]\=[0-9]*"
syn match rtfControlSymbol	"\\[^a-zA-Z\*\{\}\\']"
syn match rtfCharacter		"\\\\"
syn match rtfCharacter		"\\{"
syn match rtfCharacter		"\\}"
syn match rtfCharacter		"\\'[A-Za-z0-9][A-Za-z0-9]"
syn match rtfUnicodeCharacter	"\\u[0-9][0-9]*"
syn match rtfRed		"\\red[0-9][0-9]*"
syn match rtfGreen		"\\green[0-9][0-9]*"
syn match rtfBlue		"\\blue[0-9][0-9]*"
syn match rtfFootNote "[#$K+]{\\footnote.*}" contains=rtfControlWord,rtfNewControlWord
hi def link rtfControlWord		Statement
hi def link rtfNewControlWord	Special
hi def link rtfControlSymbol	Constant
hi def link rtfCharacter		Character
hi def link rtfUnicodeCharacter	SpecialChar
hi def link rtfFootNote		Comment
hi rtfRed	      term=underline cterm=underline ctermfg=DarkRed gui=underline guifg=DarkRed
hi rtfGreen	      term=underline cterm=underline ctermfg=DarkGreen gui=underline guifg=DarkGreen
hi rtfBlue	      term=underline cterm=underline ctermfg=DarkBlue gui=underline guifg=DarkBlue
hi def link rtfRed	rtfRed
hi def link rtfGreen	rtfGreen
hi def link rtfBlue	rtfBlue
let b:current_syntax = "rtf"
