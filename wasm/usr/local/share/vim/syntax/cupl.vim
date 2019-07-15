if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn case ignore
syn keyword cuplHeader name partno date revision rev designer company nextgroup=cuplHeaderContents
syn keyword cuplHeader assembly assy location device nextgroup=cuplHeaderContents
syn keyword cuplTodo contained TODO XXX FIXME
syn match cuplHeaderContents ".\+;"me=e-1 contains=cuplNumber contained
syn region cuplString start=+'+ end=+'+
syn region cuplString start=+"+ end=+"+
syn keyword cuplStatement append condition
syn keyword cuplStatement default else
syn keyword cuplStatement field fld format function fuse
syn keyword cuplStatement group if jump loc
syn keyword cuplStatement macro min node out
syn keyword cuplStatement pin pinnode present table
syn keyword cuplStatement sequence sequenced sequencejk sequencers sequencet
syn keyword cuplFunction log2 log8 log16 log
syn match cuplNumber "\<[-+]\=[0-9]\+\>"
syn match cuplNumber "'d'[0-9]\+\>"
syn match cuplNumber "'b'[01x]\+\>"
syn match cuplNumber "'o'[0-7x]\+\>"
syn match cuplNumber "'h'[0-9a-fx]\+\>"
syn match cuplLogicalOperator "[!#&$]"
syn match cuplArithmeticOperator "[-+*/%]"
syn match cuplArithmeticOperator "\*\*"
syn match cuplAssignmentOperator ":\=="
syn match cuplEqualityOperator ":"
syn match cuplTruthTableOperator "=>"
syn match cuplExtension "\.[as][pr]\>"
syn match cuplExtension "\.oe\>"
syn match cuplExtension "\.oemux\>"
syn match cuplExtension "\.[dlsrjk]\>"
syn match cuplExtension "\.ck\>"
syn match cuplExtension "\.dq\>"
syn match cuplExtension "\.ckmux\>"
syn match cuplExtension "\.tec\>"
syn match cuplExtension "\.cnt\>"
syn match cuplRangeOperator "\.\." contained
syn match cuplNumberRange "\<\x\+\.\.\x\+\>" contains=cuplRangeOperator
syn match cuplBitVector "\<\a\+\d\+\.\.\d\+\>" contains=cuplRangeOperator
syn match cuplSpecialChar "[\[\](){},;]"
syn match cuplDirective "\$msg"
syn match cuplDirective "\$macro"
syn match cuplDirective "\$mend"
syn match cuplDirective "\$repeat"
syn match cuplDirective "\$repend"
syn match cuplDirective "\$define"
syn match cuplDirective "\$include"
syn region cuplComment start=+/\*+ end=+\*/+ contains=cuplNumber,cuplTodo
syn sync minlines=1
hi def link cuplHeader	cuplStatement
hi def link cuplLogicalOperator	 cuplOperator
hi def link cuplRangeOperator	 cuplOperator
hi def link cuplArithmeticOperator cuplOperator
hi def link cuplAssignmentOperator cuplOperator
hi def link cuplEqualityOperator	 cuplOperator
hi def link cuplTruthTableOperator cuplOperator
hi def link cuplOperator	cuplStatement
hi def link cuplFunction	cuplStatement
hi def link cuplStatement Statement
hi def link cuplNumberRange cuplNumber
hi def link cuplNumber	  cuplString
hi def link cuplString	String
hi def link cuplComment	Comment
hi def link cuplExtension   cuplSpecial
hi def link cuplSpecialChar cuplSpecial
hi def link cuplSpecial	Special
hi def link cuplDirective PreProc
hi def link cuplTodo	Todo
let b:current_syntax = "cupl"
let &cpo = s:cpo_save
unlet s:cpo_save
