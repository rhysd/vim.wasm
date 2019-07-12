if exists("b:current_syntax")
finish
endif
if !exists("main_syntax")
let main_syntax = 'aspvbs'
endif
runtime! syntax/html.vim
unlet b:current_syntax
syn cluster htmlPreProc add=AspVBScriptInsideHtmlTags
hi def AspVBSVariableSimple   term=standout  ctermfg=3  guifg=#99ee99
hi def AspVBSVariableComplex  term=standout  ctermfg=3  guifg=#ee9900
syn match AspVBSVariableSimple  contained "\<\(bln\|byt\|dtm\=\|dbl\|int\|str\)\u\w*"
syn match AspVBSVariableComplex contained "\<\(arr\|ary\|obj\)\u\w*"
syn keyword AspVBSError contained Val Str CVar CVDate DoEvents GoSub Return GoTo
syn keyword AspVBSError contained Stop LinkExecute Add Type LinkPoke
syn keyword AspVBSError contained LinkRequest LinkSend Declare Optional Sleep
syn keyword AspVBSError contained ParamArray Static Erl TypeOf Like LSet RSet Mid StrConv
syn match AspVBSError contained "\<Def[a-zA-Z0-9_]\+\>"
syn match AspVBSError contained "^\s*Open\s\+"
syn match AspVBSError contained "Debug\.[a-zA-Z0-9_]*"
syn match AspVBSError contained "^\s*[a-zA-Z0-9_]\+:"
syn match AspVBSError contained "[a-zA-Z0-9_]\+![a-zA-Z0-9_]\+"
syn match AspVBSError contained "^\s*#.*$"
syn match AspVBSError contained "\<As\s\+[a-zA-Z0-9_]*"
syn match AspVBSError contained "\<End\>\|\<Exit\>"
syn match AspVBSError contained "\<On\s\+Error\>\|\<On\>\|\<Error\>\|\<Resume\s\+Next\>\|\<Resume\>"
syn match AspVBSError contained "\<Option\s\+\(Base\|Compare\|Private\s\+Module\)\>"
syn match AspVBSError contained "Respon\?ce\.\S*"
syn match AspVBSError contained "Respose\.\S*"
syn match AspVBSStatement contained "\<On\s\+Error\s\+\(Resume\s\+Next\|goto\s\+0\)\>\|\<Next\>"
syn match AspVBSStatement contained "\<End\s\+\(If\|For\|Select\|Class\|Function\|Sub\|With\|Property\)\>"
syn match AspVBSStatement contained "\<Exit\s\+\(Do\|For\|Sub\|Function\)\>"
syn match AspVBSStatement contained "\<Exit\s\+\(Do\|For\|Sub\|Function\|Property\)\>"
syn match AspVBSStatement contained "\<Option\s\+Explicit\>"
syn match AspVBSStatement contained "\<For\s\+Each\>\|\<For\>"
syn match AspVBSStatement contained "\<Set\>"
syn keyword AspVBSStatement contained Call Class Const Default Dim Do Loop Erase And
syn keyword AspVBSStatement contained Function If Then Else ElseIf Or
syn keyword AspVBSStatement contained Private Public Randomize ReDim
syn keyword AspVBSStatement contained Select Case Sub While With Wend Not
syn keyword AspVBSFunction contained Abs Array Asc Atn CBool CByte CCur CDate CDbl
syn keyword AspVBSFunction contained Chr CInt CLng Cos CreateObject CSng CStr Date
syn keyword AspVBSFunction contained DateAdd DateDiff DatePart DateSerial DateValue
syn keyword AspVBSFunction contained Date Day Exp Filter Fix FormatCurrency
syn keyword AspVBSFunction contained FormatDateTime FormatNumber FormatPercent
syn keyword AspVBSFunction contained GetObject Hex Hour InputBox InStr InStrRev Int
syn keyword AspVBSFunction contained IsArray IsDate IsEmpty IsNull IsNumeric
syn keyword AspVBSFunction contained IsObject Join LBound LCase Left Len LoadPicture
syn keyword AspVBSFunction contained Log LTrim Mid Minute Month MonthName MsgBox Now
syn keyword AspVBSFunction contained Oct Replace RGB Right Rnd Round RTrim
syn keyword AspVBSFunction contained ScriptEngine ScriptEngineBuildVersion
syn keyword AspVBSFunction contained ScriptEngineMajorVersion
syn keyword AspVBSFunction contained ScriptEngineMinorVersion Second Sgn Sin Space
syn keyword AspVBSFunction contained Split Sqr StrComp StrReverse String Tan Time Timer
syn keyword AspVBSFunction contained TimeSerial TimeValue Trim TypeName UBound UCase
syn keyword AspVBSFunction contained VarType Weekday WeekdayName Year
syn keyword AspVBSMethods contained Add AddFolders BuildPath Clear Close Copy
syn keyword AspVBSMethods contained CopyFile CopyFolder CreateFolder CreateTextFile
syn keyword AspVBSMethods contained Delete DeleteFile DeleteFolder DriveExists
syn keyword AspVBSMethods contained Exists FileExists FolderExists
syn keyword AspVBSMethods contained GetAbsolutePathName GetBaseName GetDrive
syn keyword AspVBSMethods contained GetDriveName GetExtensionName GetFile
syn keyword AspVBSMethods contained GetFileName GetFolder GetParentFolderName
syn keyword AspVBSMethods contained GetSpecialFolder GetTempName Items Keys Move
syn keyword AspVBSMethods contained MoveFile MoveFolder OpenAsTextStream
syn keyword AspVBSMethods contained OpenTextFile Raise Read ReadAll ReadLine Remove
syn keyword AspVBSMethods contained RemoveAll Skip SkipLine Write WriteBlankLines
syn keyword AspVBSMethods contained WriteLine
syn match AspVBSMethods contained "Response\.\w*"
syn keyword AspVBSMethods contained true false
syn match  AspVBSNumber	contained	"\<\d\+\>"
syn match  AspVBSNumber	contained	"\<\d\+\.\d*\>"
syn match  AspVBSNumber	contained	"\.\d\+\>"
syn region  AspVBSString	contained	  start=+"+  end=+"+ keepend
syn region  AspVBSComment	contained start="^REM\s\|\sREM\s" end="$" contains=AspVBSTodo keepend
syn region  AspVBSComment   contained start="^'\|\s'"   end="$" contains=AspVBSTodo keepend
syn keyword AspVBSTodo contained	TODO FIXME
syn region  AspVBSError	contained start="^\d" end="\s" keepend
syn match   AspVBSError  contained "[a-zA-Z0-9_][\$&!#]"ms=s+1
syn match   AspVBSError  contained "[a-zA-Z0-9_]%\($\|[^>]\)"ms=s+1
syn cluster AspVBScriptTop contains=AspVBSStatement,AspVBSFunction,AspVBSMethods,AspVBSNumber,AspVBSString,AspVBSComment,AspVBSError,AspVBSVariableSimple,AspVBSVariableComplex
syn region AspVBSFold start="^\s*\(class\)\s\+.*$" end="^\s*end\s\+\(class\)\>.*$" fold contained transparent keepend
syn region AspVBSFold start="^\s*\(private\|public\)\=\(\s\+default\)\=\s\+\(sub\|function\)\s\+.*$" end="^\s*end\s\+\(function\|sub\)\>.*$" fold contained transparent keepend
syn region  AspVBScriptInsideHtmlTags keepend matchgroup=Delimiter start=+<%=\=+ end=+%>+ contains=@AspVBScriptTop, AspVBSFold
syn region  AspVBScriptInsideHtmlTags keepend matchgroup=Delimiter start=+<script\s\+language="\=vbscript"\=[^>]*\s\+runatserver[^>]*>+ end=+</script>+ contains=@AspVBScriptTop
syn sync match htmlHighlight grouphere htmlTag "%>"
hi def link AspVBSLineNumber	Comment
hi def link AspVBSNumber		Number
hi def link AspVBSError		Error
hi def link AspVBSStatement	Statement
hi def link AspVBSString		String
hi def link AspVBSComment		Comment
hi def link AspVBSTodo		Todo
hi def link AspVBSFunction		Identifier
hi def link AspVBSMethods		PreProc
hi def link AspVBSEvents		Special
hi def link AspVBSTypeSpecifier	Type
let b:current_syntax = "aspvbs"
if main_syntax == 'aspvbs'
unlet main_syntax
endif
