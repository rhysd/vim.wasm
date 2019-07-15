if exists("b:current_syntax")
finish
endif
if !exists("main_syntax")
let main_syntax = 'lite'
endif
if main_syntax == 'lite'
if exists("lite_sql_query")
if lite_sql_query == 1
syn include @liteSql <sfile>:p:h/sql.vim
unlet b:current_syntax
endif
endif
endif
if main_syntax == 'msql'
if exists("msql_sql_query")
if msql_sql_query == 1
syn include @liteSql <sfile>:p:h/sql.vim
unlet b:current_syntax
endif
endif
endif
syn cluster liteSql remove=sqlString,sqlComment
syn case match
syn keyword liteIntVar ERRMSG contained
syn region liteComment		start="/\*" end="\*/" contains=liteTodo
syn keyword liteFunctions  echo printf fprintf open close read
syn keyword liteFunctions  readln readtok
syn keyword liteFunctions  split strseg chop tr sub substr
syn keyword liteFunctions  test unlink umask chmod mkdir chdir rmdir
syn keyword liteFunctions  rename truncate link symlink stat
syn keyword liteFunctions  sleep system getpid getppid kill
syn keyword liteFunctions  time ctime time2unixtime unixtime2year
syn keyword liteFunctions  unixtime2year unixtime2month unixtime2day
syn keyword liteFunctions  unixtime2hour unixtime2min unixtime2sec
syn keyword liteFunctions  strftime
syn keyword liteFunctions  getpwnam getpwuid
syn keyword liteFunctions  gethostbyname gethostbyaddress
syn keyword liteFunctions  urlEncode setContentType includeFile
syn keyword liteFunctions  msqlConnect msqlClose msqlSelectDB
syn keyword liteFunctions  msqlQuery msqlStoreResult msqlFreeResult
syn keyword liteFunctions  msqlFetchRow msqlDataSeek msqlListDBs
syn keyword liteFunctions  msqlListTables msqlInitFieldList msqlListField
syn keyword liteFunctions  msqlFieldSeek msqlNumRows msqlEncode
syn keyword liteFunctions  exit fatal typeof
syn keyword liteFunctions  crypt addHttpHeader
syn keyword liteConditional  if else
syn keyword liteRepeat  while
syn keyword liteStatement  break return continue
syn match liteOperator  "[-+=#*]"
syn match liteOperator  "/[^*]"me=e-1
syn match liteOperator  "\$"
syn match liteRelation  "&&"
syn match liteRelation  "||"
syn match liteRelation  "[!=<>]="
syn match liteRelation  "[<>]"
syn match  liteIdentifier "$\h\w*" contains=liteIntVar,liteOperator
syn match  liteGlobalIdentifier "@\h\w*" contains=liteIntVar
syn keyword liteInclude  load
syn keyword liteDefine  funct
syn keyword liteType  int uint char real
syn region liteString  keepend matchgroup=None start=+"+  skip=+\\\\\|\\"+  end=+"+ contains=liteIdentifier,liteSpecialChar,@liteSql
syn match liteNumber  "-\=\<\d\+\>"
syn match liteFloat  "\(-\=\<\d+\|-\=\)\.\d\+\>"
syn match liteSpecialChar "\\[abcfnrtv\\]" contained
syn match liteParentError "[)}\]]"
syn keyword liteTodo TODO Todo todo contained
syn match liteExec "^#!.*$"
syn cluster liteInside contains=liteComment,liteFunctions,liteIdentifier,liteGlobalIdentifier,liteConditional,liteRepeat,liteStatement,liteOperator,liteRelation,liteType,liteString,liteNumber,liteFloat,liteParent
syn region liteParent matchgroup=Delimiter start="(" end=")" contains=@liteInside
syn region liteParent matchgroup=Delimiter start="{" end="}" contains=@liteInside
syn region liteParent matchgroup=Delimiter start="\[" end="\]" contains=@liteInside
if main_syntax == 'lite'
if exists("lite_minlines")
exec "syn sync minlines=" . lite_minlines
else
syn sync minlines=100
endif
endif
hi def link liteComment		Comment
hi def link liteString		String
hi def link liteNumber		Number
hi def link liteFloat		Float
hi def link liteIdentifier	Identifier
hi def link liteGlobalIdentifier	Identifier
hi def link liteIntVar		Identifier
hi def link liteFunctions		Function
hi def link liteRepeat		Repeat
hi def link liteConditional	Conditional
hi def link liteStatement		Statement
hi def link liteType		Type
hi def link liteInclude		Include
hi def link liteDefine		Define
hi def link liteSpecialChar	SpecialChar
hi def link liteParentError	liteError
hi def link liteError		Error
hi def link liteTodo		Todo
hi def link liteOperator		Operator
hi def link liteRelation		Operator
let b:current_syntax = "lite"
if main_syntax == 'lite'
unlet main_syntax
endif
