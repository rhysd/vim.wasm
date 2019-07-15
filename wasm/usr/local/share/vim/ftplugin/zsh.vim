if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo&vim
let b:undo_ftplugin = "setl com< cms< fo<"
setlocal comments=:# commentstring=#\ %s formatoptions-=t formatoptions+=croql
let b:match_words = ',\<if\>:\<elif\>:\<else\>:\<fi\>'
\ . ',\<case\>:^\s*([^)]*):\<esac\>'
\ . ',\<\%(select\|while\|until\|repeat\|for\%(each\)\=\)\>:\<done\>'
let b:match_skip = 's:comment\|string\|heredoc\|subst'
let &cpo = s:cpo_save
unlet s:cpo_save
