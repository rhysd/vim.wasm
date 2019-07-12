if exists("b:current_syntax")
finish
endif
runtime! syntax/cpp.vim
unlet b:current_syntax
syn region cCppString		start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=cSpecial,cFormat
syn keyword cType		integer real casestring nocasestring voidptr list
syn keyword cType		uview rview uview_enum rview_enum
syn clear   cUserCont
syn match   cUserCont		"^\s*\I\i*\s*:$" contains=cUserLabel contained
syn match   cUserCont		";\s*\I\i*\s*:$" contains=cUserLabel contained
syn match   cUserCont		"^\s*\I\i*\s*:[^:]"me=e-1 contains=cUserLabel contained
syn match   cUserCont		";\s*\I\i*\s*:[^:]"me=e-1 contains=cUserLabel contained
syn match   kwtPhylum		"^\I\i*:$"
syn match   kwtPhylum		"^\I\i*\s*{\s*\(!\|\I\)\i*\s*}\s*:$"
syn keyword kwtStatement	with foreach afterforeach provided
syn match kwtDecl		"%\(uviewvar\|rviewvar\)"
syn match kwtDecl		"^%\(uview\|rview\|ctor\|dtor\|base\|storageclass\|list\|attr\|member\|option\)"
syn match kwtOption		"no-csgio\|no-unparse\|no-rewrite\|no-printdot\|no-hashtables\|smart-pointer\|weak-pointer"
syn match kwtSep		"^%}$"
syn match kwtSep		"^%{\(\s\+\I\i*\)*$"
syn match kwtCast		"\<phylum_cast\s*<"me=e-1
syn match kwtCast		"\<phylum_cast\s*$"
syn clear cErrInBracket
syn match cErrInBracket		contained ")"
syn match kwtViews		"\(\[\|<\)\@<=[ [:alnum:]_]\{-}:"
syn region kwtUnpBody		transparent keepend extend fold start="->\s*\[" start="^\s*\[" skip="\$\@<!{\_.\{-}\$\@<!}" end="\s]\s\=;\=$" end="^]\s\=;\=$" end="}]\s\=;\=$"
syn region kwtRewBody		transparent keepend extend fold start="->\s*<" start="^\s*<" end="\s>\s\=;\=$" end="^>\s\=;\=$"
hi def link kwtStatement	cppStatement
hi def link kwtDecl	cppStatement
hi def link kwtCast	cppStatement
hi def link kwtSep	Delimiter
hi def link kwtViews	Label
hi def link kwtPhylum	Type
hi def link kwtOption	PreProc
syn sync lines=300
let b:current_syntax = "kwt"
