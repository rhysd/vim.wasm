if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo&vim
let b:undo_ftplugin = "setl fo< com< tw< commentstring<"
\ . "| unlet! b:match_ignorecase b:match_words b:match_skip"
setlocal fo-=t fo+=croql
setlocal comments=:#
if &tw == 0
setlocal tw=78
endif
setlocal commentstring=#%s
noremap <silent><buffer> [[ :call search('^\s*sub\>', "bW")<CR>
noremap <silent><buffer> ]] :call search('^\s*sub\>', "W")<CR>
noremap <silent><buffer> [] :call search('^\s*endsub\>', "bW")<CR>
noremap <silent><buffer> ][ :call search('^\s*endsub\>', "W")<CR>
noremap <silent><buffer> ]# :call search('^\s*#\@!', "W")<CR>
noremap <silent><buffer> [# :call search('^\s*#\@!', "bW")<CR>
if exists("loaded_matchit")
let b:match_ignorecase = 0
let b:match_words =
\ '\<sub\>:\<return\>:\<endsub\>,' .
\ '\<do\|while\|repeat\|for\>:\<break\>:\<continue\>:\<loop\|endwhile\|until\|endfor\>,' .
\ '\<if\>:\<else\%[if]\>:\<endif\>' 
endif
setlocal ignorecase
let &cpo = s:cpo_save
unlet s:cpo_save
setlocal cpo+=M		" makes \%( match \)
