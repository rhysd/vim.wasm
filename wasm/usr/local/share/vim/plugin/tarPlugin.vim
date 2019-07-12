if &cp || exists("g:loaded_tarPlugin")
finish
endif
let g:loaded_tarPlugin = "v29"
let s:keepcpo          = &cpo
set cpo&vim
augroup tar
au!
au BufReadCmd   tarfile::*	call tar#Read(expand("<amatch>"), 1)
au FileReadCmd  tarfile::*	call tar#Read(expand("<amatch>"), 0)
au BufWriteCmd  tarfile::*	call tar#Write(expand("<amatch>"))
au FileWriteCmd tarfile::*	call tar#Write(expand("<amatch>"))
if has("unix")
au BufReadCmd   tarfile::*/*	call tar#Read(expand("<amatch>"), 1)
au FileReadCmd  tarfile::*/*	call tar#Read(expand("<amatch>"), 0)
au BufWriteCmd  tarfile::*/*	call tar#Write(expand("<amatch>"))
au FileWriteCmd tarfile::*/*	call tar#Write(expand("<amatch>"))
endif
au BufReadCmd   *.tar.gz		call tar#Browse(expand("<amatch>"))
au BufReadCmd   *.tar			call tar#Browse(expand("<amatch>"))
au BufReadCmd   *.lrp			call tar#Browse(expand("<amatch>"))
au BufReadCmd   *.tar.bz2		call tar#Browse(expand("<amatch>"))
au BufReadCmd   *.tar.Z		call tar#Browse(expand("<amatch>"))
au BufReadCmd   *.tgz			call tar#Browse(expand("<amatch>"))
au BufReadCmd   *.tbz			call tar#Browse(expand("<amatch>"))
au BufReadCmd   *.tar.lzma	call tar#Browse(expand("<amatch>"))
au BufReadCmd   *.tar.xz		call tar#Browse(expand("<amatch>"))
au BufReadCmd   *.txz			call tar#Browse(expand("<amatch>"))
augroup END
com! -nargs=? -complete=file Vimuntar call tar#Vimuntar(<q-args>)
let &cpo= s:keepcpo
unlet s:keepcpo
