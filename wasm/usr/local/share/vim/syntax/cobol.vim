if exists("b:current_syntax")
finish
endif
setlocal isk=@,48-57,-,_
if !exists('g:cobol_inline_comment')
let g:cobol_inline_comment=0
endif
syn case ignore
syn cluster cobolStart      contains=cobolAreaA,cobolAreaB,cobolComment,cobolCompiler
syn cluster cobolAreaA      contains=cobolParagraph,cobolSection,cobolDivision
syn cluster cobolAreaAB     contains=cobolLine
syn cluster cobolLine       contains=cobolReserved
syn match   cobolMarker     "^\%( \{,5\}[^ ]\)\@=.\{,6}" nextgroup=@cobolStart
syn match   cobolSpace      "^ \{6\}"  nextgroup=@cobolStart
syn match   cobolAreaA      " \{1,4\}"  contained nextgroup=@cobolAreaA,@cobolAreaAB
syn match   cobolAreaB      " \{5,\}\|- *" contained nextgroup=@cobolAreaB,@cobolAreaAB
syn match   cobolComment    "[/*C].*$" contained
syn match   cobolCompiler   "$.*$"     contained
syn match   cobolLine       ".*$"      contained contains=cobolReserved,@cobolLine
syn match   cobolDivision       "[A-Z][A-Z0-9-]*[A-Z0-9]\s\+DIVISION" contained contains=cobolDivisionName
syn keyword cobolDivisionName   contained IDENTIFICATION ENVIRONMENT DATA PROCEDURE
syn match   cobolSection        "[A-Z][A-Z0-9-]*[A-Z0-9]\s\+SECTION\."he=e-1  contained contains=cobolSectionName
syn keyword cobolSectionName    contained CONFIGURATION INPUT-OUTPUT FILE WORKING-STORAGE LOCAL-STORAGE LINKAGE
syn match   cobolParagraph      "\a[A-Z0-9-]*[A-Z0-9]\.\|\d[A-Z0-9-]*[A-Z]\."he=e-1             contained contains=cobolParagraphName
syn keyword cobolParagraphName  contained PROGRAM-ID SOURCE-COMPUTER OBJECT-COMPUTER SPECIAL-NAMES FILE-CONTROL I-O-CONTROL
syn keyword cobolReserved contained ACCEPT ACCESS ADD ADDRESS ADVANCING AFTER ALPHABET ALPHABETIC
syn keyword cobolReserved contained ALPHABETIC-LOWER ALPHABETIC-UPPER ALPHANUMERIC ALPHANUMERIC-EDITED ALS
syn keyword cobolReserved contained ALTERNATE AND ANY ARE AREA AREAS ASCENDING ASSIGN AT AUTHOR BEFORE BINARY
syn keyword cobolReserved contained BLANK BLOCK BOTTOM CANCEL CBLL CD CF CH CHARACTER CHARACTERS CLASS
syn keyword cobolReserved contained CLOCK-UNITS CLOSE COBOL CODE CODE-SET COLLATING COLUMN COMMA COMMON
syn keyword cobolReserved contained COMMUNICATIONS COMPUTATIONAL COMPUTE CONTENT CONTINUE
syn keyword cobolReserved contained CONTROL CONVERTING CORR CORRESPONDING COUNT CURRENCY DATE DATE-COMPILED
syn keyword cobolReserved contained DATE-WRITTEN DAY DAY-OF-WEEK DE DEBUG-CONTENTS DEBUG-ITEM DEBUG-LINE
syn keyword cobolReserved contained DEBUG-NAME DEBUG-SUB-1 DEBUG-SUB-2 DEBUG-SUB-3 DEBUGGING DECIMAL-POINT
syn keyword cobolReserved contained DELARATIVES DELETE DELIMITED DELIMITER DEPENDING DESCENDING DESTINATION
syn keyword cobolReserved contained DETAIL DISABLE DISPLAY DIVIDE DIVISION DOWN DUPLICATES DYNAMIC EGI ELSE EMI
syn keyword cobolReserved contained ENABLE END-ADD END-COMPUTE END-DELETE END-DIVIDE END-EVALUATE END-IF
syn keyword cobolReserved contained END-MULTIPLY END-OF-PAGE END-READ END-RECEIVE END-RETURN
syn keyword cobolReserved contained END-REWRITE END-SEARCH END-START END-STRING END-SUBTRACT END-UNSTRING
syn keyword cobolReserved contained END-WRITE EQUAL ERROR ESI EVALUATE EVERY EXCEPTION EXIT
syn keyword cobolReserved contained EXTEND EXTERNAL FALSE FD FILLER FINAL FIRST FOOTING FOR FROM
syn keyword cobolReserved contained GENERATE GIVING GLOBAL GREATER GROUP HEADING HIGH-VALUE HIGH-VALUES I-O
syn keyword cobolReserved contained INDEX INDEXED INDICATE INITIAL INITIALIZE
syn keyword cobolReserved contained INITIATE INPUT INSPECT INSTALLATION INTO IS JUST
syn keyword cobolReserved contained JUSTIFIED KEY LABEL LAST LEADING LEFT LENGTH LOCK MEMORY
syn keyword cobolReserved contained MERGE MESSAGE MODE MODULES MOVE MULTIPLE MULTIPLY NATIVE NEGATIVE NEXT NO NOT
syn keyword cobolReserved contained NUMBER NUMERIC NUMERIC-EDITED OCCURS OF OFF OMITTED ON OPEN
syn keyword cobolReserved contained OPTIONAL OR ORDER ORGANIZATION OTHER OUTPUT OVERFLOW PACKED-DECIMAL PADDING
syn keyword cobolReserved contained PAGE PAGE-COUNTER PERFORM PF PH PIC PICTURE PLUS POINTER POSITION POSITIVE
syn keyword cobolReserved contained PRINTING PROCEDURES PROCEDD PURGE QUEUE QUOTES
syn keyword cobolReserved contained RANDOM RD READ RECEIVE RECORD RECORDS REDEFINES REEL REFERENCE REFERENCES
syn keyword cobolReserved contained RELATIVE RELEASE REMAINDER REMOVAL REPLACE REPORT REPORTING
syn keyword cobolReserved contained REPORTS RERUN RESERVE RESET RETURN RETURNING REVERSED REWIND REWRITE RF RH
syn keyword cobolReserved contained RIGHT ROUNDED RUN SAME SD SEARCH SECTION SECURITY SEGMENT SEGMENT-LIMITED
syn keyword cobolReserved contained SELECT SEND SENTENCE SEPARATE SEQUENCE SEQUENTIAL SET SIGN SIZE SORT
syn keyword cobolReserved contained SORT-MERGE SOURCE STANDARD
syn keyword cobolReserved contained STANDARD-1 STANDARD-2 START STATUS STOP STRING SUB-QUEUE-1 SUB-QUEUE-2
syn keyword cobolReserved contained SUB-QUEUE-3 SUBTRACT SUM SUPPRESS SYMBOLIC SYNC SYNCHRONIZED TABLE TALLYING
syn keyword cobolReserved contained TAPE TERMINAL TERMINATE TEST TEXT THAN THEN THROUGH THRU TIME TIMES TOP
syn keyword cobolReserved contained TRAILING TRUE TYPE UNIT UNSTRING UNTIL UP UPON USAGE USE USING VALUE VALUES
syn keyword cobolReserved contained VARYING WHEN WITH WORDS WRITE
syn match   cobolReserved contained "\<CONTAINS\>"
syn match   cobolReserved contained "\<\(IF\|INVALID\|END\|EOP\)\>"
syn match   cobolReserved contained "\<ALL\>"
syn match   cobolReserved contained "\<BY\>\s\+\(==\)\@!"
syn match   cobolReserved contained "\<TO\>"
syn cluster cobolLine     add=cobolConstant,cobolNumber,cobolPic
syn keyword cobolConstant SPACE SPACES NULL ZERO ZEROES ZEROS LOW-VALUE LOW-VALUES
syn match   cobolNumber       "\<-\=\d*\.\=\d\+\>" contained
syn match   cobolPic		"\<S*9\+V*9*\>" contained
syn match   cobolPic		"\<$*\.\=9\+\>" contained
syn match   cobolPic		"\<Z*\.\=9\+\>" contained
syn match   cobolPic		"\<V9\+\>" contained
syn match   cobolPic		"\<9\+V\>" contained
syn match   cobolPic		"\<-*[Z9]\+-*\>" contained
syn match   cobolPic		"\<[ZXA]\+\>" contained
syn match   cobolTodo		"todo" contained containedin=cobolInlineComment,cobolComment
if g:cobol_inline_comment == 1
syn region  cobolInlineComment     start="*>" end="$" contains=cobolTodo,cobolMarker
syn cluster cobolLine       add=cobolInlineComment
endif
syn match   cobolBadLine      "[^ D\*$/-].*" contained
if g:cobol_inline_comment == 1
syn match   cobolBadLine      "\s\+\*\(>\)\@!.*" contained
else
syn match   cobolBadLine      "\s\+\*.*" contained
endif
syn cluster cobolStart        add=cobolBadLine
syn keyword cobolGoTo		GOTO
syn match cobolGoTo		/\<GO\>\s\+\<TO\>/
syn match cobolGoToPara       /\<GO\>\s\+\<TO\>\s\+[A-Z0-9-]\+/ contains=cobolGoTo
syn match cobolCopy		"\<COPY\>\|\<IN\>"
syn match cobolCopy           "\<REPLACING\>\s\+\(==\)\@="
syn match cobolCopy           "\<BY\>\s\+\(==\)\@="
syn match cobolCopyName       "\<COPY\>\s\+[A-Z0-9]\+\(\s\+\<IN\>\s\+[A-Z0-9]\+\)\?" contains=cobolCopy
syn cluster cobolLine         add=cobolGoToPara,cobolCopyName
syn keyword cobolBAD		ALTER ENTER RENAMES
syn cluster cobolLine       add=cobolGoTo,cobolCopy,cobolBAD,cobolWatch,cobolEXECs
syn keyword cobolWatch		OCCURS DEPENDING VARYING BINARY COMP REDEFINES
syn keyword cobolWatch		RUN PROGRAM
syn match   cobolWatch contained "\<REPLACING\>\s\+\(==\)\@!"
syn match   cobolWatch		"\<COMP-[123456XN]"
syn keyword cobolEXECs		EXEC END-EXEC
syn cluster cobolAreaA      add=cobolDeclA
syn cluster cobolAreaAB     add=cobolDecl
syn match   cobolDeclA      "\(0\=1\|77\|78\) " contained nextgroup=cobolLine
syn match   cobolDecl		"[1-4]\d " contained nextgroup=cobolLine
syn match   cobolDecl		"0\=[2-9] " contained nextgroup=cobolLine
syn match   cobolDecl		"66 " contained nextgroup=cobolLine
syn match   cobolWatch		"88 " contained nextgroup=cobolLine
syn cluster cobolLine       add=cobolCALLs,cobolString,cobolCondFlow
syn keyword cobolCALLs		END-CALL CANCEL GOBACK PERFORM END-PERFORM INVOKE THRU
syn match   cobolCALLs		"\<CALL\>"
syn match   cobolCALLProg     /\<CALL\>\s\+"\{0,1\}[A-Z0-9]\+"\{0,1\}/ contains=cobolCALLs
syn match   cobolExtras       /\<VALUE \+\d\+\./hs=s+6,he=e-1
syn cluster cobolLine         add=cobolCALLProg
syn match   cobolString       /"[^"]*\("\|$\)/
syn match   cobolString       /'[^']*\('\|$\)/
syn match   cobolIndicator   "\%7c[D-]" contained
if exists("cobol_legacy_code")
syn region  cobolCondFlow     contains=ALLBUT,cobolLine start="\<\(IF\|INVALID\|END\|EOP\)\>" skip=/\('\|"\)[^"]\{-}\("\|'\|$\)/ end="\." keepend
endif
if exists("cobol_legacy_code")
syn match   cobolBadLine      "\%73c.*" containedin=ALLBUT,cobolComment
else
syn match   cobolBadLine      "\%73c.*" containedin=ALL,cobolInlineComment,cobolComment
endif
hi def link cobolBAD      Error
hi def link cobolBadID    Error
hi def link cobolBadLine  Error
if exists("g:cobol_legacy_code")
hi def link cobolMarker   Comment
else
hi def link cobolMarker   Error
endif
hi def link cobolCALLs          Function
hi def link cobolCALLProg       Special
hi def link cobolComment        Comment
hi def link cobolInlineComment  Comment  
hi def link cobolKeys           Comment
hi def link cobolAreaB          Special
hi def link cobolCompiler       PreProc
hi def link cobolCondFlow       Special
hi def link cobolCopy           PreProc
hi def link cobolCopyName       Special
hi def link cobolDeclA          cobolDecl
hi def link cobolDecl           Type
hi def link cobolExtras         Special
hi def link cobolGoTo           Special
hi def link cobolGoToPara       Function
hi def link cobolConstant       Constant
hi def link cobolNumber         Constant
hi def link cobolPic            Constant
hi def link cobolReserved       Statement
hi def link cobolDivision       Label
hi def link cobolSection        Label
hi def link cobolParagraph      Label
hi def link cobolDivisionName   Keyword
hi def link cobolSectionName    Keyword
hi def link cobolParagraphName  Keyword
hi def link cobolString         Constant
hi def link cobolTodo           Todo
hi def link cobolWatch          Special
hi def link cobolIndicator      Special
hi def link cobolStart          Comment
let b:current_syntax = "cobol"
