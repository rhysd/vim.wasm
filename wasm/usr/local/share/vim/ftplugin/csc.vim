if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1
let s:save_cpo = &cpo
set cpo-=C
if exists("loaded_matchit")
let b:match_words=
\ '\<fix\>:\<endfix\>,' .
\ '\<if\>:\<else\%(if\)\=\>:\<endif\>,' .
\ '\<!loopondimensions\>\|\<!looponselected\>:\<!endloop\>'
endif
let b:undo_ftplugin = "unlet! b:match_words"
let &cpo = s:save_cpo
unlet s:save_cpo
