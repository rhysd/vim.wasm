if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal expandtab
setlocal indentexpr=GetOCamlIndent()
setlocal indentkeys+=0=and,0=class,0=constraint,0=done,0=else,0=end,0=exception,0=external,0=if,0=in,0=include,0=inherit,0=initializer,0=let,0=method,0=open,0=then,0=type,0=val,0=with,0;;,0>\],0\|\],0>},0\|,0},0\],0)
setlocal nolisp
setlocal nosmartindent
if !exists("no_ocaml_comments")
if (has("comments"))
setlocal comments=sr:(*,mb:*,ex:*)
setlocal fo=cqort
endif
endif
if exists("*GetOCamlIndent")
finish
endif
let s:beflet = '^\s*\(initializer\|method\|try\)\|\(\<\(begin\|do\|else\|in\|then\|try\)\|->\|<-\|=\|;\|(\)\s*$'
let s:letpat = '^\s*\(let\|type\|module\|class\|open\|exception\|val\|include\|external\)\>'
let s:letlim = '\(\<\(sig\|struct\)\|;;\)\s*$'
let s:lim = '^\s*\(exception\|external\|include\|let\|module\|open\|type\|val\)\>'
let s:module = '\<\%(begin\|sig\|struct\|object\)\>'
let s:obj = '^\s*\(constraint\|inherit\|initializer\|method\|val\)\>\|\<\(object\|object\s*(.*)\)\s*$'
let s:type = '^\s*\%(class\|let\|type\)\>.*='
function! s:GetLineWithoutFullComment(lnum)
let lnum = prevnonblank(a:lnum - 1)
let lline = substitute(getline(lnum), '(\*.*\*)\s*$', '', '')
while lline =~ '^\s*$' && lnum > 0
let lnum = prevnonblank(lnum - 1)
let lline = substitute(getline(lnum), '(\*.*\*)\s*$', '', '')
endwhile
return lnum
endfunction
function! s:GetInd(lnum, pat, lim)
let llet = search(a:pat, 'bW')
let old = indent(a:lnum)
while llet > 0
let old = indent(llet)
let nb = s:GetLineWithoutFullComment(llet)
if getline(nb) =~ a:lim
return old
endif
let llet = search(a:pat, 'bW')
endwhile
return old
endfunction
function! s:FindPair(pstart, pmid, pend)
call search(a:pend, 'bW')
return indent(searchpair(a:pstart, a:pmid, a:pend, 'bWn', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment"'))
endfunction
function! s:FindLet(pstart, pmid, pend)
call search(a:pend, 'bW')
return indent(searchpair(a:pstart, a:pmid, a:pend, 'bWn', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment" || getline(".") =~ "^\\s*let\\>.*=.*\\<in\\s*$" || getline(prevnonblank(".") - 1) =~ s:beflet'))
endfunction
function! GetOCamlIndent()
let lnum = s:GetLineWithoutFullComment(v:lnum)
if lnum == 0
return 0
endif
let ind = indent(lnum)
let lline = substitute(getline(lnum), '(\*.*\*)\s*$', '', '')
if lline =~ '^\s*|.*->\s*$'
return ind + 2 * shiftwidth()
endif
let line = getline(v:lnum)
if line =~ '^\s*end\>'
return s:FindPair(s:module, '','\<end\>')
elseif line =~ '^\s*done\>'
return s:FindPair('\<do\>', '','\<done\>')
elseif line =~ '^\s*\(\|>\)}'
return s:FindPair('{', '','}')
elseif line =~ '^\s*\(\||\|>\)\]'
return s:FindPair('\[', '','\]')
elseif line =~ '^\s*)'
return s:FindPair('(', '',')')
elseif line =~ '^\s*let\>'
if lline !~ s:lim . '\|' . s:letlim . '\|' . s:beflet
return s:FindLet(s:type, '','\<let\s*$')
endif
elseif line =~ '^\s*\(class\|type\)\>'
if lline !~ s:lim . '\|\<and\s*$\|' . s:letlim
return s:FindLet(s:type, '','\<\(class\|type\)\s*$')
endif
elseif line =~ '^\s*|'
if lline !~ '^\s*\(|[^\]]\|\(match\|type\|with\)\>\)\|\<\(function\|parser\|private\|with\)\s*$'
call search('|', 'bW')
return indent(searchpair('^\s*\(match\|type\)\>\|\<\(function\|parser\|private\|with\)\s*$', '', '^\s*|', 'bWn', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment" || getline(".") !~ "^\\s*|.*->"'))
endif
elseif line =~ '^\s*;;'
if lline !~ ';;\s*$'
return s:GetInd(v:lnum, s:letpat, s:letlim)
endif
elseif line =~ '^\s*in\>'
if lline !~ '^\s*\(let\|and\)\>'
return s:FindPair('\<let\>', '', '\<in\>')
endif
elseif line =~ '^\s*else\>'
if lline !~ '^\s*\(if\|then\)\>'
return s:FindPair('\<if\>', '', '\<else\>')
endif
elseif line =~ '^\s*then\>'
if lline !~ '^\s*\(if\|else\)\>'
return s:FindPair('\<if\>', '', '\<then\>')
endif
elseif line =~ '^\s*and\>'
if lline !~ '^\s*\(and\|let\|type\)\>\|\<end\s*$'
return ind - shiftwidth()
endif
elseif line =~ '^\s*with\>'
if lline !~ '^\s*\(match\|try\)\>'
return s:FindPair('\<\%(match\|try\)\>', '','\<with\>')
endif
elseif line =~ '^\s*\(exception\|external\|include\|open\)\>'
if lline !~ s:lim . '\|' . s:letlim
call search(line)
return indent(search('^\s*\(\(exception\|external\|include\|open\|type\)\>\|val\>.*:\)', 'bW'))
endif
elseif line =~ '^\s*val\>'
if lline !~ '^\s*\(exception\|external\|include\|open\)\>\|' . s:obj . '\|' . s:letlim
return indent(search('^\s*\(\(exception\|include\|initializer\|method\|open\|type\|val\)\>\|external\>.*:\)', 'bW'))
endif
elseif line =~ '^\s*\(constraint\|inherit\|initializer\|method\)\>'
if lline !~ s:obj
return indent(search('\<\(object\|object\s*(.*)\)\s*$', 'bW')) + shiftwidth()
endif
endif
if lline =~ '\(:\|=\|->\|<-\|(\|\[\|{\|{<\|\[|\|\[<\|\<\(begin\|do\|else\|fun\|function\|functor\|if\|initializer\|object\|parser\|private\|sig\|struct\|then\|try\)\|\<object\s*(.*)\)\s*$'
let ind = ind + shiftwidth()
elseif lline =~ ';;\s*$' && lline !~ '^\s*;;'
let ind = s:GetInd(v:lnum, s:letpat, s:letlim)
elseif lline =~ '\<end\s*$'
let ind = s:FindPair(s:module, '','\<end\>')
elseif lline =~ '\<in\s*$' && lline !~ '^\s*in\>'
let ind = s:FindPair('\<let\>', '', '\<in\>')
elseif lline =~ '\<done\s*$'
let ind = s:FindPair('\<do\>', '','\<done\>')
elseif lline =~ '\(\|>\)}\s*$'
let ind = s:FindPair('{', '','}')
elseif lline =~ '\(\||\|>\)\]\s*$'
let ind = s:FindPair('\[', '','\]')
elseif lline =~ '\*)\s*$'
call search('\*)', 'bW')
let ind = indent(searchpair('(\*', '', '\*)', 'bWn', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string"'))
elseif lline =~ ')\s*$'
let ind = s:FindPair('(', '',')')
elseif lline =~ '^\s*(\*' && line =~ '^\s*\*'
let ind = ind + 1
else
let i = indent(v:lnum)
return i == 0 ? ind : i
endif
if lline =~ '\<match\>.*\<with\>\s*\<parser\s*$'
let ind = ind - shiftwidth()
endif
return ind
endfunction
