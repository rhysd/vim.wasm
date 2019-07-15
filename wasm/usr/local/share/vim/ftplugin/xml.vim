if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1
let s:save_cpo = &cpo
set cpo&vim
setlocal commentstring=<!--%s-->
setlocal comments=s:<!--,e:-->
setlocal formatoptions-=t
setlocal formatoptions+=croql
setlocal formatexpr=xmlformat#Format()
if exists("loaded_matchit")
let b:match_ignorecase=0
let b:match_words =
\  '<:>,' .
\  '<\@<=!\[CDATA\[:]]>,'.
\  '<\@<=!--:-->,'.
\  '<\@<=?\k\+:?>,'.
\  '<\@<=\([^ \t>/]\+\)\%(\s\+[^>]*\%([^/]>\|$\)\|>\|$\):<\@<=/\1>,'.
\  '<\@<=\%([^ \t>/]\+\)\%(\s\+[^/>]*\|$\):/>'
endif
if exists('&ofu')
setlocal ofu=xmlcomplete#CompleteTags
endif
command! -nargs=+ XMLns call xmlcomplete#CreateConnection(<f-args>)
command! -nargs=? XMLent call xmlcomplete#CreateEntConnection(<f-args>)
if (has("gui_win32") || has("gui_gtk")) && !exists("b:browsefilter")
let  b:browsefilter="XML Files (*.xml)\t*.xml\n" .
\ "DTD Files (*.dtd)\t*.dtd\n" .
\ "XSD Files (*.xsd)\t*.xsd\n" .
\ "All Files (*.*)\t*.*\n"
endif
let b:undo_ftplugin = "setlocal commentstring< comments< formatoptions< formatexpr< " .
\     " | unlet! b:match_ignorecase b:match_words b:browsefilter"
let &cpo = s:save_cpo
unlet s:save_cpo
