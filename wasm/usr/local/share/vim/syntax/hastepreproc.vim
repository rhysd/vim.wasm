if exists("b:current_syntax")
finish
endif
runtime! syntax/haste.vim
unlet b:current_syntax
syn case match
syn match  hastepreprocVar 	display "\$[[:alnum:]_]*"
syn region hastepreprocVar	start="\${" end="}" contains=hastepreprocVar
syn region hastepreproc		start="#\[\s*\(\|tgfor\|tgif\)" end="$" contains=hastepreprocVar,hastepreproc,@Spell
syn region hastepreproc		start="}\s\(else\)\s{" end="$" contains=hastepreprocVar,hastepreproc,@Spell
syn region hastepreproc		start="^\s*#\s*\(ifndef\|ifdef\|else\|endif\)\>" end="$" contains=@hastepreprocGroup,@Spell
syn region hastepreproc		start="\s*##\s*\(define\|undef\)\>" end="$" contains=@hastepreprocGroup,@Spell
syn match hastepreproc		"}\{0,1}\s*]#"
hi def link hastepreproc	Preproc
hi def link hastepreprocVar	Special
hi def link hastepreprocError	Error
let b:current_syntax = "hastepreproc"
