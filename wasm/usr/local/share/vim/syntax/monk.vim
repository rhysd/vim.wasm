if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn case ignore
syn match	monkError	oneline    ![^ \t()";]*!
syn match	monkError	oneline    ")"
syn region monkQuoted matchgroup=Delimiter start="['`]" end=![ \t()";]!me=e-1 contains=ALLBUT,monkStruc,monkSyntax,monkFunc
syn region monkQuoted matchgroup=Delimiter start="['`](" matchgroup=Delimiter end=")" contains=ALLBUT,monkStruc,monkSyntax,monkFunc
syn region monkQuoted matchgroup=Delimiter start="['`]#(" matchgroup=Delimiter end=")" contains=ALLBUT,monkStruc,monkSyntax,monkFunc
syn region monkStrucRestricted matchgroup=Delimiter start="(" matchgroup=Delimiter end=")" contains=ALLBUT,monkStruc,monkSyntax,monkFunc
syn region monkStrucRestricted matchgroup=Delimiter start="#(" matchgroup=Delimiter end=")" contains=ALLBUT,monkStruc,monkSyntax,monkFunc
syn region monkUnquote matchgroup=Delimiter start="," end=![ \t()";]!me=e-1 contains=ALLBUT,monkStruc,monkSyntax,monkFunc
syn region monkUnquote matchgroup=Delimiter start=",@" end=![ \t()";]!me=e-1 contains=ALLBUT,monkStruc,monkSyntax,monkFunc
syn region monkUnquote matchgroup=Delimiter start=",(" end=")" contains=ALLBUT,monkStruc,monkSyntax,monkFunc
syn region monkUnquote matchgroup=Delimiter start=",@(" end=")" contains=ALLBUT,monkStruc,monkSyntax,monkFunc
syn region monkUnquote matchgroup=Delimiter start=",#(" end=")" contains=ALLBUT,monkStruc,monkSyntax,monkFunc
syn region monkUnquote matchgroup=Delimiter start=",@#(" end=")" contains=ALLBUT,monkStruc,monkSyntax,monkFunc
setlocal iskeyword=33,35-39,42-58,60-90,94,95,97-122,126,_
syn keyword monkSyntax lambda and or if cond case define let let* letrec
syn keyword monkSyntax begin do delay set! else =>
syn keyword monkSyntax quote quasiquote unquote unquote-splicing
syn keyword monkSyntax define-syntax let-syntax letrec-syntax syntax-rules
syn keyword monkFunc not boolean? eq? eqv? equal? pair? cons car cdr set-car!
syn keyword monkFunc set-cdr! caar cadr cdar cddr caaar caadr cadar caddr
syn keyword monkFunc cdaar cdadr cddar cdddr caaaar caaadr caadar caaddr
syn keyword monkFunc cadaar cadadr caddar cadddr cdaaar cdaadr cdadar cdaddr
syn keyword monkFunc cddaar cddadr cdddar cddddr null? list? list length
syn keyword monkFunc append reverse list-ref memq memv member assq assv assoc
syn keyword monkFunc symbol? symbol->string string->symbol number? complex?
syn keyword monkFunc real? rational? integer? exact? inexact? = < > <= >=
syn keyword monkFunc zero? positive? negative? odd? even? max min + * - / abs
syn keyword monkFunc quotient remainder modulo gcd lcm numerator denominator
syn keyword monkFunc floor ceiling truncate round rationalize exp log sin cos
syn keyword monkFunc tan asin acos atan sqrt expt make-rectangular make-polar
syn keyword monkFunc real-part imag-part magnitude angle exact->inexact
syn keyword monkFunc inexact->exact number->string string->number char=?
syn keyword monkFunc char-ci=? char<? char-ci<? char>? char-ci>? char<=?
syn keyword monkFunc char-ci<=? char>=? char-ci>=? char-alphabetic? char?
syn keyword monkFunc char-numeric? char-whitespace? char-upper-case?
syn keyword monkFunc char-lower-case?
syn keyword monkFunc char->integer integer->char char-upcase char-downcase
syn keyword monkFunc string? make-string string string-length string-ref
syn keyword monkFunc string-set! string=? string-ci=? string<? string-ci<?
syn keyword monkFunc string>? string-ci>? string<=? string-ci<=? string>=?
syn keyword monkFunc string-ci>=? substring string-append vector? make-vector
syn keyword monkFunc vector vector-length vector-ref vector-set! procedure?
syn keyword monkFunc apply map for-each call-with-current-continuation
syn keyword monkFunc call-with-input-file call-with-output-file input-port?
syn keyword monkFunc output-port? current-input-port current-output-port
syn keyword monkFunc open-input-file open-output-file close-input-port
syn keyword monkFunc close-output-port eof-object? read read-char peek-char
syn keyword monkFunc write display newline write-char call/cc
syn keyword monkFunc list-tail string->list list->string string-copy
syn keyword monkFunc string-fill! vector->list list->vector vector-fill!
syn keyword monkFunc force with-input-from-file with-output-to-file
syn keyword monkFunc char-ready? load transcript-on transcript-off eval
syn keyword monkFunc dynamic-wind port? values call-with-values
syn keyword monkFunc monk-report-environment null-environment
syn keyword monkFunc interaction-environment
syn keyword monkFunc $event-clear $event-parse $event->string $make-event-map
syn keyword monkFunc $resolve-event-definition change-pattern copy copy-strip
syn keyword monkFunc count-data-children count-map-children count-rep data-map
syn keyword monkFunc duplicate duplicate-strip file-check file-lookup get
syn keyword monkFunc insert list-lookup node-has-data? not-verify path?
syn keyword monkFunc path-defined-as-repeating? path-nodeclear path-nodedepth
syn keyword monkFunc path-nodename path-nodeparentname path->string path-valid?
syn keyword monkFunc regex string->path timestamp uniqueid verify
syn keyword monkFunc allcap? capitalize char-punctuation? char-substitute
syn keyword monkFunc char-to-char conv count-used-children degc->degf
syn keyword monkFunc diff-two-dates display-error empty-string? fail_id
syn keyword monkFunc fail_id_if fail_translation fail_translation_if
syn keyword monkFunc find-get-after find-get-before get-timestamp julian-date?
syn keyword monkFunc julian->standard leap-year? map-string not-empty-string?
syn keyword monkFunc standard-date? standard->julian string-begins-with?
syn keyword monkFunc string-contains? string-ends-with? string-search-from-left
syn keyword monkFunc string-search-from-right string->ssn strip-punct
syn keyword monkFunc strip-string substring=? symbol-table-get symbol-table-put
syn keyword monkFunc trim-string-left trim-string-right valid-decimal?
syn keyword monkFunc valid-integer? verify-type
syn match	monkNumber	oneline    "[-#+0-9.][-#+/0-9a-f@i.boxesfdl]*"
syn match	monkError	oneline    ![-#+0-9.][-#+/0-9a-f@i.boxesfdl]*[^-#+/0-9a-f@i.boxesfdl \t()";][^ \t()";]*!
syn match	monkOther	oneline    ![+-][ \t()";]!me=e-1
syn match	monkOther	oneline    ![+-]$!
syn match	monkDelimiter	oneline    !\.[ \t()";]!me=e-1
syn match	monkDelimiter	oneline    !\.$!
syn match	monkBoolean	oneline    "#[tf]"
syn match	monkError	oneline    !#[tf][^ \t()";]\+!
syn match	monkChar	oneline    "#\\"
syn match	monkChar	oneline    "#\\."
syn match	monkError	oneline    !#\\.[^ \t()";]\+!
syn match	monkChar	oneline    "#\\space"
syn match	monkError	oneline    !#\\space[^ \t()";]\+!
syn match	monkChar	oneline    "#\\newline"
syn match	monkError	oneline    !#\\newline[^ \t()";]\+!
syn match	monkOther	oneline    ,[a-z!$%&*/:<=>?^_~][-a-z!$%&*/:<=>?^_~0-9+.@]*,
syn match	monkError	oneline    ,[a-z!$%&*/:<=>?^_~][-a-z!$%&*/:<=>?^_~0-9+.@]*[^-a-z!$%&*/:<=>?^_~0-9+.@ \t()";]\+[^ \t()";]*,
syn match	monkOther	oneline    "\.\.\."
syn match	monkError	oneline    !\.\.\.[^ \t()";]\+!
syn match	monkConstant	oneline    ,\*[-a-z!$%&*/:<=>?^_~0-9+.@]*\*[ \t()";],me=e-1
syn match	monkConstant	oneline    ,\*[-a-z!$%&*/:<=>?^_~0-9+.@]*\*$,
syn match	monkError	oneline    ,\*[-a-z!$%&*/:<=>?^_~0-9+.@]*\*[^-a-z!$%&*/:<=>?^_~0-9+.@ \t()";]\+[^ \t()";]*,
syn match	monkConstant	oneline    ,<[-a-z!$%&*/:<=>?^_~0-9+.@]*>[ \t()";],me=e-1
syn match	monkConstant	oneline    ,<[-a-z!$%&*/:<=>?^_~0-9+.@]*>$,
syn match	monkError	oneline    ,<[-a-z!$%&*/:<=>?^_~0-9+.@]*>[^-a-z!$%&*/:<=>?^_~0-9+.@ \t()";]\+[^ \t()";]*,
syn match	monkSyntax	oneline    "\(\~input\|\[I\]->\)[^ \t]*"
syn match	monkFunc	oneline    "\(\~output\|\[O\]->\)[^ \t]*"
syn region monkStruc matchgroup=Delimiter start="(" matchgroup=Delimiter end=")" contains=ALL
syn region monkStruc matchgroup=Delimiter start="#(" matchgroup=Delimiter end=")" contains=ALL
syn region	monkString	start=+"+  skip=+\\[\\"]+ end=+"+
syn match	monkComment	";.*$"
syn sync match matchPlace grouphere NONE "^[^ \t]"
hi def link monkSyntax		Statement
hi def link monkFunc		Function
hi def link monkString		String
hi def link monkChar		Character
hi def link monkNumber		Number
hi def link monkBoolean		Boolean
hi def link monkDelimiter	Delimiter
hi def link monkConstant	Constant
hi def link monkComment		Comment
hi def link monkError		Error
let b:current_syntax = "monk"
let &cpo = s:cpo_save
unlet s:cpo_save
