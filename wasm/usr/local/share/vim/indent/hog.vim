if exists("b:did_indent")
finish
endif
let b:did_indent = 1
let b:undo_indent = 'setlocal smartindent< indentexpr< indentkeys<'
setlocal nosmartindent
setlocal indentexpr=GetHogIndent()
setlocal indentkeys+=!^F,o,O,0#
if exists("*GetHogIndent")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
let s:syn_blocks = '\<SnortRuleTypeBody\>'
function s:IsInBlock(lnum)
return synIDattr(synID(a:lnum, 1, 1), 'name') =~ s:syn_blocks 
endfunction
function GetHogIndent()
let prevlnum = prevnonblank(v:lnum-1)
if getline(v:lnum) =~ '^\s*#' && getline(prevlnum) =~ '^\s*#'
return indent(prevlnum)
endif
while getline(prevlnum) =~ '^\s*#'
let prevlnum = prevnonblank(prevlnum-1)
if !prevlnum
return previndent
endif
endwhile
let prevline = getline(prevlnum)
if prevline =~ '^\k\+.*\\\s*$'
return shiftwidth() 
endif
if prevline =~ '\k\+.*\\\s*$'
return indent(prevlnum)
endif
if prevline =~ '^\k\+[^#]*{}\@!\s*$' " TODO || prevline =~ '^\k\+[^#]*()\@!\s*$'
return shiftwidth()
endif
if s:IsInBlock(v:lnum)
if prevline =~ "^\k\+.*$"
return shiftwidth()
else
return indent(prevlnum)
endif
endif
return 0 
endfunction
let &cpo = s:cpo_save
unlet s:cpo_save
