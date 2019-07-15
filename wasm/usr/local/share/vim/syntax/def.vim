if exists("b:current_syntax")
finish
endif
syn case ignore
syn match defComment	";.*"
syn keyword defKeyword	LIBRARY STUB EXETYPE DESCRIPTION CODE WINDOWS DOS
syn keyword defKeyword	RESIDENTNAME PRIVATE EXPORTS IMPORTS SEGMENTS
syn keyword defKeyword	HEAPSIZE DATA
syn keyword defStorage	LOADONCALL MOVEABLE DISCARDABLE SINGLE
syn keyword defStorage	FIXED PRELOAD
syn match   defOrdinal	"\s\+@\d\+"
syn region  defString	start=+'+ end=+'+
syn match   defNumber	"\d+"
syn match   defNumber	"0x\x\+"
hi def link defComment	Comment
hi def link defKeyword	Keyword
hi def link defStorage	StorageClass
hi def link defString	String
hi def link defNumber	Number
hi def link defOrdinal	Operator
let b:current_syntax = "def"
