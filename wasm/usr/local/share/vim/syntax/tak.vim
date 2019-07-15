if exists("b:current_syntax")
finish
endif
syn case ignore
let fortran_free_source=1
runtime! syntax/fortran.vim
unlet b:current_syntax
syn keyword takOptions  AUTODAMP CPRINT CSGDUMP GPRINT HPRINT LODTMP
syn keyword takOptions  LOGIC LPRINT NCVPRINT PLOTQ QPRINT QDUMP
syn keyword takOptions  SUMMARY SOLRTN UID DICTIONARIES
syn keyword takRoutine  SSITER FWDWRD FWDBCK BCKWRD
syn keyword takControl  ABSZRO BACKUP DAMP DTIMEI DTIMEL DTIMEH IFC
syn keyword takControl  MAXTEMP NLOOPS NLOOPT NODELIST OUTPUT PLOT
syn keyword takControl  SCALE SIGMA SSCRIT TIMEND TIMEN TIMEO TRCRIT
syn keyword takControl  PLOT
syn keyword takSolids   PLATE CYL
syn keyword takSolidsArg   ID MATNAM NTYPE TEMP XL YL ZL ISTRN ISTRG NNX
syn keyword takSolidsArg   NNY NNZ INCX INCY INCZ IAK IAC DIFF ARITH BOUN
syn keyword takSolidsArg   RMIN RMAX AXMAX NNR NNTHETA INCR INCTHETA END
syn case ignore
syn keyword takMacro    fac pstart pstop
syn keyword takMacro    takcommon fstart fstop
syn keyword takIdentifier  flq flx gen ncv per sim siv stf stv tvd tvs
syn keyword takIdentifier  tvt pro thm
syn match  takFortran     "^F[0-9 ]"me=e-1
syn match  takMotran      "^M[0-9 ]"me=e-1
syn match  takComment     "^C.*$"
syn match  takComment     "^R.*$"
syn match  takComment     "\$.*$"
syn match  takHeader      "^header[^,]*"
syn match  takIncludeFile "include \+[^ ]\+"hs=s+8 contains=fortranInclude
syn match  takInteger     "-\=\<[0-9]*\>"
syn match  takFloat       "-\=\<[0-9]*\.[0-9]*"
syn match  takScientific  "-\=\<[0-9]*\.[0-9]*E[-+]\=[0-9]\+\>"
syn match  takEndData     "END OF DATA"
if exists("thermal_todo")
execute 'syn match  takTodo ' . '"^'.thermal_todo.'.*$"'
else
syn match  takTodo	    "^?.*$"
endif
hi def link takMacro		Macro
hi def link takOptions		Special
hi def link takRoutine		Type
hi def link takControl		Special
hi def link takSolids		Special
hi def link takSolidsArg		Statement
hi def link takIdentifier		Identifier
hi def link takFortran		PreProc
hi def link takMotran		PreProc
hi def link takComment		Comment
hi def link takHeader		Typedef
hi def link takIncludeFile		Type
hi def link takInteger		Number
hi def link takFloat		Float
hi def link takScientific		Float
hi def link takEndData		Macro
hi def link takTodo		Todo
let b:current_syntax = "tak"
