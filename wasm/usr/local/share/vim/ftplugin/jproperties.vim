if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
setlocal formatoptions-=t
setlocal comments=:#,:!
setlocal commentstring=#\ %s
let b:undo_ftplugin = "setl cms< com< fo<"
