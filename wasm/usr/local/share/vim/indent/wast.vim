if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=lispindent('.')
setlocal noautoindent nosmartindent
let b:undo_indent = "setl lisp< indentexpr<"
