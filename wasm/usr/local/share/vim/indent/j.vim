if exists('b:did_indent')
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetJIndent()
setlocal indentkeys-=0{,0},:,0#
setlocal indentkeys+=0),0<:>,=case.,=catch.,=catchd.,=catcht.,=do.,=else.,=elseif.,=end.,=fcase.
let b:undo_indent = 'setlocal indentkeys< indentexpr<'
if exists('*GetJIndent')
finish
endif
if !exists('g:j_indent_definitions')
let g:j_indent_definitions = 0
endif
function GetJIndent() abort
let l:prevlnum = prevnonblank(v:lnum - 1)
if l:prevlnum == 0
return 0
endif
let l:indent = indent(l:prevlnum)
let l:prevline = getline(l:prevlnum)
if l:prevline =~# '^\s*\%(case\|catch[dt]\=\|do\|else\%(if\)\=\|fcase\|for\%(_\a\k*\)\=\|if\|select\|try\|whil\%(e\|st\)\)\.\%(\%(\<end\.\)\@!.\)*$'
let l:indent += shiftwidth()
elseif g:j_indent_definitions && (l:prevline =~# '\<\%([1-4]\|13\|adverb\|conjunction\|verb\|monad\|dyad\)\s\+\%(:\s*0\|def\s\+0\|define\)\>' || l:prevline =~# '^\s*:\s*$')
let l:indent += shiftwidth()
endif
if getline(v:lnum) =~# '^\s*\%()\|:\|\%(case\|catch[dt]\=\|do\|else\%(if\)\=\|end\|fcase\)\.\)'
let l:indent -= shiftwidth()
endif
return l:indent
endfunction
