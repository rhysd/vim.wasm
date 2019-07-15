if exists("b:current_syntax")
finish
endif
runtime! syntax/cupl.vim
unlet b:current_syntax
syn clear cuplStatement
syn clear cuplFunction
syn clear cuplLogicalOperator
syn clear cuplArithmeticOperator
syn clear cuplAssignmentOperator
syn clear cuplEqualityOperator
syn clear cuplTruthTableOperator
syn clear cuplExtension
syn match  cuplsimOrder "order:" nextgroup=cuplsimOrderSpec skipempty
syn region cuplsimOrderSpec start="." end=";"me=e-1 contains=cuplComment,cuplsimOrderFormat,cuplBitVector,cuplSpecialChar,cuplLogicalOperator,cuplCommaOperator contained
syn match   cuplsimBase "base:" nextgroup=cuplsimBaseSpec skipempty
syn region  cuplsimBaseSpec start="." end=";"me=e-1 contains=cuplComment,cuplsimBaseType contained
syn keyword cuplsimBaseType octal decimal hex contained
syn match cuplsimVectors "vectors:"
syn match cuplsimOrderFormat "%\d\+\>" contained
syn match cuplsimStimulus "[10ckpx]\+"
syn match cuplsimStimulus +'\(\x\|x\)\+'+
syn match cuplsimOutput "[lhznx*]\+"
syn match cuplsimOutput +"\x\+"+
syn sync minlines=1
hi def link cuplsimOrder		cuplStatement
hi def link cuplsimBase		cuplStatement
hi def link cuplsimBaseType	cuplStatement
hi def link cuplsimVectors		cuplStatement
hi def link cuplsimStimulus	cuplNumber
hi def link cuplsimOutput		cuplNumber
hi def link cuplsimOrderFormat	cuplNumber
let b:current_syntax = "cuplsim"
