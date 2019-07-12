if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
setlocal efm=%+A./%f:%l.%c:\ %m formatprg=fmt\ -w75\ -p\\%
setlocal formatprg=fmt\ -w75\ -p\\%
if !exists("no_plugin_maps") && !exists("no_lprolog_maps")
if !hasmapto('<Plug>Comment')
nmap <buffer> <LocalLeader>c <Plug>LUncomOn
vmap <buffer> <LocalLeader>c <Plug>BUncomOn
nmap <buffer> <LocalLeader>C <Plug>LUncomOff
vmap <buffer> <LocalLeader>C <Plug>BUncomOff
endif
nnoremap <buffer> <Plug>LUncomOn mz0i/* <ESC>$A */<ESC>`z
nnoremap <buffer> <Plug>LUncomOff <ESC>:s/^\/\* \(.*\) \*\//\1/<CR>
vnoremap <buffer> <Plug>BUncomOn <ESC>:'<,'><CR>`<O<ESC>0i/*<ESC>`>o<ESC>0i*/<ESC>`<
vnoremap <buffer> <Plug>BUncomOff <ESC>:'<,'><CR>`<dd`>dd`<
endif
