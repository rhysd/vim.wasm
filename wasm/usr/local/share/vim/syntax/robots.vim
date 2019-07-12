if exists("b:current_syntax")
finish
endif
syn case ignore
syn match  robotsComment	"#.*$" contains=robotsUrl,robotsMail,robotsString
syn match  robotsStar		"\*"
syn match  robotsDelimiter	":"
syn match  robotsAgent		"^[Uu][Ss][Ee][Rr]\-[Aa][Gg][Ee][Nn][Tt]"
syn match  robotsDisallow	"^[Dd][Ii][Ss][Aa][Ll][Ll][Oo][Ww]"
synt match robotsLine		"\(^[Uu][Ss][Ee][Rr]\-[Aa][Gg][Ee][Nn][Tt]\|^[Dd][Ii][Ss][Aa][Ll][Ll][Oo][Ww]\):[^#]*"	contains=robotsAgent,robotsDisallow,robotsStar,robotsDelimiter
syn match  robotsUrl		"http[s]\=://\S*"
syn match  robotsMail		"\S*@\S*"
syn region robotsString		start=+L\="+ skip=+\\\\\|\\"+ end=+"+
hi def link robotsComment		Comment
hi def link robotsAgent		Type
hi def link robotsDisallow		Statement
hi def link robotsLine		Special
hi def link robotsStar		Operator
hi def link robotsDelimiter	Delimiter
hi def link robotsUrl		String
hi def link robotsMail		String
hi def link robotsString		String
let b:current_syntax = "robots"
