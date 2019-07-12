if exists("b:current_syntax")
finish
endif
syn keyword vsejclKeyword DLBL EXEC JOB ASSGN EOJ
syn keyword vsejclField JNM CLASS DISP USER SYSID JSEP SIZE
syn keyword vsejclField VSAM
syn region vsejclComment start="^/\*" end="$"
syn region vsejclComment start="^[\* ]\{}$" end="$"
syn region vsejclMisc start="^  " end="$" contains=Jparms
syn match vsejclString /'.\{-}'/
syn match vsejclParms /(.\{-})/ contained
hi def link vsejclComment		Comment
hi def link vsejclField		Type
hi def link vsejclKeyword		Statement
hi def link vsejclObject		Constant
hi def link vsejclString		Constant
hi def link vsejclMisc			Special
hi def link vsejclParms		Constant
let b:current_syntax = "vsejcl"
