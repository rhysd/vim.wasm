if exists("b:current_syntax")
finish
endif
syn case match
syn sync minlines=100
syn region xkbComment start="//" skip="\\$" end="$" keepend contains=xkbTodo
syn region xkbComment start="/\*" matchgroup=NONE end="\*/" contains=xkbCommentStartError,xkbTodo
syn match xkbCommentError "\*/"
syntax match xkbCommentStartError "/\*" contained
syn sync ccomment xkbComment
syn keyword xkbTodo TODO FIXME contained
syn match xkbSpecialChar "\\\d\d\d\|\\." contained
syn region xkbString start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=xkbSpecialChar oneline
syn region xkbParen start='(' end=')' contains=ALLBUT,xkbParenError,xkbSpecial,xkbTodo transparent
syn match xkbParenError ")"
syn region xkbBrace start='{' end='}' contains=ALLBUT,xkbBraceError,xkbSpecial,xkbTodo transparent
syn match xkbBraceError "}"
syn region xkbBracket start='\[' end='\]' contains=ALLBUT,xkbBracketError,xkbSpecial,xkbTodo transparent
syn match xkbBracketError "\]"
syn match xkbPhysicalKey "<\w\+>"
syn keyword xkbPreproc augment include replace
syn keyword xkbConstant False True
syn keyword xkbModif override replace
syn keyword xkbIdentifier action affect alias allowExplicit approx baseColor button clearLocks color controls cornerRadius count ctrls description driveskbd font fontSize gap group groups height indicator indicatorDrivesKeyboard interpret key keys labelColor latchToLock latchMods left level_name map maximum minimum modifier_map modifiers name offColor onColor outline preserve priority repeat row section section setMods shape slant solid symbols text top type useModMapMods virtualModifier virtualMods virtual_modifiers weight whichModState width
syn keyword xkbFunction AnyOf ISOLock LatchGroup LatchMods LockControls LockGroup LockMods LockPointerButton MovePtr NoAction PointerButton SetControls SetGroup SetMods SetPtrDflt Terminate
syn keyword xkbTModif default hidden partial virtual
syn keyword xkbSect alphanumeric_keys alternate_group function_keys keypad_keys modifier_keys xkb_compatibility xkb_geometry xkb_keycodes xkb_keymap xkb_semantics xkb_symbols xkb_types
hi def link xkbModif xkbPreproc
hi def link xkbTModif xkbPreproc
hi def link xkbPreproc Preproc
hi def link xkbIdentifier Keyword
hi def link xkbFunction Function
hi def link xkbSect Type
hi def link xkbPhysicalKey Identifier
hi def link xkbKeyword Keyword
hi def link xkbComment Comment
hi def link xkbTodo Todo
hi def link xkbConstant Constant
hi def link xkbString String
hi def link xkbSpecialChar xkbSpecial
hi def link xkbSpecial Special
hi def link xkbParenError xkbBalancingError
hi def link xkbBraceError xkbBalancingError
hi def link xkbBraketError xkbBalancingError
hi def link xkbBalancingError xkbError
hi def link xkbCommentStartError xkbCommentError
hi def link xkbCommentError xkbError
hi def link xkbError Error
let b:current_syntax = "xkb"
