if exists("b:did_ftplugin")
finish
endif
if exists('g:rmd_include_html') && g:rmd_include_html
runtime! ftplugin/html.vim ftplugin/html_*.vim ftplugin/html/*.vim
endif
setlocal comments=fb:*,fb:-,fb:+,n:>
setlocal commentstring=#\ %s
setlocal formatoptions+=tcqln
setlocal formatlistpat=^\\s*\\d\\+\\.\\s\\+\\\|^\\s*[-*+]\\s\\+
setlocal iskeyword=@,48-57,_,.
let s:cpo_save = &cpo
set cpo&vim
function! FormatRmd()
if search("^[ \t]*```[ ]*{r", "bncW") > search("^[ \t]*```$", "bncW")
setlocal comments=:#',:###,:##,:#
else
setlocal comments=fb:*,fb:-,fb:+,n:>
endif
return 1
endfunction
if !exists("g:rmd_dynamic_comments") || (exists("g:rmd_dynamic_comments") && g:rmd_dynamic_comments == 1)
setlocal formatexpr=FormatRmd()
endif
unlet! b:did_ftplugin
runtime ftplugin/pandoc.vim
let b:did_ftplugin = 1
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
