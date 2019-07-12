if exists("b:did_ftplugin")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
let b:did_ftplugin = 1
let b:undo_ftplugin = "setl commentstring<"
if exists('loaded_matchit')
let b:match_words = '\<if\>:\<elseif\>\|\<else\>:\<endif\>'
\ . ',\<foreach\>\|\<while\>:\<break\>:\<endforeach\>\|\<endwhile\>'
\ . ',\<macro\>:\<endmacro\>'
\ . ',\<function\>:\<endfunction\>'
let b:match_ignorecase = 1
let b:undo_ftplugin .= "| unlet b:match_words"
endif
setlocal commentstring=#\ %s
let &cpo = s:cpo_save
unlet s:cpo_save
