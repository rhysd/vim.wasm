if exists("b:did_indent")
finish
endif
let b:did_indent     = 1
let b:current_indent = "sqlanywhere"
setlocal indentkeys-=0{
setlocal indentkeys-=0}
setlocal indentkeys-=:
setlocal indentkeys-=0#
setlocal indentkeys-=e
setlocal indentkeys+==~end,=~else,=~elseif,=~elsif,0=~when,0=)
setlocal indentexpr=GetSQLIndent()
if exists("*GetSQLIndent")
finish
endif
let s:keepcpo= &cpo
set cpo&vim
let s:SQLBlockStart = '^\s*\%('.
\ 'if\|else\|elseif\|elsif\|'.
\ 'while\|loop\|do\|for\|'.
\ 'begin\|'.
\ 'case\|when\|merge\|exception'.
\ '\)\>'
let s:SQLBlockEnd = '^\s*\(end\)\>'
function! s:CountUnbalancedParan( line, paran_to_check )
let l = a:line
let lp = substitute(l, '[^(]', '', 'g')
let l = a:line
let rp = substitute(l, '[^)]', '', 'g')
if a:paran_to_check =~ ')'
return (strlen(rp) - strlen(lp))
elseif a:paran_to_check =~ '('
return (strlen(lp) - strlen(rp))
else
return 0
endif
endfunction
function! s:CheckToIgnoreRightParan( prev_lnum, num_levels )
let lnum = a:prev_lnum
let line = getline(lnum)
let ends = 0
let num_right_paran = a:num_levels
let ignore_paran = 0
let vircol = 1
while num_right_paran > 0
silent! exec 'norm! '.lnum."G\<bar>".vircol."\<bar>"
let right_paran = search( ')', 'W' )
if right_paran != lnum
break
endif
let vircol      = virtcol(".")
let matching_paran = searchpair('(', '', ')', 'bW',
\ 's:IsColComment(line("."), col("."))')
if matching_paran < 1
break
endif
if matching_paran == lnum
continue
endif
if getline(matching_paran) =~? '\(if\|while\)\>'
let ignore_paran = ignore_paran + 1
endif
let num_right_paran = num_right_paran - 1
endwhile
return ignore_paran
endfunction
function! s:GetStmtStarterIndent( keyword, curr_lnum )
let lnum  = a:curr_lnum
let ind = indent(a:curr_lnum) - shiftwidth()
if a:keyword =~? 'end'
exec 'normal! ^'
let stmts = '^\s*\%('.
\ '\<begin\>\|' .
\ '\%(\%(\<end\s\+\)\@<!\<loop\>\)\|' .
\ '\%(\%(\<end\s\+\)\@<!\<case\>\)\|' .
\ '\%(\%(\<end\s\+\)\@<!\<for\>\)\|' .
\ '\%(\%(\<end\s\+\)\@<!\<if\>\)'.
\ '\)'
let matching_lnum = searchpair(stmts, '', '\<end\>\zs', 'bW',
\ 's:IsColComment(line("."), col(".")) == 1')
exec 'normal! $'
if matching_lnum > 0 && matching_lnum < a:curr_lnum
let ind = indent(matching_lnum)
endif
elseif a:keyword =~? 'when'
exec 'normal! ^'
let matching_lnum = searchpair(
\ '\%(\<end\s\+\)\@<!\<case\>\|\<exception\>\|\<merge\>',
\ '',
\ '\%(\%(\<when\s\+others\>\)\|\%(\<end\s\+case\>\)\)',
\ 'bW',
\ 's:IsColComment(line("."), col(".")) == 1')
exec 'normal! $'
if matching_lnum > 0 && matching_lnum < a:curr_lnum
let ind = indent(matching_lnum)
else
let ind = indent(a:curr_lnum)
endif
endif
return ind
endfunction
function! s:IsLineComment(lnum)
let rc = synIDattr(
\ synID(a:lnum,
\     match(getline(a:lnum), '\S')+1, 0)
\ , "name")
\ =~? "comment"
return rc
endfunction
function! s:IsColComment(lnum, cnum)
let rc = synIDattr(synID(a:lnum, a:cnum, 0), "name")
\           =~? "comment"
return rc
endfunction
function! s:ModuloIndent(ind)
let ind = a:ind
if ind > 0
let modulo = ind % shiftwidth()
if modulo > 0
let ind = ind - modulo
endif
endif
return ind
endfunction
function! GetSQLIndent()
let lnum = v:lnum
let ind = indent(lnum)
let prevlnum = prevnonblank(lnum - 1)
if prevlnum <= 0
return ind
endif
if s:IsLineComment(prevlnum) == 1
if getline(v:lnum) =~ '^\s*\*'
let ind = s:ModuloIndent(indent(prevlnum))
return ind + 1
endif
if getline(v:lnum) =~ '^\s*$'
return -1
endif
endif
let ind      = indent(prevlnum)
let prevline = getline(prevlnum)
if prevline =~? s:SQLBlockStart
let ind = ind + shiftwidth()
elseif prevline =~ '[()]'
if prevline =~ '('
let num_unmatched_left = s:CountUnbalancedParan( prevline, '(' )
else
let num_unmatched_left = 0
endif
if prevline =~ ')'
let num_unmatched_right  = s:CountUnbalancedParan( prevline, ')' )
else
let num_unmatched_right  = 0
endif
if num_unmatched_left > 0
let ind = ind + ( shiftwidth() * num_unmatched_left )
elseif num_unmatched_right > 0
let ignore = s:CheckToIgnoreRightParan( prevlnum, num_unmatched_right )
if prevline =~ '^\s*)'
let ignore = ignore + 1
endif
if (num_unmatched_right - ignore) > 0
let ind = ind - ( shiftwidth() * (num_unmatched_right - ignore) )
endif
endif
endif
let line = getline(v:lnum)
if line =~? '^\s*els'
let ind = ind - shiftwidth()
elseif line =~? '^\s*end\>'
let ind = s:GetStmtStarterIndent('end', v:lnum)
elseif line =~? '^\s*when\>'
let ind = s:GetStmtStarterIndent('when', v:lnum)
elseif line =~ '^\s*)'
let num_unmatched_right  = s:CountUnbalancedParan( line, ')' )
let ignore = s:CheckToIgnoreRightParan( v:lnum, num_unmatched_right )
if line =~ '^\s*)'
endif
if (num_unmatched_right - ignore) > 0
let ind = ind - ( shiftwidth() * (num_unmatched_right - ignore) )
endif
endif
return s:ModuloIndent(ind)
endfunction
let &cpo= s:keepcpo
unlet s:keepcpo
