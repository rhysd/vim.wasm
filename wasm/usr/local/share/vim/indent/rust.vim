if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal cindent
setlocal cinoptions=L0,(0,Ws,J1,j1
setlocal cinkeys=0{,0},!^F,o,O,0[,0]
setlocal cinwords=for,if,else,while,loop,impl,mod,unsafe,trait,struct,enum,fn,extern
setlocal nolisp		" Make sure lisp indenting doesn't supersede us
setlocal autoindent	" indentexpr isn't much help otherwise
setlocal indentkeys=0{,0},!^F,o,O,0[,0]
setlocal indentexpr=GetRustIndent(v:lnum)
if exists("*GetRustIndent")
finish
endif
let s:save_cpo = &cpo
set cpo&vim
function! s:get_line_trimmed(lnum)
let line = getline(a:lnum)
let line_len = strlen(line)
if has('syntax_items')
if synIDattr(synID(a:lnum, line_len, 1), "name") =~ 'Comment\|Todo'
let min = 1
let max = line_len
while min < max
let col = (min + max) / 2
if synIDattr(synID(a:lnum, col, 1), "name") =~ 'Comment\|Todo'
let max = col
else
let min = col + 1
endif
endwhile
let line = strpart(line, 0, min - 1)
endif
return substitute(line, "\s*$", "", "")
else
return substitute(line, "\s*//.*$", "", "")
endif
endfunction
function! s:is_string_comment(lnum, col)
if has('syntax_items')
for id in synstack(a:lnum, a:col)
let synname = synIDattr(id, "name")
if synname == "rustString" || synname =~ "^rustComment"
return 1
endif
endfor
else
return 0
endif
endfunction
function GetRustIndent(lnum)
let line = getline(a:lnum)
if has('syntax_items')
let synname = synIDattr(synID(a:lnum, 1, 1), "name")
if synname == "rustString"
return -1
elseif synname =~ '\(Comment\|Todo\)'
\ && line !~ '^\s*/\*'  " not /* opening line
if synname =~ "CommentML" " multi-line
if line !~ '^\s*\*' && getline(a:lnum - 1) =~ '^\s*/\*'
return GetRustIndent(a:lnum - 1)
endif
endif
return cindent(a:lnum)
endif
endif
let prevlinenum = prevnonblank(a:lnum - 1)
let prevline = s:get_line_trimmed(prevlinenum)
while prevlinenum > 1 && prevline !~ '[^[:blank:]]'
let prevlinenum = prevnonblank(prevlinenum - 1)
let prevline = s:get_line_trimmed(prevlinenum)
endwhile
if prevline[len(prevline) - 1] == ","
\ && prevline =~# '^\s*where\s'
return indent(prevlinenum) + 6
endif
if prevline[len(prevline) - 1] == ","
\ && s:get_line_trimmed(a:lnum) !~ '^\s*[\[\]{}]'
\ && prevline !~ '^\s*fn\s'
\ && prevline !~ '([^()]\+,$'
\ && s:get_line_trimmed(a:lnum) !~ '^\s*\S\+\s*=>'
return indent(prevlinenum)
endif
if !has("patch-7.4.355")
call cursor(a:lnum, 1)
if searchpair('{\|(', '', '}\|)', 'nbW',
\ 's:is_string_comment(line("."), col("."))') == 0
if searchpair('\[', '', '\]', 'nbW',
\ 's:is_string_comment(line("."), col("."))') == 0
return 0
else
if line =~ "^\\s*]"
return 0
else
return shiftwidth()
endif
endif
endif
endif
return cindent(a:lnum)
endfunction
let &cpo = s:save_cpo
unlet s:save_cpo
