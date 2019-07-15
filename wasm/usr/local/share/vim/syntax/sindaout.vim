if exists("b:current_syntax")
finish
endif
syn case match
runtime! syntax/sinda.vim
unlet b:current_syntax
syn case match
syn keyword sindaoutPos       ON SI
syn keyword sindaoutNeg       OFF ENG
syn match sindaoutFile	       ": \w*\.TAK"hs=s+2
syn match sindaoutInteger      "T\=[0-9]*\>"ms=s+1
syn match sindaoutSectionDelim "[-<>]\{4,}" contains=sindaoutSectionTitle
syn match sindaoutSectionDelim ":\=\.\{4,}:\=" contains=sindaoutSectionTitle
syn match sindaoutSectionTitle "[-<:] \w[0-9A-Za-z_() ]\+ [->:]"hs=s+1,me=e-1
syn match sindaoutHeaderDelim  "=\{5,}"
syn match sindaoutHeaderDelim  "|\{5,}"
syn match sindaoutHeaderDelim  "+\{5,}"
syn match sindaoutLabel		"Input File:" contains=sindaoutFile
syn match sindaoutLabel		"Begin Solution: Routine"
syn match sindaoutError		"<<< Error >>>"
hi sindaHeaderDelim  ctermfg=Black ctermbg=Green	       guifg=Black guibg=Green
hi def link sindaoutPos		     Statement
hi def link sindaoutNeg		     PreProc
hi def link sindaoutTitle		     Type
hi def link sindaoutFile		     sindaIncludeFile
hi def link sindaoutInteger	     sindaInteger
hi def link sindaoutSectionDelim	      Delimiter
hi def link sindaoutSectionTitle	     Exception
hi def link sindaoutHeaderDelim	     SpecialComment
hi def link sindaoutLabel		     Identifier
hi def link sindaoutError		     Error
let b:current_syntax = "sindaout"
