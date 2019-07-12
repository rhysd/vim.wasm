if exists('b:did_ftplugin')
finish
endif
let b:did_ftplugin = 1
let b:undo_ftplugin = 'setlocal formatoptions< comments< commentstring<'
setlocal formatoptions-=t
setlocal comments=
setlocal commentstring=
