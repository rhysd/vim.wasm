if exists('b:current_syntax')
finish
endif
if !exists('g:go_highlight_array_whitespace_error')
let g:go_highlight_array_whitespace_error = 1
endif
if !exists('g:go_highlight_chan_whitespace_error')
let g:go_highlight_chan_whitespace_error = 1
endif
if !exists('g:go_highlight_extra_types')
let g:go_highlight_extra_types = 1
endif
if !exists('g:go_highlight_space_tab_error')
let g:go_highlight_space_tab_error = 1
endif
if !exists('g:go_highlight_trailing_whitespace_error')
let g:go_highlight_trailing_whitespace_error = 1
endif
syn case match
syn keyword     goDirective         package import
syn keyword     goDeclaration       var const type
syn keyword     goDeclType          struct interface
hi def link     goDirective         Statement
hi def link     goDeclaration       Keyword
hi def link     goDeclType          Keyword
syn keyword     goStatement         defer go goto return break continue fallthrough
syn keyword     goConditional       if else switch select
syn keyword     goLabel             case default
syn keyword     goRepeat            for range
hi def link     goStatement         Statement
hi def link     goConditional       Conditional
hi def link     goLabel             Label
hi def link     goRepeat            Repeat
syn keyword     goType              chan map bool string error
syn keyword     goSignedInts        int int8 int16 int32 int64 rune
syn keyword     goUnsignedInts      byte uint uint8 uint16 uint32 uint64 uintptr
syn keyword     goFloats            float32 float64
syn keyword     goComplexes         complex64 complex128
hi def link     goType              Type
hi def link     goSignedInts        Type
hi def link     goUnsignedInts      Type
hi def link     goFloats            Type
hi def link     goComplexes         Type
syn match       goType              /\<func\>/
syn match       goDeclaration       /^func\>/
syn keyword     goBuiltins          append cap close complex copy delete imag len
syn keyword     goBuiltins          make new panic print println real recover
syn keyword     goConstants         iota true false nil
hi def link     goBuiltins          Keyword
hi def link     goConstants         Keyword
syn keyword     goTodo              contained TODO FIXME XXX BUG
syn cluster     goCommentGroup      contains=goTodo
syn region      goComment           start="/\*" end="\*/" contains=@goCommentGroup,@Spell
syn region      goComment           start="//" end="$" contains=@goCommentGroup,@Spell
hi def link     goComment           Comment
hi def link     goTodo              Todo
syn match       goEscapeOctal       display contained "\\[0-7]\{3}"
syn match       goEscapeC           display contained +\\[abfnrtv\\'"]+
syn match       goEscapeX           display contained "\\x\x\{2}"
syn match       goEscapeU           display contained "\\u\x\{4}"
syn match       goEscapeBigU        display contained "\\U\x\{8}"
syn match       goEscapeError       display contained +\\[^0-7xuUabfnrtv\\'"]+
hi def link     goEscapeOctal       goSpecialString
hi def link     goEscapeC           goSpecialString
hi def link     goEscapeX           goSpecialString
hi def link     goEscapeU           goSpecialString
hi def link     goEscapeBigU        goSpecialString
hi def link     goSpecialString     Special
hi def link     goEscapeError       Error
syn cluster     goStringGroup       contains=goEscapeOctal,goEscapeC,goEscapeX,goEscapeU,goEscapeBigU,goEscapeError
syn region      goString            start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=@goStringGroup
syn region      goRawString         start=+`+ end=+`+
hi def link     goString            String
hi def link     goRawString         String
syn cluster     goCharacterGroup    contains=goEscapeOctal,goEscapeC,goEscapeX,goEscapeU,goEscapeBigU
syn region      goCharacter         start=+'+ skip=+\\\\\|\\'+ end=+'+ contains=@goCharacterGroup
hi def link     goCharacter         Character
syn region      goBlock             start="{" end="}" transparent fold
syn region      goParen             start='(' end=')' transparent
syn match       goDecimalInt        "\<\d\+\([Ee]\d\+\)\?\>"
syn match       goHexadecimalInt    "\<0x\x\+\>"
syn match       goOctalInt          "\<0\o\+\>"
syn match       goOctalError        "\<0\o*[89]\d*\>"
hi def link     goDecimalInt        Integer
hi def link     goHexadecimalInt    Integer
hi def link     goOctalInt          Integer
hi def link     Integer             Number
syn match       goFloat             "\<\d\+\.\d*\([Ee][-+]\d\+\)\?\>"
syn match       goFloat             "\<\.\d\+\([Ee][-+]\d\+\)\?\>"
syn match       goFloat             "\<\d\+[Ee][-+]\d\+\>"
hi def link     goFloat             Float
syn match       goImaginary         "\<\d\+i\>"
syn match       goImaginary         "\<\d\+\.\d*\([Ee][-+]\d\+\)\?i\>"
syn match       goImaginary         "\<\.\d\+\([Ee][-+]\d\+\)\?i\>"
syn match       goImaginary         "\<\d\+[Ee][-+]\d\+i\>"
hi def link     goImaginary         Number
if go_highlight_array_whitespace_error != 0
syn match goSpaceError display "\(\[\]\)\@<=\s\+"
endif
if go_highlight_chan_whitespace_error != 0
syn match goSpaceError display "\(<-\)\@<=\s\+\(chan\>\)\@="
syn match goSpaceError display "\(\<chan\)\@<=\s\+\(<-\)\@="
syn match goSpaceError display "\(\(^\|[={(,;]\)\s*<-\)\@<=\s\+"
endif
if go_highlight_extra_types != 0
syn match goExtraType /\<bytes\.\(Buffer\)\>/
syn match goExtraType /\<io\.\(Reader\|Writer\|ReadWriter\|ReadWriteCloser\)\>/
syn match goExtraType /\<reflect\.\(Kind\|Type\|Value\)\>/
syn match goExtraType /\<unsafe\.Pointer\>/
endif
if go_highlight_space_tab_error != 0
syn match goSpaceError display " \+\t"me=e-1
endif
if go_highlight_trailing_whitespace_error != 0
syn match goSpaceError display excludenl "\s\+$"
endif
hi def link     goExtraType         Type
hi def link     goSpaceError        Error
syn sync minlines=500
let b:current_syntax = 'go'
