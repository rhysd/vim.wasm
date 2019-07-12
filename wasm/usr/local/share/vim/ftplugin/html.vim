if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1
let s:save_cpo = &cpo
set cpo-=C
setlocal matchpairs+=<:>
setlocal commentstring=<!--%s-->
setlocal comments=s:<!--,m:\ \ \ \ ,e:-->
if exists("g:ft_html_autocomment") && (g:ft_html_autocomment == 1)
setlocal formatoptions-=t formatoptions+=croql
endif
if exists('&omnifunc')
setlocal omnifunc=htmlcomplete#CompleteTags
call htmlcomplete#DetectOmniFlavor()
endif
if exists("loaded_matchit")
let b:match_ignorecase = 1
let b:match_words = '<:>,' .
\ '<\@<=[ou]l\>[^>]*\%(>\|$\):<\@<=li\>:<\@<=/[ou]l>,' .
\ '<\@<=dl\>[^>]*\%(>\|$\):<\@<=d[td]\>:<\@<=/dl>,' .
\ '<\@<=\([^/][^ \t>]*\)[^>]*\%(>\|$\):<\@<=/\1>'
endif
if has("gui_win32")
let  b:browsefilter="HTML Files (*.html,*.htm)\t*.htm;*.html\n" .
\	"JavaScript Files (*.js)\t*.js\n" .
\	"Cascading StyleSheets (*.css)\t*.css\n" .
\	"All Files (*.*)\t*.*\n"
endif
let b:undo_ftplugin = "setlocal commentstring< matchpairs< omnifunc< comments< formatoptions<" .
\	" | unlet! b:match_ignorecase b:match_skip b:match_words b:browsefilter"
let &cpo = s:save_cpo
unlet s:save_cpo
