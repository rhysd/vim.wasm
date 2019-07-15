if exists("b:current_syntax")
finish
endif
syn case ignore
syn region sqlComment    start="{"  end="}" contains=sqlTodo
syn match sqlComment	"--.*$" contains=sqlTodo
syn sync ccomment sqlComment
syn keyword sqlBoolean  true false
syn keyword sqlBoolean  null
syn keyword sqlBoolean  public user
syn keyword sqlBoolean  current today
syn keyword sqlBoolean  year month day hour minute second fraction
syn region sqlString		start=+"+  end=+"+
syn region sqlString		start=+'+  end=+'+
syn match sqlNumber		"-\=\<\d*\.\=[0-9_]\>"
syn keyword sqlStatement allocate alter
syn keyword sqlStatement begin
syn keyword sqlStatement close commit connect create
syn keyword sqlStatement database deallocate declare delete describe disconnect drop
syn keyword sqlStatement execute fetch flush free get grant info insert
syn keyword sqlStatement load lock open output
syn keyword sqlStatement prepare put
syn keyword sqlStatement rename revoke rollback select set start stop
syn keyword sqlStatement truncate unload unlock update
syn keyword sqlStatement whenever
syn keyword sqlStatement call continue define
syn keyword sqlStatement exit
syn keyword sqlStatement let
syn keyword sqlStatement return system trace
syn keyword sqlConditional elif else if then
syn keyword sqlConditional case
syn match  sqlConditional "end \+if"
syn match  sqlRepeat "for\( \+each \+row\)\="
syn keyword sqlRepeat foreach while
syn match  sqlRepeat "end \+for"
syn match  sqlRepeat "end \+foreach"
syn match  sqlRepeat "end \+while"
syn match  sqlException "on \+exception"
syn match  sqlException "end \+exception"
syn match  sqlException "end \+exception \+with \+resume"
syn match  sqlException "raise \+exception"
syn keyword sqlKeyword aggregate add as authorization autofree by
syn keyword sqlKeyword cache cascade check cluster collation
syn keyword sqlKeyword column connection constraint cross
syn keyword sqlKeyword dataskip debug default deferred_prepare
syn keyword sqlKeyword descriptor diagnostics
syn keyword sqlKeyword each escape explain external
syn keyword sqlKeyword file foreign fragment from function
syn keyword sqlKeyword group having
syn keyword sqlKeyword immediate index inner into isolation
syn keyword sqlKeyword join key
syn keyword sqlKeyword left level log
syn keyword sqlKeyword mode modify mounting new no
syn keyword sqlKeyword object of old optical option
syn keyword sqlKeyword optimization order outer
syn keyword sqlKeyword pdqpriority pload primary procedure
syn keyword sqlKeyword references referencing release reserve
syn keyword sqlKeyword residency right role routine row
syn keyword sqlKeyword schedule schema scratch session set
syn keyword sqlKeyword statement statistics synonym
syn keyword sqlKeyword table temp temporary timeout to transaction trigger
syn keyword sqlKeyword using values view violations
syn keyword sqlKeyword where with work
syn match sqlKeyword "on \+\(exception\)\@!"
syn match sqlKeyword "end \+\(if\|for\|foreach\|while\|exception\)\@!"
syn keyword sqlKeyword resume returning
syn keyword sqlOperator	not and or
syn keyword sqlOperator	in is any some all between exists
syn keyword sqlOperator	like matches
syn keyword sqlOperator union intersect
syn keyword sqlOperator distinct unique
syn keyword sqlFunction	abs acos asin atan atan2 avg
syn keyword sqlFunction	cardinality cast char_length character_length cos count
syn keyword sqlFunction	exp filetoblob filetoclob hex
syn keyword sqlFunction	initcap length logn log10 lower lpad
syn keyword sqlFunction	min max mod octet_length pow range replace root round rpad
syn keyword sqlFunction	sin sqrt stdev substr substring sum
syn keyword sqlFunction	to_char tan to_date trim trunc upper variance
syn keyword sqlType	blob boolean byte char character clob
syn keyword sqlType	date datetime dec decimal double
syn keyword sqlType	float int int8 integer interval list lvarchar
syn keyword sqlType	money multiset nchar numeric nvarchar
syn keyword sqlType	real serial serial8 smallfloat smallint
syn keyword sqlType	text varchar varying
syn keyword sqlTodo TODO FIXME XXX DEBUG NOTE
hi def link sqlComment	Comment
hi def link sqlNumber	Number
hi def link sqlBoolean	Boolean
hi def link sqlString	String
hi def link sqlStatement	Statement
hi def link sqlConditional	Conditional
hi def link sqlRepeat		Repeat
hi def link sqlKeyword		Keyword
hi def link sqlOperator	Operator
hi def link sqlException	Exception
hi def link sqlFunction	Function
hi def link sqlType	Type
hi def link sqlTodo	Todo
let b:current_syntax = "sqlinformix"
