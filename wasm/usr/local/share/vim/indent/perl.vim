if exists("b:did_indent")
finish
endif
let b:did_indent = 1
let b:indent_use_syntax = has("syntax")
setlocal indentexpr=GetPerlIndent()
setlocal indentkeys+=0=,0),0],0=or,0=and
if !b:indent_use_syntax
setlocal indentkeys+=0=EO
endif
let s:cpo_save = &cpo
set cpo-=C
function! GetPerlIndent()
let cline = getline(v:lnum)
if cline =~ '^\s*=\L\@!'
return 0
endif
let csynid = ''
if b:indent_use_syntax
let csynid = synIDattr(synID(v:lnum,1,0),"name")
endif
if csynid == "perlPOD" || csynid == "perlHereDoc" || csynid =~ "^pod"
return indent(v:lnum)
endif
if b:indent_use_syntax
if csynid == "perlStringStartEnd" && cline =~ '^\I\i*$'
return 0
endif
else
if cline =~ '^\s*EO'
return 0
endif
endif
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let line = getline(lnum)
let ind = indent(lnum)
if b:indent_use_syntax
let skippin = 2
while skippin
let synid = synIDattr(synID(lnum,1,0),"name")
if (synid == "perlStringStartEnd" && line =~ '^\I\i*$')
\ || (skippin != 2 && synid == "perlPOD")
\ || (skippin != 2 && synid == "perlHereDoc")
\ || synid == "perlComment"
\ || synid =~ "^pod"
let lnum = prevnonblank(lnum - 1)
if lnum == 0
return 0
endif
let line = getline(lnum)
let ind = indent(lnum)
let skippin = 1
else
let skippin = 0
endif
endwhile
else
if line =~ "^EO"
let lnum = search("<<[\"']\\=EO", "bW")
let line = getline(lnum)
let ind = indent(lnum)
endif
endif
if b:indent_use_syntax
let braceclass = '[][(){}]'
let bracepos = match(line, braceclass, matchend(line, '^\s*[])}]'))
while bracepos != -1
let synid = synIDattr(synID(lnum, bracepos + 1, 0), "name")
if synid == ""
\ || synid == "perlMatchStartEnd"
\ || synid == "perlHereDoc"
\ || synid == "perlBraces"
\ || synid == "perlStatementIndirObj"
\ || synid =~ "^perlFiledescStatement"
\ || synid =~ '^perl\(Sub\|Block\|Package\)Fold'
let brace = strpart(line, bracepos, 1)
if brace == '(' || brace == '{' || brace == '['
let ind = ind + shiftwidth()
else
let ind = ind - shiftwidth()
endif
endif
let bracepos = match(line, braceclass, bracepos + 1)
endwhile
let bracepos = matchend(cline, '^\s*[])}]')
if bracepos != -1
let synid = synIDattr(synID(v:lnum, bracepos, 0), "name")
if synid == ""
\ || synid == "perlMatchStartEnd"
\ || synid == "perlBraces"
\ || synid == "perlStatementIndirObj"
\ || synid =~ '^perl\(Sub\|Block\|Package\)Fold'
let ind = ind - shiftwidth()
endif
endif
else
if line =~ '[{[(]\s*\(#[^])}]*\)\=$'
let ind = ind + shiftwidth()
endif
if cline =~ '^\s*[])}]'
let ind = ind - shiftwidth()
endif
endif
if cline =~ '^\s*\(or\|and\)\>'
if line !~ '^\s*\(or\|and\)\>'
let ind = ind + shiftwidth()
endif
elseif line =~ '^\s*\(or\|and\)\>'
let ind = ind - shiftwidth()
endif
return ind
endfunction
let &cpo = s:cpo_save
unlet s:cpo_save
