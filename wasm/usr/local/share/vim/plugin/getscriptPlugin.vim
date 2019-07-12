if exists("g:loaded_getscriptPlugin")
finish
endif
if &cp
if &verbose
echo "GetLatestVimScripts is not vi-compatible; not loaded (you need to set nocp)"
endif
finish
endif
let g:loaded_getscriptPlugin = "v36"
let s:keepcpo                = &cpo
set cpo&vim
com!        -nargs=0 GetLatestVimScripts call getscript#GetLatestVimScripts()
com!        -nargs=0 GetScripts          call getscript#GetLatestVimScripts()
silent! com -nargs=0 GLVS                call getscript#GetLatestVimScripts()
let &cpo= s:keepcpo
unlet s:keepcpo
