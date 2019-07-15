if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1
let s:save_cpo = &cpo
set cpo-=C
setlocal commentstring=#%s
setlocal formatoptions-=t
setlocal formatoptions+=crql
if exists("loaded_matchit")
let b:match_words =
\ '^\s*\<if\>.*(.*).*\<then\>:'.
\   '^\s*\<else\>\s\+\<if\>.*(.*).*\<then\>:^\s*\<else\>:'.
\   '^\s*\<endif\>,'.
\ '\%(^\s*\<foreach\>\s\+\S\+\|^s*\<while\>\).*(.*):'.
\   '\<break\>:\<continue\>:^\s*\<end\>,'.
\ '^\s*\<switch\>.*(.*):^\s*\<case\>\s\+:^\s*\<default\>:^\s*\<endsw\>'
endif
if has("gui_win32")
let  b:browsefilter="csh Scripts (*.csh)\t*.csh\n" .
\	"All Files (*.*)\t*.*\n"
endif
let b:undo_ftplugin = "setlocal commentstring< formatoptions<" .
\     " | unlet! b:match_words b:browsefilter"
let &cpo = s:save_cpo
unlet s:save_cpo
