if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1
let s:cpo_save = &cpoptions
set cpoptions&vim
setlocal include=\\<\\cINPUT\\s*=
setlocal includeexpr=substitute(v:fname,'.\\{-}=','','')
setlocal isfname-=,
setlocal comments=:**
setlocal commentstring=**%s
setlocal define=^\\*\\a.*\\c\\(NAME\\\|NSET\\\|ELSET\\)\\s*=
setlocal iskeyword+=-
let b:undo_ftplugin = "setlocal include< includeexpr< isfname<"
\ . " comments< commentstring< define< iskeyword<"
if has("folding")
setlocal foldexpr=getline(v:lnum)[0]!=\"\*\"
setlocal foldmethod=expr
let b:undo_ftplugin .= " foldexpr< foldmethod<"
endif
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "Abaqus Input Files (*.inp *.inc)\t*.inp;*.inc\n" .
\ "Abaqus Results (*.dat)\t*.dat\n" .
\ "Abaqus Messages (*.pre *.msg *.sta)\t*.pre;*.msg;*.sta\n" .
\ "All Files (*.*)\t*.*\n"
let b:undo_ftplugin .= "|unlet! b:browsefilter"
endif
if exists("loaded_matchit") && !exists("b:match_words")
let b:match_ignorecase = 1
let b:match_words = 
\ '\*part:\*end\s*part,' .
\ '\*assembly:\*end\s*assembly,' .
\ '\*instance:\*end\s*instance,' .
\ '\*step:\*end\s*step'
let b:undo_ftplugin .= "|unlet! b:match_ignorecase b:match_words"
endif
noremap <silent><buffer> [[ ?^\*\a<CR>:nohlsearch<CR>
noremap <silent><buffer> ]] /^\*\a<CR>:nohlsearch<CR>
noremap <silent><buffer> <LocalLeader><LocalLeader> 
\ :call <SID>Abaqus_ToggleComment()<CR>j
function! <SID>Abaqus_ToggleComment() range
if strpart(getline(a:firstline), 0, 2) == "**"
silent execute a:firstline . ',' . a:lastline . 's/^\*\*//'
else
silent execute a:firstline . ',' . a:lastline . 's/^/**/'
endif
endfunction
let b:undo_ftplugin .= "|unmap <buffer> [[|unmap <buffer> ]]"
\ . "|unmap <buffer> <LocalLeader><LocalLeader>"
let b:undo_ftplugin = "let s:cpo_save = &cpoptions|"
\ . "set cpoptions&vim|"
\ . b:undo_ftplugin
\ . "|let &cpoptions = s:cpo_save"
\ . "|unlet s:cpo_save"
let &cpoptions = s:cpo_save
unlet s:cpo_save
