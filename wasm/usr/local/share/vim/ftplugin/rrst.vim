if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo&vim
setlocal comments=fb:*,fb:-,fb:+,n:>
setlocal commentstring=#\ %s
setlocal formatoptions+=tcqln
setlocal formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^\\s*[-*+]\\s\\+
setlocal iskeyword=@,48-57,_,.
function! FormatRrst()
if search('^\.\. {r', "bncW") > search('^\.\. \.\.$', "bncW")
setlocal comments=:#',:###,:##,:#
else
setlocal comments=fb:*,fb:-,fb:+,n:>
endif
return 1
endfunction
if !exists("g:rrst_dynamic_comments") || (exists("g:rrst_dynamic_comments") && g:rrst_dynamic_comments == 1)
setlocal formatexpr=FormatRrst()
endif
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "R Source Files (*.R *.Rnw *.Rd *.Rmd *.Rrst)\t*.R;*.Rnw;*.Rd;*.Rmd;*.Rrst\n" .
\ "All Files (*.*)\t*.*\n"
endif
if exists('b:undo_ftplugin')
let b:undo_ftplugin .= " | setl cms< com< fo< flp< isk< | unlet! b:browsefilter"
else
let b:undo_ftplugin = "setl cms< com< fo< flp< isk< | unlet! b:browsefilter"
endif
let &cpo = s:cpo_save
unlet s:cpo_save
