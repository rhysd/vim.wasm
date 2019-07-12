if &cp || exists("g:loaded_vimball")
finish
endif
let g:loaded_vimball = "v37"
if v:version < 702
echohl WarningMsg
echo "***warning*** this version of vimball needs vim 7.2"
echohl Normal
finish
endif
let s:keepcpo= &cpo
set cpo&vim
if !exists("s:USAGE")
let s:USAGE   = 0
let s:WARNING = 1
let s:ERROR   = 2
if !exists("g:netrw_cygwin")
if has("win32") || has("win95") || has("win64") || has("win16")
if &shell =~ '\%(\<bash\>\|\<zsh\>\)\%(\.exe\)\=$'
let g:netrw_cygwin= 1
else
let g:netrw_cygwin= 0
endif
else
let g:netrw_cygwin= 0
endif
endif
if !exists("*mkdir")
if exists("g:netrw_local_mkdir")
let g:vimball_mkdir= g:netrw_local_mkdir
elseif executable("mkdir")
let g:vimball_mkdir= "mkdir"
elseif executable("makedir")
let g:vimball_mkdir= "makedir"
endif
if !exists(g:vimball_mkdir)
call vimball#ShowMesg(s:WARNING,"(vimball) g:vimball_mkdir undefined")
endif
endif
endif
fun! vimball#MkVimball(line1,line2,writelevel,...) range
if a:1 =~ '\.vim$' || a:1 =~ '\.txt$'
let vbname= substitute(a:1,'\.\a\{3}$','.vmb','')
else
let vbname= a:1
endif
if vbname !~ '\.vmb$'
let vbname= vbname.'.vmb'
endif
if !a:writelevel && a:1 =~ '[\/]'
call vimball#ShowMesg(s:ERROR,"(MkVimball) vimball name<".a:1."> should not include slashes; use ! to insist")
return
endif
if !a:writelevel && filereadable(vbname)
call vimball#ShowMesg(s:ERROR,"(MkVimball) file<".vbname."> exists; use ! to insist")
return
endif
call vimball#SaveSettings()
if a:0 >= 2
let home= expand(a:2)
else
let home= vimball#VimballHome()
endif
let curdir = getcwd()
call s:ChgDir(home)
let curtabnr = tabpagenr()
let linenr   = a:line1
while linenr <= a:line2
let svfile  = getline(linenr)
if !filereadable(svfile)
call vimball#ShowMesg(s:ERROR,"unable to read file<".svfile.">")
call s:ChgDir(curdir)
call vimball#RestoreSettings()
return
endif
if !exists("vbtabnr")
tabnew
sil! file Vimball
let vbtabnr= tabpagenr()
else
exe "tabn ".vbtabnr
endif
let lastline= line("$") + 1
if lastline == 2 && getline("$") == ""
call setline(1,'" Vimball Archiver by Charles E. Campbell')
call setline(2,'UseVimball')
call setline(3,'finish')
let lastline= line("$") + 1
endif
call setline(lastline  ,substitute(svfile,'$','	[[[1',''))
call setline(lastline+1,0)
exe "$r ".fnameescape(svfile)
call setline(lastline+1,line("$") - lastline - 1)
exe "tabn ".curtabnr
let linenr= linenr + 1
endwhile
exe "tabn ".vbtabnr
call s:ChgDir(curdir)
setlocal ff=unix
if a:writelevel
exe "w! ".fnameescape(vbname)
else
exe "w ".fnameescape(vbname)
endif
echo "Vimball<".vbname."> created"
setlocal nomod bh=wipe
exe "tabn ".curtabnr
exe "tabc! ".vbtabnr
call vimball#RestoreSettings()
endfun
fun! vimball#Vimball(really,...)
if v:version < 701 || (v:version == 701 && !exists('*fnameescape'))
echoerr "your vim is missing the fnameescape() function (pls upgrade to vim 7.2 or later)"
return
endif
if getline(1) !~ '^" Vimball Archiver'
echoerr "(Vimball) The current file does not appear to be a Vimball!"
return
endif
call vimball#SaveSettings()
let curtabnr    = tabpagenr()
let vimballfile = expand("%:tr")
tabnew
sil! file Vimball
let vbtabnr= tabpagenr()
let didhelp= ""
if a:0 > 0
let home= expand(a:1)
if has("win32") || has("win95") || has("win64") || has("win16")
if home !~ '^\a:[/\\]'
let home= getcwd().'/'.a:1
endif
elseif home !~ '^/'
let home= getcwd().'/'.a:1
endif
else
let home= vimball#VimballHome()
endif
let curdir = getcwd()
call s:ChgDir(home)
let s:ok_unablefind= 1
call vimball#RmVimball(vimballfile)
unlet s:ok_unablefind
let linenr  = 4
let filecnt = 0
if a:really
echohl Title     | echomsg "Vimball Archive"         | echohl None
else             
echohl Title     | echomsg "Vimball Archive Listing" | echohl None
echohl Statement | echomsg "files would be placed under: ".home | echohl None
endif
exe "tabn ".curtabnr
while 1 < linenr && linenr < line("$")
let fname   = substitute(getline(linenr),'\t\[\[\[1$','','')
let fname   = substitute(fname,'\\','/','g')
let fsize   = substitute(getline(linenr+1),'^\(\d\+\).\{-}$','\1','')+0
let fenc    = substitute(getline(linenr+1),'^\d\+\s*\(\S\{-}\)$','\1','')
let filecnt = filecnt + 1
if a:really
echomsg "extracted <".fname.">: ".fsize." lines"
else
echomsg "would extract <".fname.">: ".fsize." lines"
endif
if fname =~ '\<plugin/'
let anfname= substitute(fname,'\<plugin/','AsNeeded/','')
if filereadable(anfname) || (exists("s:VBRstring") && s:VBRstring =~# anfname)
let fname= anfname
endif
endif
if a:really
let fnamebuf= substitute(fname,'\\','/','g')
let dirpath = substitute(home,'\\','/','g')
while fnamebuf =~ '/'
let dirname  = dirpath."/".substitute(fnamebuf,'/.*$','','')
let dirpath  = dirname
let fnamebuf = substitute(fnamebuf,'^.\{-}/\(.*\)$','\1','')
if !isdirectory(dirname)
if exists("g:vimball_mkdir")
call system(g:vimball_mkdir." ".shellescape(dirname))
else
call mkdir(dirname)
endif
call s:RecordInVar(home,"rmdir('".dirname."')")
endif
endwhile
endif
call s:ChgDir(home)
let linenr   = linenr + 2
let lastline = linenr + fsize - 1
if lastline >= linenr
exe "silent ".linenr.",".lastline."yank a"
exe "tabn ".vbtabnr
setlocal ma
sil! %d
silent put a
1
sil! d
if a:really
let fnamepath= home."/".fname
if fenc != ""
exe "silent w! ++enc=".fnameescape(fenc)." ".fnameescape(fnamepath)
else
exe "silent w! ".fnameescape(fnamepath)
endif
echo "wrote ".fnameescape(fnamepath)
call s:RecordInVar(home,"call delete('".fnamepath."')")
endif
exe "tabn ".curtabnr
if a:really && didhelp == "" && fname =~ 'doc/[^/]\+\.\(txt\|..x\)$'
let didhelp= substitute(fname,'^\(.*\<doc\)[/\\][^.]*\.\(txt\|..x\)$','\1','')
endif
endif
let linenr= linenr + fsize
endwhile
if didhelp != ""
let htpath= home."/".didhelp
exe "helptags ".fnameescape(htpath)
echo "did helptags"
endif
while filecnt <= &ch
echomsg " "
let filecnt= filecnt + 1
endwhile
call s:RecordInFile(home)
exe "sil! tabn ".vbtabnr
setlocal nomod bh=wipe
exe "sil! tabn ".curtabnr
exe "sil! tabc! ".vbtabnr
call vimball#RestoreSettings()
call s:ChgDir(curdir)
endfun
fun! vimball#RmVimball(...)
if exists("g:vimball_norecord")
return
endif
if a:0 == 0
let curfile= expand("%:tr")
else
if a:1 =~ '[\/]'
call vimball#ShowMesg(s:USAGE,"RmVimball vimballname [path]")
return
endif
let curfile= a:1
endif
if curfile =~ '\.vmb$'
let curfile= substitute(curfile,'\.vmb','','')
elseif curfile =~ '\.vba$'
let curfile= substitute(curfile,'\.vba','','')
endif
if a:0 >= 2
let home= expand(a:2)
else
let home= vimball#VimballHome()
endif
let curdir = getcwd()
call s:ChgDir(home)
if filereadable(".VimballRecord")
keepalt keepjumps 1split 
sil! keepalt keepjumps e .VimballRecord
let keepsrch= @/
if search('^\M'.curfile."\m: ".'cw')
let foundit= 1
elseif search('^\M'.curfile.".\mvmb: ",'cw')
let foundit= 2
elseif search('^\M'.curfile.'\m[-0-9.]*\.vmb: ','cw')
let foundit= 2
elseif search('^\M'.curfile.".\mvba: ",'cw')
let foundit= 1
elseif search('^\M'.curfile.'\m[-0-9.]*\.vba: ','cw')
let foundit= 1
else
let foundit = 0
endif
if foundit
if foundit == 1
let exestring  = substitute(getline("."),'^\M'.curfile.'\m\S\{-}\.vba: ','','')
else
let exestring  = substitute(getline("."),'^\M'.curfile.'\m\S\{-}\.vmb: ','','')
endif
let s:VBRstring= substitute(exestring,'call delete(','','g')
let s:VBRstring= substitute(s:VBRstring,"[')]",'','g')
sil! keepalt keepjumps exe exestring
sil! keepalt keepjumps d
let exestring= strlen(substitute(exestring,'call delete(.\{-})|\=',"D","g"))
echomsg "removed ".exestring." files"
else
let s:VBRstring= ''
let curfile    = substitute(curfile,'\.vmb','','')
if !exists("s:ok_unablefind")
call vimball#ShowMesg(s:WARNING,"(RmVimball) unable to find <".curfile."> in .VimballRecord")
endif
endif
sil! keepalt keepjumps g/^\s*$/d
sil! keepalt keepjumps wq!
let @/= keepsrch
endif
call s:ChgDir(curdir)
endfun
fun! vimball#Decompress(fname,...)
if     expand("%") =~ '.*\.gz'  && executable("gunzip")
silent exe "!gunzip ".shellescape(a:fname)
if v:shell_error != 0
call vimball#ShowMesg(s:WARNING,"(vimball#Decompress) gunzip may have failed with <".a:fname.">")
endif
let fname= substitute(a:fname,'\.gz$','','')
exe "e ".escape(fname,' \')
if a:0 == 0| call vimball#ShowMesg(s:USAGE,"Source this file to extract it! (:so %)") | endif
elseif expand("%") =~ '.*\.gz' && executable("gzip")
silent exe "!gzip -d ".shellescape(a:fname)
if v:shell_error != 0
call vimball#ShowMesg(s:WARNING,'(vimball#Decompress) "gzip -d" may have failed with <'.a:fname.">")
endif
let fname= substitute(a:fname,'\.gz$','','')
exe "e ".escape(fname,' \')
if a:0 == 0| call vimball#ShowMesg(s:USAGE,"Source this file to extract it! (:so %)") | endif
elseif expand("%") =~ '.*\.bz2' && executable("bunzip2")
silent exe "!bunzip2 ".shellescape(a:fname)
if v:shell_error != 0
call vimball#ShowMesg(s:WARNING,"(vimball#Decompress) bunzip2 may have failed with <".a:fname.">")
endif
let fname= substitute(a:fname,'\.bz2$','','')
exe "e ".escape(fname,' \')
if a:0 == 0| call vimball#ShowMesg(s:USAGE,"Source this file to extract it! (:so %)") | endif
elseif expand("%") =~ '.*\.bz2' && executable("bzip2")
silent exe "!bzip2 -d ".shellescape(a:fname)
if v:shell_error != 0
call vimball#ShowMesg(s:WARNING,'(vimball#Decompress) "bzip2 -d" may have failed with <'.a:fname.">")
endif
let fname= substitute(a:fname,'\.bz2$','','')
exe "e ".escape(fname,' \')
if a:0 == 0| call vimball#ShowMesg(s:USAGE,"Source this file to extract it! (:so %)") | endif
elseif expand("%") =~ '.*\.zip' && executable("unzip")
silent exe "!unzip ".shellescape(a:fname)
if v:shell_error != 0
call vimball#ShowMesg(s:WARNING,"(vimball#Decompress) unzip may have failed with <".a:fname.">")
endif
let fname= substitute(a:fname,'\.zip$','','')
exe "e ".escape(fname,' \')
if a:0 == 0| call vimball#ShowMesg(s:USAGE,"Source this file to extract it! (:so %)") | endif
endif
if a:0 == 0| setlocal noma bt=nofile fmr=[[[,]]] fdm=marker | endif
endfun
fun! vimball#ShowMesg(level,msg)
let rulerkeep   = &ruler
let showcmdkeep = &showcmd
set noruler noshowcmd
redraw!
if &fo =~# '[ta]'
echomsg "***vimball*** ".a:msg
else
if a:level == s:WARNING || a:level == s:USAGE
echohl WarningMsg
elseif a:level == s:ERROR
echohl Error
endif
echomsg "***vimball*** ".a:msg
echohl None
endif
if a:level != s:USAGE
call inputsave()|let ok= input("Press <cr> to continue")|call inputrestore()
endif
let &ruler   = rulerkeep
let &showcmd = showcmdkeep
endfun
fun! s:ChgDir(newdir)
if (has("win32") || has("win95") || has("win64") || has("win16"))
try
exe 'silent cd '.fnameescape(substitute(a:newdir,'/','\\','g'))
catch  /^Vim\%((\a\+)\)\=:E/
call mkdir(fnameescape(substitute(a:newdir,'/','\\','g')))
exe 'silent cd '.fnameescape(substitute(a:newdir,'/','\\','g'))
endtry
else
try
exe 'silent cd '.fnameescape(a:newdir)
catch  /^Vim\%((\a\+)\)\=:E/
call mkdir(fnameescape(a:newdir))
exe 'silent cd '.fnameescape(a:newdir)
endtry
endif
endfun
fun! s:RecordInVar(home,cmd)
if a:cmd =~ '^rmdir'
elseif !exists("s:recordfile")
let s:recordfile= a:cmd
else
let s:recordfile= s:recordfile."|".a:cmd
endif
endfun
fun! s:RecordInFile(home)
if exists("g:vimball_norecord")
return
endif
if exists("s:recordfile") || exists("s:recorddir")
let curdir= getcwd()
call s:ChgDir(a:home)
keepalt keepjumps 1split 
let cmd= expand("%:tr").": "
sil! keepalt keepjumps e .VimballRecord
setlocal ma
$
if exists("s:recordfile") && exists("s:recorddir")
let cmd= cmd.s:recordfile."|".s:recorddir
elseif exists("s:recorddir")
let cmd= cmd.s:recorddir
elseif exists("s:recordfile")
let cmd= cmd.s:recordfile
else
return
endif
keepalt keepjumps put=cmd
sil! keepalt keepjumps g/^\s*$/d
sil! keepalt keepjumps wq!
call s:ChgDir(curdir)
if exists("s:recorddir")
unlet s:recorddir
endif
if exists("s:recordfile")
unlet s:recordfile
endif
else
endif
endfun
fun! vimball#VimballHome()
if exists("g:vimball_home")
let home= g:vimball_home
else
for home in split(&rtp,',') + ['']
if isdirectory(home) && filewritable(home) | break | endif
let basehome= substitute(home,'[/\\]\.vim$','','')
if isdirectory(basehome) && filewritable(basehome)
let home= basehome."/.vim"
break
endif
endfor
if home == ""
let home= substitute(&rtp,',.*$','','')
endif
if (has("win32") || has("win95") || has("win64") || has("win16"))
let home= substitute(home,'/','\\','g')
endif
endif
if !isdirectory(home)
if exists("g:vimball_mkdir")
call system(g:vimball_mkdir." ".shellescape(home))
else
call mkdir(home)
endif
endif
return home
endfun
fun! vimball#SaveSettings()
let s:makeep  = getpos("'a")
let s:regakeep= @a
if exists("+acd")
let s:acdkeep = &acd
endif
let s:eikeep  = &ei
let s:fenkeep = &l:fen
let s:hidkeep = &hidden
let s:ickeep  = &ic
let s:lzkeep  = &lz
let s:pmkeep  = &pm
let s:repkeep = &report
let s:vekeep  = &ve
let s:ffkeep  = &l:ff
let s:swfkeep = &l:swf
if exists("+acd")
setlocal ei=all ve=all noacd nofen noic report=999 nohid bt= ma lz pm= ff=unix noswf
else
setlocal ei=all ve=all       nofen noic report=999 nohid bt= ma lz pm= ff=unix noswf
endif
setlocal ff=unix
endfun
fun! vimball#RestoreSettings()
let @a      = s:regakeep
if exists("+acd")
let &acd   = s:acdkeep
endif
let &l:fen  = s:fenkeep
let &hidden = s:hidkeep
let &ic     = s:ickeep
let &lz     = s:lzkeep
let &pm     = s:pmkeep
let &report = s:repkeep
let &ve     = s:vekeep
let &ei     = s:eikeep
let &l:ff   = s:ffkeep
if s:makeep[0] != 0
call setpos("'a",s:makeep)
endif
if exists("+acd")
unlet s:acdkeep
endif
unlet s:regakeep s:eikeep s:fenkeep s:hidkeep s:ickeep s:repkeep s:vekeep s:makeep s:lzkeep s:pmkeep s:ffkeep
endfun
let &cpo = s:keepcpo
unlet s:keepcpo
