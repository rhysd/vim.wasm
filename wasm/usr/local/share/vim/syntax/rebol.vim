if exists("b:current_syntax")
finish
endif
syn case ignore
setlocal isk=@,48-57,?,!,.,',+,-,*,&,\|,=,_,~
syn keyword	rebolTodo	contained TODO
syn match       rebolComment    ";.*$" contains=rebolTodo
syn match       rebolWord       "\a\k*"
syn match       rebolWordPath   "[^[:space:]]/[^[:space]]"ms=s+1,me=e-1
syn keyword     rebolBoolean    true false on off yes no
syn match       rebolInteger    "\<[+-]\=\d\+\('\d*\)*\>"
syn match       rebolDecimal    "[+-]\=\(\d\+\('\d*\)*\)\=[,.]\d*\(e[+-]\=\d\+\)\="
syn match       rebolDecimal    "[+-]\=\d\+\('\d*\)*\(e[+-]\=\d\+\)\="
syn match       rebolTime       "[+-]\=\(\d\+\('\d*\)*\:\)\{1,2}\d\+\('\d*\)*\([.,]\d\+\)\=\([AP]M\)\=\>"
syn match       rebolTime       "[+-]\=:\d\+\([.,]\d*\)\=\([AP]M\)\=\>"
syn match       rebolDate       "\d\{1,2}\([/-]\)\(Jan\|Feb\|Mar\|Apr\|May\|Jun\|Jul\|Aug\|Sep\|Oct\|Nov\|Dec\)\1\(\d\{2}\)\{1,2}\>"
syn match       rebolDate       "\d\{1,2}\([/-]\)\(January\|February\|March\|April\|May\|June\|July\|August\|September\|October\|November\|December\)\1\(\d\{2}\)\{1,2}\>"
syn match       rebolDate       "\d\{1,2}\([/-]\)\d\{1,2}\1\(\d\{2}\)\{1,2}\>"
syn match       rebolDate       "\d\{4}-\d\{1,2}-\d\{1,2}\>"
syn match       rebolDate       "\d\{1,2}\.\d\{1,2}\.\d\{4}\>"
syn match       rebolMoney      "\a*\$\d\+\('\d*\)*\([,.]\d\+\)\="
syn region      rebolString     oneline start=+"+ skip=+^"+ end=+"+ contains=rebolSpecialCharacter
syn region      rebolString     start=+[^#]{+ end=+}+ skip=+{[^}]*}+ contains=rebolSpecialCharacter
syn region      rebolBinary     start=+\d*#{+ end=+}+ contains=rebolComment
syn match       rebolEmail      "\<\k\+@\(\k\+\.\)*\k\+\>"
syn match       rebolFile       "%\(\k\+/\)*\k\+[/]\=" contains=rebolSpecialCharacter
syn region      rebolFile       oneline start=+%"+ end=+"+ contains=rebolSpecialCharacter
syn match	rebolURL	"http://\k\+\(\.\k\+\)*\(:\d\+\)\=\(/\(\k\+/\)*\(\k\+\)\=\)*"
syn match	rebolURL	"file://\k\+\(\.\k\+\)*/\(\k\+/\)*\k\+"
syn match	rebolURL	"ftp://\(\k\+:\k\+@\)\=\k\+\(\.\k\+\)*\(:\d\+\)\=/\(\k\+/\)*\k\+"
syn match	rebolURL	"mailto:\k\+\(\.\k\+\)*@\k\+\(\.\k\+\)*"
syn match	rebolIssue	"#\(\d\+-\)*\d\+"
syn match	rebolTuple	"\(\d\+\.\)\{2,}"
syn match       rebolSpecialCharacter contained "\^[^[:space:][]"
syn match       rebolSpecialCharacter contained "%\d\+"
syn match       rebolMathOperator  "\(\*\{1,2}\|+\|-\|/\{1,2}\)"
syn keyword     rebolMathFunction  abs absolute add arccosine arcsine arctangent cosine
syn keyword     rebolMathFunction  divide exp log-10 log-2 log-e max maximum min
syn keyword     rebolMathFunction  minimum multiply negate power random remainder sine
syn keyword     rebolMathFunction  square-root subtract tangent
syn keyword     rebolBinaryOperator complement and or xor ~
syn match       rebolLogicOperator "[<>=]=\="
syn match       rebolLogicOperator "<>"
syn keyword     rebolLogicOperator not
syn keyword     rebolLogicFunction all any
syn keyword     rebolLogicFunction head? tail?
syn keyword     rebolLogicFunction negative? positive? zero? even? odd?
syn keyword     rebolLogicFunction binary? block? char? date? decimal? email? empty?
syn keyword     rebolLogicFunction file? found? function? integer? issue? logic? money?
syn keyword     rebolLogicFunction native? none? object? paren? path? port? series?
syn keyword     rebolLogicFunction string? time? tuple? url? word?
syn keyword     rebolLogicFunction exists? input? same? value?
syn keyword     rebolType       binary! block! char! date! decimal! email! file!
syn keyword     rebolType       function! integer! issue! logic! money! native!
syn keyword     rebolType       none! object! paren! path! port! string! time!
syn keyword     rebolType       tuple! url! word!
syn keyword     rebolTypeFunction type?
syn keyword     rebolStatement  break catch exit halt reduce return shield
syn keyword     rebolConditional if else
syn keyword     rebolRepeat     for forall foreach forskip loop repeat while until do
syn keyword     rebolStatement  change clear copy fifth find first format fourth free
syn keyword     rebolStatement  func function head insert last match next parse past
syn keyword     rebolStatement  pick remove second select skip sort tail third trim length?
syn keyword     rebolStatement  alias bind use
syn keyword     rebolStatement  import make make-object rebol info?
syn keyword     rebolStatement  delete echo form format import input load mold prin
syn keyword     rebolStatement  print probe read save secure send write
syn keyword     rebolOperator   size? modified?
syn keyword     rebolStatement  help probe trace
syn keyword     rebolStatement  func function free
syn keyword     rebolConstant   none
hi def link rebolTodo     Todo
hi def link rebolStatement Statement
hi def link rebolLabel	Label
hi def link rebolConditional Conditional
hi def link rebolRepeat	Repeat
hi def link rebolOperator	Operator
hi def link rebolLogicOperator rebolOperator
hi def link rebolLogicFunction rebolLogicOperator
hi def link rebolMathOperator rebolOperator
hi def link rebolMathFunction rebolMathOperator
hi def link rebolBinaryOperator rebolOperator
hi def link rebolBinaryFunction rebolBinaryOperator
hi def link rebolType     Type
hi def link rebolTypeFunction rebolOperator
hi def link rebolWord     Identifier
hi def link rebolWordPath rebolWord
hi def link rebolFunction	Function
hi def link rebolCharacter Character
hi def link rebolSpecialCharacter SpecialChar
hi def link rebolString	String
hi def link rebolNumber   Number
hi def link rebolInteger  rebolNumber
hi def link rebolDecimal  rebolNumber
hi def link rebolTime     rebolNumber
hi def link rebolDate     rebolNumber
hi def link rebolMoney    rebolNumber
hi def link rebolBinary   rebolNumber
hi def link rebolEmail    rebolString
hi def link rebolFile     rebolString
hi def link rebolURL      rebolString
hi def link rebolIssue    rebolNumber
hi def link rebolTuple    rebolNumber
hi def link rebolFloat    Float
hi def link rebolBoolean  Boolean
hi def link rebolConstant Constant
hi def link rebolComment	Comment
hi def link rebolError	Error
if exists("my_rebol_file")
if file_readable(expand(my_rebol_file))
execute "source " . my_rebol_file
endif
endif
let b:current_syntax = "rebol"
