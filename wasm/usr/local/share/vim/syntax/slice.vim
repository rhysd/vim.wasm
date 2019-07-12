if exists("b:current_syntax")
finish
endif
syn keyword sliceType	    bool byte double float int long short string void
syn keyword sliceQualifier  const extends idempotent implements local nonmutating out throws
syn keyword sliceConstruct  class enum exception dictionary interface module LocalObject Object sequence struct
syn keyword sliceQualifier  const extends idempotent implements local nonmutating out throws
syn keyword sliceBoolean    false true
syn region  sliceIncluded    display contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match   sliceIncluded   display contained "<[^>]*>"
syn match   sliceInclude    display "^\s*#\s*include\>\s*["<]" contains=sliceIncluded
syn region  sliceGuard      start="^#\(define\|ifndef\|endif\)" end="$"
syn region sliceString		start=+"+  end=+"+
syn case ignore
syn match   sliceNumbers    display transparent "\<\d\|\.\d" contains=sliceNumber,sliceFloat,sliceOctal
syn match   sliceNumber     display contained "\d\+"
syn match   sliceNumber     display contained "0x\x\+\(u\=l\{0,2}\|ll\=u\)\>"
syn match   sliceOctal      display contained "0\o\+\(u\=l\{0,2}\|ll\=u\)\>" contains=sliceOctalZero
syn match   sliceOctalZero  display contained "\<0"
syn match   sliceFloat      display contained "\d\+f"
syn match   sliceFloat      display contained "\d\+\.\d*\(e[-+]\=\d\+\)\=[fl]\="
syn match   sliceFloat      display contained "\.\d\+\(e[-+]\=\d\+\)\=[fl]\=\>"
syn match   sliceFloat      display contained "\d\+e[-+]\=\d\+[fl]\=\>"
syn case match
syn region sliceComment    start="/\*"  end="\*/"
syn match sliceComment	"//.*"
syn sync ccomment sliceComment
hi def link sliceComment	Comment
hi def link sliceConstruct	Keyword
hi def link sliceType	Type
hi def link sliceString	String
hi def link sliceIncluded	String
hi def link sliceQualifier	Keyword
hi def link sliceInclude	Include
hi def link sliceGuard	PreProc
hi def link sliceBoolean	Boolean
hi def link sliceFloat	Number
hi def link sliceNumber	Number
hi def link sliceOctal	Number
hi def link sliceOctalZero	Special
hi def link sliceNumberError Special
let b:current_syntax = "slice"
