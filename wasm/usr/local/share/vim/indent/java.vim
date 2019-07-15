if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal cindent cinoptions& cinoptions+=j1
setlocal indentkeys& indentkeys+=0=extends indentkeys+=0=implements
setlocal indentexpr=GetJavaIndent()
let b:undo_indent = "set cin< cino< indentkeys< indentexpr<"
if exists("*GetJavaIndent")
finish
endif
let s:keepcpo= &cpo
set cpo&vim
function! SkipJavaBlanksAndComments(startline)
let lnum = a:startline
while lnum > 1
let lnum = prevnonblank(lnum)
if getline(lnum) =~ '\*/\s*$'
while getline(lnum) !~ '/\*' && lnum > 1
let lnum = lnum - 1
endwhile
if getline(lnum) =~ '^\s*/\*'
let lnum = lnum - 1
else
break
endif
elseif getline(lnum) =~ '^\s*//'
let lnum = lnum - 1
else
break
endif
endwhile
return lnum
endfunction
function GetJavaIndent()
let theIndent = cindent(v:lnum)
if getline(v:lnum) =~ '^\s*\*'
return theIndent
endif
let lnum = SkipJavaBlanksAndComments(v:lnum - 1)
if getline(lnum) =~ '^\s*@.*$'
return indent(lnum)
endif
let prev = lnum
while prev > 1
let next_prev = SkipJavaBlanksAndComments(prev - 1)
if getline(next_prev) !~ ',\s*$'
break
endif
let prev = next_prev
endwhile
if getline(v:lnum) =~ '^\s*\(throws\|extends\|implements\)\>'
\ && getline(lnum) !~ '^\s*\(throws\|extends\|implements\)\>'
let theIndent = theIndent + shiftwidth()
endif
let cont_kw = matchstr(getline(prev),
\ '^\s*\zs\(throws\|implements\|extends\)\>\ze.*,\s*$')
if strlen(cont_kw) > 0
let amount = strlen(cont_kw) + 1
if getline(lnum) !~ ',\s*$'
let theIndent = theIndent - (amount + shiftwidth())
if theIndent < 0
let theIndent = 0
endif
elseif prev == lnum
let theIndent = theIndent + amount
if cont_kw ==# 'throws'
let theIndent = theIndent + shiftwidth()
endif
endif
elseif getline(prev) =~ '^\s*\(throws\|implements\|extends\)\>'
\ && (getline(prev) =~ '{\s*$'
\  || getline(v:lnum) =~ '^\s*{\s*$')
let theIndent = theIndent - shiftwidth()
endif
if getline(v:lnum) =~ '^\s*}\s*\(//.*\|/\*.*\)\=$'
call cursor(v:lnum, 1)
silent normal! %
let lnum = line('.')
if lnum < v:lnum
while lnum > 1
let next_lnum = SkipJavaBlanksAndComments(lnum - 1)
if getline(lnum) !~ '^\s*\(throws\|extends\|implements\)\>'
\ && getline(next_lnum) !~ ',\s*$'
break
endif
let lnum = prevnonblank(next_lnum)
endwhile
return indent(lnum)
endif
endif
let lnum = SkipJavaBlanksAndComments(v:lnum - 1)
if getline(lnum) =~ '^\s*}\s*\(//.*\|/\*.*\)\=$' && indent(lnum) < theIndent
let theIndent = indent(lnum)
endif
return theIndent
endfunction
let &cpo = s:keepcpo
unlet s:keepcpo
