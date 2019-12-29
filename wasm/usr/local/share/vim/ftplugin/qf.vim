if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
if !get(g:, 'qf_disable_statusline')
let b:undo_ftplugin = "set stl<"
setlocal stl=%t%{exists('w:quickfix_title')?\ '\ '.w:quickfix_title\ :\ ''}\ %=%-15(%l,%c%V%)\ %P
endif
