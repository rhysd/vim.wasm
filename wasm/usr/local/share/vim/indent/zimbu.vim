if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal ai nolisp nocin
setlocal indentexpr=GetZimbuIndent(v:lnum)
setlocal indentkeys=0{,0},!^F,o,O,0=ELSE,0=ELSEIF,0=CASE,0=DEFAULT,0=FINALLY
setlocal sw=2 et
let b:undo_indent = "setl et< sw< ai< indentkeys< indentexpr="
if exists("*GetZimbuIndent")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
let s:maxoff = 50	" maximum number of lines to look backwards for ()
func GetZimbuIndent(lnum)
let prevLnum = prevnonblank(a:lnum - 1)
if prevLnum == 0
return 0
endif
call cursor(prevLnum, 1)
let parlnum = searchpair('(\|{\|\[', '', ')\|}\|\]', 'nbW',
\ "line('.') < " . (prevLnum - s:maxoff) . " ? dummy :"
\ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
\ . " =~ '\\(Comment\\|String\\|Char\\)$'")
if parlnum > 0
let plindent = indent(parlnum)
let plnumstart = parlnum
else
let plindent = indent(prevLnum)
let plnumstart = prevLnum
endif
call cursor(a:lnum, 1)
let p = searchpair('(\|{\|\[', '', ')\|}\|\]', 'bW',
\ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :"
\ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
\ . " =~ '\\(Comment\\|String\\|Char\\)$'")
if p > 0
if p == prevLnum
let pp = searchpair('(\|{\|\[', '', ')\|}\|\]', 'bW',
\ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :"
\ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
\ . " =~ '\\(Comment\\|String\\|Char\\)$'")
if pp > 0
return indent(prevLnum) + shiftwidth()
endif
return indent(prevLnum) + shiftwidth() * 2
endif
if plnumstart == p
return indent(prevLnum)
endif
return plindent
endif
let prevline = getline(prevLnum)
let thisline = getline(a:lnum)
if thisline !~ '^\s*#'
while prevline =~ '^\s*#'
let prevLnum = prevnonblank(prevLnum - 1)
if prevLnum == 0
return 0
endif
let prevline = getline(prevLnum)
let plindent = indent(prevLnum)
endwhile
endif
if prevline =~ '^\s*\(IF\|\|ELSEIF\|ELSE\|GENERATE_IF\|\|GENERATE_ELSEIF\|GENERATE_ELSE\|WHILE\|REPEAT\|TRY\|CATCH\|FINALLY\|FOR\|DO\|SWITCH\|CASE\|DEFAULT\|FUNC\|VIRTUAL\|ABSTRACT\|DEFINE\|REPLACE\|FINAL\|PROC\|MAIN\|NEW\|ENUM\|CLASS\|INTERFACE\|BITS\|MODULE\|SHARED\)\>'
let plindent += shiftwidth()
endif
if thisline =~ '^\s*\(}\|ELSEIF\>\|ELSE\>\|CATCH\|FINALLY\|GENERATE_ELSEIF\>\|GENERATE_ELSE\>\|UNTIL\>\)'
let plindent -= shiftwidth()
endif
if thisline =~ '^\s*\(CASE\>\|DEFAULT\>\)' && prevline !~ '^\s*SWITCH\>'
let plindent -= shiftwidth()
endif
if a:lnum == prevLnum + 1 && thisline =~ '^\s*#' && prevline !~ '^\s*#'
let n = match(prevline, '#')
if n > 1
let plindent = n
endif
endif
return plindent
endfunc
let &cpo = s:cpo_save
unlet s:cpo_save
