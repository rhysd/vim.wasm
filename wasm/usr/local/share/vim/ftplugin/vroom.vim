if exists('b:did_ftplugin')
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo-=C
let b:undo_ftplugin = 'setlocal formatoptions< shiftwidth< softtabstop<' .
\ ' expandtab< iskeyword< comments< commentstring<'
setlocal formatoptions-=t
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab
setlocal iskeyword+=#
setlocal comments=
setlocal commentstring=
let &cpo = s:cpo_save
unlet s:cpo_save
