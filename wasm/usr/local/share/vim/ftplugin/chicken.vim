if !exists('b:did_scheme_ftplugin')
finish
endif
setl keywordprg=chicken-doc
setl lispwords+=and-let*
setl lispwords+=compiler-typecase
setl lispwords+=condition-case
setl lispwords+=define-compiler-syntax
setl lispwords+=define-constant
setl lispwords+=define-external
setl lispwords+=define-for-syntax
setl lispwords+=define-foreign-type
setl lispwords+=define-inline
setl lispwords+=define-location
setl lispwords+=define-record
setl lispwords+=define-record-printer
setl lispwords+=define-specialization
setl lispwords+=fluid-let
setl lispwords+=foreign-lambda*
setl lispwords+=foreign-primitive
setl lispwords+=foreign-safe-lambda*
setl lispwords+=functor
setl lispwords+=handle-exceptions
setl lispwords+=let-compiler-syntax
setl lispwords+=let-location
setl lispwords+=let-optionals
setl lispwords+=let-optionals*
setl lispwords+=letrec-values
setl lispwords+=match
setl lispwords+=match-let
setl lispwords+=match-let*
setl lispwords+=match-letrec
setl lispwords+=module
setl lispwords+=receive
setl lispwords+=set!-values
setl lispwords+=test-group
let b:undo_ftplugin = b:undo_ftplugin . ' keywordprg<'
if exists('g:loaded_matchit') && !exists('b:match_words')
let b:match_words = '#>:<#'
let b:undo_ftplugin = b:undo_ftplugin . ' | unlet! b:match_words'
endif
