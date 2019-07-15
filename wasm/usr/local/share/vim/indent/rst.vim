if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetRSTIndent()
setlocal indentkeys=!^F,o,O
setlocal nosmartindent
if exists("*GetRSTIndent")
finish
endif
let s:itemization_pattern = '^\s*[-*+]\s'
let s:enumeration_pattern = '^\s*\%(\d\+\|#\)\.\s\+'
function GetRSTIndent()
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let ind = indent(lnum)
let line = getline(lnum)
if line =~ s:itemization_pattern
let ind += 2
elseif line =~ s:enumeration_pattern
let ind += matchend(line, s:enumeration_pattern)
endif
let line = getline(v:lnum - 1)
if line =~ '^:.\+:\s\{-1,\}\S.\+[^.!?:]$'
return matchend(line, '^:.\{-1,}:\s\+')
endif
if line =~ '^\s*$'
execute lnum
call search('^\s*\%([-*+]\s\|\%(\d\+\|#\)\.\s\|\.\.\|$\)', 'bW')
let line = getline('.')
if line =~ s:itemization_pattern
let ind -= 2
elseif line =~ s:enumeration_pattern
let ind -= matchend(line, s:enumeration_pattern)
elseif line =~ '^\s*\.\.'
let ind -= 3
endif
endif
return ind
endfunction
