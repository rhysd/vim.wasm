if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal cindent
setlocal cinwords=""
setlocal cinoptions+=+0
setlocal cinoptions+=p0
setlocal cinoptions+=i0
setlocal cinoptions+=t0
setlocal cinoptions+=*500
let b:undo_indent = "setl cin< cino< cinw<"
