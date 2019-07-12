if exists("b:did_ftplugin")
finish
endif
source $VIMRUNTIME/ftplugin/initex.vim
let s:save_cpo = &cpo
set cpo&vim
let b:undo_ftplugin .= "| unlet! b:match_ignorecase b:match_skip b:match_words"
let &l:define .= '\|\\new\(count\|dimen\|skip\|muskip\|box\|toks\|read\|write'
\ .	'\|fam\|insert\)'
if exists("loaded_matchit")
let b:match_ignorecase = 0
\ | let b:match_skip = 'r:\\\@<!\%(\\\\\)*%'
\ | let b:match_words = '(:),\[:],{:},\\(:\\),\\\[:\\],\\{:\\}'
endif " exists("loaded_matchit")
let &cpo = s:save_cpo
unlet s:save_cpo
