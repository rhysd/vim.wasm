if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1  " Don't load another plugin for this buffer
let b:undo_ftplugin = "setl tw< wrap< lbr< et< ts< fenc< bomb< ff<"
setlocal textwidth=0
setlocal wrap
setlocal linebreak
setlocal noexpandtab
setlocal tabstop=4
setlocal fileencoding=utf-8
setlocal bomb
setlocal fileformat=unix
if exists("g:flexwiki_maps")
nmap <buffer> <Up>   gk
nmap <buffer> k      gk
vmap <buffer> <Up>   gk
vmap <buffer> k      gk
nmap <buffer> <Down> gj
nmap <buffer> j      gj
vmap <buffer> <Down> gj
vmap <buffer> j      gj
imap <buffer> <S-Down>   <C-o>gj
imap <buffer> <S-Up>     <C-o>gk
if v:version >= 700
imap <buffer> <Down>   <C-o>gj
imap <buffer> <Up>     <C-o>gk
endif
endif
