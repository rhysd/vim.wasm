if exists("b:current_syntax")
finish
endif
syn case match
runtime! syntax/tak.vim
unlet b:current_syntax
syn case match
syn keyword takoutPos       ON SI
syn keyword takoutNeg       OFF ENG
syn match takoutTitle	     "TAK III"
syn match takoutTitle	     "Release \d.\d\d"
syn match takoutTitle	     " K & K  Associates *Thermal Analysis Kit III *Serial Number \d\d-\d\d\d"
syn match takoutFile	     ": \w*\.TAK"hs=s+2
syn match takoutInteger      "T\=[0-9]*\>"ms=s+1
syn match takoutSectionDelim "[-<>]\{4,}" contains=takoutSectionTitle
syn match takoutSectionDelim ":\=\.\{4,}:\=" contains=takoutSectionTitle
syn match takoutSectionTitle "[-<:] \w[0-9A-Za-z_() ]\+ [->:]"hs=s+1,me=e-1
syn match takoutHeaderDelim  "=\{5,}"
syn match takoutHeaderDelim  "|\{5,}"
syn match takoutHeaderDelim  "+\{5,}"
syn match takoutLabel	     "Input File:" contains=takoutFile
syn match takoutLabel	     "Begin Solution: Routine"
syn match takoutError	     "<<< Error >>>"
hi def link takoutPos		   Statement
hi def link takoutNeg		   PreProc
hi def link takoutTitle		   Type
hi def link takoutFile		   takIncludeFile
hi def link takoutInteger		   takInteger
hi def link takoutSectionDelim	    Delimiter
hi def link takoutSectionTitle	   Exception
hi def link takoutHeaderDelim	   SpecialComment
hi def link takoutLabel		   Identifier
hi def link takoutError		   Error
let b:current_syntax = "takout"
