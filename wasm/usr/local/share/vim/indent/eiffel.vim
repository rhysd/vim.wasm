if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetEiffelIndent()
setlocal nolisp
setlocal nosmartindent
setlocal nocindent
setlocal autoindent
setlocal comments=:--
setlocal indentkeys+==end,=else,=ensure,=require,=check,=loop,=until
setlocal indentkeys+==creation,=feature,=inherit,=class,=is,=redefine,=rename,=variant
setlocal indentkeys+==invariant,=do,=local,=export
let b:undo_indent = "setl smartindent< indentkeys< indentexpr< autoindent< comments< "
let s:trust_user_indent = '\(+\)\(\s*\(--\).*\)\=$'
let s:relative_indent = '^\s*\(deferred\|class\|feature\|creation\|inherit\|loop\|from\|across\|until\|if\|else\|elseif\|ensure\|require\|check\|do\|local\|invariant\|variant\|rename\|redefine\|do\|export\)\>'
let s:outdent = '^\s*\(else\|invariant\|variant\|do\|require\|until\|loop\|local\)\>'
let s:no_indent = '^\s*\(class\|feature\|creation\|inherit\)\>'
let s:single_dent = '^[^-]\+[[:alnum:]]\+ is\(\s*\(--\).*\)\=$'
let s:inheritance_dent = '\s*\(redefine\|rename\|export\)\>'
if exists("*GetEiffelIndent")
finish
endif
let s:keepcpo= &cpo
set cpo&vim
function GetEiffelIndent()
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
if getline(lnum) =~ s:trust_user_indent
return -1
endif
let ind = indent(lnum)
if getline(lnum) =~ s:relative_indent
let ind = ind + shiftwidth()
endif
if getline(v:lnum) =~ s:single_dent && getline(v:lnum) !~ s:relative_indent
\ && getline(v:lnum) !~ '\s*\<\(and\|or\|implies\)\>'
let ind = shiftwidth()
endif
if getline(v:lnum) =~ s:inheritance_dent
let ind = 2 * shiftwidth()
endif
if getline(lnum) =~ s:single_dent
let ind = ind + shiftwidth()
endif
if getline(v:lnum) =~ s:no_indent
let ind = 0
endif
if getline(v:lnum) =~ s:outdent && getline(v:lnum - 1) !~ s:single_dent
\ && getline(v:lnum - 1) !~ '^\s*do\>'
let ind = ind - shiftwidth()
endif
if getline(v:lnum) =~ '^\s*end\>'
let ind = ind - shiftwidth()
endif
if getline(v:lnum) =~ '^\s*end\>' && ind == shiftwidth()
let ind = 0
endif
return ind
endfunction
let &cpo = s:keepcpo
unlet s:keepcpo
