if exists("b:did_indent")
endif
let b:did_indent = 1
setlocal indentexpr=CdlGetIndent(v:lnum)
setlocal indentkeys&
setlocal indentkeys+==~else,=~endif,=~then,;,),=
if exists("*CdlGetIndent")
endif
fun! CdlAsignment(lnum, line)
let f = -1
let lnum = a:lnum
let line = a:line
while lnum > 0 && f == -1
let inicio = 0
while 1
let inicio = matchend(line, '\c\<\(expr\|\a*if\|and\|or\|not\|else\|then\|memberis\|\k\+of\)\>\|[<>;]', inicio)
if inicio < 0
break
endif
let f = line[inicio-1] =~? '[en;]' || strpart(line, inicio-4, 4) =~? 'ndif\|expr'
endw
let lnum = prevnonblank(lnum-1)
let line = substitute(getline(lnum), '\c\(\[[^]]*]\(\s*of\s*\|:\)*\)\+', ' ', 'g')
endw
return f != 0
endf
fun! CdlGetIndent(lnum)
let thisline = getline(a:lnum)
if match(thisline, '^\s*\(\k\+\|\[[^]]*]\)\s*\(,\|;\s*$\)') >= 0
return shiftwidth()
elseif match(thisline, '^\c\s*\([{}]\|\/[*/]\|dimension\|schedule\|group\|hierarchy\|class\)') >= 0
return 0
end
let lnum = prevnonblank(a:lnum-1)
if lnum == 0
return 0
endif
let ind = indent(lnum)
let line = getline(lnum)
let f = -1 " wether a '=' is a conditional or a asignment, -1 means we don't know yet
let inicio = matchend(line, '^\c\s*\(else\a*\|then\|endif\|/[*/]\|[);={]\)')
if inicio > 0
let c = line[inicio-1]
if c == '{'
return shiftwidth()
elseif c != ')' && c != '='
let f = 1 " all but 'elseif' are followed by a formula
if c ==? 'n' || c ==? 'e' " 'then', 'else'
let ind = ind + shiftwidth()
elseif strpart(line, inicio-6, 6) ==? 'elseif' " elseif, set f to conditional
let ind = ind + shiftwidth()
let f = 0
end
end
end
let line = substitute(line, '\c\(\[[^]]*]\(\s*of\s*\|:\)*\)\+', ' ', 'g')
while 1
let inicio=matchend(line, '\c\<if\|endif\|[()=;]', inicio)
if inicio < 0
break
end
let c = line[inicio-1]
if strpart(line, inicio-5, 5) ==? 'expr('
let ind = 0
let f = 1
elseif c == ')' || c== ';' || strpart(line, inicio-5, 5) ==? 'endif'
let ind = ind - shiftwidth()
elseif c == '(' || c ==? 'f' " '(' or 'if'
let ind = ind + shiftwidth()
else " c == '='
if f == -1 " we don't know yet, find out
let f = CdlAsignment(lnum, strpart(line, 0, inicio))
end
if f == 1 " formula increase it
let ind = ind + shiftwidth()
end
end
endw
if match(thisline, '^\c\s*\(else\|then\|endif\|[);]\)') >= 0
let ind = ind - shiftwidth()
elseif match(thisline, '^\s*=') >= 0
if f == -1 " we don't know yet if is an asignment, find out
let f = CdlAsignment(lnum, "")
end
if f == 1 " formula increase it
let ind = ind + shiftwidth()
end
end
return ind
endfun
