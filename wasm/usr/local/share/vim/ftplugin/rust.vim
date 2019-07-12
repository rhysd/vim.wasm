if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:save_cpo = &cpo
set cpo&vim
augroup rust.vim
autocmd!
if exists("g:rust_bang_comment_leader") && g:rust_bang_comment_leader != 0
setlocal comments=s1:/*,mb:*,ex:*/,s0:/*,mb:\ ,ex:*/,:///,://!,://
else
setlocal comments=s0:/*!,m:\ ,ex:*/,s1:/*,mb:*,ex:*/,:///,://!,://
endif
setlocal commentstring=//%s
setlocal formatoptions-=t formatoptions+=croqnl
silent! setlocal formatoptions+=j
setlocal smartindent nocindent
if !exists("g:rust_recommended_style") || g:rust_recommended_style != 0
setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
setlocal textwidth=99
endif
setlocal includeexpr=substitute(v:fname,'::','/','g')
setlocal suffixesadd=.rs
if exists("g:ftplugin_rust_source_path")
let &l:path=g:ftplugin_rust_source_path . ',' . &l:path
endif
if exists("g:loaded_delimitMate")
if exists("b:delimitMate_excluded_regions")
let b:rust_original_delimitMate_excluded_regions = b:delimitMate_excluded_regions
endif
let s:delimitMate_extra_excluded_regions = ',rustLifetimeCandidate,rustGenericLifetimeCandidate'
autocmd User <buffer>
\ if expand('<afile>') ==# 'delimitMate_map' && match(
\     delimitMate#Get("excluded_regions"),
\     s:delimitMate_extra_excluded_regions) == -1
\|  let b:delimitMate_excluded_regions =
\       delimitMate#Get("excluded_regions")
\       . s:delimitMate_extra_excluded_regions
\|endif
autocmd User <buffer>
\ if expand('<afile>') ==# 'delimitMate_unmap'
\|  let b:delimitMate_excluded_regions = substitute(
\       delimitMate#Get("excluded_regions"),
\       '\C\V' . s:delimitMate_extra_excluded_regions,
\       '', 'g')
\|endif
endif
if has("folding") && exists('g:rust_fold') && g:rust_fold != 0
let b:rust_set_foldmethod=1
setlocal foldmethod=syntax
if g:rust_fold == 2
setlocal foldlevel<
else
setlocal foldlevel=99
endif
endif
if has('conceal') && exists('g:rust_conceal') && g:rust_conceal != 0
let b:rust_set_conceallevel=1
setlocal conceallevel=2
endif
nnoremap <silent> <buffer> [[ :call rust#Jump('n', 'Back')<CR>
nnoremap <silent> <buffer> ]] :call rust#Jump('n', 'Forward')<CR>
xnoremap <silent> <buffer> [[ :call rust#Jump('v', 'Back')<CR>
xnoremap <silent> <buffer> ]] :call rust#Jump('v', 'Forward')<CR>
onoremap <silent> <buffer> [[ :call rust#Jump('o', 'Back')<CR>
onoremap <silent> <buffer> ]] :call rust#Jump('o', 'Forward')<CR>
command! -nargs=* -complete=file -bang -buffer RustRun call rust#Run(<bang>0, <q-args>)
command! -nargs=* -complete=customlist,rust#CompleteExpand -bang -buffer RustExpand call rust#Expand(<bang>0, <q-args>)
command! -nargs=* -buffer RustEmitIr call rust#Emit("llvm-ir", <q-args>)
command! -nargs=* -buffer RustEmitAsm call rust#Emit("asm", <q-args>)
command! -range=% RustPlay :call rust#Play(<count>, <line1>, <line2>, <f-args>)
command! -buffer RustFmt call rustfmt#Format()
command! -range -buffer RustFmtRange call rustfmt#FormatRange(<line1>, <line2>)
nnoremap <silent> <buffer> <D-r> :RustRun<CR>
nnoremap <buffer> <D-R> :RustRun! <C-r>=join(b:rust_last_rustc_args)<CR><C-\>erust#AppendCmdLine(' -- ' . join(b:rust_last_args))<CR>
if !exists("b:rust_last_rustc_args") || !exists("b:rust_last_args")
let b:rust_last_rustc_args = []
let b:rust_last_args = []
endif
let b:undo_ftplugin = "
\ setlocal formatoptions< comments< commentstring< includeexpr< suffixesadd<
\|setlocal tabstop< shiftwidth< softtabstop< expandtab< textwidth<
\|if exists('b:rust_original_delimitMate_excluded_regions')
\|let b:delimitMate_excluded_regions = b:rust_original_delimitMate_excluded_regions
\|unlet b:rust_original_delimitMate_excluded_regions
\|else
\|unlet! b:delimitMate_excluded_regions
\|endif
\|if exists('b:rust_set_foldmethod')
\|setlocal foldmethod< foldlevel<
\|unlet b:rust_set_foldmethod
\|endif
\|if exists('b:rust_set_conceallevel')
\|setlocal conceallevel<
\|unlet b:rust_set_conceallevel
\|endif
\|unlet! b:rust_last_rustc_args b:rust_last_args
\|delcommand RustRun
\|delcommand RustExpand
\|delcommand RustEmitIr
\|delcommand RustEmitAsm
\|delcommand RustPlay
\|nunmap <buffer> <D-r>
\|nunmap <buffer> <D-R>
\|nunmap <buffer> [[
\|nunmap <buffer> ]]
\|xunmap <buffer> [[
\|xunmap <buffer> ]]
\|ounmap <buffer> [[
\|ounmap <buffer> ]]
\|set matchpairs-=<:>
\"
if get(g:, "rustfmt_autosave", 0)
autocmd BufWritePre *.rs silent! call rustfmt#Format()
endif
augroup END
let &cpo = s:save_cpo
unlet s:save_cpo
