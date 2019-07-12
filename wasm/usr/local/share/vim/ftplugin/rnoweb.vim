if exists("b:did_ftplugin")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
runtime! ftplugin/tex.vim
let b:did_ftplugin = 1
runtime ftplugin/tex_*.vim
setlocal iskeyword=@,48-57,_,.
setlocal suffixesadd=.bib,.tex
setlocal comments=b:%,b:#,b:##,b:###,b:#'
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "R Source Files (*.R *.Rnw *.Rd *.Rmd *.Rrst)\t*.R;*.Rnw;*.Rd;*.Rmd;*.Rrst\n" .
\ "All Files (*.*)\t*.*\n"
endif
if exists('b:undo_ftplugin')
let b:undo_ftplugin .= " | setl isk< sua< com< | unlet! b:browsefilter"
else
let b:undo_ftplugin = "setl isk< sua< com< | unlet! b:browsefilter"
endif
let &cpo = s:cpo_save
unlet s:cpo_save
