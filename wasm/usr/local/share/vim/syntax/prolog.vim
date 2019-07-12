if exists("b:current_syntax")
finish
endif
syn case match
syn region   prologCComment start=+/\*+ end=+\*/+
syn match    prologComment  +%.*+
syn keyword  prologKeyword  module meta_predicate multifile dynamic
syn match    prologCharCode +0'\\\=.+
syn region   prologString   start=+"+ skip=+\\\\\|\\"+ end=+"+
syn region   prologAtom     start=+'+ skip=+\\\\\|\\'+ end=+'+
syn region   prologClause   matchgroup=prologClauseHead start=+^\s*[a-z]\w*+ matchgroup=Normal end=+\.\s\|\.$+ contains=ALLBUT,prologClause
if !exists("prolog_highlighting_clean")
syn keyword prologKeyword   abolish current_output  peek_code
syn keyword prologKeyword   append  current_predicate       put_byte
syn keyword prologKeyword   arg     current_prolog_flag     put_char
syn keyword prologKeyword   asserta fail    put_code
syn keyword prologKeyword   assertz findall read
syn keyword prologKeyword   at_end_of_stream        float   read_term
syn keyword prologKeyword   atom    flush_output    repeat
syn keyword prologKeyword   atom_chars      functor retract
syn keyword prologKeyword   atom_codes      get_byte        set_input
syn keyword prologKeyword   atom_concat     get_char        set_output
syn keyword prologKeyword   atom_length     get_code        set_prolog_flag
syn keyword prologKeyword   atomic  halt    set_stream_position
syn keyword prologKeyword   bagof   integer setof
syn keyword prologKeyword   call    is      stream_property
syn keyword prologKeyword   catch   nl      sub_atom
syn keyword prologKeyword   char_code       nonvar  throw
syn keyword prologKeyword   char_conversion number  true
syn keyword prologKeyword   clause  number_chars    unify_with_occurs_check
syn keyword prologKeyword   close   number_codes    var
syn keyword prologKeyword   compound        once    write
syn keyword prologKeyword   copy_term       op      write_canonical
syn keyword prologKeyword   current_char_conversion open    write_term
syn keyword prologKeyword   current_input   peek_byte       writeq
syn keyword prologKeyword   current_op      peek_char
syn match   prologOperator "=\\=\|=:=\|\\==\|=<\|==\|>=\|\\=\|\\+\|<\|>\|="
syn match   prologAsIs     "===\|\\===\|<=\|=>"
syn match   prologNumber            "\<[0123456789]*\>'\@!"
syn match   prologCommentError      "\*/"
syn match   prologSpecialCharacter  ";"
syn match   prologSpecialCharacter  "!"
syn match   prologSpecialCharacter  ":-"
syn match   prologSpecialCharacter  "-->"
syn match   prologQuestion          "?-.*\."  contains=prologNumber
endif
syn sync maxlines=50
hi def link prologComment          Comment
hi def link prologCComment         Comment
hi def link prologCharCode         Special
if exists ("prolog_highlighting_clean")
hi def link prologKeyword        Statement
hi def link prologClauseHead     Statement
hi def link prologClause Normal
else
hi def link prologKeyword        Keyword
hi def link prologClauseHead     Constant
hi def link prologClause Normal
hi def link prologQuestion       PreProc
hi def link prologSpecialCharacter Special
hi def link prologNumber         Number
hi def link prologAsIs           Normal
hi def link prologCommentError   Error
hi def link prologAtom           String
hi def link prologString         String
hi def link prologOperator       Operator
endif
let b:current_syntax = "prolog"
