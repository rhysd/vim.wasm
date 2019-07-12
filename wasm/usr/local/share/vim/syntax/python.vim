if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
if exists("python_no_doctest_highlight")
let python_no_doctest_code_highlight = 1
endif
if exists("python_highlight_all")
if exists("python_no_builtin_highlight")
unlet python_no_builtin_highlight
endif
if exists("python_no_doctest_code_highlight")
unlet python_no_doctest_code_highlight
endif
if exists("python_no_doctest_highlight")
unlet python_no_doctest_highlight
endif
if exists("python_no_exception_highlight")
unlet python_no_exception_highlight
endif
if exists("python_no_number_highlight")
unlet python_no_number_highlight
endif
let python_space_error_highlight = 1
endif
syn keyword pythonStatement	False None True
syn keyword pythonStatement	as assert break continue del exec global
syn keyword pythonStatement	lambda nonlocal pass print return with yield
syn keyword pythonStatement	class def nextgroup=pythonFunction skipwhite
syn keyword pythonConditional	elif else if
syn keyword pythonRepeat	for while
syn keyword pythonOperator	and in is not or
syn keyword pythonException	except finally raise try
syn keyword pythonInclude	from import
syn keyword pythonAsync		async await
syn match   pythonDecorator	"@" display contained
syn match   pythonDecoratorName	"@\s*\h\%(\w\|\.\)*" display contains=pythonDecorator
syn match   pythonMatrixMultiply
\ "\%(\w\|[])]\)\s*@"
\ contains=ALLBUT,pythonDecoratorName,pythonDecorator,pythonFunction,pythonDoctestValue
\ transparent
syn match   pythonMatrixMultiply
\ "[^\\]\\\s*\n\%(\s*\.\.\.\s\)\=\s\+@"
\ contains=ALLBUT,pythonDecoratorName,pythonDecorator,pythonFunction,pythonDoctestValue
\ transparent
syn match   pythonMatrixMultiply
\ "^\s*\%(\%(>>>\|\.\.\.\)\s\+\)\=\zs\%(\h\|\%(\h\|[[(]\).\{-}\%(\w\|[])]\)\)\s*\n\%(\s*\.\.\.\s\)\=\s\+@\%(.\{-}\n\%(\s*\.\.\.\s\)\=\s\+@\)*"
\ contains=ALLBUT,pythonDecoratorName,pythonDecorator,pythonFunction,pythonDoctestValue
\ transparent
syn match   pythonFunction	"\h\w*" display contained
syn match   pythonComment	"#.*$" contains=pythonTodo,@Spell
syn keyword pythonTodo		FIXME NOTE NOTES TODO XXX contained
syn region  pythonString matchgroup=pythonQuotes
\ start=+[uU]\=\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
\ contains=pythonEscape,@Spell
syn region  pythonString matchgroup=pythonTripleQuotes
\ start=+[uU]\=\z('''\|"""\)+ end="\z1" keepend
\ contains=pythonEscape,pythonSpaceError,pythonDoctest,@Spell
syn region  pythonRawString matchgroup=pythonQuotes
\ start=+[uU]\=[rR]\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
\ contains=@Spell
syn region  pythonRawString matchgroup=pythonTripleQuotes
\ start=+[uU]\=[rR]\z('''\|"""\)+ end="\z1" keepend
\ contains=pythonSpaceError,pythonDoctest,@Spell
syn match   pythonEscape	+\\[abfnrtv'"\\]+ contained
syn match   pythonEscape	"\\\o\{1,3}" contained
syn match   pythonEscape	"\\x\x\{2}" contained
syn match   pythonEscape	"\%(\\u\x\{4}\|\\U\x\{8}\)" contained
syn match   pythonEscape	"\\N{\a\+\%(\s\a\+\)*}" contained
syn match   pythonEscape	"\\$"
if !exists("python_no_number_highlight")
syn match   pythonNumber	"\<0[oO]\=\o\+[Ll]\=\>"
syn match   pythonNumber	"\<0[xX]\x\+[Ll]\=\>"
syn match   pythonNumber	"\<0[bB][01]\+[Ll]\=\>"
syn match   pythonNumber	"\<\%([1-9]\d*\|0\)[Ll]\=\>"
syn match   pythonNumber	"\<\d\+[jJ]\>"
syn match   pythonNumber	"\<\d\+[eE][+-]\=\d\+[jJ]\=\>"
syn match   pythonNumber
\ "\<\d\+\.\%([eE][+-]\=\d\+\)\=[jJ]\=\%(\W\|$\)\@="
syn match   pythonNumber
\ "\%(^\|\W\)\zs\d*\.\d\+\%([eE][+-]\=\d\+\)\=[jJ]\=\>"
endif
if !exists("python_no_builtin_highlight")
syn keyword pythonBuiltin	False True None
syn keyword pythonBuiltin	NotImplemented Ellipsis __debug__
syn keyword pythonBuiltin	abs all any bin bool bytearray callable chr
syn keyword pythonBuiltin	classmethod compile complex delattr dict dir
syn keyword pythonBuiltin	divmod enumerate eval filter float format
syn keyword pythonBuiltin	frozenset getattr globals hasattr hash
syn keyword pythonBuiltin	help hex id input int isinstance
syn keyword pythonBuiltin	issubclass iter len list locals map max
syn keyword pythonBuiltin	memoryview min next object oct open ord pow
syn keyword pythonBuiltin	print property range repr reversed round set
syn keyword pythonBuiltin	setattr slice sorted staticmethod str
syn keyword pythonBuiltin	sum super tuple type vars zip __import__
syn keyword pythonBuiltin	basestring cmp execfile file
syn keyword pythonBuiltin	long raw_input reduce reload unichr
syn keyword pythonBuiltin	unicode xrange
syn keyword pythonBuiltin	ascii bytes exec
syn keyword pythonBuiltin	apply buffer coerce intern
syn match   pythonAttribute	/\.\h\w*/hs=s+1
\ contains=ALLBUT,pythonBuiltin,pythonFunction,pythonAsync
\ transparent
endif
if !exists("python_no_exception_highlight")
syn keyword pythonExceptions	BaseException Exception
syn keyword pythonExceptions	ArithmeticError BufferError
syn keyword pythonExceptions	LookupError
syn keyword pythonExceptions	EnvironmentError StandardError
syn keyword pythonExceptions	AssertionError AttributeError
syn keyword pythonExceptions	EOFError FloatingPointError GeneratorExit
syn keyword pythonExceptions	ImportError IndentationError
syn keyword pythonExceptions	IndexError KeyError KeyboardInterrupt
syn keyword pythonExceptions	MemoryError NameError NotImplementedError
syn keyword pythonExceptions	OSError OverflowError ReferenceError
syn keyword pythonExceptions	RuntimeError StopIteration SyntaxError
syn keyword pythonExceptions	SystemError SystemExit TabError TypeError
syn keyword pythonExceptions	UnboundLocalError UnicodeError
syn keyword pythonExceptions	UnicodeDecodeError UnicodeEncodeError
syn keyword pythonExceptions	UnicodeTranslateError ValueError
syn keyword pythonExceptions	ZeroDivisionError
syn keyword pythonExceptions	BlockingIOError BrokenPipeError
syn keyword pythonExceptions	ChildProcessError ConnectionAbortedError
syn keyword pythonExceptions	ConnectionError ConnectionRefusedError
syn keyword pythonExceptions	ConnectionResetError FileExistsError
syn keyword pythonExceptions	FileNotFoundError InterruptedError
syn keyword pythonExceptions	IsADirectoryError NotADirectoryError
syn keyword pythonExceptions	PermissionError ProcessLookupError
syn keyword pythonExceptions	RecursionError StopAsyncIteration
syn keyword pythonExceptions	TimeoutError
syn keyword pythonExceptions	IOError VMSError WindowsError
syn keyword pythonExceptions	BytesWarning DeprecationWarning FutureWarning
syn keyword pythonExceptions	ImportWarning PendingDeprecationWarning
syn keyword pythonExceptions	RuntimeWarning SyntaxWarning UnicodeWarning
syn keyword pythonExceptions	UserWarning Warning
syn keyword pythonExceptions	ResourceWarning
endif
if exists("python_space_error_highlight")
syn match   pythonSpaceError	display excludenl "\s\+$"
syn match   pythonSpaceError	display " \+\t"
syn match   pythonSpaceError	display "\t\+ "
endif
if !exists("python_no_doctest_highlight")
if !exists("python_no_doctest_code_highlight")
syn region pythonDoctest
\ start="^\s*>>>\s" end="^\s*$"
\ contained contains=ALLBUT,pythonDoctest,pythonFunction,@Spell
syn region pythonDoctestValue
\ start=+^\s*\%(>>>\s\|\.\.\.\s\|"""\|'''\)\@!\S\++ end="$"
\ contained
else
syn region pythonDoctest
\ start="^\s*>>>" end="^\s*$"
\ contained contains=@NoSpell
endif
endif
syn sync match pythonSync grouphere NONE "^\%(def\|class\)\s\+\h\w*\s*[(:]"
hi def link pythonStatement		Statement
hi def link pythonConditional		Conditional
hi def link pythonRepeat		Repeat
hi def link pythonOperator		Operator
hi def link pythonException		Exception
hi def link pythonInclude		Include
hi def link pythonAsync			Statement
hi def link pythonDecorator		Define
hi def link pythonDecoratorName		Function
hi def link pythonFunction		Function
hi def link pythonComment		Comment
hi def link pythonTodo			Todo
hi def link pythonString		String
hi def link pythonRawString		String
hi def link pythonQuotes		String
hi def link pythonTripleQuotes		pythonQuotes
hi def link pythonEscape		Special
if !exists("python_no_number_highlight")
hi def link pythonNumber		Number
endif
if !exists("python_no_builtin_highlight")
hi def link pythonBuiltin		Function
endif
if !exists("python_no_exception_highlight")
hi def link pythonExceptions		Structure
endif
if exists("python_space_error_highlight")
hi def link pythonSpaceError		Error
endif
if !exists("python_no_doctest_highlight")
hi def link pythonDoctest		Special
hi def link pythonDoctestValue	Define
endif
let b:current_syntax = "python"
let &cpo = s:cpo_save
unlet s:cpo_save
