if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn case ignore
syn keyword abelHeader		module title device options
syn keyword abelSection		declarations equations test_vectors end
syn keyword abelDeclaration	state truth_table state_diagram property
syn keyword abelType		pin node attribute constant macro library
syn keyword abelTypeId		com reg neg pos buffer dc reg_d reg_t contained
syn keyword abelTypeId		reg_sr reg_jk reg_g retain xor invert contained
syn keyword abelStatement	when then else if with endwith case endcase
syn keyword abelStatement	fuses expr trace
if exists("abel_obsolete_ok")
syn keyword abelStatement enable flag in
else
syn keyword abelError enable flag in
endif
syn match abelDirective "@alternate"
syn match abelDirective "@standard"
syn match abelDirective "@const"
syn match abelDirective "@dcset"
syn match abelDirective "@include"
syn match abelDirective "@page"
syn match abelDirective "@radix"
syn match abelDirective "@repeat"
syn match abelDirective "@irp"
syn match abelDirective "@expr"
syn match abelDirective "@if"
syn match abelDirective "@ifb"
syn match abelDirective "@ifnb"
syn match abelDirective "@ifdef"
syn match abelDirective "@ifndef"
syn match abelDirective "@ifiden"
syn match abelDirective "@ifniden"
syn keyword abelTodo contained TODO XXX FIXME
syn region abelSpecifier start='istype' end=';' contains=abelTypeIdChar,abelTypeId,abelTypeIdEnd keepend
syn match  abelTypeIdChar "[,']" contained
syn match  abelTypeIdEnd  ";" contained
syn match  abelSpecial contained "\\['\\]"
syn region abelString start=+'+ skip=+\\"+ end=+'+ contains=abelSpecial
syn match abelNumber "\<[-+]\=[0-9]\+\>"
syn match abelNumber "\^d[0-9]\+\>"
syn match abelNumber "\^b[01]\+\>"
syn match abelNumber "\^o[0-7]\+\>"
syn match abelNumber "\^h[0-9a-f]\+\>"
syn match abelSpecialChar "[\[\](){},;:?]"
syn match abelLogicalOperator "[!#&$]"
syn match abelRangeOperator "\.\."
syn match abelAlternateOperator "[/*+]"
syn match abelAlternateOperator ":[+*]:"
syn match abelArithmeticOperator "[-%]"
syn match abelArithmeticOperator "<<"
syn match abelArithmeticOperator ">>"
syn match abelRelationalOperator "[<>!=]="
syn match abelRelationalOperator "[<>]"
syn match abelAssignmentOperator "[:?]\=="
syn match abelAssignmentOperator "?:="
syn match abelTruthTableOperator "->"
syn match abelExtension "\.aclr\>"
syn match abelExtension "\.aset\>"
syn match abelExtension "\.clk\>"
syn match abelExtension "\.clr\>"
syn match abelExtension "\.com\>"
syn match abelExtension "\.fb\>"
syn match abelExtension "\.[co]e\>"
syn match abelExtension "\.l[eh]\>"
syn match abelExtension "\.fc\>"
syn match abelExtension "\.pin\>"
syn match abelExtension "\.set\>"
syn match abelExtension "\.[djksrtq]\>"
syn match abelExtension "\.pr\>"
syn match abelExtension "\.re\>"
syn match abelExtension "\.a[pr]\>"
syn match abelExtension "\.s[pr]\>"
syn match abelConstant "\.[ckudfpxz]\."
syn match abelConstant "\.sv[2-9]\."
syn region abelComment start=+"+ end=+"\|$+ contains=abelNumber,abelTodo
if !exists("abel_cpp_comments_illegal")
syn region abelComment start=+//+ end=+$+ contains=abelNumber,abelTodo
endif
syn sync minlines=1
hi def link abelHeader		abelStatement
hi def link abelSection		abelStatement
hi def link abelDeclaration	abelStatement
hi def link abelLogicalOperator	abelOperator
hi def link abelRangeOperator	abelOperator
hi def link abelAlternateOperator	abelOperator
hi def link abelArithmeticOperator	abelOperator
hi def link abelRelationalOperator	abelOperator
hi def link abelAssignmentOperator	abelOperator
hi def link abelTruthTableOperator	abelOperator
hi def link abelSpecifier		abelStatement
hi def link abelOperator		abelStatement
hi def link abelStatement		Statement
hi def link abelIdentifier		Identifier
hi def link abelTypeId		abelType
hi def link abelTypeIdChar		abelType
hi def link abelType		Type
hi def link abelNumber		abelString
hi def link abelString		String
hi def link abelConstant		Constant
hi def link abelComment		Comment
hi def link abelExtension		abelSpecial
hi def link abelSpecialChar	abelSpecial
hi def link abelTypeIdEnd		abelSpecial
hi def link abelSpecial		Special
hi def link abelDirective		PreProc
hi def link abelTodo		Todo
hi def link abelError		Error
let b:current_syntax = "abel"
let &cpo = s:cpo_save
unlet s:cpo_save
