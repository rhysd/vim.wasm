if exists("did_load_ftplugin")
finish
endif
let did_load_ftplugin = 1
augroup filetypeplugin
au FileType * call s:LoadFTPlugin()
func! s:LoadFTPlugin()
if exists("b:undo_ftplugin")
exe b:undo_ftplugin
unlet! b:undo_ftplugin b:did_ftplugin
endif
let s = expand("<amatch>")
if s != ""
if &cpo =~# "S" && exists("b:did_ftplugin")
unlet b:did_ftplugin
endif
for name in split(s, '\.')
exe 'runtime! ftplugin/' . name . '.vim ftplugin/' . name . '_*.vim ftplugin/' . name . '/*.vim'
endfor
endif
endfunc
augroup END
