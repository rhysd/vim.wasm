if exists("g:loaded_getscript")
finish
endif
let g:loaded_getscript= "v36"
if &cp
echoerr "GetLatestVimScripts is not vi-compatible; not loaded (you need to set nocp)"
finish
endif
if v:version < 702
echohl WarningMsg
echo "***warning*** this version of getscript needs vim 7.2"
echohl Normal
finish
endif
let s:keepcpo = &cpo
set cpo&vim
if !exists("g:getscript_cygwin")
if has("win32") || has("win95") || has("win64") || has("win16")
if &shell =~ '\%(\<bash\>\|\<zsh\>\)\%(\.exe\)\=$'
let g:getscript_cygwin= 1
else
let g:getscript_cygwin= 0
endif
else
let g:getscript_cygwin= 0
endif
endif
if !exists("g:GetLatestVimScripts_wget")
if executable("wget")
let g:GetLatestVimScripts_wget= "wget"
elseif executable("curl")
let g:GetLatestVimScripts_wget= "curl"
else
let g:GetLatestVimScripts_wget    = 'echo "GetLatestVimScripts needs wget or curl"'
let g:GetLatestVimScripts_options = ""
endif
endif
if !exists("g:GetLatestVimScripts_options")
if g:GetLatestVimScripts_wget == "wget"
let g:GetLatestVimScripts_options= "-q -O"
elseif g:GetLatestVimScripts_wget == "curl"
let g:GetLatestVimScripts_options= "-s -O"
else
let g:GetLatestVimScripts_options= ""
endif
endif
if !exists("g:GetLatestVimScripts_allowautoinstall")
let g:GetLatestVimScripts_allowautoinstall= 1
endif
if !exists("g:GetLatestVimScripts_scriptaddr")
let g:GetLatestVimScripts_scriptaddr = 'http://vim.sourceforge.net/script.php?script_id='
endif
let s:autoinstall= ""
if g:GetLatestVimScripts_allowautoinstall
if (has("win32") || has("gui_win32") || has("gui_win32s") || has("win16") || has("win64") || has("win32unix") || has("win95")) && &shell != "bash"
let s:dotvim= "vimfiles"
if !exists("g:GetLatestVimScripts_mv")
let g:GetLatestVimScripts_mv= "ren"
endif
else
let s:dotvim= ".vim"
if !exists("g:GetLatestVimScripts_mv")
let g:GetLatestVimScripts_mv= "mv"
endif
endif
if exists("g:GetLatestVimScripts_autoinstalldir") && isdirectory(g:GetLatestVimScripts_autoinstalldir)
let s:autoinstall= g:GetLatestVimScripts_autoinstalldir"
elseif exists('$HOME') && isdirectory(expand("$HOME")."/".s:dotvim)
let s:autoinstall= $HOME."/".s:dotvim
endif
endif
com!        -nargs=0 GetLatestVimScripts call getscript#GetLatestVimScripts()
com!        -nargs=0 GetScript           call getscript#GetLatestVimScripts()
silent! com -nargs=0 GLVS                call getscript#GetLatestVimScripts()
fun! getscript#GetLatestVimScripts()
if executable(g:GetLatestVimScripts_wget) != 1
echoerr "GetLatestVimScripts needs ".g:GetLatestVimScripts_wget." which apparently is not available on your system"
return
endif
if !exists("*fnameescape")
echoerr "GetLatestVimScripts needs fnameescape() (provided by 7.1.299 or later)"
return
endif
for datadir in split(&rtp,',') + ['']
if isdirectory(datadir."/GetLatest")
let datadir= datadir . "/GetLatest"
break
endif
if filereadable(datadir."GetLatestVimScripts.dat")
break
endif
endfor
if datadir == ""
echoerr 'Missing "GetLatest/" on your runtimepath - see :help glvs-dist-install'
return
endif
if filewritable(datadir) != 2
echoerr "(getLatestVimScripts) Your ".datadir." isn't writable"
return
endif
let datafile= datadir."/GetLatestVimScripts.dat"
if !filereadable(datafile)
echoerr "Your data file<".datafile."> isn't readable"
return
endif
if !filewritable(datafile)
echoerr "Your data file<".datafile."> isn't writable"
return
endif
let eikeep  = &ei
let hlskeep = &hls
let acdkeep = &acd
set ei=all hls&vim noacd
let origdir= getcwd()
exe "cd ".fnameescape(substitute(datadir,'\','/','ge'))
split
exe "e ".fnameescape(substitute(datafile,'\','/','ge'))
res 1000
let s:downloads = 0
let s:downerrors= 0
let lastline    = line("$")
let firstdir    = substitute(&rtp,',.*$','','')
let plugins     = split(globpath(firstdir,"plugin/**/*.vim"),'\n')
let plugins     = plugins + split(globpath(firstdir,"AsNeeded/**/*.vim"),'\n')
let foundscript = 0
for plugin in plugins
$
exe "silent r ".fnameescape(plugin)
exe "silent bwipe ".bufnr("#")
while search('^"\s\+GetLatestVimScripts:\s\+\d\+\s\+\d\+','W') != 0
let depscript   = substitute(getline("."),'^"\s\+GetLatestVimScripts:\s\+\d\+\s\+\d\+\s\+\(.*\)$','\1','e')
let depscriptid = substitute(getline("."),'^"\s\+GetLatestVimScripts:\s\+\(\d\+\)\s\+.*$','\1','')
let llp1        = lastline+1
let curline     = line(".")
let noai_script = substitute(depscript,'\s*:AutoInstall:\s*','','e')
exe llp1
let srchline    = search('^\s*'.depscriptid.'\s\+\d\+\s\+.*$','bW')
if srchline == 0
let srchline= search('\<'.noai_script.'\>','bW')
endif
if srchline == 0
let keep_rega   = @a
let @a          = substitute(getline(curline),'^"\s\+GetLatestVimScripts:\s\+','','')
echomsg "Appending <".@a."> to ".datafile." for ".depscript
exe lastline."put a"
let @a          = keep_rega
let lastline    = llp1
let curline     = curline     + 1
let foundscript = foundscript + 1
endif
let curline = curline + 1
exe curline
endwhile
let llp1= lastline + 1
exe "silent! ".llp1.",$d"
endfor
if foundscript == 0
setlocal nomod
endif
setlocal lz
1
1
/^-----/,$g/^\s*\d/call s:GetOneScript()
try
silent! ?^-------?
catch /^Vim\%((\a\+)\)\=:E114/
return
endtry
exe "norm! kz\<CR>"
redraw!
let s:msg = ""
if s:downloads == 1
let s:msg = "Downloaded one updated script to <".datadir.">"
elseif s:downloads == 2
let s:msg= "Downloaded two updated scripts to <".datadir.">"
elseif s:downloads > 1
let s:msg= "Downloaded ".s:downloads." updated scripts to <".datadir.">"
else
let s:msg= "Everything was already current"
endif
if s:downerrors > 0
let s:msg= s:msg." (".s:downerrors." downloading errors)"
endif
echomsg s:msg
if &mod
silent! w!
endif
q!
exe "cd ".fnameescape(substitute(origdir,'\','/','ge'))
let &ei  = eikeep
let &hls = hlskeep
let &acd = acdkeep
setlocal nolz
endfun
fun! s:GetOneScript(...)
let rega= @a
let t_ti= &t_ti
let t_te= &t_te
let rs  = &rs
set t_ti= t_te= nors
if a:0 >= 3
let scriptid = a:1
let srcid    = a:2
let fname    = a:3
let cmmnt    = ""
else
let curline  = getline(".")
if curline =~ '^\s*#'
let @a= rega
return
endif
let parsepat = '^\s*\(\d\+\)\s\+\(\d\+\)\s\+\(.\{-}\)\(\s*#.*\)\=$'
try
let scriptid = substitute(curline,parsepat,'\1','e')
catch /^Vim\%((\a\+)\)\=:E486/
let scriptid= 0
endtry
try
let srcid    = substitute(curline,parsepat,'\2','e')
catch /^Vim\%((\a\+)\)\=:E486/
let srcid= 0
endtry
try
let fname= substitute(curline,parsepat,'\3','e')
catch /^Vim\%((\a\+)\)\=:E486/
let fname= ""
endtry
try
let cmmnt= substitute(curline,parsepat,'\4','e')
catch /^Vim\%((\a\+)\)\=:E486/
let cmmnt= ""
endtry
endif
if scriptid == 0 || srcid == 0
let @a= rega
return
endif
let doautoinstall= 0
if fname =~ ":AutoInstall:"
let aicmmnt= substitute(fname,'\s\+:AutoInstall:\s\+',' ','')
if s:autoinstall != ""
let doautoinstall = g:GetLatestVimScripts_allowautoinstall
endif
else
let aicmmnt= fname
endif
exe "norm z\<CR>"
redraw!
echo 'considering <'.aicmmnt.'> scriptid='.scriptid.' srcid='.srcid
let scriptaddr = g:GetLatestVimScripts_scriptaddr.scriptid
let tmpfile    = tempname()
let v:errmsg   = ""
let itry= 1
while itry <= 3
if has("win32") || has("win16") || has("win95")
new|exe "silent r!".g:GetLatestVimScripts_wget." ".g:GetLatestVimScripts_options." ".shellescape(tmpfile).' '.shellescape(scriptaddr)|bw!
else
exe "silent !".g:GetLatestVimScripts_wget." ".g:GetLatestVimScripts_options." ".shellescape(tmpfile)." ".shellescape(scriptaddr)
endif
if itry == 1
exe "silent vsplit ".fnameescape(tmpfile)
else
silent! e %
endif
setlocal bh=wipe
silent! 1
let findpkg= search('Click on the package to download','W')
if findpkg > 0
break
endif
let itry= itry + 1
endwhile
if findpkg == 0 || itry >= 4
silent q!
call delete(tmpfile)
let &t_ti        = t_ti
let &t_te        = t_te
let &rs          = rs
let s:downerrors = s:downerrors + 1
echomsg "***warning*** couldn'".'t find "Click on the package..." in description page for <'.aicmmnt.">"
let @a= rega
return
endif
let findsrcid= search('src_id=','W')
if findsrcid == 0
silent q!
call delete(tmpfile)
let &t_ti        = t_ti
let &t_te        = t_te
let &rs          = rs
let s:downerrors = s:downerrors + 1
echomsg "***warning*** couldn'".'t find "src_id=" in description page for <'.aicmmnt.">"
let @a= rega
return
endif
let srcidpat   = '^\s*<td class.*src_id=\(\d\+\)">\([^<]\+\)<.*$'
let latestsrcid= substitute(getline("."),srcidpat,'\1','')
let sname      = substitute(getline("."),srcidpat,'\2','') " script name actually downloaded
silent q!
call delete(tmpfile)
let srcid       = srcid       + 0
let latestsrcid = latestsrcid + 0
if latestsrcid > srcid
let s:downloads= s:downloads + 1
if sname == bufname("%")
let sname= "NEW_".sname
endif
echomsg ".downloading new <".sname.">"
if has("win32") || has("win16") || has("win95")
new|exe "silent r!".g:GetLatestVimScripts_wget." ".g:GetLatestVimScripts_options." ".shellescape(sname)." ".shellescape('http://vim.sourceforge.net/scripts/download_script.php?src_id='.latestsrcid)|q
else
exe "silent !".g:GetLatestVimScripts_wget." ".g:GetLatestVimScripts_options." ".shellescape(sname)." ".shellescape('http://vim.sourceforge.net/scripts/download_script.php?src_id=').latestsrcid
endif
if doautoinstall
if filereadable(sname)
exe "silent !".g:GetLatestVimScripts_mv." ".shellescape(sname)." ".shellescape(s:autoinstall)
let curdir    = fnameescape(substitute(getcwd(),'\','/','ge'))
let installdir= curdir."/Installed"
if !isdirectory(installdir)
call mkdir(installdir)
endif
exe "cd ".fnameescape(s:autoinstall)
let firstdir= substitute(&rtp,',.*$','','')
let pname   = substitute(sname,'\..*','.vim','')
if filereadable(firstdir.'/AsNeeded/'.pname)
let tgtdir= "AsNeeded"
else
let tgtdir= "plugin"
endif
if sname =~ '\.bz2$'
exe "sil !bunzip2 ".shellescape(sname)
let sname= substitute(sname,'\.bz2$','','')
elseif sname =~ '\.gz$'
exe "sil !gunzip ".shellescape(sname)
let sname= substitute(sname,'\.gz$','','')
elseif sname =~ '\.xz$'
exe "sil !unxz ".shellescape(sname)
let sname= substitute(sname,'\.xz$','','')
else
endif
if sname =~ '\.zip$'
exe "silent !unzip -o ".shellescape(sname)
elseif sname =~ '\.tar$'
exe "silent !tar -xvf ".shellescape(sname)
elseif sname =~ '\.tgz$'
exe "silent !tar -zxvf ".shellescape(sname)
elseif sname =~ '\.taz$'
exe "silent !tar -Zxvf ".shellescape(sname)
elseif sname =~ '\.tbz$'
exe "silent !tar -jxvf ".shellescape(sname)
elseif sname =~ '\.txz$'
exe "silent !tar -Jxvf ".shellescape(sname)
elseif sname =~ '\.vba$'
silent 1split
if exists("g:vimball_home")
let oldvimballhome= g:vimball_home
endif
let g:vimball_home= s:autoinstall
exe "silent e ".fnameescape(sname)
silent so %
silent q
if exists("oldvimballhome")
let g:vimball_home= oldvimballhome
else
unlet g:vimball_home
endif
else
endif
if sname =~ '.vim$'
exe "silent !".g:GetLatestVimScripts_mv." ".shellescape(sname)." ".tgtdir
else
exe "silent !".g:GetLatestVimScripts_mv." ".shellescape(sname)." ".installdir
endif
if tgtdir != "plugin"
exe "silent !".g:GetLatestVimScripts_mv." plugin/".shellescape(pname)." ".tgtdir
endif
let docdir= substitute(&rtp,',.*','','e')."/doc"
exe "helptags ".fnameescape(docdir)
exe "cd ".fnameescape(curdir)
endif
if fname !~ ':AutoInstall:'
let modline=scriptid." ".latestsrcid." :AutoInstall: ".fname.cmmnt
else
let modline=scriptid." ".latestsrcid." ".fname.cmmnt
endif
else
let modline=scriptid." ".latestsrcid." ".fname.cmmnt
endif
call setline(line("."),modline)
endif
let &t_ti = t_ti
let &t_te = t_te
let &rs   = rs
let @a    = rega
endfun
let &cpo= s:keepcpo
unlet s:keepcpo
