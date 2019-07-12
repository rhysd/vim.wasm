if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
setlocal nomodeline
let b:undo_ftplugin = 'setl modeline<'
