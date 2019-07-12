if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetPascalIndent(v:lnum)
setlocal indentkeys&
setlocal indentkeys+==end;,==const,==type,==var,==begin,==repeat,==until,==for
setlocal indentkeys+==program,==function,==procedure,==object,==private
setlocal indentkeys+==record,==if,==else,==case
if exists("*GetPascalIndent")
finish
endif
function! s:GetPrevNonCommentLineNum( line_num )
let SKIP_LINES = '^\s*\(\((\*\)\|\(\*\ \)\|\(\*)\)\|{\|}\)'
let nline = a:line_num
while nline > 0
let nline = prevnonblank(nline-1)
if getline(nline) !~? SKIP_LINES
break
endif
endwhile
return nline
endfunction
function! s:PurifyCode( line_num )
let pureline = 'TODO'
return pureline
endfunction
function! GetPascalIndent( line_num )
if a:line_num == 0
return 0
endif
let this_codeline = getline( a:line_num )
if this_codeline =~ '^\s*\*'
return indent( a:line_num - 1)
endif
if this_codeline =~ '^\s*end\.'
return 0
endif
if this_codeline =~ '^\s*\({\|(\*\)\$'
return 0
endif
if this_codeline =~ '^\s*\(program\|procedure\|function\|type\)\>'
return 0
endif
if this_codeline =~ '^\s*\((\*\ _\+\ \*)\|\(const\|var\)\)$'
return 0
endif
let prev_codeline_num = s:GetPrevNonCommentLineNum( a:line_num )
let prev_codeline = getline( prev_codeline_num )
let indnt = indent( prev_codeline_num )
if prev_codeline =~ '\<\(type\|const\|var\)$'
return indnt + shiftwidth()
endif
if prev_codeline =~ '\<repeat$'
if this_codeline !~ '^\s*until\>'
return indnt + shiftwidth()
else
return indnt
endif
endif
if prev_codeline =~ '\<\(begin\|record\)$'
if this_codeline !~ '^\s*end\>'
return indnt + shiftwidth()
else
return indnt
endif
endif
if prev_codeline =~ '\<\(\|else\|then\|do\)$' || prev_codeline =~ ':$'
if this_codeline !~ '^\s*begin\>'
return indnt + shiftwidth()
else
return indnt
endif
endif
if prev_codeline =~ '([^)]\+$'
return indnt + shiftwidth()
endif
if this_codeline =~ '^\s*else\>' && prev_codeline !~ '\<end$'
return indnt - shiftwidth()
endif
let prev2_codeline_num = s:GetPrevNonCommentLineNum( prev_codeline_num )
let prev2_codeline = getline( prev2_codeline_num )
if prev2_codeline =~ '\<\(then\|else\|do\)$' && prev_codeline !~ '\<begin$'
if this_codeline =~ '^\s*\(end;\|except\|finally\|\)$'
return indnt - 2 * shiftwidth()
endif
return indnt - shiftwidth()
endif
if this_codeline =~ '^\s*\(end\|until\)\>'
return indnt - shiftwidth()
endif
if this_codeline =~ '^\s*begin$'
return 0
endif
if this_codeline =~ '^\s*\(interface\|implementation\|uses\|unit\)\>'
return 0
endif
if prev_codeline =~ '^\s*\(unit\|uses\|try\|except\|finally\|private\|protected\|public\|published\)$'
return indnt + shiftwidth()
endif
if this_codeline =~ '^\s*\(except\|finally\)$'
return indnt - shiftwidth()
endif
if this_codeline =~ '^\s*\(private\|protected\|public\|published\)$'
return indnt - shiftwidth()
endif
return indnt
endfunction
