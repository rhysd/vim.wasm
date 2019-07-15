fun s:check(cmd)
let name = substitute(a:cmd, '\(\S*\).*', '\1', '')
if !exists("s:have_" . name)
let e = executable(name)
if e < 0
let r = system(name . " --version")
let e = (r !~ "not found" && r != "")
endif
exe "let s:have_" . name . "=" . e
endif
exe "return s:have_" . name
endfun
fun s:set_compression(line)
let l:cm = char2nr(a:line[2])
if l:cm == 8
let l:xfl = char2nr(a:line[8])
if l:xfl == 2
let b:gzip_comp_arg = "-9"
elseif l:xfl == 4
let b:gzip_comp_arg = "-1"
endif
endif
endfun
fun gzip#read(cmd)
if !s:check(a:cmd)
return
endif
silent! unlet b:gzip_comp_arg
if a:cmd[0] == 'g'
call s:set_compression(getline(1))
endif
let pm_save = &pm
set pm=
let cpo_save = &cpo
set cpo-=a cpo-=A
let ma_save = &ma
setlocal ma
let write_save = &write
set write
if has("folding")
let fen_save = &fen
setlocal nofen
endif
let empty = line("'[") == 1 && line("']") == line("$")
let tmp = tempname()
let tmpe = tmp . "." . expand("<afile>:e")
if exists('*fnameescape')
let tmp_esc = fnameescape(tmp)
let tmpe_esc = fnameescape(tmpe)
else
let tmp_esc = escape(tmp, ' ')
let tmpe_esc = escape(tmpe, ' ')
endif
execute "silent '[,']w " . tmpe_esc
call system(a:cmd . " " . s:escape(tmpe))
if !filereadable(tmp)
echoerr "Error: Could not read uncompressed file"
let ok = 0
else
let ok = 1
let l = line("'[") - 1
if exists(":lockmarks")
lockmarks '[,']d _
else
'[,']d _
endif
setlocal nobin
if exists(":lockmarks")
if empty
execute "silent lockmarks " . l . "r ++edit " . tmp_esc
else
execute "silent lockmarks " . l . "r " . tmp_esc
endif
else
execute "silent " . l . "r " . tmp_esc
endif
if empty
silent $delete _
1
endif
call delete(tmp)
silent! exe "bwipe " . tmp_esc
silent! exe "bwipe " . tmpe_esc
endif
let b:uncompressOk = ok
let &pm = pm_save
let &cpo = cpo_save
let &l:ma = ma_save
let &write = write_save
if has("folding")
let &l:fen = fen_save
endif
if ok && empty
if exists('*fnameescape')
let fname = fnameescape(expand("%:r"))
else
let fname = escape(expand("%:r"), " \t\n*?[{`$\\%#'\"|!<")
endif
if &verbose >= 8
execute "doau BufReadPost " . fname
else
execute "silent! doau BufReadPost " . fname
endif
endif
endfun
fun gzip#write(cmd)
if exists('b:uncompressOk') && !b:uncompressOk
echomsg "Not compressing file because uncompress failed; reset b:uncompressOk to compress anyway"
elseif s:check(a:cmd)
let nm = resolve(expand("<afile>"))
let nmt = s:tempname(nm)
if rename(nm, nmt) == 0
if exists("b:gzip_comp_arg")
call system(a:cmd . " " . b:gzip_comp_arg . " -- " . s:escape(nmt))
else
call system(a:cmd . " -- " . s:escape(nmt))
endif
call rename(nmt . "." . expand("<afile>:e"), nm)
endif
endif
endfun
fun gzip#appre(cmd)
if s:check(a:cmd)
let nm = expand("<afile>")
silent! unlet b:gzip_comp_arg
if a:cmd[0] == 'g'
call s:set_compression(readfile(nm, "b", 1)[0])
endif
let nmt = expand("<afile>:p:h") . "/X~=@l9q5"
let nmte = nmt . "." . expand("<afile>:e")
if rename(nm, nmte) == 0
if &patchmode != "" && getfsize(nm . &patchmode) == -1
call system(a:cmd . " -c -- " . s:escape(nmte) . " > " . s:escape(nmt))
call rename(nmte, nm . &patchmode)
else
call system(a:cmd . " -- " . s:escape(nmte))
endif
call rename(nmt, nm)
endif
endif
endfun
fun s:tempname(name)
let fn = fnamemodify(a:name, ":r")
if !filereadable(fn) && !isdirectory(fn)
return fn
endif
return fnamemodify(a:name, ":p:h") . "/X~=@l9q5"
endfun
fun s:escape(name)
if exists("*shellescape")
return shellescape(a:name)
endif
return "'" . a:name . "'"
endfun
