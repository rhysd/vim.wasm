if exists("b:current_syntax")
finish
endif
source <sfile>:p:h/java.vim
syn case ignore
syn keyword sqljSpecial   null
syn keyword sqljKeyword	access add as asc by check cluster column
syn keyword sqljKeyword	compress connect current decimal default
syn keyword sqljKeyword	desc else exclusive file for from group
syn keyword sqljKeyword	having identified immediate increment index
syn keyword sqljKeyword	initial into is level maxextents mode modify
syn keyword sqljKeyword	nocompress nowait of offline on online start
syn keyword sqljKeyword	successful synonym table then to trigger uid
syn keyword sqljKeyword	unique user validate values view whenever
syn keyword sqljKeyword	where with option order pctfree privileges
syn keyword sqljKeyword	public resource row rowlabel rownum rows
syn keyword sqljKeyword	session share size smallint
syn keyword sqljKeyword  fetch database context iterator field join
syn keyword sqljKeyword  foreign outer inner isolation left right
syn keyword sqljKeyword  match primary key
syn keyword sqljOperator	not and or
syn keyword sqljOperator	in any some all between exists
syn keyword sqljOperator	like escape
syn keyword sqljOperator union intersect minus
syn keyword sqljOperator prior distinct
syn keyword sqljOperator	sysdate
syn keyword sqljOperator	max min avg sum count hex
syn keyword sqljStatement	alter analyze audit comment commit create
syn keyword sqljStatement	delete drop explain grant insert lock noaudit
syn keyword sqljStatement	rename revoke rollback savepoint select set
syn keyword sqljStatement	 truncate update begin work
syn keyword sqljType		char character date long raw mlslabel number
syn keyword sqljType		rowid varchar varchar2 float integer
syn keyword sqljType		byte text serial
syn region sqljString		start=+"+  skip=+\\\\\|\\"+  end=+"+
syn region sqljString		start=+'+  skip=+\\\\\|\\"+  end=+'+
syn match sqljNumber		"-\=\<\d*\.\=[0-9_]\>"
syn match sqljPre		"#sql"
syn region sqljComment    start="/\*"  end="\*/"
syn match sqlComment	"--.*"
syn sync ccomment sqljComment
hi def link sqljComment	Comment
hi def link sqljKeyword	sqljSpecial
hi def link sqljNumber	Number
hi def link sqljOperator	sqljStatement
hi def link sqljSpecial	Special
hi def link sqljStatement	Statement
hi def link sqljString	String
hi def link sqljType	Type
hi def link sqljPre	PreProc
let b:current_syntax = "sqlj"
