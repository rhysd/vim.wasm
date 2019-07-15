if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn cluster wastCluster       contains=wastModule,wastInstWithType,wastInstGeneral,wastParamInst,wastControlInst,wastString,wastNamedVar,wastUnnamedVar,wastFloat,wastNumber,wastComment,wastList,wastType
syn match   wastInstWithType  "\%((\s*\)\@<=\<\%(i32\|i64\|f32\|f64\|memory\)\.[[:alnum:]_]\+\%(/\%(i32\|i64\|f32\|f64\)\)\=\>\%(\s\+\%(align\|offset\)=\)\=" contained display
syn match   wastInstGeneral   "\%((\s*\)\@<=\<[[:alnum:]_]\+\>" contained display
syn match   wastControlInst   "\%((\s*\)\@<=\<\%(block\|end\|loop\|if\|else\|unreachable\|nop\|br\|br_if\|br_table\|return\|call\|call_indirect\)\>" contained display
syn match   wastParamInst     "\%((\s*\)\@<=\<\%(drop\|select\)\>" contained display
syn match   wastNamedVar      "$\+[[:alnum:]!#$%&'∗./:=><?@\\^_`~+-]*" contained display
syn match   wastUnnamedVar    "$\+\d\+[[:alnum:]!#$%&'∗./:=><?@\\^_`~+-]\@!" contained display
syn region  wastString        start=+"+ skip=+\\\\\|\\"+ end=+"+ contained contains=wastStringSpecial
syn match   wastStringSpecial "\\\x\x\|\\[tnr'\\\"]\|\\u\x\+" contained containedin=wastString
syn match   wastFloat         "\<-\=\d\%(_\=\d\)*\%(\.\d\%(_\=\d\)*\)\=\%([eE][-+]\=\d\%(_\=\d\)*\)\=" display contained
syn match   wastFloat         "\<-\=0x\x\%(_\=\d\)*\%(\.\x\%(_\=\x\)*\)\=\%([pP][-+]\=\d\%(_\=\d\)*\)\=" display contained
syn keyword wastFloat         inf nan contained
syn match   wastNumber        "\<-\=\d\%(_\=\d\)*\>" display contained
syn match   wastNumber        "\<-\=0x\x\%(_\=\x\)*\>" display contained
syn region  wastComment       start=";;" end="$" display
syn region  wastComment       start="(;;\@!" end=";)"
syn region  wastList          matchgroup=wastListDelimiter start="(;\@!" matchgroup=wastListDelimiter end=";\@<!)" contains=@wastCluster
syn keyword wastType          i64 i32 f64 f32 param result anyfunc mut contained
syn match   wastType          "\%((\_s*\)\@<=func\%(\_s*[()]\)\@=" display contained
syn keyword wastModule        module type export import table memory global data elem contained
syn match   wastModule        "\%((\_s*\)\@<=func\%(\_s\+\$\)\@=" display contained
syn sync lines=100
hi def link wastModule        PreProc
hi def link wastListDelimiter Delimiter
hi def link wastInstWithType  Operator
hi def link wastInstGeneral   Operator
hi def link wastControlInst   Statement
hi def link wastParamInst     Conditional
hi def link wastString        String
hi def link wastStringSpecial Special
hi def link wastNamedVar      Identifier
hi def link wastUnnamedVar    PreProc
hi def link wastFloat         Float
hi def link wastNumber        Number
hi def link wastComment       Comment
hi def link wastType          Type
let b:current_syntax = "wast"
let &cpo = s:cpo_save
unlet s:cpo_save
