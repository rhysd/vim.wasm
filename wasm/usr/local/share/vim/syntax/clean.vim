if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn keyword cleanConditional if case
syn keyword cleanLabel let! with where in of
syn keyword cleanSpecial Start
syn keyword cleanKeyword infixl infixr infix
syn keyword cleanBasicType Int Real Char Bool String
syn keyword cleanSpecialType World ProcId Void Files File
syn keyword cleanModuleSystem module implementation definition system
syn keyword cleanTypeClass class instance export
syn region cleanIncludeRegion start="^\s*\(from\|import\|\s\+\(as\|qualified\)\)" end="\n" contains=cleanIncludeKeyword keepend
syn keyword cleanIncludeKeyword contained from import as qualified
syn keyword cleanBoolDenot True False
syn region cleanStringDenot start=+"+ skip=+\(\(\\\\\)\+\|\\"\)+ end=+"+ display
syn match cleanCharDenot "'\(\\\\\|\\'\|[^'\\]\)\+'" display
syn match cleanIntegerDenot "[\~+-]\?\<\(\d\+\|0[0-7]\+\|0x[0-9A-Fa-f]\+\)\>" display
syn match cleanRealDenot "[\~+-]\?\d\+\.\d\+\(E[\~+-]\?\d\+\)\?" display
syn region cleanList start="\[" end="\]" contains=ALL
syn region cleanRecord start="{" end="}" contains=ALL
syn region cleanArray start="{:" end=":}" contains=ALL
syn match cleanTuple "([^=]*,[^=]*)" contains=ALL
syn region cleanComment start="/\*"  end="\*/" contains=cleanComment,cleanTodo fold
syn region cleanComment start="//.*" end="$" display contains=cleanTodo
syn keyword cleanTodo TODO FIXME XXX contained
syn match cleanFuncTypeDef "\([a-zA-Z].*\|(\=[-~@#$%^?!+*<>\/|&=:]\+)\=\)\s*\(infix[lr]\=\)\=\s*\d\=\s*::.*->.*" contains=cleanSpecial,cleanBasicType,cleanSpecialType,cleanKeyword
hi def link cleanComment      Comment
hi def link cleanStringDenot  String
hi def link cleanCharDenot    Character
hi def link cleanIntegerDenot Number
hi def link cleanBoolDenot    Boolean
hi def link cleanRealDenot    Float
hi def link cleanTypeClass    Keyword
hi def link cleanConditional  Conditional
hi def link cleanLabel		Label
hi def link cleanKeyword      Keyword
hi def link cleanIncludeKeyword      Include
hi def link cleanModuleSystem PreProc
hi def link cleanBasicType    Type
hi def link cleanSpecialType  Type
hi def link cleanFuncTypeDef  Typedef
hi def link cleanSpecial      Special
hi def link cleanList			Special
hi def link cleanArray		Special
hi def link cleanRecord		Special
hi def link cleanTuple		Special
hi def link cleanTodo         Todo
let b:current_syntax = "clean"
let &cpo = s:cpo_save
unlet s:cpo_save
