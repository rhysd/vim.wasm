if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
setlocal comments=s:(;,e:;),:;;
setlocal commentstring=(;%s;)
setlocal formatoptions-=t
setlocal iskeyword+=$,.,/
let b:undo_ftplugin = "setlocal comments< commentstring< formatoptions< iskeyword<"
