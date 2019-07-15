if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal nosmartindent
setlocal noautoindent
setlocal indentexpr=GetNsisIndent(v:lnum)
setlocal indentkeys=!^F,o,O
setlocal indentkeys+==~${Else,=~${EndIf,=~${EndUnless,=~${AndIf,=~${AndUnless,=~${OrIf,=~${OrUnless,=~${Case,=~${Default,=~${EndSelect,=~${EndSwith,=~${Loop,=~${Next,=~${MementoSectionEnd,=~FunctionEnd,=~SectionEnd,=~SectionGroupEnd,=~PageExEnd,0=~!macroend,0=~!if,0=~!else,0=~!endif
if exists("*GetNsisIndent")
finish
endif
function! GetNsisIndent(lnum)
if getline(a:lnum - 1) =~ '\\$'
if a:lnum > 1 && getline(a:lnum - 2) =~ '\\$'
return indent(a:lnum - 1)
endif
return indent(a:lnum - 1) + shiftwidth() * 2
endif
let l:thisl = substitute(getline(a:lnum), '[;#].*$', '', '')
let l:preproc = l:thisl =~? '^\s*!\%(if\|else\|endif\)'
let l:prevlnum = a:lnum
while 1
let l:prevlnum = prevnonblank(l:prevlnum - 1)
if l:prevlnum == 0
return 0
endif
let l:prevl = substitute(getline(l:prevlnum), '[;#].*$', '', '')
let l:prevpreproc = l:prevl =~? '^\s*!\%(if\|else\|endif\)'
if l:preproc == l:prevpreproc && getline(l:prevlnum - 1) !~? '\\$'
break
endif
endwhile
let l:previ = indent(l:prevlnum)
let l:ind = l:previ
if l:preproc
if l:prevl =~? '^\s*!\%(if\%(\%(macro\)\?n\?def\)\?\|else\)\>'
let l:ind += shiftwidth()
endif
if l:thisl =~? '^\s*!\%(else\|endif\)\?\>'
let l:ind -= shiftwidth()
endif
return l:ind
endif
if l:prevl =~? '^\s*\%(\${\%(If\|IfNot\|Unless\|ElseIf\|ElseIfNot\|ElseUnless\|Else\|AndIf\|AndIfNot\|AndUnless\|OrIf\|OrIfNot\|OrUnless\|Select\|Case\|Case[2-5]\|CaseElse\|Default\|Switch\|Do\|DoWhile\|DoUntil\|For\|ForEach\|MementoSection\)}\|Function\>\|Section\>\|SectionGroup\|PageEx\>\|!macro\>\)'
let l:ind += shiftwidth()
endif
if l:thisl =~? '^\s*\%(\${\%(ElseIf\|ElseIfNot\|ElseUnless\|Else\|EndIf\|EndUnless\|AndIf\|AndIfNot\|AndUnless\|OrIf\|OrIfNot\|OrUnless\|Loop\|LoopWhile\|LoopUntil\|Next\|MementoSectionEnd\)\>}\?\|FunctionEnd\>\|SectionEnd\>\|SectionGroupEnd\|PageExEnd\>\|!macroend\>\)'
let l:ind -= shiftwidth()
elseif l:thisl =~? '^\s*\${\%(Case\|Case[2-5]\|CaseElse\|Default\)\>}\?'
if l:prevl !~? '^\s*\${\%(Select\|Switch\)}'
let l:ind -= shiftwidth()
endif
elseif l:thisl =~? '^\s*\${\%(EndSelect\|EndSwitch\)\>}\?'
if l:prevl =~? '^\s*\${\%(Select\|Switch\)}'
let l:ind -= shiftwidth()
else
let l:ind -= shiftwidth() * 2
endif
endif
return l:ind
endfunction
