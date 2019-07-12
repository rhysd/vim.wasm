if exists("b:current_syntax")
finish
endif
syntax case match
syn keyword cheetahKeyword contained if else unless elif for in not
syn keyword cheetahKeyword contained while repeat break continue pass end
syn keyword cheetahKeyword contained set del attr def global include raw echo
syn keyword cheetahKeyword contained import from extends implements
syn keyword cheetahKeyword contained assert raise try catch finally
syn keyword cheetahKeyword contained errorCatcher breakpoint silent cache filter
syn match   cheetahKeyword contained "\<compiler-settings\>"
syn match   cheetahPlaceHolder "$\(\*[0-9.]\+[wdhms]\?\*\|\*\)\?\h\w*\(\.\h\w*\)*" display
syn match   cheetahPlaceHolder "$\(\*[0-9.]\+[wdhms]\?\*\|\*\)\?{\h\w*\(\.\h\w*\)*}" display
syn match   cheetahDirective "^\s*#[^#].*$"  contains=cheetahPlaceHolder,cheetahKeyword,cheetahComment display
syn match   cheetahContinuation "\\$"
syn match   cheetahComment "##.*$" display
syn region  cheetahMultiLineComment start="#\*" end="\*#"
hi def link cheetahPlaceHolder Identifier
hi def link cheetahDirective PreCondit
hi def link cheetahKeyword Define
hi def link cheetahContinuation Special
hi def link cheetahComment Comment
hi def link cheetahMultiLineComment Comment
let b:current_syntax = "cheetah"
