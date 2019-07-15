if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo&vim
let b:undo_ftplugin = "setlocal fo< com< tw<"
\ . "| unlet! b:browsefilter b:match_ignorecase b:match_words"
setlocal fo-=t fo+=croqlm1
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
if &textwidth == 0 
setlocal tw=78
endif
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "Verilog Source Files (*.v)\t*.v\n" .
\ "All Files (*.*)\t*.*\n"
endif
if exists("loaded_matchit")
let b:match_ignorecase=0
let b:match_words=
\ '\<begin\>:\<end\>,' .
\ '\<case\>\|\<casex\>\|\<casez\>:\<endcase\>,' .
\ '\<module\>:\<endmodule\>,' .
\ '\<if\>:`\@<!\<else\>,' .
\ '\<function\>:\<endfunction\>,' .
\ '`ifn\?def\>:`elsif\>:`else\>:`endif\>,' .
\ '\<task\>:\<endtask\>,' .
\ '\<specify\>:\<endspecify\>,' .
\ '\<config\>:\<endconfig\>,' .
\ '\<generate\>:\<endgenerate\>,' .
\ '\<fork\>:\<join\>,' .
\ '\<primitive\>:\<endprimitive\>,' .
\ '\<table\>:\<endtable\>'
endif
let &cpo = s:cpo_save
unlet s:cpo_save
