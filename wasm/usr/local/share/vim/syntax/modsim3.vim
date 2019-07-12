if exists("b:current_syntax")
finish
endif
syn keyword modsim3Keyword ACTID ALL AND AS ASK
syn keyword modsim3Keyword BY CALL CASE CLASS CONST DIV
syn keyword modsim3Keyword DOWNTO DURATION ELSE ELSIF EXIT FALSE FIXED FOR
syn keyword modsim3Keyword FOREACH FORWARD IF IN INHERITED INOUT
syn keyword modsim3Keyword INTERRUPT LOOP
syn keyword modsim3Keyword MOD MONITOR NEWVALUE
syn keyword modsim3Keyword NONMODSIM NOT OBJECT OF ON OR ORIGINAL OTHERWISE OUT
syn keyword modsim3Keyword OVERRIDE PRIVATE PROTO REPEAT
syn keyword modsim3Keyword RETURN REVERSED SELF STRERR TELL
syn keyword modsim3Keyword TERMINATE THISMETHOD TO TRUE TYPE UNTIL VALUE VAR
syn keyword modsim3Keyword WAIT WAITFOR WHEN WHILE WITH
syn keyword modsim3Builtin ABS ACTIVATE ADDMONITOR CAP CHARTOSTR CHR CLONE
syn keyword modsim3Builtin DEACTIVATE DEC DISPOSE FLOAT GETMONITOR HIGH INC
syn keyword modsim3Builtin INPUT INSERT INTTOSTR ISANCESTOR LOW LOWER MAX MAXOF
syn keyword modsim3Builtin MIN MINOF NEW OBJTYPEID OBJTYPENAME OBJVARID ODD
syn keyword modsim3Builtin ONERROR ONEXIT ORD OUTPUT POSITION PRINT REALTOSTR
syn keyword modsim3Builtin REPLACE REMOVEMONITOR ROUND SCHAR SIZEOF SPRINT
syn keyword modsim3Builtin STRLEN STRTOCHAR STRTOINT STRTOREAL SUBSTR TRUNC
syn keyword modsim3Builtin UPDATEVALUE UPPER VAL
syn keyword modsim3BuiltinNoParen HALT TRACE
syn keyword modsim3Block PROCEDURE METHOD MODULE MAIN DEFINITION IMPLEMENTATION
syn keyword modsim3Block BEGIN END
syn keyword modsim3Include IMPORT FROM
syn keyword modsim3Type ANYARRAY ANYOBJ ANYREC ARRAY BOOLEAN CHAR INTEGER
syn keyword modsim3Type LMONITORED LRMONITORED NILARRAY NILOBJ NILREC REAL
syn keyword modsim3Type RECORD RMONITOR RMONITORED STRING
syn region modsim3Paren	transparent start='(' end=')' contains=ALLBUT,modsim3ParenError
syn match modsim3ParenError ")"
syn region modsim3Comment1 start="{" end="}" contains=modsim3Comment1,modsim3Comment2
syn region modsim3Comment2 start="(\*" end="\*)" contains=modsim3Comment1,modsim3Comment2
syn region modsim3String start=+"+ end=+"+
syn match modsim3Literal "'[^']'\|''''"
hi def link modsim3Keyword	Statement
hi def link modsim3Block		Statement
hi def link modsim3Comment1	Comment
hi def link modsim3Comment2	Comment
hi def link modsim3String		String
hi def link modsim3Literal	Character
hi def link modsim3Include	Statement
hi def link modsim3Type		Type
hi def link modsim3ParenError	Error
hi def link modsim3Builtin	Function
hi def link modsim3BuiltinNoParen	Function
let b:current_syntax = "modsim3"
