if exists("b:current_syntax")
finish
endif
syn match jargonChaptTitle	/:[^:]*:/
syn match jargonEmailAddr	/[^<@ ^I]*@[^ ^I>]*/
syn match jargonUrl	 +\(http\|ftp\)://[^\t )"]*+
syn match jargonMark	/{[^}]*}/
hi def link jargonChaptTitle	Title
hi def link jargonEmailAddr	 Comment
hi def link jargonUrl	 Comment
hi def link jargonMark	Label
let b:current_syntax = "jargon"
