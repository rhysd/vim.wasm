if exists("b:current_syntax")
finish
endif
syn region modula2Header matchgroup=modula2Header start="PROCEDURE " end="(" contains=modula2Ident oneline
syn region modula2Header matchgroup=modula2Header start="MODULE " end=";" contains=modula2Ident oneline
syn region modula2Header matchgroup=modula2Header start="BEGIN (\*" end="\*)" contains=modula2Ident oneline
syn region modula2Header matchgroup=modula2Header start="END " end=";" contains=modula2Ident oneline
syn region modula2Keyword start="END" end=";" contains=ALLBUT,modula2Ident oneline
syn keyword modula2AttKeyword CONST EXIT HALT RETURN TYPE VAR
syn keyword modula2Keyword AND ARRAY BY CASE DEFINITION DIV DO ELSE
syn keyword modula2Keyword ELSIF EXPORT FOR FROM IF IMPLEMENTATION IMPORT
syn keyword modula2Keyword IN LOOP MOD NOT OF OR POINTER QUALIFIED RECORD
syn keyword modula2Keyword SET THEN TO UNTIL WHILE WITH
syn keyword modula2Type ADDRESS BITSET BOOLEAN CARDINAL CHAR INTEGER REAL WORD
syn keyword modula2StdFunc ABS CAP CHR DEC EXCL INC INCL ORD SIZE TSIZE VAL
syn keyword modula2StdConst FALSE NIL TRUE
syn keyword modula2StdFunc NEW DISPOSE
syn keyword modula2Type BYTE LONGCARD LONGINT LONGREAL PROC SHORTCARD SHORTINT
syn keyword modula2StdFunc MAX MIN
syn match   modula2Ident " [A-Z,a-z][A-Z,a-z,0-9,_]*" contained
syn region modula2Comment start="(\*" end="\*)" contains=modula2Comment,modula2Todo
syn keyword modula2Todo	contained TODO FIXME XXX
syn region modula2String start=+"+ end=+"+
syn region modula2String start="'" end="'"
syn region modula2Set start="{" end="}"
hi def link modula2Ident		Identifier
hi def link modula2StdConst	Boolean
hi def link modula2Type		Identifier
hi def link modula2StdFunc		Identifier
hi def link modula2Header		Type
hi def link modula2Keyword		Statement
hi def link modula2AttKeyword	PreProc
hi def link modula2Comment		Comment
hi def link modula2Todo		Todo
hi def link modula2String		String
hi def link modula2Set		String
let b:current_syntax = "modula2"
