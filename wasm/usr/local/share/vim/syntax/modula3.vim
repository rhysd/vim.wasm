if exists("b:current_syntax")
finish
endif
syn keyword modula3Keyword ABS ADDRES ADR ADRSIZE AND ANY
syn keyword modula3Keyword ARRAY AS BITS BITSIZE BOOLEAN BRANDED BY BYTESIZE
syn keyword modula3Keyword CARDINAL CASE CEILING CHAR CONST DEC DEFINITION
syn keyword modula3Keyword DISPOSE DIV
syn keyword modula3Keyword EVAL EXIT EXCEPT EXCEPTION
syn keyword modula3Keyword EXIT EXPORTS EXTENDED FALSE FINALLY FIRST FLOAT
syn keyword modula3Keyword FLOOR FROM GENERIC IMPORT
syn keyword modula3Keyword IN INC INTEGER ISTYPE LAST LOCK
syn keyword modula3Keyword LONGREAL LOOPHOLE MAX METHOD MIN MOD MUTEX
syn keyword modula3Keyword NARROW NEW NIL NOT NULL NUMBER OF OR ORD RAISE
syn keyword modula3Keyword RAISES READONLY REAL RECORD REF REFANY
syn keyword modula3Keyword RETURN ROOT
syn keyword modula3Keyword ROUND SET SUBARRAY TEXT TRUE TRUNC TRY TYPE
syn keyword modula3Keyword TYPECASE TYPECODE UNSAFE UNTRACED VAL VALUE VAR WITH
syn keyword modula3Block PROCEDURE FUNCTION MODULE INTERFACE REPEAT THEN
syn keyword modula3Block BEGIN END OBJECT METHODS OVERRIDES RECORD REVEAL
syn keyword modula3Block WHILE UNTIL DO TO IF FOR ELSIF ELSE LOOP
syn region modula3Comment start="(\*" end="\*)"
syn region modula3String start=+"+ end=+"+
syn region modula3String start=+'+ end=+'+
hi def link modula3Keyword	Statement
hi def link modula3Block		PreProc
hi def link modula3Comment	Comment
hi def link modula3String		String
let b:current_syntax = "modula3"
