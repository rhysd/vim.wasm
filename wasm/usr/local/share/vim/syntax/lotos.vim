if exists("b:current_syntax")
finish
endif
syn case ignore
syn region lotosComment	start="(\*"  end="\*)" contains=lotosTodo
syn match  lotosDelimiter       "[][]"
syn match  lotosDelimiter	">>"
syn match  lotosDelimiter	"->"
syn match  lotosDelimiter	"\[>"
syn match  lotosDelimiter	"[|;!?:=,]"
syn keyword lotosStatement	specification endspec process endproc
syn keyword lotosStatement	where behaviour behavior
syn keyword lotosStatement      any let par accept choice hide of in
syn keyword lotosStatement	i stop exit noexit
syn keyword lotosOperator	eq ne succ and or xor implies iff
syn keyword lotosOperator	not true false
syn keyword lotosOperator	Insert Remove IsIn NotIn Union Ints
syn keyword lotosOperator	Minus Includes IsSubsetOf
syn keyword lotosOperator	lt le ge gt 0
syn keyword lotosSort		Boolean Bool FBoolean FBool Element
syn keyword lotosSort		Set String NaturalNumber Nat HexString
syn keyword lotosSort		HexDigit DecString DecDigit
syn keyword lotosSort		OctString OctDigit BitString Bit
syn keyword lotosSort		Octet OctetString
syn keyword lotosType	type endtype library endlib sorts formalsorts
syn keyword lotosType	eqns formaleqns opns formalopns forall ofsort is
syn keyword lotosType   for renamedby actualizedby sortnames opnnames
syn keyword lotosType   using
syn sync lines=250
hi def link lotosStatement		Statement
hi def link lotosProcess		Label
hi def link lotosOperator		Operator
hi def link lotosSort		Function
hi def link lotosType		Type
hi def link lotosComment		Comment
hi def link lotosDelimiter		String
let b:current_syntax = "lotos"
