if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=TcshGetIndent()
setlocal indentkeys+=e,0=end,0=endsw indentkeys-=0{,0},0),:,0#
if exists("*TcshGetIndent")
finish
endif
function TcshGetIndent()
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let ind = indent(lnum)
let line = getline(lnum)
if line =~ '\v^\s*%(while|foreach)>|^\s*%(case\s.*:|default:|else)\s*$|%(<then|\\)$'
let ind = ind + shiftwidth()
endif
if line =~ '\v^\s*breaksw>'
let ind = ind - shiftwidth()
endif
let line = getline(v:lnum)
if line =~ '\v^\s*%(else|end|endif)\s*$'
let ind = ind - shiftwidth()
endif
return ind
endfunction
