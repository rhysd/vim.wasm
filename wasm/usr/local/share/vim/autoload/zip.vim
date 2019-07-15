if &cp || exists("g:loaded_zip")
finish
endif
let g:loaded_zip= "v28"
if v:version < 702
echohl WarningMsg
echo "***warning*** this version of zip needs vim 7.2 or later"
echohl Normal
finish
endif
let s:keepcpo= &cpo
set cpo&vim
let s:zipfile_escape = ' ?&;\'
let s:ERROR          = 2
let s:WARNING        = 1
let s:NOTE           = 0
if !exists("g:zip_shq")
if &shq != ""
let g:zip_shq= &shq
elseif has("unix")
let g:zip_shq= "'"
else
let g:zip_shq= '"'
endif
endif
if !exists("g:zip_zipcmd")
let g:zip_zipcmd= "zip"
endif
if !exists("g:zip_unzipcmd")
let g:zip_unzipcmd= "unzip"
endif
if !exists("g:zip_extractcmd")
let g:zip_extractcmd= g:zip_unzipcmd
endif
fun! zip#Browse(zipfile)
if !filereadable(a:zipfile) || readfile(a:zipfile, "", 1)[0] !~ '^PK'
exe "noautocmd e ".fnameescape(a:zipfile)
return
endif
let repkeep= &report
set report=10
if !exists("*fnameescape")
if &verbose > 1
echoerr "the zip plugin is not available (your vim doens't support fnameescape())"
endif
return
endif
if !executable(g:zip_unzipcmd)
redraw!
echohl Error | echo "***error*** (zip#Browse) unzip not available on your system"
let &report= repkeep
return
endif
if !filereadable(a:zipfile)
if a:zipfile !~# '^\a\+://'
redraw!
echohl Error | echo "***error*** (zip#Browse) File not readable<".a:zipfile.">" | echohl None
endif
let &report= repkeep
return
endif
if &ma != 1
set ma
endif
let b:zipfile= a:zipfile
setlocal noswapfile
setlocal buftype=nofile
setlocal bufhidden=hide
setlocal nobuflisted
setlocal nowrap
set ft=tar
call append(0, ['" zip.vim version '.g:loaded_zip,
\                '" Browsing zipfile '.a:zipfile,
\                '" Select a file with cursor and press ENTER'])
keepj $
exe "keepj sil! r! ".g:zip_unzipcmd." -Z -1 -- ".s:Escape(a:zipfile,1)
if v:shell_error != 0
redraw!
echohl WarningMsg | echo "***warning*** (zip#Browse) ".fnameescape(a:zipfile)." is not a zip file" | echohl None
keepj sil! %d
let eikeep= &ei
set ei=BufReadCmd,FileReadCmd
exe "keepj r ".fnameescape(a:zipfile)
let &ei= eikeep
keepj 1d
return
endif
setlocal noma nomod ro
noremap <silent> <buffer> <cr>	:call <SID>ZipBrowseSelect()<cr>
noremap <silent> <buffer> x		:call zip#Extract()<cr>
let &report= repkeep
endfun
fun! s:ZipBrowseSelect()
let repkeep= &report
set report=10
let fname= getline(".")
if fname =~ '^"'
let &report= repkeep
return
endif
if fname =~ '/$'
redraw!
echohl Error | echo "***error*** (zip#Browse) Please specify a file, not a directory" | echohl None
let &report= repkeep
return
endif
let zipfile = b:zipfile
let curfile= expand("%")
new
if !exists("g:zip_nomax") || g:zip_nomax == 0
wincmd _
endif
let s:zipfile_{winnr()}= curfile
exe "e ".fnameescape("zipfile:".zipfile.'::'.fname)
filetype detect
let &report= repkeep
endfun
fun! zip#Read(fname,mode)
let repkeep= &report
set report=10
if has("unix")
let zipfile = substitute(a:fname,'zipfile:\(.\{-}\)::[^\\].*$','\1','')
let fname   = substitute(a:fname,'zipfile:.\{-}::\([^\\].*\)$','\1','')
else
let zipfile = substitute(a:fname,'^.\{-}zipfile:\(.\{-}\)::[^\\].*$','\1','')
let fname   = substitute(a:fname,'^.\{-}zipfile:.\{-}::\([^\\].*\)$','\1','')
let fname   = substitute(fname, '[', '[[]', 'g')
endif
if !executable(substitute(g:zip_unzipcmd,'\s\+.*$','',''))
redraw!
echohl Error | echo "***error*** (zip#Read) sorry, your system doesn't appear to have the ".g:zip_unzipcmd." program" | echohl None
let &report= repkeep
return
endif
let temp = tempname()
let fn   = expand('%:p')
exe "sil! !".g:zip_unzipcmd." -p -- ".s:Escape(zipfile,1)." ".s:Escape(fnameescape(fname),1).' > '.temp
sil exe 'keepalt file '.temp
sil keepj e!
sil exe 'keepalt file '.fnameescape(fn)
call delete(temp)
filetype detect
set nomod
let &report= repkeep
endfun
fun! zip#Write(fname)
let repkeep= &report
set report=10
if !executable(substitute(g:zip_zipcmd,'\s\+.*$','',''))
redraw!
echohl Error | echo "***error*** (zip#Write) sorry, your system doesn't appear to have the ".g:zip_zipcmd." program" | echohl None
let &report= repkeep
return
endif
if !exists("*mkdir")
redraw!
echohl Error | echo "***error*** (zip#Write) sorry, mkdir() doesn't work on your system" | echohl None
let &report= repkeep
return
endif
let curdir= getcwd()
let tmpdir= tempname()
if tmpdir =~ '\.'
let tmpdir= substitute(tmpdir,'\.[^.]*$','','e')
endif
call mkdir(tmpdir,"p")
if s:ChgDir(tmpdir,s:ERROR,"(zip#Write) cannot cd to temporary directory")
let &report= repkeep
return
endif
if isdirectory("_ZIPVIM_")
call s:Rmdir("_ZIPVIM_")
endif
call mkdir("_ZIPVIM_")
cd _ZIPVIM_
if has("unix")
let zipfile = substitute(a:fname,'zipfile:\(.\{-}\)::[^\\].*$','\1','')
let fname   = substitute(a:fname,'zipfile:.\{-}::\([^\\].*\)$','\1','')
else
let zipfile = substitute(a:fname,'^.\{-}zipfile:\(.\{-}\)::[^\\].*$','\1','')
let fname   = substitute(a:fname,'^.\{-}zipfile:.\{-}::\([^\\].*\)$','\1','')
endif
if fname =~ '/'
let dirpath = substitute(fname,'/[^/]\+$','','e')
if has("win32unix") && executable("cygpath")
let dirpath = substitute(system("cygpath ".s:Escape(dirpath,0)),'\n','','e')
endif
call mkdir(dirpath,"p")
endif
if zipfile !~ '/'
let zipfile= curdir.'/'.zipfile
endif
exe "w! ".fnameescape(fname)
if has("win32unix") && executable("cygpath")
let zipfile = substitute(system("cygpath ".s:Escape(zipfile,0)),'\n','','e')
endif
if (has("win32") || has("win95") || has("win64") || has("win16")) && &shell !~? 'sh$'
let fname = substitute(fname, '[', '[[]', 'g')
endif
call system(g:zip_zipcmd." -u ".s:Escape(fnamemodify(zipfile,":p"),0)." ".s:Escape(fname,0))
if v:shell_error != 0
redraw!
echohl Error | echo "***error*** (zip#Write) sorry, unable to update ".zipfile." with ".fname | echohl None
elseif s:zipfile_{winnr()} =~ '^\a\+://'
let netzipfile= s:zipfile_{winnr()}
1split|enew
let binkeep= &binary
let eikeep = &ei
set binary ei=all
exe "e! ".fnameescape(zipfile)
call netrw#NetWrite(netzipfile)
let &ei     = eikeep
let &binary = binkeep
q!
unlet s:zipfile_{winnr()}
endif
cd ..
call s:Rmdir("_ZIPVIM_")
call s:ChgDir(curdir,s:WARNING,"(zip#Write) unable to return to ".curdir."!")
call s:Rmdir(tmpdir)
setlocal nomod
let &report= repkeep
endfun
fun! zip#Extract()
let repkeep= &report
set report=10
let fname= getline(".")
if fname =~ '^"'
let &report= repkeep
return
endif
if fname =~ '/$'
redraw!
echohl Error | echo "***error*** (zip#Extract) Please specify a file, not a directory" | echohl None
let &report= repkeep
return
endif
call system(g:zip_extractcmd." ".shellescape(b:zipfile)." ".shellescape(shell))
if v:shell_error != 0
echohl Error | echo "***error*** ".g:zip_extractcmd." ".b:zipfile." ".fname.": failed!" | echohl NONE
elseif !filereadable(fname)
echohl Error | echo "***error*** attempted to extract ".fname." but it doesn't appear to be present!"
else
echo "***note*** successfully extracted ".fname
endif
let &report= repkeep
endfun
fun! s:Escape(fname,isfilt)
if exists("*shellescape")
if a:isfilt
let qnameq= shellescape(a:fname,1)
else
let qnameq= shellescape(a:fname)
endif
else
let qnameq= g:zip_shq.escape(a:fname,g:zip_shq).g:zip_shq
endif
return qnameq
endfun
fun! s:ChgDir(newdir,errlvl,errmsg)
try
exe "cd ".fnameescape(a:newdir)
catch /^Vim\%((\a\+)\)\=:E344/
redraw!
if a:errlvl == s:NOTE
echo "***note*** ".a:errmsg
elseif a:errlvl == s:WARNING
echohl WarningMsg | echo "***warning*** ".a:errmsg | echohl NONE
elseif a:errlvl == s:ERROR
echohl Error | echo "***error*** ".a:errmsg | echohl NONE
endif
return 1
endtry
return 0
endfun
fun! s:Rmdir(fname)
if (has("win32") || has("win95") || has("win64") || has("win16")) && &shell !~? 'sh$'
call system("rmdir /S/Q ".s:Escape(a:fname,0))
else
call system("/bin/rm -rf ".s:Escape(a:fname,0))
endif
endfun
let &cpo= s:keepcpo
unlet s:keepcpo
