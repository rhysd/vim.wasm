if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let b:undo_ftplugin = "setl modeline< tw< fo< comments<"
setlocal nomodeline
if &tw == 0
setlocal tw=72
endif
setlocal fo+=tcql
setlocal comments+=n:>
if !exists("no_plugin_maps") && !exists("no_mail_maps")
if !hasmapto('<Plug>MailQuote')
vmap <buffer> <LocalLeader>q <Plug>MailQuote
nmap <buffer> <LocalLeader>q <Plug>MailQuote
endif
vnoremap <buffer> <Plug>MailQuote :s/^/> /<CR>:noh<CR>``
nnoremap <buffer> <Plug>MailQuote :.,$s/^/> /<CR>:noh<CR>``
endif
