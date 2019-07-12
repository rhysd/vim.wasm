if exists("b:current_syntax")
finish
endif
syn keyword uilType	arguments	callbacks	color
syn keyword uilType	compound_string	controls	end
syn keyword uilType	exported	file		include
syn keyword uilType	module		object		procedure
syn keyword uilType	user_defined	xbitmapfile
syn keyword uilTodo contained	TODO
syn match   uilSpecial contained "\\\d\d\d\|\\."
syn region  uilString		start=+"+  skip=+\\\\\|\\"+  end=+"+  contains=@Spell,uilSpecial
syn match   uilCharacter	"'[^\\]'"
syn region  uilString		start=+'+  skip=+\\\\\|\\'+  end=+'+  contains=@Spell,uilSpecial
syn match   uilSpecialCharacter	"'\\.'"
syn match   uilSpecialStatement	"Xm[^	 =(){}:;]*"
syn match   uilSpecialFunction	"MrmNcreateCallback"
syn match   uilRessource	"XmN[^	 =(){}:;]*"
syn match  uilNumber		"-\=\<\d*\.\=\d\+\(e\=f\=\|[uU]\=[lL]\=\)\>"
syn match  uilNumber		"0[xX]\x\+\>"
syn region uilComment		start="/\*"  end="\*/" contains=@Spell,uilTodo
syn match  uilComment		"!.*" contains=@Spell,uilTodo
syn match  uilCommentError	"\*/"
syn region uilPreCondit		start="^#\s*\(if\>\|ifdef\>\|ifndef\>\|elif\>\|else\>\|endif\>\)"  skip="\\$"  end="$" contains=uilComment,uilString,uilCharacter,uilNumber,uilCommentError
syn match  uilIncluded contained "<[^>]*>"
syn match  uilInclude		"^#\s*include\s\+." contains=uilString,uilIncluded
syn match  uilLineSkip		"\\$"
syn region uilDefine		start="^#\s*\(define\>\|undef\>\)" end="$" contains=uilLineSkip,uilComment,uilString,uilCharacter,uilNumber,uilCommentError
syn sync ccomment uilComment
hi def link uilCharacter		uilString
hi def link uilSpecialCharacter	uilSpecial
hi def link uilNumber		uilString
hi def link uilCommentError	uilError
hi def link uilInclude		uilPreCondit
hi def link uilDefine		uilPreCondit
hi def link uilIncluded		uilString
hi def link uilSpecialFunction	uilRessource
hi def link uilRessource		Identifier
hi def link uilSpecialStatement	Keyword
hi def link uilError		Error
hi def link uilPreCondit		PreCondit
hi def link uilType		Type
hi def link uilString		String
hi def link uilComment		Comment
hi def link uilSpecial		Special
hi def link uilTodo		Todo
let b:current_syntax = "uil"
