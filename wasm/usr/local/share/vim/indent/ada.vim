if exists("b:did_indent") || version < 700
finish
endif
let b:did_indent = 45
setlocal indentexpr=GetAdaIndent()
setlocal indentkeys-=0{,0}
setlocal indentkeys+=0=~then,0=~end,0=~elsif,0=~when,0=~exception,0=~begin,0=~is,0=~record
if exists("*GetAdaIndent")
finish
endif
let s:keepcpo= &cpo
set cpo&vim
if exists("g:ada_with_gnat_project_files")
let s:AdaBlockStart = '^\s*\(if\>\|while\>\|else\>\|elsif\>\|loop\>\|for\>.*\<\(loop\|use\)\>\|declare\>\|begin\>\|type\>.*\<is\>[^;]*$\|\(type\>.*\)\=\<record\>\|procedure\>\|function\>\|accept\>\|do\>\|task\>\|package\>\|project\>\|then\>\|when\>\|is\>\)'
else
let s:AdaBlockStart = '^\s*\(if\>\|while\>\|else\>\|elsif\>\|loop\>\|for\>.*\<\(loop\|use\)\>\|declare\>\|begin\>\|type\>.*\<is\>[^;]*$\|\(type\>.*\)\=\<record\>\|procedure\>\|function\>\|accept\>\|do\>\|task\>\|package\>\|then\>\|when\>\|is\>\)'
endif
function s:MainBlockIndent (prev_indent, prev_lnum, blockstart, stop_at)
let lnum = a:prev_lnum
let line = substitute( getline(lnum), g:ada#Comment, '', '' )
while lnum > 1
if a:stop_at != ''  &&  line =~ '^\s*' . a:stop_at  &&  indent(lnum) < a:prev_indent
return a:prev_indent
elseif line =~ '^\s*' . a:blockstart
let ind = indent(lnum)
if ind < a:prev_indent
return ind
endif
endif
let lnum = prevnonblank(lnum - 1)
while 1
let line = substitute( getline(lnum), g:ada#Comment, '', '' )
if line !~ '^\s*$' && line !~ '^\s*#'
break
endif
let lnum = prevnonblank(lnum - 1)
if lnum <= 0
return a:prev_indent
endif
endwhile
endwhile
return a:prev_indent - shiftwidth()
endfunction MainBlockIndent
function s:EndBlockIndent( prev_indent, prev_lnum, blockstart, blockend )
let lnum = a:prev_lnum
let line = getline(lnum)
let ends = 0
while lnum > 1
if getline(lnum) =~ '^\s*' . a:blockstart
let ind = indent(lnum)
if ends <= 0
if ind < a:prev_indent
return ind
endif
else
let ends = ends - 1
endif
elseif getline(lnum) =~ '^\s*' . a:blockend
let ends = ends + 1
endif
let lnum = prevnonblank(lnum - 1)
while 1
let line = getline(lnum)
let line = substitute( line, g:ada#Comment, '', '' )
if line !~ '^\s*$'
break
endif
let lnum = prevnonblank(lnum - 1)
if lnum <= 0
return a:prev_indent
endif
endwhile
endwhile
return a:prev_indent - shiftwidth()
endfunction EndBlockIndent
function s:StatementIndent( current_indent, prev_lnum )
let lnum  = a:prev_lnum
while lnum > 0
let prev_lnum = lnum
let lnum = prevnonblank(lnum - 1)
while 1
let line = substitute( getline(lnum), g:ada#Comment, '', '' )
if line !~ '^\s*$' && line !~ '^\s*#'
break
endif
let lnum = prevnonblank(lnum - 1)
if lnum <= 0
return a:current_indent
endif
endwhile
if line =~ s:AdaBlockStart || line =~ '(\s*$'
return a:current_indent
endif
if line !~ '[.=(]\s*$'
let ind = indent(prev_lnum)
if ind < a:current_indent
return ind
endif
endif
endwhile
return a:current_indent
endfunction StatementIndent
function GetAdaIndent()
let lnum = prevnonblank(v:lnum - 1)
let ind = indent(lnum)
let package_line = 0
while 1
let line = substitute( getline(lnum), g:ada#Comment, '', '' )
if line !~ '^\s*$' && line !~ '^\s*#'
break
endif
let lnum = prevnonblank(lnum - 1)
if lnum <= 0
return ind
endif
endwhile
let ind = indent(lnum)
let initind = ind
if line =~ s:AdaBlockStart  ||  line =~ '(\s*$'
let false_match = 0
if line =~ '^\s*\(procedure\|function\|package\)\>.*\<is\s*new\>'
let false_match = 1
elseif line =~ ')\s*;\s*$'  ||  line =~ '^\([^(]*([^)]*)\)*[^(]*;\s*$'
let false_match = 1
endif
if ! false_match
let ind = ind + shiftwidth()
endif
elseif line =~ '^\s*\(case\|exception\)\>'
let ind = ind + 2 * shiftwidth()
elseif line =~ '^\s*end\s*record\>'
let ind = s:MainBlockIndent( ind+shiftwidth(), lnum, 'type\>', '' )
elseif line =~ '\(^\s*new\>.*\)\@<!)\s*[;,]\s*$'
exe lnum
exe 'normal! $F)%'
if getline('.') =~ '^\s*('
let ind = indent( prevnonblank( line('.')-1 ) )
else
let ind = indent('.')
endif
exe v:lnum
elseif line =~ '[.=(]\s*$'
let ind = ind + shiftwidth()
elseif line =~ '^\s*new\>'
let ind = s:StatementIndent( ind - shiftwidth(), lnum )
elseif line =~ ';\s*$'
let ind = s:StatementIndent( ind, lnum )
endif
let continuation = (line =~ '[A-Za-z0-9_]\s*$')
let line = getline(v:lnum)
if line =~ '^\s*#'
let ind = 0
elseif continuation && line =~ '^\s*('
if ind == initind
let ind = ind + shiftwidth()
endif
elseif line =~ '^\s*\(begin\|is\)\>'
let ind = s:MainBlockIndent( ind, lnum, '\(procedure\|function\|declare\|package\|task\)\>', 'begin\>' )
elseif line =~ '^\s*record\>'
let ind = s:MainBlockIndent( ind, lnum, 'type\>\|for\>.*\<use\>', '' ) + shiftwidth()
elseif line =~ '^\s*\(else\|elsif\)\>'
let ind = s:MainBlockIndent( ind, lnum, 'if\>', '' )
elseif line =~ '^\s*when\>'
let ind = s:MainBlockIndent( ind, lnum, '\(case\|exception\)\>', '' ) + shiftwidth()
elseif line =~ '^\s*end\>\s*\<if\>'
let ind = s:EndBlockIndent( ind, lnum, 'if\>', 'end\>\s*\<if\>' )
elseif line =~ '^\s*end\>\s*\<loop\>'
let ind = s:EndBlockIndent( ind, lnum, '\(\(while\|for\)\>.*\)\?\<loop\>', 'end\>\s*\<loop\>' )
elseif line =~ '^\s*end\>\s*\<record\>'
let ind = s:EndBlockIndent( ind, lnum, '\(type\>.*\)\=\<record\>', 'end\>\s*\<record\>' )
elseif line =~ '^\s*end\>\s*\<procedure\>'
let ind = s:EndBlockIndent( ind, lnum, 'procedure\>.*\<is\>', 'end\>\s*\<procedure\>' )
elseif line =~ '^\s*end\>\s*\<case\>'
let ind = s:EndBlockIndent( ind, lnum, 'case\>.*\<is\>', 'end\>\s*\<case\>' )
elseif line =~ '^\s*end\>'
let ind = s:MainBlockIndent( ind, lnum, '\(if\|while\|for\|loop\|accept\|begin\|record\|case\|exception\|package\)\>', '' )
elseif line =~ '^\s*exception\>'
let ind = s:MainBlockIndent( ind, lnum, 'begin\>', '' )
elseif line =~ '^\s*then\>'
let ind = s:MainBlockIndent( ind, lnum, 'if\>', '' )
endif
return ind
endfunction GetAdaIndent
let &cpo = s:keepcpo
unlet s:keepcpo
finish " 1}}}
