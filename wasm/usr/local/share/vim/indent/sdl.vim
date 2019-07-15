if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetSDLIndent()
setlocal indentkeys+==~end,=~state,*<Return>
if exists("*GetSDLIndent")
endif
let s:cpo_save = &cpo
set cpo&vim
function! GetSDLIndent()
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let ind = indent(lnum)
let virtuality = '^\s*\(\(virtual\|redefined\|finalized\)\s\+\)\=\s*'
if getline(lnum) =~ '^\s*\*'
let ind = ind - 1
endif
if getline(v:lnum) =~ '^\s*\*'
let ind = ind + 1
endif
if (getline(lnum) =~? '^\s*\(start\|state\|system\|package\|connection\|channel\|alternative\|macro\|operator\|newtype\|select\|substructure\|decision\|generator\|refinement\|service\|method\|exceptionhandler\|asntype\|syntype\|value\|(.*):\|\(priority\s\+\)\=input\|provided\)'
\ || getline(lnum) =~? virtuality . '\(process\|procedure\|block\|object\)')
\ && getline(lnum) !~? 'end[[:alpha:]]\+;$'
let ind = ind + shiftwidth()
endif
if getline(lnum) =~? '^\s*\(stop\|return\>\|nextstate\)'
let ind = ind - shiftwidth()
endif
if getline(v:lnum) =~? '^\s*end\>'
let ind = ind - shiftwidth()
endif
if getline(v:lnum) =~? '^\s*\((.*)\|else\):'
normal k
let ind = indent(searchpair('^\s*decision', '', '^\s*enddecision', 'bW',
\ 'synIDattr(synID(line("."), col("."), 0), "name") =~? "sdlString"'))
endif
if getline(v:lnum) =~? '^\s*state\>'
let ind = indent(search('^\s*start', 'bW'))
endif
if getline(v:lnum) =~? '^\s*\(\(end\)\=system\|\(end\)\=package\)'
return 0
endif
if getline(v:lnum) =~? '^\s*end[[:alpha:]]'
normal k
let partner=matchstr(getline(v:lnum), '\(' . virtuality . 'end\)\@<=[[:alpha:]]\+')
let ind = indent(searchpair(virtuality . partner, '', '^\s*end' . partner, 'bW',
\ 'synIDattr(synID(line("."), col("."), 0), "name") =~? "sdlString"'))
endif
return ind
endfunction
let &cpo = s:cpo_save
unlet s:cpo_save
