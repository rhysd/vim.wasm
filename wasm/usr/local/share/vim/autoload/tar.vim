if &cp || exists("g:loaded_tar")
finish
endif
let g:loaded_tar= "v29"
if v:version < 702
echohl WarningMsg
echo "***warning*** this version of tar needs vim 7.2"
echohl Normal
finish
endif
let s:keepcpo= &cpo
set cpo&vim
if !exists("g:tar_browseoptions")
let g:tar_browseoptions= "Ptf"
endif
if !exists("g:tar_readoptions")
let g:tar_readoptions= "OPxf"
endif
if !exists("g:tar_cmd")
let g:tar_cmd= "tar"
endif
if !exists("g:tar_writeoptions")
let g:tar_writeoptions= "uf"
endif
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
if !exists("g:tar_copycmd")
if !exists("g:netrw_localcopycmd")
if has("win32") || has("win95") || has("win64") || has("win16")
if g:netrw_cygwin
let g:netrw_localcopycmd= "cp"
else
let g:netrw_localcopycmd= "copy"
endif
elseif has("unix") || has("macunix")
let g:netrw_localcopycmd= "cp"
else
let g:netrw_localcopycmd= ""
endif
endif
let g:tar_copycmd= g:netrw_localcopycmd
endif
if !exists("g:tar_extractcmd")
let g:tar_extractcmd= "tar -xf"
endif
if !exists("g:tar_shq")
if exists("+shq") && exists("&shq") && &shq != ""
let g:tar_shq= &shq
elseif has("win32") || has("win95") || has("win64") || has("win16")
if exists("g:netrw_cygwin") && g:netrw_cygwin
let g:tar_shq= "'"
else
let g:tar_shq= '"'
endif
else
let g:tar_shq= "'"
endif
endif
fun! tar#Browse(tarfile)
let repkeep= &report
set report=10
if !executable(g:tar_cmd)
redraw!
echohl Error | echo '***error*** (tar#Browse) "'.g:tar_cmd.'" not available on your system'
let &report= repkeep
return
endif
if !filereadable(a:tarfile)
if a:tarfile !~# '^\a\+://'
redraw!
echohl Error | echo "***error*** (tar#Browse) File not readable<".a:tarfile.">" | echohl None
endif
let &report= repkeep
return
endif
if &ma != 1
set ma
endif
let b:tarfile= a:tarfile
setlocal noswapfile
setlocal buftype=nofile
setlocal bufhidden=hide
setlocal nobuflisted
setlocal nowrap
set ft=tar
let lastline= line("$")
call setline(lastline+1,'" tar.vim version '.g:loaded_tar)
call setline(lastline+2,'" Browsing tarfile '.a:tarfile)
call setline(lastline+3,'" Select a file with cursor and press ENTER')
keepj $put =''
keepj sil! 0d
keepj $
let tarfile= a:tarfile
if has("win32unix") && executable("cygpath")
let tarfile=substitute(system("cygpath -u ".shellescape(tarfile,0)),'\n$','','e')
endif
let curlast= line("$")
if tarfile =~# '\.\(gz\|tgz\)$'
let gzip_command = s:get_gzip_command(tarfile)
exe "sil! r! " . gzip_command . " -d -c -- ".shellescape(tarfile,1)." | ".g:tar_cmd." -".g:tar_browseoptions." - "
elseif tarfile =~# '\.lrp'
exe "sil! r! cat -- ".shellescape(tarfile,1)."|gzip -d -c -|".g:tar_cmd." -".g:tar_browseoptions." - "
elseif tarfile =~# '\.\(bz2\|tbz\|tb2\)$'
exe "sil! r! bzip2 -d -c -- ".shellescape(tarfile,1)." | ".g:tar_cmd." -".g:tar_browseoptions." - "
elseif tarfile =~# '\.\(lzma\|tlz\)$'
exe "sil! r! lzma -d -c -- ".shellescape(tarfile,1)." | ".g:tar_cmd." -".g:tar_browseoptions." - "
elseif tarfile =~# '\.\(xz\|txz\)$'
exe "sil! r! xz --decompress --stdout -- ".shellescape(tarfile,1)." | ".g:tar_cmd." -".g:tar_browseoptions." - "
else
if tarfile =~ '^\s*-'
let tarfile = substitute(tarfile, '-', './-', '')
endif
exe "sil! r! ".g:tar_cmd." -".g:tar_browseoptions." ".shellescape(tarfile,1)
endif
if v:shell_error != 0
redraw!
echohl WarningMsg | echo "***warning*** (tar#Browse) please check your g:tar_browseoptions<".g:tar_browseoptions.">"
return
endif
if line("$") == curlast || ( line("$") == (curlast + 1) && getline("$") =~ '\c\%(warning\|error\|inappropriate\|unrecognized\)')
redraw!
echohl WarningMsg | echo "***warning*** (tar#Browse) ".a:tarfile." doesn't appear to be a tar file" | echohl None
keepj sil! %d
let eikeep= &ei
set ei=BufReadCmd,FileReadCmd
exe "r ".fnameescape(a:tarfile)
let &ei= eikeep
keepj sil! 1d
return
endif
setlocal noma nomod ro
noremap <silent> <buffer> <cr> :call <SID>TarBrowseSelect()<cr>
let &report= repkeep
endfun
fun! s:TarBrowseSelect()
let repkeep= &report
set report=10
let fname= getline(".")
if !exists("g:tar_secure") && fname =~ '^\s*-\|\s\+-'
redraw!
echohl WarningMsg | echo '***warning*** (tar#BrowseSelect) rejecting tarfile member<'.fname.'> because of embedded "-"'
return
endif
if fname =~ '^"'
let &report= repkeep
return
endif
let tarfile= b:tarfile
let curfile= expand("%")
if has("win32unix") && executable("cygpath")
let tarfile=substitute(system("cygpath -u ".shellescape(tarfile,0)),'\n$','','e')
endif
new
if !exists("g:tar_nomax") || g:tar_nomax == 0
wincmd _
endif
let s:tblfile_{winnr()}= curfile
call tar#Read("tarfile:".tarfile.'::'.fname,1)
filetype detect
set nomod
exe 'com! -buffer -nargs=? -complete=file TarDiff	:call tar#Diff(<q-args>,"'.fnameescape(fname).'")'
let &report= repkeep
endfun
fun! tar#Read(fname,mode)
let repkeep= &report
set report=10
let tarfile = substitute(a:fname,'tarfile:\(.\{-}\)::.*$','\1','')
let fname   = substitute(a:fname,'tarfile:.\{-}::\(.*\)$','\1','')
if has("win32unix") && executable("cygpath")
let tarfile=substitute(system("cygpath -u ".shellescape(tarfile,0)),'\n$','','e')
endif
if  fname =~ '\.bz2$' && executable("bzcat")
let decmp= "|bzcat"
let doro = 1
elseif      fname =~ '\.gz$'  && executable("zcat")
let decmp= "|zcat"
let doro = 1
elseif  fname =~ '\.lzma$' && executable("lzcat")
let decmp= "|lzcat"
let doro = 1
elseif  fname =~ '\.xz$' && executable("xzcat")
let decmp= "|xzcat"
let doro = 1
else
let decmp=""
let doro = 0
if fname =~ '\.bz2$\|\.gz$\|\.lzma$\|\.xz$\|\.zip$\|\.Z$'
setlocal bin
endif
endif
if exists("g:tar_secure")
let tar_secure= " -- "
else
let tar_secure= " "
endif
if tarfile =~# '\.bz2$'
exe "sil! r! bzip2 -d -c -- ".shellescape(tarfile,1)."| ".g:tar_cmd." -".g:tar_readoptions." - ".tar_secure.shellescape(fname,1).decmp
elseif tarfile =~# '\.\(gz\|tgz\)$'
let gzip_command = s:get_gzip_command(tarfile)
exe "sil! r! " . gzip_command . " -d -c -- ".shellescape(tarfile,1)."| ".g:tar_cmd." -".g:tar_readoptions." - ".tar_secure.shellescape(fname,1).decmp
elseif tarfile =~# '\.lrp$'
exe "sil! r! cat -- ".shellescape(tarfile,1)." | gzip -d -c - | ".g:tar_cmd." -".g:tar_readoptions." - ".tar_secure.shellescape(fname,1).decmp
elseif tarfile =~# '\.lzma$'
exe "sil! r! lzma -d -c -- ".shellescape(tarfile,1)."| ".g:tar_cmd." -".g:tar_readoptions." - ".tar_secure.shellescape(fname,1).decmp
elseif tarfile =~# '\.\(xz\|txz\)$'
exe "sil! r! xz --decompress --stdout -- ".shellescape(tarfile,1)." | ".g:tar_cmd." -".g:tar_readoptions." - ".tar_secure.shellescape(fname,1).decmp
else
if tarfile =~ '^\s*-'
let tarfile = substitute(tarfile, '-', './-', '')
endif
exe "silent r! ".g:tar_cmd." -".g:tar_readoptions.shellescape(tarfile,1)." ".tar_secure.shellescape(fname,1).decmp
endif
if doro
setlocal ro
endif
let b:tarfile= a:fname
exe "file tarfile::".fnameescape(fname)
keepj sil! 0d
set nomod
let &report= repkeep
endfun
fun! tar#Write(fname)
let repkeep= &report
set report=10
if !exists("g:tar_secure") && a:fname =~ '^\s*-\|\s\+-'
redraw!
echohl WarningMsg | echo '***warning*** (tar#Write) rejecting tarfile member<'.a:fname.'> because of embedded "-"'
return
endif
if !executable(g:tar_cmd)
redraw!
echohl Error | echo '***error*** (tar#Browse) "'.g:tar_cmd.'" not available on your system'
let &report= repkeep
return
endif
if !exists("*mkdir")
redraw!
echohl Error | echo "***error*** (tar#Write) sorry, mkdir() doesn't work on your system" | echohl None
let &report= repkeep
return
endif
let curdir= getcwd()
let tmpdir= tempname()
if tmpdir =~ '\.'
let tmpdir= substitute(tmpdir,'\.[^.]*$','','e')
endif
call mkdir(tmpdir,"p")
try
exe "cd ".fnameescape(tmpdir)
catch /^Vim\%((\a\+)\)\=:E344/
redraw!
echohl Error | echo "***error*** (tar#Write) cannot cd to temporary directory" | Echohl None
let &report= repkeep
return
endtry
if isdirectory("_ZIPVIM_")
call s:Rmdir("_ZIPVIM_")
endif
call mkdir("_ZIPVIM_")
cd _ZIPVIM_
let tarfile = substitute(b:tarfile,'tarfile:\(.\{-}\)::.*$','\1','')
let fname   = substitute(b:tarfile,'tarfile:.\{-}::\(.*\)$','\1','')
let gzip_command = s:get_gzip_command(tarfile)
if tarfile =~# '\.bz2'
call system("bzip2 -d -- ".shellescape(tarfile,0))
let tarfile = substitute(tarfile,'\.bz2','','e')
let compress= "bzip2 -- ".shellescape(tarfile,0)
elseif tarfile =~# '\.gz'
call system(gzip_command . " -d -- ".shellescape(tarfile,0))
let tarfile = substitute(tarfile,'\.gz','','e')
let compress= "gzip -- ".shellescape(tarfile,0)
elseif tarfile =~# '\.tgz'
call system(gzip_command . " -d -- ".shellescape(tarfile,0))
let tarfile = substitute(tarfile,'\.tgz','.tar','e')
let compress= "gzip -- ".shellescape(tarfile,0)
let tgz     = 1
elseif tarfile =~# '\.xz'
call system("xz -d -- ".shellescape(tarfile,0))
let tarfile = substitute(tarfile,'\.xz','','e')
let compress= "xz -- ".shellescape(tarfile,0)
elseif tarfile =~# '\.lzma'
call system("lzma -d -- ".shellescape(tarfile,0))
let tarfile = substitute(tarfile,'\.lzma','','e')
let compress= "lzma -- ".shellescape(tarfile,0)
endif
if v:shell_error != 0
redraw!
echohl Error | echo "***error*** (tar#Write) sorry, unable to update ".tarfile." with ".fname | echohl None
else
if fname =~ '/'
let dirpath = substitute(fname,'/[^/]\+$','','e')
if has("win32unix") && executable("cygpath")
let dirpath = substitute(system("cygpath ".shellescape(dirpath, 0)),'\n','','e')
endif
call mkdir(dirpath,"p")
endif
if tarfile !~ '/'
let tarfile= curdir.'/'.tarfile
endif
if tarfile =~ '^\s*-'
let tarfile = substitute(tarfile, '-', './-', '')
endif
if exists("g:tar_secure")
let tar_secure= " -- "
else
let tar_secure= " "
endif
exe "w! ".fnameescape(fname)
if has("win32unix") && executable("cygpath")
let tarfile = substitute(system("cygpath ".shellescape(tarfile,0)),'\n','','e')
endif
call system(g:tar_cmd." --delete -f ".shellescape(tarfile,0).tar_secure.shellescape(fname,0))
if v:shell_error != 0
redraw!
echohl Error | echo "***error*** (tar#Write) sorry, unable to update ".fnameescape(tarfile)." with ".fnameescape(fname) | echohl None
else
call system(g:tar_cmd." -".g:tar_writeoptions." ".shellescape(tarfile,0).tar_secure.shellescape(fname,0))
if v:shell_error != 0
redraw!
echohl Error | echo "***error*** (tar#Write) sorry, unable to update ".fnameescape(tarfile)." with ".fnameescape(fname) | echohl None
elseif exists("compress")
call system(compress)
if exists("tgz")
call rename(tarfile.".gz",substitute(tarfile,'\.tar$','.tgz','e'))
endif
endif
endif
if s:tblfile_{winnr()} =~ '^\a\+://'
let tblfile= s:tblfile_{winnr()}
1split|enew
let binkeep= &l:binary
let eikeep = &ei
set binary ei=all
exe "e! ".fnameescape(tarfile)
call netrw#NetWrite(tblfile)
let &ei       = eikeep
let &l:binary = binkeep
q!
unlet s:tblfile_{winnr()}
endif
endif
cd ..
call s:Rmdir("_ZIPVIM_")
exe "cd ".fnameescape(curdir)
setlocal nomod
let &report= repkeep
endfun
fun! tar#Diff(userfname,fname)
let fname= a:fname
if a:userfname != ""
let fname= a:userfname
endif
if filereadable(fname)
diffthis
wincmd v
exe "e ".fnameescape(fname)
diffthis
else
redraw!
echo "***warning*** unable to read file<".fname.">"
endif
endfun
fun! s:Rmdir(fname)
if has("unix")
call system("/bin/rm -rf -- ".shellescape(a:fname,0))
elseif has("win32") || has("win95") || has("win64") || has("win16")
if &shell =~? "sh$"
call system("/bin/rm -rf -- ".shellescape(a:fname,0))
else
call system("del /S ".shellescape(a:fname,0))
endif
endif
endfun
fun! tar#Vimuntar(...)
let tarball = expand("%")
let tarbase = substitute(tarball,'\..*$','','')
let tarhome = expand("%:p")
if has("win32") || has("win95") || has("win64") || has("win16")
let tarhome= substitute(tarhome,'\\','/','g')
endif
let tarhome= substitute(tarhome,'/[^/]*$','','')
let tartail = expand("%:t")
let curdir  = getcwd()
if a:0 > 0 && a:1 != ""
let vimhome= a:1
else
let vimhome= vimball#VimballHome()
endif
if simplify(curdir) != simplify(vimhome)
call system(netrw#WinPath(g:tar_copycmd)." ".shellescape(tartail)." ".shellescape(vimhome))
exe "cd ".fnameescape(vimhome)
endif
if tartail =~ '\.tgz'
let gzip_command = s:get_gzip_command(tarfile)
if executable(gzip_command)
silent exe "!" . gzip_command . " -d ".shellescape(tartail)
elseif executable("gunzip")
silent exe "!gunzip ".shellescape(tartail)
elseif executable("gzip")
silent exe "!gzip -d ".shellescape(tartail)
else
echoerr "unable to decompress<".tartail."> on this sytem"
if simplify(curdir) != simplify(tarhome)
call delete(tartail.".tar")
exe "cd ".fnameescape(curdir)
endif
return
endif
else
call vimball#Decompress(tartail,0)
endif
let extractcmd= netrw#WinPath(g:tar_extractcmd)
call system(extractcmd." ".shellescape(tarbase.".tar"))
if filereadable("doc/".tarbase.".txt")
exe "helptags ".getcwd()."/doc"
endif
if simplify(tarhome) != simplify(vimhome)
call delete(vimhome."/".tarbase.".tar")
exe "cd ".fnameescape(curdir)
endif
endfun
func s:get_gzip_command(file)
if a:file =~# 'z$'
let filetype = system('file ' . a:file)
if filetype =~ 'bzip2 compressed' && executable('bzip2')
return 'bzip2'
endif
if filetype =~ 'XZ compressed' && executable('xz')
return 'xz'
endif
endif
if a:file =~# 'bz2$'
return 'bzip2'
endif
if a:file =~# 'xz$'
return 'xz'
endif
return 'gzip'
endfunc
let &cpo= s:keepcpo
unlet s:keepcpo
