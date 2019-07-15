if exists("b:current_syntax")
finish
endif
if !exists("b:lhs_markup")
if exists("lhs_markup")
if lhs_markup =~ '\<\%(tex\|none\)\>'
let b:lhs_markup = matchstr(lhs_markup,'\<\%(tex\|none\)\>')
else
echohl WarningMsg | echo "Unknown value of lhs_markup" | echohl None
let b:lhs_markup = "unknown"
endif
else
let b:lhs_markup = "unknown"
endif
else
if b:lhs_markup !~ '\<\%(tex\|none\)\>'
let b:lhs_markup = "unknown"
endif
endif
let s:oldline=line(".")
let s:oldcolumn=col(".")
call cursor(1,1)
if b:lhs_markup == "unknown"
if search('\\documentclass\|\\begin{\(code}\)\@!\|\\\(sub\)*section\|\\chapter|\\part','W') != 0
let b:lhs_markup = "tex"
else
let b:lhs_markup = "plain"
endif
endif
if b:lhs_markup == "tex"
runtime! syntax/tex.vim
unlet b:current_syntax
setlocal isk+=_
syntax cluster lhsTeXContainer contains=tex.*Zone,texAbstract
else
syntax cluster lhsTeXContainer contains=.*
endif
syntax include @haskellTop syntax/haskell.vim
syntax region lhsHaskellBirdTrack start="^>" end="\%(^[^>]\)\@=" contains=@haskellTop,lhsBirdTrack containedin=@lhsTeXContainer
syntax region lhsHaskellBeginEndBlock start="^\\begin{code}\s*$" matchgroup=NONE end="\%(^\\end{code}.*$\)\@=" contains=@haskellTop,beginCodeBegin containedin=@lhsTeXContainer
syntax match lhsBirdTrack "^>" contained
syntax match beginCodeBegin "^\\begin" nextgroup=beginCodeCode contained
syntax region beginCodeCode  matchgroup=texDelimiter start="{" end="}"
hi def link lhsBirdTrack Comment
hi def link beginCodeBegin	      texCmdName
hi def link beginCodeCode	      texSection
call cursor (s:oldline, s:oldcolumn)
unlet s:oldline
unlet s:oldcolumn
let b:current_syntax = "lhaskell"
