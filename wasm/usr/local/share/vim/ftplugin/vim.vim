if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo-=C
if !exists('*VimFtpluginUndo')
func VimFtpluginUndo()
setl fo< isk< com< tw< commentstring<
if exists('b:did_add_maps')
silent! nunmap <buffer> [[
silent! vunmap <buffer> [[
silent! nunmap <buffer> ]]
silent! vunmap <buffer> ]]
silent! nunmap <buffer> []
silent! vunmap <buffer> []
silent! nunmap <buffer> ][
silent! vunmap <buffer> ][
silent! nunmap <buffer> ]"
silent! vunmap <buffer> ]"
silent! nunmap <buffer> ["
silent! vunmap <buffer> ["
endif
unlet! b:match_ignorecase b:match_words b:match_skip b:did_add_maps
endfunc
endif
let b:undo_ftplugin = "call VimFtpluginUndo()"
setlocal fo-=t fo+=croql
setlocal isk+=#
setlocal keywordprg=:help
setlocal com=sO:\"\ -,mO:\"\ \ ,eO:\"\",:\"
if &tw == 0
setlocal tw=78
endif
setlocal commentstring=\"%s
if !exists("no_plugin_maps") && !exists("no_vim_maps")
let b:did_add_maps = 1
nnoremap <silent><buffer> [[ m':call search('^\s*fu\%[nction]\>', "bW")<CR>
vnoremap <silent><buffer> [[ m':<C-U>exe "normal! gv"<Bar>call search('^\s*fu\%[nction]\>', "bW")<CR>
nnoremap <silent><buffer> ]] m':call search('^\s*fu\%[nction]\>', "W")<CR>
vnoremap <silent><buffer> ]] m':<C-U>exe "normal! gv"<Bar>call search('^\s*fu\%[nction]\>', "W")<CR>
nnoremap <silent><buffer> [] m':call search('^\s*endf\%[unction]\>', "bW")<CR>
vnoremap <silent><buffer> [] m':<C-U>exe "normal! gv"<Bar>call search('^\s*endf\%[unction]\>', "bW")<CR>
nnoremap <silent><buffer> ][ m':call search('^\s*endf\%[unction]\>', "W")<CR>
vnoremap <silent><buffer> ][ m':<C-U>exe "normal! gv"<Bar>call search('^\s*endf\%[unction]\>', "W")<CR>
nnoremap <silent><buffer> ]" :call search('^\(\s*".*\n\)\@<!\(\s*"\)', "W")<CR>
vnoremap <silent><buffer> ]" :<C-U>exe "normal! gv"<Bar>call search('^\(\s*".*\n\)\@<!\(\s*"\)', "W")<CR>
nnoremap <silent><buffer> [" :call search('\%(^\s*".*\n\)\%(^\s*"\)\@!', "bW")<CR>
vnoremap <silent><buffer> [" :<C-U>exe "normal! gv"<Bar>call search('\%(^\s*".*\n\)\%(^\s*"\)\@!', "bW")<CR>
endif
if exists("loaded_matchit")
let b:match_ignorecase = 0
let b:match_words =
\ '\<fu\%[nction]\>:\<retu\%[rn]\>:\<endf\%[unction]\>,' .
\ '\<\(wh\%[ile]\|for\)\>:\<brea\%[k]\>:\<con\%[tinue]\>:\<end\(w\%[hile]\|fo\%[r]\)\>,' .
\ '\<if\>:\<el\%[seif]\>:\<en\%[dif]\>,' .
\ '\<try\>:\<cat\%[ch]\>:\<fina\%[lly]\>:\<endt\%[ry]\>,' .
\ '\<aug\%[roup]\s\+\%(END\>\)\@!\S:\<aug\%[roup]\s\+END\>,'
let b:match_skip = 'synIDattr(synID(line("."),col("."),1),"name")
\ =~? "comment\\|string\\|vimSynReg\\|vimSet"'
endif
let &cpo = s:cpo_save
unlet s:cpo_save
