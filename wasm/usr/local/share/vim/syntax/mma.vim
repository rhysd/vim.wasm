if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syntax cluster mmaNotes contains=mmaTodo,mmaFixme
syntax cluster mmaComments contains=mmaComment,mmaFunctionComment,mmaItem,mmaFunctionTitle,mmaCommentStar
syntax cluster mmaCommentStrings contains=mmaLooseQuote,mmaCommentString,mmaUnicode
syntax cluster mmaStrings contains=@mmaCommentStrings,mmaString
syntax cluster mmaTop contains=mmaOperator,mmaGenericFunction,mmaPureFunction,mmaVariable
syntax keyword mmaVariable True False None Automatic All Null C General
syntax keyword mmaVariable Pi I E Infinity ComplexInfinity Indeterminate GoldenRatio EulerGamma Degree Catalan Khinchin Glaisher
syntax keyword mmaVariable Byte Character Expression Number Real String Word EndOfFile Integer Symbol
syntax keyword mmaVariable Integers Complexes Reals Booleans Rationals
syntax keyword mmaPattern DigitCharacter LetterCharacter WhitespaceCharacter WordCharacter EndOfString StartOfString EndOfLine StartOfLine WordBoundary
syntax keyword mmaVariable Next Previous After Before Character Word Expression TextLine CellContents Cell CellGroup EvaluationCell ButtonCell GeneratedCell Notebook
syntax keyword mmaVariable CellTags CellStyle CellLabel
syntax keyword mmaVariable Above Below Left Right
syntax keyword mmaVariable Black Blue Brown Cyan Gray Green Magenta Orange Pink Purple Red White Yellow
syntax keyword mmaVariable Protected Listable OneIdentity Orderless Flat Constant NumericFunction Locked ReadProtected HoldFirst HoldRest HoldAll HoldAllComplete SequenceHold NHoldFirst NHoldRest NHoldAll Temporary Stub
syntax match mmaItem "\%(^[( |*\t]*\)\@<=\%(:\+\|\w\)\w\+\%( \w\+\)\{0,3}:" contained contains=@mmaNotes
syntax keyword mmaTodo TODO NOTE HEY contained
syntax match mmaTodo "X\{3,}" contained
syntax keyword mmaFixme FIX[ME] FIXTHIS BROKEN contained
syntax match mmaFixme "BUG\%( *\#\=[0-9]\+\)\=" contained
syntax match mmaFixme "\%(Y\=A\+R\+G\+\|GRR\+\|CR\+A\+P\+\)\%(!\+\)\=" contained
syntax match mmaemPHAsis "\%(^\|\s\)\([_/]\)[a-zA-Z0-9]\+\%([- \t':]\+[a-zA-Z0-9]\+\)*\1\%(\s\|$\)" contained contains=mmaemPHAsis
syntax match mmaemPHAsis "\%(^\|\s\)(\@<!\*[a-zA-Z0-9]\+\%([- \t':]\+[a-zA-Z0-9]\+\)*)\@!\*\%(\s\|$\)" contained contains=mmaemPHAsis
syntax region mmaComment start=+(\*+ end=+\*)+ skipempty contains=@mmaNotes,mmaItem,@mmaCommentStrings,mmaemPHAsis,mmaComment
syntax region mmaFunctionComment start="(\*\*\+" end="\*\+)" contains=@mmaNotes,mmaItem,mmaFunctionTitle,@mmaCommentStrings,mmaemPHAsis,mmaComment
syntax region mmaFunctionTitle contained matchgroup=mmaFunctionComment start="\%((\*\*[ *]*\)" matchgroup=mmaFunctionTitle keepend end=".[.!-]\=\s*$" end="[.!-][ \t\r<&]"me=e-1 end="\%(\*\+)\)\@=" contained contains=@mmaNotes,mmaItem,mmaCommentStar
syntax match mmaComment "(\*\*\+)"
syntax match mmaCommentStar "^\s*\*\+" contained
syntax match mmaVariable "\$\a\+[0-9a-zA-Z$]*"
syntax match mmaVariable "`[a-zA-Z$]\+[0-9a-zA-Z$]*" contains=mmaVariable
syntax match mmaVariable "[a-zA-Z$]\+[0-9a-zA-Z$]*`" contains=mmaVariable
syntax region mmaString start=+\\\@<!"+ skip=+\\\@<!\\\%(\\\\\)*"+ end=+"+
syntax region mmaCommentString oneline start=+\\\@<!"+ skip=+\\\@<!\\\%(\\\\\)*"+ end=+"+ contained
syntax match mmaPatternError "\%(_\{4,}\|)\s*&\s*)\@!\)" contained
syntax match mmaPattern "[A-Za-z0-9`]\+\s*:\+[=>]\@!" contains=mmaOperator
syntax match mmaPattern ": *[^ ,]\+[\], ]\@=" contains=@mmaCommentStrings,@mmaTop,mmaOperator
syntax match mmaPattern "[A-Za-z0-9`]*_\+\%(\a\+\)\=\%(?([^)]\+)\|?[^\]},]\+\)\=" contains=@mmaTop,@mmaCommentStrings,mmaPatternError
syntax match mmaOperator "\%(@\{1,3}\|//[.@]\=\)"
syntax match mmaOperator "\%(/[;:@.]\=\|\^\=:\==\)"
syntax match mmaOperator "\%([-:=]\=>\|<=\=\)"
syntax match mmaOperator "[*+=^.:?-]"
syntax match mmaOperator "\%(\~\~\=\)"
syntax match mmaOperator "\%(=\{2,3}\|=\=!=\|||\=\|&&\|!\)" contains=ALLBUT,mmaPureFunction
syntax match mmaMessage "`\=\([a-zA-Z$]\+[0-9a-zA-Z$]*\)\%(`\%([a-zA-Z$]\+[0-9a-zA-Z$]*\)\=\)*::\a\+" contains=mmaMessageType
syntax match mmaMessageType "::\a\+"hs=s+2 contained
syntax match mmaPureFunction "#\%(#\|\d\+\)\="
syntax match mmaPureFunction "&"
syntax match mmaGenericFunction "[A-Za-z0-9`]\+\s*\%([@[]\|/:\|/\=/@\)\@=" contains=mmaOperator
syntax match mmaGenericFunction "\~\s*[^~]\+\s*\~"hs=s+1,he=e-1 contains=mmaOperator,mmaBoring
syntax match mmaGenericFunction "//\s*[A-Za-z0-9`]\+"hs=s+2 contains=mmaOperator
syntax match mmaNumber "\<\%(\d\+\.\=\d*\|\d*\.\=\d\+\)\>"
syntax match mmaNumber "`\d\+\%(\d\@!\.\|\>\)"
syntax match mmaUnicode "\\\[\w\+\d*\]"
syntax match mmaUnicode "\\\%(\x\{3}\|\.\x\{2}\|:\x\{4}\)"
syntax match mmaError "\*)" containedin=ALLBUT,@mmaComments,@mmaStrings
syntax match mmaError "\%([/]{3,}\|[&:|+*?~-]\{3,}\|[.=]\{4,}\|_\@<=\.\{2,}\|`\{2,}\)" containedin=ALLBUT,@mmaComments,@mmaStrings
syntax match mmaBoring "[(){}]" contained
set commentstring='(*%s*)'
syntax sync fromstart
hi def link mmaComment           Comment
hi def link mmaCommentStar       Comment
hi def link mmaFunctionComment   Comment
hi def link mmaLooseQuote        Comment
hi def link mmaGenericFunction   Function
hi def link mmaVariable          Identifier
hi def link mmaOperator          Operator
hi def link mmaPatternOp         Operator
hi def link mmaPureFunction      Operator
hi def link mmaString            String
hi def link mmaCommentString     String
hi def link mmaUnicode           String
hi def link mmaMessage           Type
hi def link mmaNumber            Type
hi def link mmaPattern           Type
hi def link mmaError             Error
hi def link mmaFixme             Error
hi def link mmaPatternError      Error
hi def link mmaTodo              Todo
hi def link mmaemPHAsis          Special
hi def link mmaFunctionTitle     Special
hi def link mmaMessageType       Special
hi def link mmaItem              Preproc
let b:current_syntax = "mma"
let &cpo = s:cpo_save
unlet s:cpo_save
