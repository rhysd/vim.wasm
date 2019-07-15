if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo&vim
if !exists('g:rst_fold_enabled')
let g:rst_fold_enabled = 0
endif
let b:undo_ftplugin = "setl com< cms< et< fo<"
setlocal comments=fb:.. commentstring=..\ %s expandtab
setlocal formatoptions+=tcroql
if exists("g:rst_style") && g:rst_style != 0
setlocal expandtab shiftwidth=3 softtabstop=3 tabstop=8
endif
if has('patch-7.3.867')  " Introduced the TextChanged event.
setlocal foldmethod=expr
setlocal foldexpr=RstFold#GetRstFold()
setlocal foldtext=RstFold#GetRstFoldText()
augroup RstFold
autocmd TextChanged,InsertLeave <buffer> unlet! b:RstFoldCache
augroup END
endif
let &cpo = s:cpo_save
unlet s:cpo_save
