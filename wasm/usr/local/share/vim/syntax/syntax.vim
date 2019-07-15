if !has("syntax")
finish
endif
if exists("syntax_on") || exists("syntax_manual")
so <sfile>:p:h/nosyntax.vim
endif
runtime syntax/synload.vim
if exists("did_load_filetypes")
let s:did_ft = 1
else
filetype on
let s:did_ft = 0
endif
augroup syntaxset
au! FileType *	exe "set syntax=" . expand("<amatch>")
augroup END
doautoall syntaxset FileType
if !s:did_ft
doautoall filetypedetect BufRead
endif
