if exists("b:current_syntax")
finish
endif
runtime syntax/rst.vim
unlet! b:current_syntax
syntax include @R syntax/r.vim
if exists("g:rrst_syn_hl_chunk")
syntax match rrstChunkDelim "^\.\. {r" contained
syntax match rrstChunkDelim "}$" contained
else
syntax match rrstChunkDelim "^\.\. {r .*}$" contained
endif
syntax match rrstChunkDelim "^\.\. \.\.$" contained
syntax region rrstChunk start="^\.\. {r.*}$" end="^\.\. \.\.$" contains=@R,rrstChunkDelim keepend transparent fold
syntax match rrstInlineDelim "`" contained
syntax match rrstInlineDelim ":r:" contained
syntax region rrstInline start=":r: *`" skip=/\\\\\|\\`/ end="`" contains=@R,rrstInlineDelim keepend
hi def link rrstChunkDelim Special
hi def link rrstInlineDelim Special
let b:current_syntax = "rrst"
