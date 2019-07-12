if exists("b:did_ftplugin")
finish
endif
source $VIMRUNTIME/ftplugin/plaintex.vim
let s:save_cpo = &cpo
set cpo&vim
let b:undo_ftplugin .= "| setl inex<"
let &l:define .= '\|\\\(re\)\=new\(boolean\|command\|counter\|environment\|font'
\ . '\|if\|length\|savebox\|theorem\(style\)\=\)\s*\*\=\s*{\='
\ . '\|DeclareMathOperator\s*{\=\s*'
let &l:include .= '\|\\include{'
let &l:includeexpr = "substitute(v:fname, '^.\\{-}{\\|}.*', '', 'g')"
if exists("loaded_matchit")
let b:match_words .= ',\\begin\s*\({\a\+\*\=}\):\\end\s*\1'
endif " exists("loaded_matchit")
let &cpo = s:save_cpo
unlet s:save_cpo
