if exists("b:did_indent")
finish
endif
let b:did_indent = 1
let s:cposet=&cpoptions
set cpoptions&vim
setlocal indentkeys+==~end,=~case,=~if,=~else,=~do,=~where,=~elsewhere,=~select
setlocal indentkeys+==~endif,=~enddo,=~endwhere,=~endselect,=~elseif
setlocal indentkeys+==~type,=~interface,=~forall,=~associate,=~block,=~enum
setlocal indentkeys+==~endforall,=~endassociate,=~endblock,=~endenum
if exists("b:fortran_indent_more") || exists("g:fortran_indent_more")
setlocal indentkeys+==~function,=~subroutine,=~module,=~contains,=~program
setlocal indentkeys+==~endfunction,=~endsubroutine,=~endmodule
setlocal indentkeys+==~endprogram
endif
if !exists("b:fortran_fixed_source")
if exists("fortran_free_source")
let b:fortran_fixed_source = 0
elseif exists("fortran_fixed_source")
let b:fortran_fixed_source = 1
elseif expand("%:e") ==? "f\<90\|95\|03\|08\>"
let b:fortran_fixed_source = 0
elseif expand("%:e") ==? "f\|f77\|for"
let b:fortran_fixed_source = 1
else
let s:lmax = 500
if ( s:lmax > line("$") )
let s:lmax = line("$")
endif
let b:fortran_fixed_source = 1
let s:ln=1
while s:ln <= s:lmax
let s:test = strpart(getline(s:ln),0,5)
if s:test !~ '^[Cc*]' && s:test !~ '^ *[!#]' && s:test =~ '[^ 0-9\t]' && s:test !~ '^[ 0-9]*\t'
let b:fortran_fixed_source = 0
break
endif
let s:ln = s:ln + 1
endwhile
endif
endif
if (b:fortran_fixed_source == 1)
setlocal indentexpr=FortranGetFixedIndent()
if exists("*FortranGetFixedIndent")
finish
endif
else
setlocal indentexpr=FortranGetFreeIndent()
if exists("*FortranGetFreeIndent")
finish
endif
endif
function FortranGetIndent(lnum)
let ind = indent(a:lnum)
let prevline=getline(a:lnum)
let prevstat=substitute(prevline, '!.*$', '', '')
let prev2line=getline(a:lnum-1)
let prev2stat=substitute(prev2line, '!.*$', '', '')
if exists("b:fortran_do_enddo") || exists("g:fortran_do_enddo")
if prevstat =~? '^\s*\(\d\+\s\)\=\s*\(\a\w*\s*:\)\=\s*do\>'
let ind = ind + shiftwidth()
endif
if getline(v:lnum) =~? '^\s*\(\d\+\s\)\=\s*end\s*do\>'
let ind = ind - shiftwidth()
endif
endif
if prevstat =~? '^\s*\(case\|class\|else\|else\s*if\|else\s*where\)\>'
\ ||prevstat=~? '^\s*\(type\|interface\|associate\|enum\)\>'
\ ||prevstat=~?'^\s*\(\d\+\s\)\=\s*\(\a\w*\s*:\)\=\s*\(forall\|where\|block\)\>'
\ ||prevstat=~? '^\s*\(\d\+\s\)\=\s*\(\a\w*\s*:\)\=\s*if\>'
let ind = ind + shiftwidth()
if prevstat =~? '\<if\>' && prevstat !~? '\<then\>'
let ind = ind - shiftwidth()
endif
if prevstat =~? '^\s*type\s*('
let ind = ind - shiftwidth()
endif
endif
if !exists("b:fortran_indent_less") && !exists("g:fortran_indent_less")
let prefix='\(\(pure\|impure\|elemental\|recursive\)\s\+\)\{,2}'
let type='\(\(integer\|real\|double\s\+precision\|complex\|logical'
\.'\|character\|type\|class\)\s*\S*\s\+\)\='
if prevstat =~? '^\s*\(contains\|submodule\|program\)\>'
\ ||prevstat =~? '^\s*'.'module\>\(\s*\procedure\)\@!'
\ ||prevstat =~? '^\s*'.prefix.'subroutine\>'
\ ||prevstat =~? '^\s*'.prefix.type.'function\>'
\ ||prevstat =~? '^\s*'.type.prefix.'function\>'
let ind = ind + shiftwidth()
endif
if getline(v:lnum) =~? '^\s*contains\>'
\ ||getline(v:lnum)=~? '^\s*end\s*'
\ .'\(function\|subroutine\|module\|submodule\|program\)\>'
let ind = ind - shiftwidth()
endif
endif
if getline(v:lnum) =~? '^\s*\(\d\+\s\)\=\s*'
\. '\(else\|else\s*if\|else\s*where\|case\|class\|'
\. 'end\s*\(if\|where\|select\|interface\|'
\. 'type\|forall\|associate\|enum\|block\)\)\>'
let ind = ind - shiftwidth()
if prevstat =~? '\<select\s\+\(case\|type\)\>'
let ind = ind + shiftwidth()
endif
endif
if prevstat =~ '&\s*$' && prev2stat !~ '&\s*$'
let ind = ind + shiftwidth()
endif
if prevstat !~ '&\s*$' && prev2stat =~ '&\s*$' && prevstat !~? '\<then\>'
let ind = ind - shiftwidth()
endif
return ind
endfunction
function FortranGetFreeIndent()
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let ind=FortranGetIndent(lnum)
return ind
endfunction
function FortranGetFixedIndent()
let currline=getline(v:lnum)
if strpart(currline,0,6) =~ '[^ \t]'
let ind = indent(v:lnum)
return ind
endif
let lnum = v:lnum - 1
while lnum > 0
let prevline=getline(lnum)
if (prevline =~ "^[C*!]") || (prevline =~ "^\s*$")
\ || (strpart(prevline,5,1) !~ "[ 0]")
let lnum = lnum - 1
else
let test=strpart(prevline,0,5)
if test =~ "[0-9]"
let lnum = lnum - 1
else
break
endif
endif
endwhile
if lnum == 0
return 6
endif
let ind=FortranGetIndent(lnum)
return ind
endfunction
let &cpoptions=s:cposet
unlet s:cposet
