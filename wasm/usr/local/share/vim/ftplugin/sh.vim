if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1
let s:save_cpo = &cpo
set cpo-=C
setlocal commentstring=#%s
if exists("loaded_matchit")
let s:sol = '\%(;\s*\|^\s*\)\@<='  " start of line
let b:match_words =
\ s:sol.'if\>:' . s:sol.'elif\>:' . s:sol.'else\>:' . s:sol. 'fi\>,' .
\ s:sol.'\%(for\|while\)\>:' . s:sol. 'done\>,' .
\ s:sol.'case\>:' . s:sol. 'esac\>'
endif
if has("gui_win32")
let  b:browsefilter="Bourne Shell Scripts (*.sh)\t*.sh\n" .
\	"Korn Shell Scripts (*.ksh)\t*.ksh\n" .
\	"Bash Shell Scripts (*.bash)\t*.bash\n" .
\	"All Files (*.*)\t*.*\n"
endif
let b:undo_ftplugin = "setlocal cms< | unlet! b:browsefilter b:match_words"
let &cpo = s:save_cpo
unlet s:save_cpo
