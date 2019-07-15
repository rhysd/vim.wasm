if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword jovialTodo TODO FIXME XXX contained
syn match jovialBitConstant "[1-5]B'[0-9A-V]'"
syn match jovialNumber "\<\d\+\>"
syn match jovialFloat "\d\+E[-+]\=\d\+"
syn match jovialFloat "\d\+\.\d*\(E[-+]\=\d\+\)\="
syn match jovialFloat "\.\d\+\(E[-+]\=\d\+\)\="
syn region jovialComment start=/"/ end=/"/ contains=jovialTodo
syn region jovialComment start=/%/ end=/%/ contains=jovialTodo
syn match jovialIdentifier "[A-Z\$][A-Z0-9'\$]\+"
syn region jovialString start="\s*'" skip=/''/ end=/'/ oneline
syn region jovialPreProc start="\s*![A-Z]\+" end=/;/
syn keyword jovialOperator AND OR NOT XOR EQV MOD
syn keyword jovialType ITEM B C P V
syn match jovialType "\<S\(,R\|,T\|,Z\)\=\>"
syn match jovialType "\<U\(,R\|,T\|,Z\)\=\>"
syn match jovialType "\<F\(,R\|,T\|,Z\)\=\>"
syn match jovialType "\<A\(,R\|,T\|,Z\)\=\>"
syn keyword jovialStorageClass STATIC CONSTANT PARALLEL BLOCK N M D W
syn keyword jovialStructure TABLE STATUS
syn keyword jovialConstant NULL
syn keyword jovialBoolean FALSE TRUE
syn keyword jovialTypedef TYPE
syn keyword jovialStatement ABORT BEGIN BY BYREF BYRES BYVAL CASE COMPOOL
syn keyword jovialStatement DEF DEFAULT DEFINE ELSE END EXIT FALLTHRU FOR
syn keyword jovialStatement GOTO IF INLINE INSTANCE LABEL LIKE OVERLAY POS
syn keyword jovialStatement PROC PROGRAM REC REF RENT REP RETURN START STOP
syn keyword jovialStatement TERM THEN WHILE
syn keyword jovialStatement CONDITION ENCAPSULATION EXPORTS FREE HANDLER IN INTERRUPT NEW
syn keyword jovialStatement PROTECTED READONLY REGISTER SIGNAL TO UPDATE WITH WRITEONLY ZONE
syn keyword jovialConstant BITSINBYTE BITSINWORD LOCSINWORD
syn keyword jovialConstant BYTESINWORD BITSINPOINTER INTPRECISION
syn keyword jovialConstant FLOATPRECISION FIXEDPRECISION FLOATRADIX
syn keyword jovialConstant MAXFLOATPRECISION MAXFIXEDPRECISION
syn keyword jovialConstant MAXINTSIZE MAXBYTES MAXBITS
syn keyword jovialConstant MAXTABLESIZE MAXSTOP MINSTOP MAXSIGDIGITS
syn keyword jovialFunction BYTEPOS MAXINT MININT
syn keyword jovialFunction IMPLFLOATPRECISION IMPLFIXEDPRECISION IMPLINTSIZE
syn keyword jovialFunction MINSIZE MINFRACTION MINSCALE MINRELPRECISION
syn keyword jovialFunction MAXFLOAT MINFLOAT FLOATRELPRECISION
syn keyword jovialFunction FLOATUNDERFLOW MAXFIXED MINFIXED
syn keyword jovialFunction LOC NEXT BIT BYTE SHIFTL SHIFTR ABS SGN BITSIZE
syn keyword jovialFunction BYTESIZE WORDSIZE LBOUND UBOUND NWDSEN FIRST
syn keyword jovialFunction LAST NENT
hi def link jovialBitConstant Number
hi def link jovialBoolean Boolean
hi def link jovialComment Comment
hi def link jovialConstant Constant
hi def link jovialFloat Float
hi def link jovialFunction Function
hi def link jovialNumber Number
hi def link jovialOperator Operator
hi def link jovialPreProc PreProc
hi def link jovialStatement Statement
hi def link jovialStorageClass StorageClass
hi def link jovialString String
hi def link jovialStructure Structure
hi def link jovialTodo Todo
hi def link jovialType Type
hi def link jovialTypedef Typedef
let b:current_syntax = "jovial"
