if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
setl comments=:;
setl define=^\\s*(def\\k*
setl formatoptions-=t
setl iskeyword+=+,-,*,/,%,<,=,>,:,$,?,!,@-@,94
setl lisp
setl commentstring=;%s
setl comments^=:;;;,:;;,sr:#\|,mb:\|,ex:\|#
let b:undo_ftplugin = "setlocal comments< define< formatoptions< iskeyword< lisp< commentstring<"
