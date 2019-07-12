if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal cindent
let b:undo_indent = "setl cin<"
