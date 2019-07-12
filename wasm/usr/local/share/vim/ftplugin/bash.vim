if exists("b:did_ftplugin")
finish
endif
let b:is_bash = 1
if exists("b:is_sh")
unlet b:is_sh
endif
if exists("b:is_kornshell")
unlet b:is_kornshell
endif
augroup bash_filetype
au BufWinEnter * call SetBashFt()
augroup END
func SetBashFt()
au! bash_filetype
set ft=sh
endfunc
