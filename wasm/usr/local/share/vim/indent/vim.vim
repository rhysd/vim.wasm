if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetVimIndent()
setlocal indentkeys+==end,=else,=cat,=fina,=END,0\\,0=\"\\\ 
let b:undo_indent = "setl indentkeys< indentexpr<"
if exists("*GetVimIndent")
finish
endif
let s:keepcpo= &cpo
set cpo&vim
function GetVimIndent()
let ignorecase_save = &ignorecase
try
let &ignorecase = 0
return GetVimIndentIntern()
finally
let &ignorecase = ignorecase_save
endtry
endfunc
let s:lineContPat = '^\s*\(\\\|"\\ \)'
function GetVimIndentIntern()
let lnum = prevnonblank(v:lnum - 1)
let cur_text = getline(v:lnum)
if cur_text !~ s:lineContPat
while lnum > 0 && getline(lnum) =~ s:lineContPat
let lnum = lnum - 1
endwhile
endif
if lnum == 0
return 0
endif
let prev_text = getline(lnum)
let ind = indent(lnum)
if cur_text =~ s:lineContPat && v:lnum > 1 && prev_text !~ s:lineContPat
if exists("g:vim_indent_cont")
let ind = ind + g:vim_indent_cont
else
let ind = ind + shiftwidth() * 3
endif
elseif prev_text =~ '^\s*aug\%[roup]\s\+' && prev_text !~ '^\s*aug\%[roup]\s\+[eE][nN][dD]\>'
let ind = ind + shiftwidth()
else
if prev_text !~ '^\s*au\%[tocmd]'
let i = match(prev_text, '\(^\||\)\s*\(if\|wh\%[ile]\|for\|try\|cat\%[ch]\|fina\%[lly]\|fu\%[nction]\|el\%[seif]\)\>')
if i >= 0
let ind += shiftwidth()
if strpart(prev_text, i, 1) == '|' && has('syntax_items')
\ && synIDattr(synID(lnum, i, 1), "name") =~ '\(Comment\|String\)$'
let ind -= shiftwidth()
endif
endif
endif
endif
let i = match(prev_text, '[^\\]|\s*\(ene\@!\)')
if i > 0 && prev_text !~ '^\s*au\%[tocmd]'
if !has('syntax_items') || synIDattr(synID(lnum, i + 2, 1), "name") !~ '\(Comment\|String\)$'
let ind = ind - shiftwidth()
endif
endif
if cur_text =~ '^\s*\(ene\@!\|cat\|fina\|el\|aug\%[roup]\s\+[eE][nN][dD]\)'
let ind = ind - shiftwidth()
endif
return ind
endfunction
let &cpo = s:keepcpo
unlet s:keepcpo
