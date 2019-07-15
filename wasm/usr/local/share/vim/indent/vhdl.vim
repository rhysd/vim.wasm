if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetVHDLindent()
setlocal indentkeys=!^F,o,O,0(,0)
setlocal indentkeys+==~begin,=~end\ ,=~end\	,=~is,=~select,=~when
setlocal indentkeys+==~if,=~then,=~elsif,=~else
setlocal indentkeys+==~case,=~loop,=~for,=~generate,=~record,=~units,=~process,=~block,=~function,=~component,=~procedure
setlocal indentkeys+==~architecture,=~configuration,=~entity,=~package
let s:NC = '\%(--.*\)\@<!'
let s:ES = '\s*\%(--.*\)\=$'
let s:NE = '\%(\<end\s\+\)\@<!'
if !exists("g:vhdl_indent_genportmap")
let g:vhdl_indent_genportmap = 1
endif
if !exists("g:vhdl_indent_rhsassign")
let g:vhdl_indent_rhsassign = 1
endif
if exists("*GetVHDLindent")
finish
endif
function GetVHDLindent()
let curn = v:lnum
let curs = getline(curn)
let prevn = prevnonblank(curn - 1)
let prevs = getline(prevn)
while prevn > 0 && prevs =~ '^\s*--'
let prevn = prevnonblank(prevn - 1)
let prevs = getline(prevn)
endwhile
let prevs_noi = substitute(prevs, '^\s*', '', '')
let ind = prevn > 0 ? indent(prevn) : 0
let ind2 = ind
let s0 = s:NC.'\<report\>\s*".*"'
if curs =~? s0
let curs = ""
endif
if prevs =~? s0
let prevs = ""
endif
if curs =~ '^\s*--'
let pn = curn - 1
let ps = getline(pn)
if curs =~ '^\s*--\s' && ps =~ '--'
return indent(pn) + stridx(substitute(ps, '^\s*', '', ''), '--')
else
let nn = nextnonblank(curn + 1)
let ns = getline(nn)
while nn > 0 && ns =~ '^\s*--'
let nn = nextnonblank(nn + 1)
let ns = getline(nn)
endwhile
let n = indent(nn)
return n != -1 ? n : ind
endif
endif
let pn = prevnonblank(prevn - 1)
let ps = getline(pn)
while pn > 0 && ps =~ '^\s*--'
let pn = prevnonblank(pn - 1)
let ps = getline(pn)
endwhile
if (curs =~ '^\s*)' || curs =~? '^\s*\%(\<\%(procedure\|generic\|map\|port\)\>.*\)\@<!\w\+\s*\w*\s*\((.*)\)*\s*\%(=>\s*\S\+\|:[^=]\@=\s*\%(\%(in\|out\|inout\|buffer\|linkage\)\>\|\s\+\)\)') && (prevs =~? s:NC.'\<\%(procedure\s\+\S\+\|generic\|map\|port\)\s*(\%(\s*\w\)\=' || (ps =~? s:NC.'\<\%(procedure\|generic\|map\|port\)'.s:ES && prevs =~ '^\s*('))
if curs =~ '^\s*)'
return ind2 + stridx(prevs_noi, '(')
endif
let m = matchend(prevs_noi, '(\s*\ze\w')
if m != -1
return ind2 + m
else
if g:vhdl_indent_genportmap
return ind2 + stridx(prevs_noi, '(') + shiftwidth()
else
return ind2 + shiftwidth()
endif
endif
endif
if prevs =~? '^\s*\S\+\s*<=[^;]*'.s:ES
if g:vhdl_indent_rhsassign
return ind2 + matchend(prevs_noi, '<=\s*\ze.')
else
return ind2 + shiftwidth()
endif
endif
let m = 0
if prevs =~? '^\s*end\s\+\%(record\|units\)\>'
let m = 3
elseif prevs =~ '^\s*)'
let m = 1
elseif prevs =~ s:NC.'\%(<=.*\)\@<!;'.s:ES || (curs !~ '^\s*)' && prevs =~ s:NC.'=>.*'.s:NC.')'.s:ES)
let m = 2
endif
if m > 0
let pn = prevnonblank(prevn - 1)
let ps = getline(pn)
while pn > 0
let t = indent(pn)
if ps !~ '^\s*--' && (t < ind || (t == ind && m == 3))
if m < 3 && ps !~? '^\s*\S\+\s*<=[^;]*'.s:ES
if ps =~? s:NC.'\<\%(procedure\|generic\|map\|port\)\>' || ps =~ '^\s*('
let ind = t
endif
break
endif
let ind = t
if m > 1
let ppn = prevnonblank(pn - 1)
let pps = getline(ppn)
while ppn > 0 && pps =~ '^\s*--'
let ppn = prevnonblank(ppn - 1)
let pps = getline(ppn)
endwhile
if m == 2
let s1 = s:NC.'\<select'.s:ES
if ps !~? s1 && pps =~? s1
let ind = indent(ppn)
endif
elseif m == 3
let s1 = '^\s*type\>'
if ps !~? s1 && pps =~? s1
let ind = indent(ppn)
endif
endif
endif
break
endif
let pn = prevnonblank(pn - 1)
let ps = getline(pn)
endwhile
endif
if curs =~? s:NC.'\<begin\>'
let s2 = s:NC.s:NE.'\<\%(architecture\|block\|entity\|function\|generate\|procedure\|process\)\>'
let pn = prevnonblank(curn - 1)
let ps = getline(pn)
while pn > 0 && (ps =~ '^\s*--' || ps !~? s2)
let pn = prevnonblank(pn - 1)
let ps = getline(pn)
if (ps =~? s:NC.'\<begin\>')
return indent(pn) - shiftwidth()
endif
endwhile
if (pn == 0)
return ind - shiftwidth()
else
return indent(pn)
endif
endif
if curs =~? s:NC.s:NE.'\<\%(record\|units\)\>'
let s3 = s:NC.s:NE.'\<type\>'
if curs !~? s3.'.*'.s:NC.'\<\%(record\|units\)\>.*'.s:ES && prevs =~? s3
let ind = ind + shiftwidth()
endif
return ind
endif
if curs =~? '^\s*\%(architecture\|configuration\|entity\|library\|package\)\>'
return 0
endif
if curs =~? '^\s*\<is\>' && prevs =~? s:NC.s:NE.'\<\%(architecture\|block\|configuration\|entity\|function\|package\|procedure\|process\|type\)\>'
return ind2
endif
if curs =~? '^\s*\<then\>' && prevs =~? s:NC.'\%(\<elsif\>\|'.s:NE.'\<if\>\)'
return ind2
endif
if curs =~? '^\s*\<generate\>' && prevs =~? s:NC.s:NE.'\%(\%(\<wait\s\+\)\@<!\<for\|\<if\)\>'
return ind2
endif
if prevs =~? s:NC.s:NE.'\<\%(block\|process\)\>'
return ind + shiftwidth()
endif
if prevs =~? '^\s*\%(architecture\|configuration\|entity\|package\)\>'
return ind + shiftwidth()
endif
if prevs =~? s:NC.'\<select'.s:ES
return ind + shiftwidth()
endif
if prevs =~? s:NC.'\%(\<begin\>\|'.s:NE.'\<\%(loop\|record\|units\)\>\)' || prevs =~? '^\s*\%(component\|else\|for\)\>' || prevs =~? s:NC.'\%('.s:NE.'\<generate\|\<\%(is\|then\)\|=>\)'.s:ES
let ind = ind + shiftwidth()
endif
let s4 = '^\s*when\>'
if curs =~? s4
if prevs =~? s:NC.'\<is'.s:ES
return ind
elseif prevs !~? s4
return ind - shiftwidth()
else
return ind2
endif
endif
let s5 = 'block\|for\|function\|generate\|if\|loop\|procedure\|process\|record\|units'
if curs =~? '^\s*\%(else\|elsif\|end\s\+\%('.s5.'\)\)\>'
if prevs =~? '^\s*\%(elsif\|'.s5.'\)'
return ind
else
return ind - shiftwidth()
endif
endif
let m = 0
if curs =~? '^\s*end\s\+case\>'
let m = 1
elseif curs =~? '^\s*end\s\+component\>'
let m = 2
endif
if m > 0
let pn = prevn
let ps = getline(pn)
while pn > 0
if ps !~ '^\s*--'
if m == 1
if ps =~? '^\s*end\s\+case\>'
return indent(pn) - 2 * shiftwidth()
elseif ps =~? '^\s*when\>'
return indent(pn) - shiftwidth()
elseif ps =~? '^\s*case\>'
return indent(pn)
endif
elseif m == 2
if ps =~? '^\s*component\>'
return indent(pn)
endif
endif
endif
let pn = prevnonblank(pn - 1)
let ps = getline(pn)
endwhile
return ind - shiftwidth()
endif
if curs =~ '^\s*)'
return ind - shiftwidth()
endif
if curs =~? '^\s*end\s\+\%(architecture\|configuration\|entity\|package\)\>'
return 0
endif
if curs =~? '^\s*end\%(\s\|;'.s:ES.'\)'
return ind - shiftwidth()
endif
if curs =~? '^\s*\%(\<\%(procedure\|generic\|map\|port\)\>.*\)\@<!\w\+\s*\w*\s*:[^=]\@=\s*\%(\%(in\|out\|inout\|buffer\|linkage\)\>\|\w\+\s\+:=\)'
return ind2
endif
if curs =~? '^\s*\%(\<\%(procedure\|generic\|map\|port\)\>.*\)\@<!\w\+\s*\w*\s*:[^=].*[^;].*$'
if prevs =~? '^\s*\%(\<\%(procedure\|generic\|map\|port\)\>.*\)\@<!\w\+\s*\w*\s*:[^=].*;.*$'
return ind2
endif
endif
return ind
endfunction
