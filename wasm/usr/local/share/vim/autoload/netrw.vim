if &cp || exists("g:loaded_netrw")
finish
endif
if v:version < 704 || (v:version == 704 && !has("patch213"))
if !exists("s:needpatch213")
unsilent echomsg "***sorry*** this version of netrw requires vim v7.4 with patch 213"
endif
let s:needpatch213= 1
finish
endif
let g:loaded_netrw = "v156"
if !exists("s:NOTE")
let s:NOTE    = 0
let s:WARNING = 1
let s:ERROR   = 2
endif
let s:keepcpo= &cpo
setl cpo&vim
fun! netrw#ErrorMsg(level,msg,errnum)
if a:level < g:netrw_errorlvl
return
endif
if a:level == 1
let level= "**warning** (netrw) "
elseif a:level == 2
let level= "**error** (netrw) "
else
let level= "**note** (netrw) "
endif
if g:netrw_use_errorwindow
let s:winBeforeErr= winnr()
if bufexists("NetrwMessage") && bufwinnr("NetrwMessage") > 0
exe bufwinnr("NetrwMessage")."wincmd w"
setl ma noro
if type(a:msg) == 3
for msg in a:msg
NetrwKeepj call setline(line("$")+1,level.msg)
endfor
else
NetrwKeepj call setline(line("$")+1,level.a:msg)
endif
NetrwKeepj $
else
bo 1split
sil! call s:NetrwEnew()
sil! NetrwKeepj call s:NetrwSafeOptions()
setl bt=nofile
NetrwKeepj file NetrwMessage
setl ma noro
if type(a:msg) == 3
for msg in a:msg
NetrwKeepj call setline(line("$")+1,level.msg)
endfor
else
NetrwKeepj call setline(line("$"),level.a:msg)
endif
NetrwKeepj $
endif
if &fo !~ '[ta]'
syn clear
syn match netrwMesgNote	"^\*\*note\*\*"
syn match netrwMesgWarning	"^\*\*warning\*\*"
syn match netrwMesgError	"^\*\*error\*\*"
hi link netrwMesgWarning WarningMsg
hi link netrwMesgError   Error
endif
setl ro nomod noma bh=wipe
else
if a:level == s:WARNING
echohl WarningMsg
elseif a:level == s:ERROR
echohl Error
endif
if type(a:msg) == 3
for msg in a:msg
unsilent echomsg level.msg
endfor
else
unsilent echomsg level.a:msg
endif
echohl None
endif
endfun
fun s:NetrwInit(varname,value)
if !exists(a:varname)
if type(a:value) == 0
exe "let ".a:varname."=".a:value
elseif type(a:value) == 1 && a:value =~ '^[{[]'
exe "let ".a:varname."=".a:value
elseif type(a:value) == 1
exe "let ".a:varname."="."'".a:value."'"
else
exe "let ".a:varname."=".a:value
endif
endif
endfun
call s:NetrwInit("g:netrw_dirhist_cnt",0)
if !exists("s:LONGLIST")
call s:NetrwInit("s:THINLIST",0)
call s:NetrwInit("s:LONGLIST",1)
call s:NetrwInit("s:WIDELIST",2)
call s:NetrwInit("s:TREELIST",3)
call s:NetrwInit("s:MAXLIST" ,4)
endif
call s:NetrwInit("g:netrw_use_errorwindow",1)
if !exists("g:netrw_dav_cmd")
if executable("cadaver")
let g:netrw_dav_cmd	= "cadaver"
elseif executable("curl")
let g:netrw_dav_cmd	= "curl"
else
let g:netrw_dav_cmd   = ""
endif
endif
if !exists("g:netrw_fetch_cmd")
if executable("fetch")
let g:netrw_fetch_cmd	= "fetch -o"
else
let g:netrw_fetch_cmd	= ""
endif
endif
if !exists("g:netrw_file_cmd")
if executable("elinks")
call s:NetrwInit("g:netrw_file_cmd","elinks")
elseif executable("links")
call s:NetrwInit("g:netrw_file_cmd","links")
endif
endif
if !exists("g:netrw_ftp_cmd")
let g:netrw_ftp_cmd	= "ftp"
endif
let s:netrw_ftp_cmd= g:netrw_ftp_cmd
if !exists("g:netrw_ftp_options")
let g:netrw_ftp_options= "-i -n"
endif
if !exists("g:netrw_http_cmd")
if executable("elinks")
let g:netrw_http_cmd = "elinks"
call s:NetrwInit("g:netrw_http_xcmd","-source >")
elseif executable("links")
let g:netrw_http_cmd = "links"
call s:NetrwInit("g:netrw_http_xcmd","-source >")
elseif executable("curl")
let g:netrw_http_cmd	= "curl"
call s:NetrwInit("g:netrw_http_xcmd","-o")
elseif executable("wget")
let g:netrw_http_cmd	= "wget"
call s:NetrwInit("g:netrw_http_xcmd","-q -O")
elseif executable("fetch")
let g:netrw_http_cmd	= "fetch"
call s:NetrwInit("g:netrw_http_xcmd","-o")
else
let g:netrw_http_cmd	= ""
endif
endif
call s:NetrwInit("g:netrw_http_put_cmd","curl -T")
call s:NetrwInit("g:netrw_keepj","keepj")
call s:NetrwInit("g:netrw_rcp_cmd"  , "rcp")
call s:NetrwInit("g:netrw_rsync_cmd", "rsync")
if !exists("g:netrw_scp_cmd")
if executable("scp")
call s:NetrwInit("g:netrw_scp_cmd" , "scp -q")
elseif executable("pscp")
if (has("win32") || has("win95") || has("win64") || has("win16")) && filereadable('c:\private.ppk')
call s:NetrwInit("g:netrw_scp_cmd", 'pscp -i c:\private.ppk')
else
call s:NetrwInit("g:netrw_scp_cmd", 'pscp -q')
endif
else
call s:NetrwInit("g:netrw_scp_cmd" , "scp -q")
endif
endif
call s:NetrwInit("g:netrw_sftp_cmd" , "sftp")
call s:NetrwInit("g:netrw_ssh_cmd"  , "ssh")
if (has("win32") || has("win95") || has("win64") || has("win16"))
\ && exists("g:netrw_use_nt_rcp")
\ && g:netrw_use_nt_rcp
\ && executable( $SystemRoot .'/system32/rcp.exe')
let s:netrw_has_nt_rcp = 1
let s:netrw_rcpmode    = '-b'
else
let s:netrw_has_nt_rcp = 0
let s:netrw_rcpmode    = ''
endif
if !exists("g:netrw_cygwin")
if has("win32") || has("win95") || has("win64") || has("win16")
if  has("win32unix") && &shell =~ '\%(\<bash\>\|\<zsh\>\)\%(\.exe\)\=$'
let g:netrw_cygwin= 1
else
let g:netrw_cygwin= 0
endif
else
let g:netrw_cygwin= 0
endif
endif
call s:NetrwInit("g:netrw_alto"        , &sb)
call s:NetrwInit("g:netrw_altv"        , &spr)
call s:NetrwInit("g:netrw_banner"      , 1)
call s:NetrwInit("g:netrw_browse_split", 0)
call s:NetrwInit("g:netrw_bufsettings" , "noma nomod nonu nobl nowrap ro nornu")
call s:NetrwInit("g:netrw_chgwin"      , -1)
call s:NetrwInit("g:netrw_compress"    , "gzip")
call s:NetrwInit("g:netrw_ctags"       , "ctags")
if exists("g:netrw_cursorline") && !exists("g:netrw_cursor")
call netrw#ErrorMsg(s:NOTE,'g:netrw_cursorline is deprecated; use g:netrw_cursor instead',77)
let g:netrw_cursor= g:netrw_cursorline
endif
call s:NetrwInit("g:netrw_cursor"      , 2)
let s:netrw_usercul = &cursorline
let s:netrw_usercuc = &cursorcolumn
call s:NetrwInit("g:netrw_cygdrive","/cygdrive")
call s:NetrwInit("s:didstarstar",0)
call s:NetrwInit("g:netrw_dirhist_cnt"      , 0)
call s:NetrwInit("g:netrw_decompress"       , '{ ".gz" : "gunzip", ".bz2" : "bunzip2", ".zip" : "unzip", ".tar" : "tar -xf", ".xz" : "unxz" }')
call s:NetrwInit("g:netrw_dirhistmax"       , 10)
call s:NetrwInit("g:netrw_errorlvl"  , s:NOTE)
call s:NetrwInit("g:netrw_fastbrowse"       , 1)
call s:NetrwInit("g:netrw_ftp_browse_reject", '^total\s\+\d\+$\|^Trying\s\+\d\+.*$\|^KERBEROS_V\d rejected\|^Security extensions not\|No such file\|: connect to address [0-9a-fA-F:]*: No route to host$')
if !exists("g:netrw_ftp_list_cmd")
if has("unix") || (exists("g:netrw_cygwin") && g:netrw_cygwin)
let g:netrw_ftp_list_cmd     = "ls -lF"
let g:netrw_ftp_timelist_cmd = "ls -tlF"
let g:netrw_ftp_sizelist_cmd = "ls -slF"
else
let g:netrw_ftp_list_cmd     = "dir"
let g:netrw_ftp_timelist_cmd = "dir"
let g:netrw_ftp_sizelist_cmd = "dir"
endif
endif
call s:NetrwInit("g:netrw_ftpmode",'binary')
call s:NetrwInit("g:netrw_hide",1)
if !exists("g:netrw_ignorenetrc")
if &shell =~ '\c\<\%(cmd\|4nt\)\.exe$'
let g:netrw_ignorenetrc= 1
else
let g:netrw_ignorenetrc= 0
endif
endif
call s:NetrwInit("g:netrw_keepdir",1)
if !exists("g:netrw_list_cmd")
if g:netrw_scp_cmd =~ '^pscp' && executable("pscp")
if (has("win32") || has("win95") || has("win64") || has("win16")) && filereadable("c:\\private.ppk")
let g:netrw_scp_cmd ="pscp -i C:\\private.ppk"
endif
if exists("g:netrw_list_cmd_options")
let g:netrw_list_cmd= g:netrw_scp_cmd." -ls USEPORT HOSTNAME: ".g:netrw_list_cmd_options
else
let g:netrw_list_cmd= g:netrw_scp_cmd." -ls USEPORT HOSTNAME:"
endif
elseif executable(g:netrw_ssh_cmd)
if exists("g:netrw_list_cmd_options")
let g:netrw_list_cmd= g:netrw_ssh_cmd." USEPORT HOSTNAME ls -FLa ".g:netrw_list_cmd_options
else
let g:netrw_list_cmd= g:netrw_ssh_cmd." USEPORT HOSTNAME ls -FLa"
endif
else
let g:netrw_list_cmd= ""
endif
endif
call s:NetrwInit("g:netrw_list_hide","")
if exists("g:netrw_local_copycmd")
let g:netrw_localcopycmd= g:netrw_local_copycmd
call netrw#ErrorMsg(s:NOTE,"g:netrw_local_copycmd is deprecated in favor of g:netrw_localcopycmd",84)
endif
if !exists("g:netrw_localcmdshell")
let g:netrw_localcmdshell= ""
endif
if !exists("g:netrw_localcopycmd")
if has("win32") || has("win95") || has("win64") || has("win16")
if g:netrw_cygwin
let g:netrw_localcopycmd= "cp"
else
let g:netrw_localcopycmd= expand("$COMSPEC")." /c copy"
endif
elseif has("unix") || has("macunix")
let g:netrw_localcopycmd= "cp"
else
let g:netrw_localcopycmd= ""
endif
endif
if !exists("g:netrw_localcopydircmd")
if has("win32") || has("win95") || has("win64") || has("win16")
if g:netrw_cygwin
let g:netrw_localcopydircmd= "cp -R"
else
let g:netrw_localcopycmd= expand("$COMSPEC")." /c xcopy /e /c /h /i /k"
endif
elseif has("unix") || has("macunix")
let g:netrw_localcopydircmd= "cp -R"
else
let g:netrw_localcopycmd= ""
endif
endif
if exists("g:netrw_local_mkdir")
let g:netrw_localmkdir= g:netrw_local_mkdir
call netrw#ErrorMsg(s:NOTE,"g:netrw_local_mkdir is deprecated in favor of g:netrw_localmkdir",87)
endif
if has("win32") || has("win95") || has("win64") || has("win16")
if g:netrw_cygwin
call s:NetrwInit("g:netrw_localmkdir","mkdir")
else
let g:netrw_localmkdir= expand("$COMSPEC")." /c mkdir"
endif
else
call s:NetrwInit("g:netrw_localmkdir","mkdir")
endif
call s:NetrwInit("g:netrw_remote_mkdir","mkdir")
if exists("g:netrw_local_movecmd")
let g:netrw_localmovecmd= g:netrw_local_movecmd
call netrw#ErrorMsg(s:NOTE,"g:netrw_local_movecmd is deprecated in favor of g:netrw_localmovecmd",88)
endif
if !exists("g:netrw_localmovecmd")
if has("win32") || has("win95") || has("win64") || has("win16")
if g:netrw_cygwin
let g:netrw_localmovecmd= "mv"
else
let g:netrw_localmovecmd= expand("$COMSPEC")." /c move"
endif
elseif has("unix") || has("macunix")
let g:netrw_localmovecmd= "mv"
else
let g:netrw_localmovecmd= ""
endif
endif
if v:version < 704 || !has("patch1109")
if exists("g:netrw_local_rmdir")
let g:netrw_localrmdir= g:netrw_local_rmdir
call netrw#ErrorMsg(s:NOTE,"g:netrw_local_rmdir is deprecated in favor of g:netrw_localrmdir",86)
endif
if has("win32") || has("win95") || has("win64") || has("win16")
if g:netrw_cygwin
call s:NetrwInit("g:netrw_localrmdir","rmdir")
else
let g:netrw_localrmdir= expand("$COMSPEC")." /c rmdir"
endif
else
call s:NetrwInit("g:netrw_localrmdir","rmdir")
endif
endif
call s:NetrwInit("g:netrw_liststyle"  , s:THINLIST)
if g:netrw_liststyle < 0 || g:netrw_liststyle >= s:MAXLIST
let g:netrw_liststyle= s:THINLIST
endif
if g:netrw_liststyle == s:LONGLIST && g:netrw_scp_cmd !~ '^pscp'
let g:netrw_list_cmd= g:netrw_list_cmd." -l"
endif
call s:NetrwInit("g:netrw_markfileesc"   , '*./[\~')
call s:NetrwInit("g:netrw_maxfilenamelen", 32)
call s:NetrwInit("g:netrw_menu"          , 1)
call s:NetrwInit("g:netrw_mkdir_cmd"     , g:netrw_ssh_cmd." USEPORT HOSTNAME mkdir")
call s:NetrwInit("g:netrw_mousemaps"     , (exists("+mouse") && &mouse =~# '[anh]'))
call s:NetrwInit("g:netrw_retmap"        , 0)
if has("unix") || (exists("g:netrw_cygwin") && g:netrw_cygwin)
call s:NetrwInit("g:netrw_chgperm"       , "chmod PERM FILENAME")
elseif has("win32") || has("win95") || has("win64") || has("win16")
call s:NetrwInit("g:netrw_chgperm"       , "cacls FILENAME /e /p PERM")
else
call s:NetrwInit("g:netrw_chgperm"       , "chmod PERM FILENAME")
endif
call s:NetrwInit("g:netrw_preview"       , 0)
call s:NetrwInit("g:netrw_scpport"       , "-P")
call s:NetrwInit("g:netrw_servername"    , "NETRWSERVER")
call s:NetrwInit("g:netrw_sshport"       , "-p")
call s:NetrwInit("g:netrw_rename_cmd"    , g:netrw_ssh_cmd." USEPORT HOSTNAME mv")
call s:NetrwInit("g:netrw_rm_cmd"        , g:netrw_ssh_cmd." USEPORT HOSTNAME rm")
call s:NetrwInit("g:netrw_rmdir_cmd"     , g:netrw_ssh_cmd." USEPORT HOSTNAME rmdir")
call s:NetrwInit("g:netrw_rmf_cmd"       , g:netrw_ssh_cmd." USEPORT HOSTNAME rm -f ")
call s:NetrwInit("g:netrw_quickhelp",0)
let s:QuickHelp= ["-:go up dir  D:delete  R:rename  s:sort-by  x:special",
\              "(create new)  %:file  d:directory",
\              "(windows split&open) o:horz  v:vert  p:preview",
\              "i:style  qf:file info  O:obtain  r:reverse",
\              "(marks)  mf:mark file  mt:set target  mm:move  mc:copy",
\              "(bookmarks)  mb:make  mB:delete  qb:list  gb:go to",
\              "(history)  qb:list  u:go up  U:go down",
\              "(targets)  mt:target Tb:use bookmark  Th:use history"]
call s:NetrwInit("g:netrw_sepchr"        , (&enc == "euc-jp")? "\<Char-0x01>" : "\<Char-0xff>")
if !exists("g:netrw_keepj") || g:netrw_keepj == "keepj"
call s:NetrwInit("s:netrw_silentxfer"    , (exists("g:netrw_silent") && g:netrw_silent != 0)? "sil keepj " : "keepj ")
else
call s:NetrwInit("s:netrw_silentxfer"    , (exists("g:netrw_silent") && g:netrw_silent != 0)? "sil " : " ")
endif
call s:NetrwInit("g:netrw_sort_by"       , "name") " alternatives: date                                      , size
call s:NetrwInit("g:netrw_sort_options"  , "")
call s:NetrwInit("g:netrw_sort_direction", "normal") " alternative: reverse  (z y x ...)
if !exists("g:netrw_sort_sequence")
if has("unix")
let g:netrw_sort_sequence= '[\/]$,\<core\%(\.\d\+\)\=\>,\.h$,\.c$,\.cpp$,\~\=\*$,*,\.o$,\.obj$,\.info$,\.swp$,\.bak$,\~$'
else
let g:netrw_sort_sequence= '[\/]$,\.h$,\.c$,\.cpp$,*,\.o$,\.obj$,\.info$,\.swp$,\.bak$,\~$'
endif
endif
call s:NetrwInit("g:netrw_special_syntax"   , 0)
call s:NetrwInit("g:netrw_ssh_browse_reject", '^total\s\+\d\+$')
call s:NetrwInit("g:netrw_suppress_gx_mesg",  1)
call s:NetrwInit("g:netrw_use_noswf"        , 1)
call s:NetrwInit("g:netrw_sizestyle"        ,"b")
call s:NetrwInit("g:netrw_timefmt","%c")
if !exists("g:netrw_xstrlen")
if exists("g:Align_xstrlen")
let g:netrw_xstrlen= g:Align_xstrlen
elseif exists("g:drawit_xstrlen")
let g:netrw_xstrlen= g:drawit_xstrlen
elseif &enc == "latin1" || !has("multi_byte")
let g:netrw_xstrlen= 0
else
let g:netrw_xstrlen= 1
endif
endif
call s:NetrwInit("g:NetrwTopLvlMenu","Netrw.")
call s:NetrwInit("g:netrw_win95ftp",1)
call s:NetrwInit("g:netrw_winsize",50)
call s:NetrwInit("g:netrw_wiw",1)
if g:netrw_winsize > 100|let g:netrw_winsize= 100|endif
call s:NetrwInit("g:netrw_fname_escape",' ?&;%')
if has("win32") || has("win95") || has("win64") || has("win16")
call s:NetrwInit("g:netrw_glob_escape",'*?`{[]$')
else
call s:NetrwInit("g:netrw_glob_escape",'*[]?`{~$\')
endif
call s:NetrwInit("g:netrw_menu_escape",'.&? \')
call s:NetrwInit("g:netrw_tmpfile_escape",' &;')
call s:NetrwInit("s:netrw_map_escape","<|\n\r\\\<C-V>\"")
if has("gui_running") && (&enc == 'utf-8' || &enc == 'utf-16' || &enc == 'ucs-4')
let s:treedepthstring= "│ "
else
let s:treedepthstring= "| "
endif
call s:NetrwInit("s:netrw_nbcd",'{}')
if v:version >= 700 && has("balloon_eval") && !exists("s:initbeval") && !exists("g:netrw_nobeval") && has("syntax") && exists("g:syntax_on")
let &l:bexpr = "netrw#BalloonHelp()"
au FileType netrw	setl beval
au WinLeave *		if &ft == "netrw" && exists("s:initbeval")|let &beval= s:initbeval|endif
au VimEnter * 		let s:initbeval= &beval
endif
au WinEnter *	if &ft == "netrw"|call s:NetrwInsureWinVars()|endif
if g:netrw_keepj =~# "keepj"
com! -nargs=*	NetrwKeepj	keepj <args>
else
let g:netrw_keepj= ""
com! -nargs=*	NetrwKeepj	<args>
endif
if v:version >= 700 && has("balloon_eval") && has("syntax") && exists("g:syntax_on") && !exists("g:netrw_nobeval")
fun! netrw#BalloonHelp()
if &ft != "netrw"
return ""
endif
if !exists("w:netrw_bannercnt") || v:beval_lnum >= w:netrw_bannercnt || (exists("g:netrw_nobeval") && g:netrw_nobeval)
let mesg= ""
elseif     v:beval_text == "Netrw" || v:beval_text == "Directory" || v:beval_text == "Listing"
let mesg = "i: thin-long-wide-tree  gh: quick hide/unhide of dot-files   qf: quick file info  %:open new file"
elseif     getline(v:beval_lnum) =~ '^"\s*/'
let mesg = "<cr>: edit/enter   o: edit/enter in horiz window   t: edit/enter in new tab   v:edit/enter in vert window"
elseif     v:beval_text == "Sorted" || v:beval_text == "by"
let mesg = 's: sort by name, time, file size, extension   r: reverse sorting order   mt: mark target'
elseif v:beval_text == "Sort"   || v:beval_text == "sequence"
let mesg = "S: edit sorting sequence"
elseif v:beval_text == "Hiding" || v:beval_text == "Showing"
let mesg = "a: hiding-showing-all   ctrl-h: editing hiding list   mh: hide/show by suffix"
elseif v:beval_text == "Quick" || v:beval_text == "Help"
let mesg = "Help: press <F1>"
elseif v:beval_text == "Copy/Move" || v:beval_text == "Tgt"
let mesg = "mt: mark target   mc: copy marked file to target   mm: move marked file to target"
else
let mesg= ""
endif
return mesg
endfun
endif
fun! netrw#Explore(indx,dosplit,style,...)
if !exists("b:netrw_curdir")
let b:netrw_curdir= getcwd()
endif
if &ft != "netrw"
let w:netrw_rexfile= expand("%:p")
endif
let curdir     = simplify(b:netrw_curdir)
let curfiledir = substitute(expand("%:p"),'^\(.*[/\\]\)[^/\\]*$','\1','e')
if !exists("g:netrw_cygwin") && (has("win32") || has("win95") || has("win64") || has("win16"))
let curdir= substitute(curdir,'\','/','g')
endif
if a:0 > 0
if a:1 =~ "\\\s" && !filereadable(s:NetrwFile(a:1)) && !isdirectory(s:NetrwFile(a:1))
call netrw#Explore(a:indx,a:dosplit,a:style,substitute(a:1,'\\\(\s\)','\1','g'))
return
endif
endif
if has("clipboard")
sil! let keepregstar = @*
sil! let keepregplus = @+
endif
sil! let keepregslash= @/
if a:dosplit || (&modified && &hidden == 0 && &bufhidden != "hide") || a:style == 6
call s:SaveWinVars()
let winsz= g:netrw_winsize
if a:indx > 0
let winsz= a:indx
endif
if a:style == 0      " Explore, Sexplore
let winsz= (winsz > 0)? (winsz*winheight(0))/100 : -winsz
if winsz == 0|let winsz= ""|endif
exe "noswapfile ".winsz."wincmd s"
elseif a:style == 1  "Explore!, Sexplore!
let winsz= (winsz > 0)? (winsz*winwidth(0))/100 : -winsz
if winsz == 0|let winsz= ""|endif
exe "keepalt noswapfile ".winsz."wincmd v"
elseif a:style == 2  " Hexplore
let winsz= (winsz > 0)? (winsz*winheight(0))/100 : -winsz
if winsz == 0|let winsz= ""|endif
exe "keepalt noswapfile bel ".winsz."wincmd s"
elseif a:style == 3  " Hexplore!
let winsz= (winsz > 0)? (winsz*winheight(0))/100 : -winsz
if winsz == 0|let winsz= ""|endif
exe "keepalt noswapfile abo ".winsz."wincmd s"
elseif a:style == 4  " Vexplore
let winsz= (winsz > 0)? (winsz*winwidth(0))/100 : -winsz
if winsz == 0|let winsz= ""|endif
exe "keepalt noswapfile lefta ".winsz."wincmd v"
elseif a:style == 5  " Vexplore!
let winsz= (winsz > 0)? (winsz*winwidth(0))/100 : -winsz
if winsz == 0|let winsz= ""|endif
exe "keepalt noswapfile rightb ".winsz."wincmd v"
elseif a:style == 6  " Texplore
call s:SaveBufVars()
exe "keepalt tabnew ".fnameescape(curdir)
call s:RestoreBufVars()
endif
call s:RestoreWinVars()
endif
NetrwKeepj norm! 0
if a:0 > 0
if a:1 =~ '^\~' && (has("unix") || (exists("g:netrw_cygwin") && g:netrw_cygwin))
let dirname= simplify(substitute(a:1,'\~',expand("$HOME"),''))
elseif a:1 == '.'
let dirname= simplify(exists("b:netrw_curdir")? b:netrw_curdir : getcwd())
if dirname !~ '/$'
let dirname= dirname."/"
endif
elseif a:1 =~ '\$'
let dirname= simplify(expand(a:1))
elseif a:1 !~ '^\*\{1,2}/' && a:1 !~ '^\a\{3,}://'
let dirname= simplify(a:1)
else
let dirname= a:1
endif
else
call s:NetrwClearExplore()
return
endif
if dirname =~ '\.\./\=$'
let dirname= simplify(fnamemodify(dirname,':p:h'))
elseif dirname =~ '\.\.' || dirname == '.'
let dirname= simplify(fnamemodify(dirname,':p'))
endif
if dirname =~ '^\*//'
let pattern= substitute(dirname,'^\*//\(.*\)$','\1','')
let starpat= 1
if &hls | let keepregslash= s:ExplorePatHls(pattern) | endif
elseif dirname =~ '^\*\*//'
let pattern= substitute(dirname,'^\*\*//','','')
let starpat= 2
elseif dirname =~ '/\*\*/'
let prefixdir= substitute(dirname,'^\(.\{-}\)\*\*.*$','\1','')
if prefixdir =~ '^/' || (prefixdir =~ '^\a:/' && (has("win32") || has("win95") || has("win64") || has("win16")))
let b:netrw_curdir = prefixdir
else
let b:netrw_curdir= getcwd().'/'.prefixdir
endif
let dirname= substitute(dirname,'^.\{-}\(\*\*/.*\)$','\1','')
let starpat= 4
elseif dirname =~ '^\*/'
let starpat= 3
elseif dirname=~ '^\*\*/'
let starpat= 4
else
let starpat= 0
endif
if starpat == 0 && a:indx >= 0
if dirname == ""
let dirname= curfiledir
endif
if dirname =~# '^scp://' || dirname =~ '^ftp://'
call netrw#Nread(2,dirname)
else
if dirname == ""
let dirname= getcwd()
elseif (has("win32") || has("win95") || has("win64") || has("win16")) && !g:netrw_cygwin
if dirname !~ '^[a-zA-Z]:' && dirname !~ '^\\\\\w\+' && dirname !~ '^//\w\+'
let dirname= b:netrw_curdir."/".dirname
endif
elseif dirname !~ '^/'
let dirname= b:netrw_curdir."/".dirname
endif
call netrw#LocalBrowseCheck(dirname)
endif
if exists("w:netrw_bannercnt")
exe w:netrw_bannercnt
endif
elseif a:indx <= 0
if !mapcheck("<s-up>","n") && !mapcheck("<s-down>","n") && exists("b:netrw_curdir")
let s:didstarstar= 1
nnoremap <buffer> <silent> <s-up>	:Pexplore<cr>
nnoremap <buffer> <silent> <s-down>	:Nexplore<cr>
endif
if has("path_extra")
if !exists("w:netrw_explore_indx")
let w:netrw_explore_indx= 0
endif
let indx = a:indx
if indx == -1
if !exists("w:netrw_explore_list") " sanity check
NetrwKeepj call netrw#ErrorMsg(s:WARNING,"using Nexplore or <s-down> improperly; see help for netrw-starstar",40)
if has("clipboard")
sil! let @* = keepregstar
sil! let @+ = keepregstar
endif
sil! let @/ = keepregslash
return
endif
let indx= w:netrw_explore_indx
if indx < 0                        | let indx= 0                           | endif
if indx >= w:netrw_explore_listlen | let indx= w:netrw_explore_listlen - 1 | endif
let curfile= w:netrw_explore_list[indx]
while indx < w:netrw_explore_listlen && curfile == w:netrw_explore_list[indx]
let indx= indx + 1
endwhile
if indx >= w:netrw_explore_listlen | let indx= w:netrw_explore_listlen - 1 | endif
elseif indx == -2
if !exists("w:netrw_explore_list") " sanity check
NetrwKeepj call netrw#ErrorMsg(s:WARNING,"using Pexplore or <s-up> improperly; see help for netrw-starstar",41)
if has("clipboard")
sil! let @* = keepregstar
sil! let @+ = keepregstar
endif
sil! let @/ = keepregslash
return
endif
let indx= w:netrw_explore_indx
if indx < 0                        | let indx= 0                           | endif
if indx >= w:netrw_explore_listlen | let indx= w:netrw_explore_listlen - 1 | endif
let curfile= w:netrw_explore_list[indx]
while indx >= 0 && curfile == w:netrw_explore_list[indx]
let indx= indx - 1
endwhile
if indx < 0                        | let indx= 0                           | endif
else
NetrwKeepj keepalt call s:NetrwClearExplore()
let w:netrw_explore_indx= 0
if !exists("b:netrw_curdir")
let b:netrw_curdir= getcwd()
endif
if starpat == 1
try
exe "NetrwKeepj noautocmd vimgrep /".pattern."/gj ".fnameescape(b:netrw_curdir)."/*"
catch /^Vim\%((\a\+)\)\=:E480/
keepalt call netrw#ErrorMsg(s:WARNING,"no match with pattern<".pattern.">",76)
return
endtry
let w:netrw_explore_list = s:NetrwExploreListUniq(map(getqflist(),'bufname(v:val.bufnr)'))
if &hls | let keepregslash= s:ExplorePatHls(pattern) | endif
elseif starpat == 2
try
exe "sil NetrwKeepj noautocmd keepalt vimgrep /".pattern."/gj "."**/*"
catch /^Vim\%((\a\+)\)\=:E480/
keepalt call netrw#ErrorMsg(s:WARNING,'no files matched pattern<'.pattern.'>',45)
if &hls | let keepregslash= s:ExplorePatHls(pattern) | endif
if has("clipboard")
sil! let @* = keepregstar
sil! let @+ = keepregstar
endif
sil! let @/ = keepregslash
return
endtry
let s:netrw_curdir       = b:netrw_curdir
let w:netrw_explore_list = getqflist()
let w:netrw_explore_list = s:NetrwExploreListUniq(map(w:netrw_explore_list,'s:netrw_curdir."/".bufname(v:val.bufnr)'))
if &hls | let keepregslash= s:ExplorePatHls(pattern) | endif
elseif starpat == 3
let filepat= substitute(dirname,'^\*/','','')
let filepat= substitute(filepat,'^[%#<]','\\&','')
let w:netrw_explore_list= s:NetrwExploreListUniq(split(expand(b:netrw_curdir."/".filepat),'\n'))
if &hls | let keepregslash= s:ExplorePatHls(filepat) | endif
elseif starpat == 4
let w:netrw_explore_list= s:NetrwExploreListUniq(split(expand(b:netrw_curdir."/".dirname),'\n'))
if &hls | let keepregslash= s:ExplorePatHls(dirname) | endif
endif " switch on starpat to build w:netrw_explore_list
let w:netrw_explore_listlen = len(w:netrw_explore_list)
if w:netrw_explore_listlen == 0 || (w:netrw_explore_listlen == 1 && w:netrw_explore_list[0] =~ '\*\*\/')
keepalt NetrwKeepj call netrw#ErrorMsg(s:WARNING,"no files matched",42)
if has("clipboard")
sil! let @* = keepregstar
sil! let @+ = keepregstar
endif
sil! let @/ = keepregslash
return
endif
endif  " if indx ... endif
let w:netrw_explore_indx= indx
if indx >= w:netrw_explore_listlen || indx < 0
let indx                = (indx < 0)? ( w:netrw_explore_listlen - 1 ) : 0
let w:netrw_explore_indx= indx
keepalt NetrwKeepj call netrw#ErrorMsg(s:NOTE,"no more files match Explore pattern",43)
endif
exe "let dirfile= w:netrw_explore_list[".indx."]"
let newdir= substitute(dirfile,'/[^/]*$','','e')
call netrw#LocalBrowseCheck(newdir)
if !exists("w:netrw_liststyle")
let w:netrw_liststyle= g:netrw_liststyle
endif
if w:netrw_liststyle == s:THINLIST || w:netrw_liststyle == s:LONGLIST
keepalt NetrwKeepj call search('^'.substitute(dirfile,"^.*/","","").'\>',"W")
else
keepalt NetrwKeepj call search('\<'.substitute(dirfile,"^.*/","","").'\>',"w")
endif
let w:netrw_explore_mtchcnt = indx + 1
let w:netrw_explore_bufnr   = bufnr("%")
let w:netrw_explore_line    = line(".")
keepalt NetrwKeepj call s:SetupNetrwStatusLine('%f %h%m%r%=%9*%{NetrwStatusLine()}')
else
if !exists("g:netrw_quiet")
keepalt NetrwKeepj call netrw#ErrorMsg(s:WARNING,"your vim needs the +path_extra feature for Exploring with **!",44)
endif
if has("clipboard")
sil! let @* = keepregstar
sil! let @+ = keepregstar
endif
sil! let @/ = keepregslash
return
endif
else
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && dirname =~ '/'
sil! unlet w:netrw_treedict
sil! unlet w:netrw_treetop
endif
let newdir= dirname
if !exists("b:netrw_curdir")
NetrwKeepj call netrw#LocalBrowseCheck(getcwd())
else
NetrwKeepj call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(1,newdir))
endif
endif
if exists("w:netrw_explore_indx") && exists("b:netrw_curdir")
if !exists("s:explore_prvdir") || s:explore_prvdir != b:netrw_curdir
let s:explore_prvdir = b:netrw_curdir
let s:explore_match  = ""
let dirlen           = strlen(b:netrw_curdir)
if b:netrw_curdir !~ '/$'
let dirlen= dirlen + 1
endif
let prvfname= ""
for fname in w:netrw_explore_list
if fname =~ '^'.b:netrw_curdir
if s:explore_match == ""
let s:explore_match= '\<'.escape(strpart(fname,dirlen),g:netrw_markfileesc).'\>'
else
let s:explore_match= s:explore_match.'\|\<'.escape(strpart(fname,dirlen),g:netrw_markfileesc).'\>'
endif
elseif fname !~ '^/' && fname != prvfname
if s:explore_match == ""
let s:explore_match= '\<'.escape(fname,g:netrw_markfileesc).'\>'
else
let s:explore_match= s:explore_match.'\|\<'.escape(fname,g:netrw_markfileesc).'\>'
endif
endif
let prvfname= fname
endfor
exe "2match netrwMarkFile /".s:explore_match."/"
endif
echo "<s-up>==Pexplore  <s-down>==Nexplore"
else
2match none
if exists("s:explore_match")  | unlet s:explore_match  | endif
if exists("s:explore_prvdir") | unlet s:explore_prvdir | endif
echo " "
endif
let s:netrw_events= 2
if has("clipboard")
sil! let @* = keepregstar
sil! let @+ = keepregstar
endif
sil! let @/ = keepregslash
endfun
fun! netrw#Lexplore(count,rightside,...)
let curwin= winnr()
if a:0 > 0 && a:1 != ""
let a1 = expand(a:1)
exe "1wincmd w"
if &ft == "netrw"
exe "Explore ".fnameescape(a1)
exe curwin."wincmd w"
if exists("t:netrw_lexposn")
unlet t:netrw_lexposn
endif
return
endif
exe curwin."wincmd w"
else
let a1= ""
endif
if exists("t:netrw_lexbufnr")
let lexwinnr = bufwinnr(t:netrw_lexbufnr)
else
let lexwinnr= 0
endif
if lexwinnr > 0
exe lexwinnr."wincmd w"
let g:netrw_winsize = -winwidth(0)
let t:netrw_lexposn = winsaveview()
close
if lexwinnr < curwin
let curwin= curwin - 1
endif
exe curwin."wincmd w"
unlet t:netrw_lexbufnr
else
exe "1wincmd w"
let keep_altv    = g:netrw_altv
let g:netrw_altv = 0
if a:count != 0
let netrw_winsize   = g:netrw_winsize
let g:netrw_winsize = a:count
endif
let curfile= expand("%")
exe (a:rightside? "botright" : "topleft")." vertical ".((g:netrw_winsize > 0)? (g:netrw_winsize*winwidth(0))/100 : -g:netrw_winsize) . " new"
if a:0 > 0 && a1 != ""
exe "Explore ".fnameescape(a1)
elseif curfile =~ '^\a\{3,}://'
exe "Explore ".substitute(curfile,'[^/\\]*$','','')
else
Explore .
endif
if a:count != 0
let g:netrw_winsize = netrw_winsize
endif
setlocal winfixwidth
let g:netrw_altv     = keep_altv
let t:netrw_lexbufnr = bufnr("%")
if exists("t:netrw_lexposn")
call winrestview(t:netrw_lexposn)
unlet t:netrw_lexposn
endif
endif
if exists("g:netrw_chgwin") && g:netrw_chgwin == -1
if a:rightside
let g:netrw_chgwin= 1
else
let g:netrw_chgwin= 2
endif
endif
endfun
fun! netrw#Clean(sys)
if a:sys
let choice= confirm("Remove personal and system copies of netrw?","&Yes\n&No")
else
let choice= confirm("Remove personal copy of netrw?","&Yes\n&No")
endif
let diddel= 0
let diddir= ""
if choice == 1
for dir in split(&rtp,',')
if filereadable(dir."/plugin/netrwPlugin.vim")
if s:NetrwDelete(dir."/plugin/netrwPlugin.vim")        |call netrw#ErrorMsg(1,"unable to remove ".dir."/plugin/netrwPlugin.vim",55)        |endif
if s:NetrwDelete(dir."/autoload/netrwFileHandlers.vim")|call netrw#ErrorMsg(1,"unable to remove ".dir."/autoload/netrwFileHandlers.vim",55)|endif
if s:NetrwDelete(dir."/autoload/netrwSettings.vim")    |call netrw#ErrorMsg(1,"unable to remove ".dir."/autoload/netrwSettings.vim",55)    |endif
if s:NetrwDelete(dir."/autoload/netrw.vim")            |call netrw#ErrorMsg(1,"unable to remove ".dir."/autoload/netrw.vim",55)            |endif
if s:NetrwDelete(dir."/syntax/netrw.vim")              |call netrw#ErrorMsg(1,"unable to remove ".dir."/syntax/netrw.vim",55)              |endif
if s:NetrwDelete(dir."/syntax/netrwlist.vim")          |call netrw#ErrorMsg(1,"unable to remove ".dir."/syntax/netrwlist.vim",55)          |endif
let diddir= dir
let diddel= diddel + 1
if !a:sys|break|endif
endif
endfor
endif
echohl WarningMsg
if diddel == 0
echomsg "netrw is either not installed or not removable"
elseif diddel == 1
echomsg "removed one copy of netrw from <".diddir.">"
else
echomsg "removed ".diddel." copies of netrw"
endif
echohl None
endfun
fun! netrw#MakeTgt(dname)
let svpos               = winsaveview()
let s:netrwmftgt_islocal= (a:dname !~ '^\a\{3,}://')
if s:netrwmftgt_islocal
let netrwmftgt= simplify(a:dname)
else
let netrwmftgt= a:dname
endif
if exists("s:netrwmftgt") && netrwmftgt == s:netrwmftgt
unlet s:netrwmftgt s:netrwmftgt_islocal
else
let s:netrwmftgt= netrwmftgt
endif
if g:netrw_fastbrowse <= 1
call s:NetrwRefresh((b:netrw_curdir !~ '\a\{3,}://'),b:netrw_curdir)
endif
call winrestview(svpos)
endfun
fun! netrw#Obtain(islocal,fname,...)
if type(a:fname) == 1
let fnamelist= [ a:fname ]
elseif type(a:fname) == 3
let fnamelist= a:fname
else
call netrw#ErrorMsg(s:ERROR,"attempting to use NetrwObtain on something not a filename or a list",62)
return
endif
if a:0 > 0
let tgtdir= a:1
else
let tgtdir= getcwd()
endif
if exists("b:netrw_islocal") && b:netrw_islocal
if exists("b:netrw_curdir") && getcwd() != b:netrw_curdir
let topath= s:ComposePath(tgtdir,"")
if (has("win32") || has("win95") || has("win64") || has("win16"))
for fname in fnamelist
call system(g:netrw_localcopycmd." ".s:ShellEscape(fname)." ".s:ShellEscape(topath))
if v:shell_error != 0
call netrw#ErrorMsg(s:WARNING,"consider setting g:netrw_localcopycmd<".g:netrw_localcopycmd."> to something that works",80)
return
endif
endfor
else
let filelist= join(map(deepcopy(fnamelist),"s:ShellEscape(v:val)"))
call system(g:netrw_localcopycmd." ".filelist." ".s:ShellEscape(topath))
if v:shell_error != 0
call netrw#ErrorMsg(s:WARNING,"consider setting g:netrw_localcopycmd<".g:netrw_localcopycmd."> to something that works",80)
return
endif
endif
elseif !exists("b:netrw_curdir")
call netrw#ErrorMsg(s:ERROR,"local browsing directory doesn't exist!",36)
else
call netrw#ErrorMsg(s:WARNING,"local browsing directory and current directory are identical",37)
endif
else
if type(a:fname) == 1
call s:SetupNetrwStatusLine('%f %h%m%r%=%9*Obtaining '.a:fname)
endif
call s:NetrwMethod(b:netrw_curdir)
if b:netrw_method == 4
if exists("g:netrw_port") && g:netrw_port != ""
let useport= " ".g:netrw_scpport." ".g:netrw_port
else
let useport= ""
endif
if b:netrw_fname =~ '/'
let path= substitute(b:netrw_fname,'^\(.*/\).\{-}$','\1','')
else
let path= ""
endif
let filelist= join(map(deepcopy(fnamelist),'s:ShellEscape(g:netrw_machine.":".path.v:val,1)'))
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_scp_cmd.s:ShellEscape(useport,1)." ".filelist." ".s:ShellEscape(tgtdir,1))
elseif b:netrw_method == 2
call s:SaveBufVars()|sil NetrwKeepj new|call s:RestoreBufVars()
let tmpbufnr= bufnr("%")
setl ff=unix
if exists("g:netrw_ftpmode") && g:netrw_ftpmode != ""
NetrwKeepj put =g:netrw_ftpmode
endif
if exists("b:netrw_fname") && b:netrw_fname != ""
call setline(line("$")+1,'cd "'.b:netrw_fname.'"')
endif
if exists("g:netrw_ftpextracmd")
NetrwKeepj put =g:netrw_ftpextracmd
endif
for fname in fnamelist
call setline(line("$")+1,'get "'.fname.'"')
endfor
if exists("g:netrw_port") && g:netrw_port != ""
call s:NetrwExe(s:netrw_silentxfer."%!".s:netrw_ftp_cmd." -i ".s:ShellEscape(g:netrw_machine,1)." ".s:ShellEscape(g:netrw_port,1))
else
call s:NetrwExe(s:netrw_silentxfer."%!".s:netrw_ftp_cmd." -i ".s:ShellEscape(g:netrw_machine,1))
endif
if getline(1) !~ "^$" && !exists("g:netrw_quiet") && getline(1) !~ '^Trying '
let debugkeep= &debug
setl debug=msg
call netrw#ErrorMsg(s:ERROR,getline(1),4)
let &debug= debugkeep
endif
elseif b:netrw_method == 3
call s:SaveBufVars()|sil NetrwKeepj new|call s:RestoreBufVars()
let tmpbufnr= bufnr("%")
setl ff=unix
if exists("g:netrw_port") && g:netrw_port != ""
NetrwKeepj put ='open '.g:netrw_machine.' '.g:netrw_port
else
NetrwKeepj put ='open '.g:netrw_machine
endif
if exists("g:netrw_uid") && g:netrw_uid != ""
if exists("g:netrw_ftp") && g:netrw_ftp == 1
NetrwKeepj put =g:netrw_uid
if exists("s:netrw_passwd") && s:netrw_passwd != ""
NetrwKeepj put ='\"'.s:netrw_passwd.'\"'
endif
elseif exists("s:netrw_passwd")
NetrwKeepj put ='user \"'.g:netrw_uid.'\" \"'.s:netrw_passwd.'\"'
endif
endif
if exists("g:netrw_ftpmode") && g:netrw_ftpmode != ""
NetrwKeepj put =g:netrw_ftpmode
endif
if exists("b:netrw_fname") && b:netrw_fname != ""
NetrwKeepj call setline(line("$")+1,'cd "'.b:netrw_fname.'"')
endif
if exists("g:netrw_ftpextracmd")
NetrwKeepj put =g:netrw_ftpextracmd
endif
if exists("g:netrw_ftpextracmd")
NetrwKeepj put =g:netrw_ftpextracmd
endif
for fname in fnamelist
NetrwKeepj call setline(line("$")+1,'get "'.fname.'"')
endfor
NetrwKeepj norm! 1Gdd
call s:NetrwExe(s:netrw_silentxfer."%!".s:netrw_ftp_cmd." ".g:netrw_ftp_options)
if getline(1) !~ "^$"
if !exists("g:netrw_quiet")
NetrwKeepj call netrw#ErrorMsg(s:ERROR,getline(1),5)
endif
endif
elseif b:netrw_method == 9
if a:fname =~ '/'
let localfile= substitute(a:fname,'^.*/','','')
else
let localfile= a:fname
endif
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_sftp_cmd." ".s:ShellEscape(g:netrw_machine.":".b:netrw_fname,1).s:ShellEscape(localfile)." ".s:ShellEscape(tgtdir))
elseif !exists("b:netrw_method") || b:netrw_method < 0
return
else
if !exists("g:netrw_quiet")
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"current protocol not supported for obtaining file",97)
endif
return
endif
if type(a:fname) == 1 && exists("s:netrw_users_stl")
NetrwKeepj call s:SetupNetrwStatusLine(s:netrw_users_stl)
endif
endif
if exists("tmpbufnr")
if bufnr("%") != tmpbufnr
exe tmpbufnr."bw!"
else
q!
endif
endif
endfun
fun! netrw#Nread(mode,fname)
let svpos= winsaveview()
call netrw#NetRead(a:mode,a:fname)
call winrestview(svpos)
if exists("w:netrw_liststyle") && w:netrw_liststyle != s:TREELIST
if exists("w:netrw_bannercnt")
exe w:netrw_bannercnt
endif
endif
endfun
fun! s:NetrwOptionRestore(vt)
if !exists("{a:vt}netrw_optionsave")
call s:RestorePosn(s:netrw_nbcd)
return
endif
unlet {a:vt}netrw_optionsave
if exists("+acd")
if exists("{a:vt}netrw_acdkeep")
let curdir = getcwd()
let &l:acd = {a:vt}netrw_acdkeep
unlet {a:vt}netrw_acdkeep
if &l:acd
call s:NetrwLcd(curdir)
endif
endif
endif
if exists("{a:vt}netrw_aikeep")   |let &l:ai     = {a:vt}netrw_aikeep      |unlet {a:vt}netrw_aikeep   |endif
if exists("{a:vt}netrw_awkeep")   |let &l:aw     = {a:vt}netrw_awkeep      |unlet {a:vt}netrw_awkeep   |endif
if exists("{a:vt}netrw_blkeep")   |let &l:bl     = {a:vt}netrw_blkeep      |unlet {a:vt}netrw_blkeep   |endif
if exists("{a:vt}netrw_btkeep")   |let &l:bt     = {a:vt}netrw_btkeep      |unlet {a:vt}netrw_btkeep   |endif
if exists("{a:vt}netrw_bombkeep") |let &l:bomb   = {a:vt}netrw_bombkeep    |unlet {a:vt}netrw_bombkeep |endif
if exists("{a:vt}netrw_cedit")    |let &cedit    = {a:vt}netrw_cedit       |unlet {a:vt}netrw_cedit    |endif
if exists("{a:vt}netrw_cikeep")   |let &l:ci     = {a:vt}netrw_cikeep      |unlet {a:vt}netrw_cikeep   |endif
if exists("{a:vt}netrw_cinkeep")  |let &l:cin    = {a:vt}netrw_cinkeep     |unlet {a:vt}netrw_cinkeep  |endif
if exists("{a:vt}netrw_cinokeep") |let &l:cino   = {a:vt}netrw_cinokeep    |unlet {a:vt}netrw_cinokeep |endif
if exists("{a:vt}netrw_comkeep")  |let &l:com    = {a:vt}netrw_comkeep     |unlet {a:vt}netrw_comkeep  |endif
if exists("{a:vt}netrw_cpokeep")  |let &l:cpo    = {a:vt}netrw_cpokeep     |unlet {a:vt}netrw_cpokeep  |endif
if exists("{a:vt}netrw_diffkeep") |let &l:diff   = {a:vt}netrw_diffkeep    |unlet {a:vt}netrw_diffkeep |endif
if exists("{a:vt}netrw_fenkeep")  |let &l:fen    = {a:vt}netrw_fenkeep     |unlet {a:vt}netrw_fenkeep  |endif
if exists("g:netrw_ffkep") && g:netrw_ffkeep
if exists("{a:vt}netrw_ffkeep")   |let &l:ff     = {a:vt}netrw_ffkeep      |unlet {a:vt}netrw_ffkeep   |endif
endif
if exists("{a:vt}netrw_fokeep")   |let &l:fo     = {a:vt}netrw_fokeep      |unlet {a:vt}netrw_fokeep   |endif
if exists("{a:vt}netrw_gdkeep")   |let &l:gd     = {a:vt}netrw_gdkeep      |unlet {a:vt}netrw_gdkeep   |endif
if exists("{a:vt}netrw_hidkeep")  |let &l:hidden = {a:vt}netrw_hidkeep     |unlet {a:vt}netrw_hidkeep  |endif
if exists("{a:vt}netrw_imkeep")   |let &l:im     = {a:vt}netrw_imkeep      |unlet {a:vt}netrw_imkeep   |endif
if exists("{a:vt}netrw_iskkeep")  |let &l:isk    = {a:vt}netrw_iskkeep     |unlet {a:vt}netrw_iskkeep  |endif
if exists("{a:vt}netrw_lskeep")   |let &l:ls     = {a:vt}netrw_lskeep      |unlet {a:vt}netrw_lskeep   |endif
if exists("{a:vt}netrw_makeep")   |let &l:ma     = {a:vt}netrw_makeep      |unlet {a:vt}netrw_makeep   |endif
if exists("{a:vt}netrw_magickeep")|let &l:magic  = {a:vt}netrw_magickeep   |unlet {a:vt}netrw_magickeep|endif
if exists("{a:vt}netrw_modkeep")  |let &l:mod    = {a:vt}netrw_modkeep     |unlet {a:vt}netrw_modkeep  |endif
if exists("{a:vt}netrw_nukeep")   |let &l:nu     = {a:vt}netrw_nukeep      |unlet {a:vt}netrw_nukeep   |endif
if exists("{a:vt}netrw_rnukeep")  |let &l:rnu    = {a:vt}netrw_rnukeep     |unlet {a:vt}netrw_rnukeep  |endif
if exists("{a:vt}netrw_repkeep")  |let &l:report = {a:vt}netrw_repkeep     |unlet {a:vt}netrw_repkeep  |endif
if exists("{a:vt}netrw_rokeep")   |let &l:ro     = {a:vt}netrw_rokeep      |unlet {a:vt}netrw_rokeep   |endif
if exists("{a:vt}netrw_selkeep")  |let &l:sel    = {a:vt}netrw_selkeep     |unlet {a:vt}netrw_selkeep  |endif
if exists("{a:vt}netrw_spellkeep")|let &l:spell  = {a:vt}netrw_spellkeep   |unlet {a:vt}netrw_spellkeep|endif
if has("clipboard")
if exists("{a:vt}netrw_starkeep") |let @*        = {a:vt}netrw_starkeep    |unlet {a:vt}netrw_starkeep |endif
endif
if exists("{a:vt}netrw_twkeep")   |let &l:tw     = {a:vt}netrw_twkeep      |unlet {a:vt}netrw_twkeep   |endif
if exists("{a:vt}netrw_wigkeep")  |let &l:wig    = {a:vt}netrw_wigkeep     |unlet {a:vt}netrw_wigkeep  |endif
if exists("{a:vt}netrw_wrapkeep") |let &l:wrap   = {a:vt}netrw_wrapkeep    |unlet {a:vt}netrw_wrapkeep |endif
if exists("{a:vt}netrw_writekeep")|let &l:write  = {a:vt}netrw_writekeep   |unlet {a:vt}netrw_writekeep|endif
if exists("s:yykeep")             |let  @@       = s:yykeep                |unlet s:yykeep             |endif
if exists("{a:vt}netrw_swfkeep")
if &directory == ""
let &l:directory= getcwd()
sil! let &l:swf = {a:vt}netrw_swfkeep
setl directory=
unlet {a:vt}netrw_swfkeep
elseif &l:swf != {a:vt}netrw_swfkeep
if !g:netrw_use_noswf
sil! let &l:swf= {a:vt}netrw_swfkeep
endif
unlet {a:vt}netrw_swfkeep
endif
endif
if exists("{a:vt}netrw_dirkeep") && isdirectory(s:NetrwFile({a:vt}netrw_dirkeep)) && g:netrw_keepdir
let dirkeep = substitute({a:vt}netrw_dirkeep,'\\','/','g')
if exists("{a:vt}netrw_dirkeep")
call s:NetrwLcd(dirkeep)
unlet {a:vt}netrw_dirkeep
endif
endif
if has("clipboard")
if exists("{a:vt}netrw_regstar") |sil! let @*= {a:vt}netrw_regstar |unlet {a:vt}netrw_regstar |endif
endif
if exists("{a:vt}netrw_regslash")|sil! let @/= {a:vt}netrw_regslash|unlet {a:vt}netrw_regslash|endif
call s:RestorePosn(s:netrw_nbcd)
if &ft != "netrw"
filetype detect
endif
endfun
fun! s:NetrwOptionSave(vt)
if !exists("{a:vt}netrw_optionsave")
let {a:vt}netrw_optionsave= 1
else
return
endif
let s:yykeep          = @@
if exists("&l:acd")|let {a:vt}netrw_acdkeep  = &l:acd|endif
let {a:vt}netrw_aikeep    = &l:ai
let {a:vt}netrw_awkeep    = &l:aw
let {a:vt}netrw_bhkeep    = &l:bh
let {a:vt}netrw_blkeep    = &l:bl
let {a:vt}netrw_btkeep    = &l:bt
let {a:vt}netrw_bombkeep  = &l:bomb
let {a:vt}netrw_cedit     = &cedit
let {a:vt}netrw_cikeep    = &l:ci
let {a:vt}netrw_cinkeep   = &l:cin
let {a:vt}netrw_cinokeep  = &l:cino
let {a:vt}netrw_comkeep   = &l:com
let {a:vt}netrw_cpokeep   = &l:cpo
let {a:vt}netrw_diffkeep  = &l:diff
let {a:vt}netrw_fenkeep   = &l:fen
if !exists("g:netrw_ffkeep") || g:netrw_ffkeep
let {a:vt}netrw_ffkeep    = &l:ff
endif
let {a:vt}netrw_fokeep    = &l:fo           " formatoptions
let {a:vt}netrw_gdkeep    = &l:gd           " gdefault
let {a:vt}netrw_hidkeep   = &l:hidden
let {a:vt}netrw_imkeep    = &l:im
let {a:vt}netrw_iskkeep   = &l:isk
let {a:vt}netrw_lskeep    = &l:ls
let {a:vt}netrw_makeep    = &l:ma
let {a:vt}netrw_magickeep = &l:magic
let {a:vt}netrw_modkeep   = &l:mod
let {a:vt}netrw_nukeep    = &l:nu
let {a:vt}netrw_rnukeep   = &l:rnu
let {a:vt}netrw_repkeep   = &l:report
let {a:vt}netrw_rokeep    = &l:ro
let {a:vt}netrw_selkeep   = &l:sel
let {a:vt}netrw_spellkeep = &l:spell
if !g:netrw_use_noswf
let {a:vt}netrw_swfkeep  = &l:swf
endif
if has("clipboard")
let {a:vt}netrw_starkeep = @*
endif
let {a:vt}netrw_tskeep    = &l:ts
let {a:vt}netrw_twkeep    = &l:tw           " textwidth
let {a:vt}netrw_wigkeep   = &l:wig          " wildignore
let {a:vt}netrw_wrapkeep  = &l:wrap
let {a:vt}netrw_writekeep = &l:write
if g:netrw_keepdir
let {a:vt}netrw_dirkeep  = getcwd()
endif
if has("clipboard")
if &go =~# 'a' | sil! let {a:vt}netrw_regstar = @* | endif
endif
sil! let {a:vt}netrw_regslash= @/
endfun
fun! s:NetrwSafeOptions()
if exists("+acd") | setl noacd | endif
setl noai
setl noaw
setl nobl
setl nobomb
setl bt=nofile
setl noci
setl nocin
setl bh=hide
setl cino=
setl com=
setl cpo-=a
setl cpo-=A
setl fo=nroql2
setl nohid
setl noim
setl isk+=@ isk+=* isk+=/
setl magic
if g:netrw_use_noswf
setl noswf
endif
setl report=10000
setl sel=inclusive
setl nospell
setl tw=0
setl wig=
setl cedit&
call s:NetrwCursor()
if &ft == "netrw"
sil! keepalt NetrwKeepj doau FileType netrw
endif
endfun
fun! NetrwStatusLine()
if !exists("w:netrw_explore_bufnr") || w:netrw_explore_bufnr != bufnr("%") || !exists("w:netrw_explore_line") || w:netrw_explore_line != line(".") || !exists("w:netrw_explore_list")
let &stl        = s:netrw_users_stl
let &laststatus = s:netrw_users_ls
if exists("w:netrw_explore_bufnr")|unlet w:netrw_explore_bufnr|endif
if exists("w:netrw_explore_line") |unlet w:netrw_explore_line |endif
return ""
else
return "Match ".w:netrw_explore_mtchcnt." of ".w:netrw_explore_listlen
endif
endfun
fun! netrw#NetRead(mode,...)
call s:NetrwOptionSave("w:")
call s:NetrwSafeOptions()
call s:RestoreCursorline()
setl bl
if     a:mode == 0 " read remote file before current line
let readcmd = "0r"
elseif a:mode == 1 " read file after current line
let readcmd = "r"
elseif a:mode == 2 " replace with remote file
let readcmd = "%r"
elseif a:mode == 3 " skip read of file (leave as temporary)
let readcmd = "t"
else
exe a:mode
let readcmd = "r"
endif
let ichoice = (a:0 == 0)? 0 : 1
let tmpfile= s:GetTempfile("")
if tmpfile == ""
return
endif
while ichoice <= a:0
if exists("b:netrw_lastfile") && a:0 == 0
let choice = b:netrw_lastfile
let ichoice= ichoice + 1
else
exe "let choice= a:" . ichoice
if match(choice,"?") == 0
echomsg 'NetRead Usage:'
echomsg ':Nread machine:path                         uses rcp'
echomsg ':Nread "machine path"                       uses ftp   with <.netrc>'
echomsg ':Nread "machine id password path"           uses ftp'
echomsg ':Nread dav://machine[:port]/path            uses cadaver'
echomsg ':Nread fetch://machine/path                 uses fetch'
echomsg ':Nread ftp://[user@]machine[:port]/path     uses ftp   autodetects <.netrc>'
echomsg ':Nread http://[user@]machine/path           uses http  wget'
echomsg ':Nread file:///path           		  uses elinks'
echomsg ':Nread https://[user@]machine/path          uses http  wget'
echomsg ':Nread rcp://[user@]machine/path            uses rcp'
echomsg ':Nread rsync://machine[:port]/path          uses rsync'
echomsg ':Nread scp://[user@]machine[[:#]port]/path  uses scp'
echomsg ':Nread sftp://[user@]machine[[:#]port]/path uses sftp'
sleep 4
break
elseif match(choice,'^"') != -1
if match(choice,'"$') != -1
let choice= strpart(choice,1,strlen(choice)-2)
else
let choice      = strpart(choice,1,strlen(choice)-1)
let wholechoice = ""
while match(choice,'"$') == -1
let wholechoice = wholechoice . " " . choice
let ichoice     = ichoice + 1
if ichoice > a:0
if !exists("g:netrw_quiet")
call netrw#ErrorMsg(s:ERROR,"Unbalanced string in filename '". wholechoice ."'",3)
endif
return
endif
let choice= a:{ichoice}
endwhile
let choice= strpart(wholechoice,1,strlen(wholechoice)-1) . " " . strpart(choice,0,strlen(choice)-1)
endif
endif
endif
let ichoice= ichoice + 1
call s:NetrwMethod(choice)
if !exists("b:netrw_method") || b:netrw_method < 0
return
endif
let tmpfile= s:GetTempfile(b:netrw_fname) " apply correct suffix
if choice =~ "^.*[\/]$" && b:netrw_method != 5 && choice !~ '^https\=://'
NetrwKeepj call s:NetrwBrowse(0,choice)
return
endif
if exists("g:netrw_silent") && g:netrw_silent == 0 && &ch >= 1
echo "(netrw) Processing your read request..."
endif
if  b:netrw_method == 1 " read with rcp
if s:netrw_has_nt_rcp == 1
if exists("g:netrw_uid") &&	( g:netrw_uid != "" )
let uid_machine = g:netrw_machine .'.'. g:netrw_uid
else
let uid_machine = g:netrw_machine .'.'. $USERNAME
endif
else
if exists("g:netrw_uid") &&	( g:netrw_uid != "" )
let uid_machine = g:netrw_uid .'@'. g:netrw_machine
else
let uid_machine = g:netrw_machine
endif
endif
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_rcp_cmd." ".s:netrw_rcpmode." ".s:ShellEscape(uid_machine.":".b:netrw_fname,1)." ".s:ShellEscape(tmpfile,1))
let result           = s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
let b:netrw_lastfile = choice
elseif b:netrw_method  == 2		" read with ftp + <.netrc>
let netrw_fname= b:netrw_fname
NetrwKeepj call s:SaveBufVars()|new|NetrwKeepj call s:RestoreBufVars()
let filtbuf= bufnr("%")
setl ff=unix
NetrwKeepj put =g:netrw_ftpmode
if exists("g:netrw_ftpextracmd")
NetrwKeepj put =g:netrw_ftpextracmd
endif
call setline(line("$")+1,'get "'.netrw_fname.'" '.tmpfile)
if exists("g:netrw_port") && g:netrw_port != ""
call s:NetrwExe(s:netrw_silentxfer."%!".s:netrw_ftp_cmd." -i ".s:ShellEscape(g:netrw_machine,1)." ".s:ShellEscape(g:netrw_port,1))
else
call s:NetrwExe(s:netrw_silentxfer."%!".s:netrw_ftp_cmd." -i ".s:ShellEscape(g:netrw_machine,1))
endif
if getline(1) !~ "^$" && !exists("g:netrw_quiet") && getline(1) !~ '^Trying '
let debugkeep = &debug
setl debug=msg
NetrwKeepj call netrw#ErrorMsg(s:ERROR,getline(1),4)
let &debug    = debugkeep
endif
call s:SaveBufVars()
keepj bd!
if bufname("%") == "" && getline("$") == "" && line('$') == 1
q!
endif
call s:RestoreBufVars()
let result           = s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
let b:netrw_lastfile = choice
elseif b:netrw_method == 3		" read with ftp + machine, id, passwd, and fname
let netrw_fname= escape(b:netrw_fname,g:netrw_fname_escape)
NetrwKeepj call s:SaveBufVars()|new|NetrwKeepj call s:RestoreBufVars()
let filtbuf= bufnr("%")
setl ff=unix
if exists("g:netrw_port") && g:netrw_port != ""
NetrwKeepj put ='open '.g:netrw_machine.' '.g:netrw_port
else
NetrwKeepj put ='open '.g:netrw_machine
endif
if exists("g:netrw_uid") && g:netrw_uid != ""
if exists("g:netrw_ftp") && g:netrw_ftp == 1
NetrwKeepj put =g:netrw_uid
if exists("s:netrw_passwd")
NetrwKeepj put ='\"'.s:netrw_passwd.'\"'
endif
elseif exists("s:netrw_passwd")
NetrwKeepj put ='user \"'.g:netrw_uid.'\" \"'.s:netrw_passwd.'\"'
endif
endif
if exists("g:netrw_ftpmode") && g:netrw_ftpmode != ""
NetrwKeepj put =g:netrw_ftpmode
endif
if exists("g:netrw_ftpextracmd")
NetrwKeepj put =g:netrw_ftpextracmd
endif
NetrwKeepj put ='get \"'.netrw_fname.'\" '.tmpfile
NetrwKeepj norm! 1Gdd
call s:NetrwExe(s:netrw_silentxfer."%!".s:netrw_ftp_cmd." ".g:netrw_ftp_options)
if getline(1) !~ "^$"
if !exists("g:netrw_quiet")
call netrw#ErrorMsg(s:ERROR,getline(1),5)
endif
endif
call s:SaveBufVars()|keepj bd!|call s:RestoreBufVars()
let result           = s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
let b:netrw_lastfile = choice
elseif     b:netrw_method  == 4	" read with scp
if exists("g:netrw_port") && g:netrw_port != ""
let useport= " ".g:netrw_scpport." ".g:netrw_port
else
let useport= ""
endif
if g:netrw_scp_cmd =~ '^scp' && (has("win32") || has("win95") || has("win64") || has("win16"))
let tmpfile_get = substitute(tr(tmpfile, '\', '/'), '^\(\a\):[/\\]\(.*\)$', '/\1/\2', '')
else
let tmpfile_get = tmpfile
endif
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_scp_cmd.useport." ".s:ShellEscape(g:netrw_machine.":".b:netrw_fname,1)." ".s:ShellEscape(tmpfile_get,1))
let result           = s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
let b:netrw_lastfile = choice
elseif     b:netrw_method  == 5
if g:netrw_http_cmd == ""
if !exists("g:netrw_quiet")
call netrw#ErrorMsg(s:ERROR,"neither the wget nor the fetch command is available",6)
endif
return
endif
if match(b:netrw_fname,"#") == -1 || exists("g:netrw_http_xcmd")
if exists("g:netrw_http_xcmd")
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_http_cmd." ".s:ShellEscape(b:netrw_http."://".g:netrw_machine.b:netrw_fname,1)." ".g:netrw_http_xcmd." ".s:ShellEscape(tmpfile,1))
else
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_http_cmd." ".s:ShellEscape(tmpfile,1)." ".s:ShellEscape(b:netrw_http."://".g:netrw_machine.b:netrw_fname,1))
endif
let result = s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
else
let netrw_html= substitute(b:netrw_fname,"#.*$","","")
let netrw_tag = substitute(b:netrw_fname,"^.*#","","")
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_http_cmd." ".s:ShellEscape(tmpfile,1)." ".s:ShellEscape(b:netrw_http."://".g:netrw_machine.netrw_html,1))
let result = s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
exe 'NetrwKeepj norm! 1G/<\s*a\s*name=\s*"'.netrw_tag.'"/'."\<CR>"
endif
let b:netrw_lastfile = choice
setl ro nomod
elseif     b:netrw_method  == 6
if !executable(g:netrw_dav_cmd)
call netrw#ErrorMsg(s:ERROR,g:netrw_dav_cmd." is not executable",73)
return
endif
if g:netrw_dav_cmd =~ "curl"
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_dav_cmd." ".s:ShellEscape("dav://".g:netrw_machine.b:netrw_fname,1)." ".s:ShellEscape(tmpfile,1))
else
let netrw_fname= escape(b:netrw_fname,g:netrw_fname_escape)
new
setl ff=unix
if exists("g:netrw_port") && g:netrw_port != ""
NetrwKeepj put ='open '.g:netrw_machine.' '.g:netrw_port
else
NetrwKeepj put ='open '.g:netrw_machine
endif
if exists("g:netrw_uid") && exists("s:netrw_passwd") && g:netrw_uid != ""
NetrwKeepj put ='user '.g:netrw_uid.' '.s:netrw_passwd
endif
NetrwKeepj put ='get '.netrw_fname.' '.tmpfile
NetrwKeepj put ='quit'
NetrwKeepj norm! 1Gdd
call s:NetrwExe(s:netrw_silentxfer."%!".g:netrw_dav_cmd)
keepj bd!
endif
let result           = s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
let b:netrw_lastfile = choice
elseif     b:netrw_method  == 7
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_rsync_cmd." ".s:ShellEscape(g:netrw_machine.":".b:netrw_fname,1)." ".s:ShellEscape(tmpfile,1))
let result		 = s:NetrwGetFile(readcmd,tmpfile, b:netrw_method)
let b:netrw_lastfile = choice
elseif     b:netrw_method  == 8
if g:netrw_fetch_cmd == ""
if !exists("g:netrw_quiet")
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"fetch command not available",7)
endif
return
endif
if exists("g:netrw_option") && g:netrw_option =~ ":https\="
let netrw_option= "http"
else
let netrw_option= "ftp"
endif
if exists("g:netrw_uid") && g:netrw_uid != "" && exists("s:netrw_passwd") && s:netrw_passwd != ""
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_fetch_cmd." ".s:ShellEscape(tmpfile,1)." ".s:ShellEscape(netrw_option."://".g:netrw_uid.':'.s:netrw_passwd.'@'.g:netrw_machine."/".b:netrw_fname,1))
else
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_fetch_cmd." ".s:ShellEscape(tmpfile,1)." ".s:ShellEscape(netrw_option."://".g:netrw_machine."/".b:netrw_fname,1))
endif
let result		= s:NetrwGetFile(readcmd,tmpfile, b:netrw_method)
let b:netrw_lastfile = choice
setl ro nomod
elseif     b:netrw_method  == 9
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_sftp_cmd." ".s:ShellEscape(g:netrw_machine.":".b:netrw_fname,1)." ".tmpfile)
let result		= s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
let b:netrw_lastfile = choice
elseif      b:netrw_method == 10 && exists("g:netrw_file_cmd")
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_file_cmd." ".s:ShellEscape(b:netrw_fname,1)." ".tmpfile)
let result		= s:NetrwGetFile(readcmd, tmpfile, b:netrw_method)
let b:netrw_lastfile = choice
else
call netrw#ErrorMsg(s:WARNING,"unable to comply with your request<" . choice . ">",8)
endif
endwhile
if exists("b:netrw_method")
unlet b:netrw_method
unlet b:netrw_fname
endif
if s:FileReadable(tmpfile) && tmpfile !~ '.tar.bz2$' && tmpfile !~ '.tar.gz$' && tmpfile !~ '.zip' && tmpfile !~ '.tar' && readcmd != 't' && tmpfile !~ '.tar.xz$' && tmpfile !~ '.txz'
NetrwKeepj call s:NetrwDelete(tmpfile)
endif
NetrwKeepj call s:NetrwOptionRestore("w:")
endfun
fun! netrw#NetWrite(...) range
let mod= 0
call s:NetrwOptionSave("w:")
call s:NetrwSafeOptions()
let tmpfile= s:GetTempfile("")
if tmpfile == ""
return
endif
if a:0 == 0
let ichoice = 0
else
let ichoice = 1
endif
let curbufname= expand("%")
if &binary
exe "sil NetrwKeepj w! ".fnameescape(v:cmdarg)." ".fnameescape(tmpfile)
elseif g:netrw_cygwin
let cygtmpfile= substitute(tmpfile,g:netrw_cygdrive.'/\(.\)','\1:','')
exe "sil NetrwKeepj ".a:firstline."," . a:lastline . "w! ".fnameescape(v:cmdarg)." ".fnameescape(cygtmpfile)
else
exe "sil NetrwKeepj ".a:firstline."," . a:lastline . "w! ".fnameescape(v:cmdarg)." ".fnameescape(tmpfile)
endif
if curbufname == ""
0file!
endif
while ichoice <= a:0
if exists("b:netrw_lastfile") && a:0 == 0
let choice = b:netrw_lastfile
let ichoice= ichoice + 1
else
exe "let choice= a:" . ichoice
if match(choice,"?") == 0
echomsg 'NetWrite Usage:"'
echomsg ':Nwrite machine:path                        uses rcp'
echomsg ':Nwrite "machine path"                      uses ftp with <.netrc>'
echomsg ':Nwrite "machine id password path"          uses ftp'
echomsg ':Nwrite dav://[user@]machine/path           uses cadaver'
echomsg ':Nwrite fetch://[user@]machine/path         uses fetch'
echomsg ':Nwrite ftp://machine[#port]/path           uses ftp  (autodetects <.netrc>)'
echomsg ':Nwrite rcp://machine/path                  uses rcp'
echomsg ':Nwrite rsync://[user@]machine/path         uses rsync'
echomsg ':Nwrite scp://[user@]machine[[:#]port]/path uses scp'
echomsg ':Nwrite sftp://[user@]machine/path          uses sftp'
sleep 4
break
elseif match(choice,"^\"") != -1
if match(choice,"\"$") != -1
let choice=strpart(choice,1,strlen(choice)-2)
else
let choice      = strpart(choice,1,strlen(choice)-1)
let wholechoice = ""
while match(choice,"\"$") == -1
let wholechoice= wholechoice . " " . choice
let ichoice    = ichoice + 1
if choice > a:0
if !exists("g:netrw_quiet")
call netrw#ErrorMsg(s:ERROR,"Unbalanced string in filename '". wholechoice ."'",13)
endif
return
endif
let choice= a:{ichoice}
endwhile
let choice= strpart(wholechoice,1,strlen(wholechoice)-1) . " " . strpart(choice,0,strlen(choice)-1)
endif
endif
endif
let ichoice= ichoice + 1
NetrwKeepj call s:NetrwMethod(choice)
if !exists("b:netrw_method") || b:netrw_method < 0
return
endif
if exists("g:netrw_silent") && g:netrw_silent == 0 && &ch >= 1
echo "(netrw) Processing your write request..."
endif
if  b:netrw_method == 1
if s:netrw_has_nt_rcp == 1
if exists("g:netrw_uid") &&  ( g:netrw_uid != "" )
let uid_machine = g:netrw_machine .'.'. g:netrw_uid
else
let uid_machine = g:netrw_machine .'.'. $USERNAME
endif
else
if exists("g:netrw_uid") &&  ( g:netrw_uid != "" )
let uid_machine = g:netrw_uid .'@'. g:netrw_machine
else
let uid_machine = g:netrw_machine
endif
endif
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_rcp_cmd." ".s:netrw_rcpmode." ".s:ShellEscape(tmpfile,1)." ".s:ShellEscape(uid_machine.":".b:netrw_fname,1))
let b:netrw_lastfile = choice
elseif b:netrw_method == 2
let netrw_fname = b:netrw_fname
let bhkeep      = &l:bh
let curbuf      = bufnr("%")
setl bh=hide
keepj keepalt enew
setl ff=unix
NetrwKeepj put =g:netrw_ftpmode
if exists("g:netrw_ftpextracmd")
NetrwKeepj put =g:netrw_ftpextracmd
endif
NetrwKeepj call setline(line("$")+1,'put "'.tmpfile.'" "'.netrw_fname.'"')
if exists("g:netrw_port") && g:netrw_port != ""
call s:NetrwExe(s:netrw_silentxfer."%!".s:netrw_ftp_cmd." -i ".s:ShellEscape(g:netrw_machine,1)." ".s:ShellEscape(g:netrw_port,1))
else
call s:NetrwExe(s:netrw_silentxfer."%!".s:netrw_ftp_cmd." -i ".s:ShellEscape(g:netrw_machine,1))
endif
if getline(1) !~ "^$"
if !exists("g:netrw_quiet")
NetrwKeepj call netrw#ErrorMsg(s:ERROR,getline(1),14)
endif
let mod=1
endif
let filtbuf= bufnr("%")
exe curbuf."b!"
let &l:bh            = bhkeep
exe filtbuf."bw!"
let b:netrw_lastfile = choice
elseif b:netrw_method == 3
let netrw_fname = b:netrw_fname
let bhkeep      = &l:bh
let curbuf      = bufnr("%")
setl bh=hide
keepj keepalt enew
setl ff=unix
if exists("g:netrw_port") && g:netrw_port != ""
NetrwKeepj put ='open '.g:netrw_machine.' '.g:netrw_port
else
NetrwKeepj put ='open '.g:netrw_machine
endif
if exists("g:netrw_uid") && g:netrw_uid != ""
if exists("g:netrw_ftp") && g:netrw_ftp == 1
NetrwKeepj put =g:netrw_uid
if exists("s:netrw_passwd") && s:netrw_passwd != ""
NetrwKeepj put ='\"'.s:netrw_passwd.'\"'
endif
elseif exists("s:netrw_passwd") && s:netrw_passwd != ""
NetrwKeepj put ='user \"'.g:netrw_uid.'\" \"'.s:netrw_passwd.'\"'
endif
endif
NetrwKeepj put =g:netrw_ftpmode
if exists("g:netrw_ftpextracmd")
NetrwKeepj put =g:netrw_ftpextracmd
endif
NetrwKeepj put ='put \"'.tmpfile.'\" \"'.netrw_fname.'\"'
let b:netrw_lastfile = choice
NetrwKeepj norm! 1Gdd
call s:NetrwExe(s:netrw_silentxfer."%!".s:netrw_ftp_cmd." ".g:netrw_ftp_options)
if getline(1) !~ "^$"
if  !exists("g:netrw_quiet")
call netrw#ErrorMsg(s:ERROR,getline(1),15)
endif
let mod=1
endif
let filtbuf= bufnr("%")
exe curbuf."b!"
let &l:bh= bhkeep
exe filtbuf."bw!"
elseif     b:netrw_method == 4
if exists("g:netrw_port") && g:netrw_port != ""
let useport= " ".g:netrw_scpport." ".fnameescape(g:netrw_port)
else
let useport= ""
endif
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_scp_cmd.useport." ".s:ShellEscape(tmpfile,1)." ".s:ShellEscape(g:netrw_machine.":".b:netrw_fname,1))
let b:netrw_lastfile = choice
elseif     b:netrw_method == 5
let curl= substitute(g:netrw_http_put_cmd,'\s\+.*$',"","")
if executable(curl)
let url= g:netrw_choice
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_http_put_cmd." ".s:ShellEscape(tmpfile,1)." ".s:ShellEscape(url,1) )
elseif !exists("g:netrw_quiet")
call netrw#ErrorMsg(s:ERROR,"can't write to http using <".g:netrw_http_put_cmd".">".",16)
endif
elseif     b:netrw_method == 6
let netrw_fname = escape(b:netrw_fname,g:netrw_fname_escape)
let bhkeep      = &l:bh
let curbuf      = bufnr("%")
setl bh=hide
keepj keepalt enew
setl ff=unix
if exists("g:netrw_port") && g:netrw_port != ""
NetrwKeepj put ='open '.g:netrw_machine.' '.g:netrw_port
else
NetrwKeepj put ='open '.g:netrw_machine
endif
if exists("g:netrw_uid") && exists("s:netrw_passwd") && g:netrw_uid != ""
NetrwKeepj put ='user '.g:netrw_uid.' '.s:netrw_passwd
endif
NetrwKeepj put ='put '.tmpfile.' '.netrw_fname
NetrwKeepj norm! 1Gdd
call s:NetrwExe(s:netrw_silentxfer."%!".g:netrw_dav_cmd)
let filtbuf= bufnr("%")
exe curbuf."b!"
let &l:bh            = bhkeep
exe filtbuf."bw!"
let b:netrw_lastfile = choice
elseif     b:netrw_method == 7
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_rsync_cmd." ".s:ShellEscape(tmpfile,1)." ".s:ShellEscape(g:netrw_machine.":".b:netrw_fname,1))
let b:netrw_lastfile = choice
elseif     b:netrw_method == 9
let netrw_fname= escape(b:netrw_fname,g:netrw_fname_escape)
if exists("g:netrw_uid") &&  ( g:netrw_uid != "" )
let uid_machine = g:netrw_uid .'@'. g:netrw_machine
else
let uid_machine = g:netrw_machine
endif
let bhkeep = &l:bh
let curbuf = bufnr("%")
setl bh=hide
keepj keepalt enew
setl ff=unix
call setline(1,'put "'.escape(tmpfile,'\').'" '.netrw_fname)
let sftpcmd= substitute(g:netrw_sftp_cmd,"%TEMPFILE%",escape(tmpfile,'\'),"g")
call s:NetrwExe(s:netrw_silentxfer."%!".sftpcmd.' '.s:ShellEscape(uid_machine,1))
let filtbuf= bufnr("%")
exe curbuf."b!"
let &l:bh            = bhkeep
exe filtbuf."bw!"
let b:netrw_lastfile = choice
else
call netrw#ErrorMsg(s:WARNING,"unable to comply with your request<" . choice . ">",17)
let leavemod= 1
endif
endwhile
if s:FileReadable(tmpfile)
call s:NetrwDelete(tmpfile)
endif
call s:NetrwOptionRestore("w:")
if a:firstline == 1 && a:lastline == line("$")
let &mod= mod
elseif !exists("leavemod")
setl nomod
endif
endfun
fun! netrw#NetSource(...)
if a:0 > 0 && a:1 == '?'
echomsg 'NetSource Usage:'
echomsg ':Nsource dav://machine[:port]/path            uses cadaver'
echomsg ':Nsource fetch://machine/path                 uses fetch'
echomsg ':Nsource ftp://[user@]machine[:port]/path     uses ftp   autodetects <.netrc>'
echomsg ':Nsource http[s]://[user@]machine/path        uses http  wget'
echomsg ':Nsource rcp://[user@]machine/path            uses rcp'
echomsg ':Nsource rsync://machine[:port]/path          uses rsync'
echomsg ':Nsource scp://[user@]machine[[:#]port]/path  uses scp'
echomsg ':Nsource sftp://[user@]machine[[:#]port]/path uses sftp'
sleep 4
else
let i= 1
while i <= a:0
call netrw#NetRead(3,a:{i})
if s:FileReadable(s:netrw_tmpfile)
exe "so ".fnameescape(s:netrw_tmpfile)
if delete(s:netrw_tmpfile)
call netrw#ErrorMsg(s:ERROR,"unable to delete directory <".s:netrw_tmpfile.">!",103)
endif
unlet s:netrw_tmpfile
else
call netrw#ErrorMsg(s:ERROR,"unable to source <".a:{i}.">!",48)
endif
let i= i + 1
endwhile
endif
endfun
fun! netrw#SetTreetop(...)
if exists("w:netrw_treetop")
let inittreetop= w:netrw_treetop
unlet w:netrw_treetop
endif
if exists("w:netrw_treedict")
unlet w:netrw_treedict
endif
if a:1 == "" && exists("inittreetop")
let treedir= s:NetrwTreePath(inittreetop)
else
if isdirectory(s:NetrwFile(a:1))
let treedir= a:1
elseif exists("b:netrw_curdir") && (isdirectory(s:NetrwFile(b:netrw_curdir."/".a:1)) || a:1 =~ '^\a\{3,}://')
let treedir= b:netrw_curdir."/".a:1
else
let netrwbuf= bufnr("%")
call netrw#ErrorMsg(s:ERROR,"sorry, ".a:1." doesn't seem to be a directory!",95)
exe bufwinnr(netrwbuf)."wincmd w"
let treedir= "."
endif
endif
let islocal= expand("%") !~ '^\a\{3,}://'
if islocal
call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(islocal,treedir))
else
call s:NetrwBrowse(islocal,s:NetrwBrowseChgDir(islocal,treedir))
endif
endfun
fun! s:NetrwGetFile(readcmd, tfile, method)
if a:readcmd == 't'
return
endif
let rfile= bufname("%")
if exists("*NetReadFixup")
let line2= line("$")
endif
if a:readcmd[0] == '%'
if g:netrw_cygwin
let tfile= substitute(a:tfile,g:netrw_cygdrive.'/\(.\)','\1:','')
else
let tfile= a:tfile
endif
exe "sil! keepalt file ".fnameescape(tfile)
if     rfile =~ '\.zip$'
call zip#Browse(tfile)
elseif rfile =~ '\.tar$'
call tar#Browse(tfile)
elseif rfile =~ '\.tar\.gz$'
call tar#Browse(tfile)
elseif rfile =~ '\.tar\.bz2$'
call tar#Browse(tfile)
elseif rfile =~ '\.tar\.xz$'
call tar#Browse(tfile)
elseif rfile =~ '\.txz$'
call tar#Browse(tfile)
else
NetrwKeepj e!
endif
exe "sil! NetrwKeepj keepalt file ".fnameescape(rfile)
let iskkeep= &l:isk
setl isk-=/
let &l:isk= iskkeep
let line1 = 1
let line2 = line("$")
elseif !&ma
NetrwKeepj call netrw#ErrorMsg(s:WARNING,"attempt to read<".a:tfile."> into a non-modifiable buffer!",94)
return
elseif s:FileReadable(a:tfile)
let curline = line(".")
let lastline= line("$")
exe "NetrwKeepj ".a:readcmd." ".fnameescape(v:cmdarg)." ".fnameescape(a:tfile)
let line1= curline + 1
let line2= line("$") - lastline + 1
else
NetrwKeepj call netrw#ErrorMsg(s:WARNING,"file <".a:tfile."> not readable",9)
return
endif
if exists("*NetReadFixup")
NetrwKeepj call NetReadFixup(a:method, line1, line2)
endif
if has("gui") && has("menu") && has("gui_running") && &go =~# 'm' && g:netrw_menu
NetrwKeepj call s:UpdateBuffersMenu()
endif
endfun
fun! s:NetrwMethod(choice)
if strlen(substitute(a:choice,'[^/]','','g')) < 3
call netrw#ErrorMsg(s:ERROR,"not a netrw-style url; netrw uses protocol://[user@]hostname[:port]/[path])",78)
let b:netrw_method = -1
return
endif
if exists("g:netrw_machine")
let curmachine= g:netrw_machine
else
let curmachine= "N O T A HOST"
endif
if exists("g:netrw_port")
let netrw_port= g:netrw_port
endif
let s:netrw_ftp_cmd= g:netrw_ftp_cmd
let b:netrw_method  = 0
let g:netrw_machine = ""
let b:netrw_fname   = ""
let g:netrw_port    = ""
let g:netrw_choice  = a:choice
let mipf     = '^\(\S\+\)\s\+\(\S\+\)\s\+\(\S\+\)\s\+\(\S\+\)$'
let mf       = '^\(\S\+\)\s\+\(\S\+\)$'
let ftpurm   = '^ftp://\(\([^/]*\)@\)\=\([^/#:]\{-}\)\([#:]\d\+\)\=/\(.*\)$'
let rcpurm   = '^rcp://\%(\([^/]*\)@\)\=\([^/]\{-}\)/\(.*\)$'
let rcphf    = '^\(\(\h\w*\)@\)\=\(\h\w*\):\([^@]\+\)$'
let scpurm   = '^scp://\([^/#:]\+\)\%([#:]\(\d\+\)\)\=/\(.*\)$'
let httpurm  = '^https\=://\([^/]\{-}\)\(/.*\)\=$'
let davurm   = '^davs\=://\([^/]\+\)/\(.*/\)\([-_.~[:alnum:]]\+\)$'
let rsyncurm = '^rsync://\([^/]\{-}\)/\(.*\)\=$'
let fetchurm = '^fetch://\(\([^/]*\)@\)\=\([^/#:]\{-}\)\(:http\)\=/\(.*\)$'
let sftpurm  = '^sftp://\([^/]\{-}\)/\(.*\)\=$'
let fileurm  = '^file\=://\(.*\)$'
if match(a:choice,rcpurm) == 0
let b:netrw_method  = 1
let userid          = substitute(a:choice,rcpurm,'\1',"")
let g:netrw_machine = substitute(a:choice,rcpurm,'\2',"")
let b:netrw_fname   = substitute(a:choice,rcpurm,'\3',"")
if userid != ""
let g:netrw_uid= userid
endif
elseif match(a:choice,scpurm) == 0
let b:netrw_method  = 4
let g:netrw_machine = substitute(a:choice,scpurm,'\1',"")
let g:netrw_port    = substitute(a:choice,scpurm,'\2',"")
let b:netrw_fname   = substitute(a:choice,scpurm,'\3',"")
elseif match(a:choice,httpurm) == 0
let b:netrw_method = 5
let g:netrw_machine= substitute(a:choice,httpurm,'\1',"")
let b:netrw_fname  = substitute(a:choice,httpurm,'\2',"")
let b:netrw_http   = (a:choice =~ '^https:')? "https" : "http"
elseif match(a:choice,davurm) == 0
let b:netrw_method= 6
if a:choice =~ 'davs:'
let g:netrw_machine= 'https://'.substitute(a:choice,davurm,'\1/\2',"")
else
let g:netrw_machine= 'http://'.substitute(a:choice,davurm,'\1/\2',"")
endif
let b:netrw_fname  = substitute(a:choice,davurm,'\3',"")
elseif match(a:choice,rsyncurm) == 0
let b:netrw_method = 7
let g:netrw_machine= substitute(a:choice,rsyncurm,'\1',"")
let b:netrw_fname  = substitute(a:choice,rsyncurm,'\2',"")
elseif match(a:choice,ftpurm) == 0
let userid	      = substitute(a:choice,ftpurm,'\2',"")
let g:netrw_machine= substitute(a:choice,ftpurm,'\3',"")
let g:netrw_port   = substitute(a:choice,ftpurm,'\4',"")
let b:netrw_fname  = substitute(a:choice,ftpurm,'\5',"")
if userid != ""
let g:netrw_uid= userid
endif
if curmachine != g:netrw_machine
if exists("s:netwr_hup[".g:netrw_machine."]")
call NetUserPass("ftp:".g:netrw_machine)
elseif exists("s:netrw_passwd")
unlet s:netrw_passwd
endif
if exists("netrw_port")
unlet netrw_port
endif
endif
if exists("g:netrw_uid") && exists("s:netrw_passwd")
let b:netrw_method = 3
else
let host= substitute(g:netrw_machine,'\..*$','','')
if exists("s:netrw_hup[host]")
call NetUserPass("ftp:".host)
elseif (has("win32") || has("win95") || has("win64") || has("win16")) && s:netrw_ftp_cmd =~# '-[sS]:'
if g:netrw_ftp_cmd =~# '-[sS]:\S*MACHINE\>'
let s:netrw_ftp_cmd= substitute(g:netrw_ftp_cmd,'\<MACHINE\>',g:netrw_machine,'')
endif
let b:netrw_method= 2
elseif s:FileReadable(expand("$HOME/.netrc")) && !g:netrw_ignorenetrc
let b:netrw_method= 2
else
if !exists("g:netrw_uid") || g:netrw_uid == ""
call NetUserPass()
elseif !exists("s:netrw_passwd") || s:netrw_passwd == ""
call NetUserPass(g:netrw_uid)
endif
let b:netrw_method= 3
endif
endif
elseif match(a:choice,fetchurm) == 0
let b:netrw_method = 8
let g:netrw_userid = substitute(a:choice,fetchurm,'\2',"")
let g:netrw_machine= substitute(a:choice,fetchurm,'\3',"")
let b:netrw_option = substitute(a:choice,fetchurm,'\4',"")
let b:netrw_fname  = substitute(a:choice,fetchurm,'\5',"")
elseif match(a:choice,mipf) == 0
let b:netrw_method  = 3
let g:netrw_machine = substitute(a:choice,mipf,'\1',"")
let g:netrw_uid     = substitute(a:choice,mipf,'\2',"")
let s:netrw_passwd  = substitute(a:choice,mipf,'\3',"")
let b:netrw_fname   = substitute(a:choice,mipf,'\4',"")
call NetUserPass(g:netrw_machine,g:netrw_uid,s:netrw_passwd)
elseif match(a:choice,mf) == 0
if exists("g:netrw_uid") && exists("s:netrw_passwd")
let b:netrw_method  = 3
let g:netrw_machine = substitute(a:choice,mf,'\1',"")
let b:netrw_fname   = substitute(a:choice,mf,'\2',"")
elseif s:FileReadable(expand("$HOME/.netrc"))
let b:netrw_method  = 2
let g:netrw_machine = substitute(a:choice,mf,'\1',"")
let b:netrw_fname   = substitute(a:choice,mf,'\2',"")
endif
elseif match(a:choice,sftpurm) == 0
let b:netrw_method = 9
let g:netrw_machine= substitute(a:choice,sftpurm,'\1',"")
let b:netrw_fname  = substitute(a:choice,sftpurm,'\2',"")
elseif match(a:choice,rcphf) == 0
let b:netrw_method  = 1
let userid          = substitute(a:choice,rcphf,'\2',"")
let g:netrw_machine = substitute(a:choice,rcphf,'\3',"")
let b:netrw_fname   = substitute(a:choice,rcphf,'\4',"")
if userid != ""
let g:netrw_uid= userid
endif
elseif match(a:choice,fileurm) == 0 && exists("g:netrw_file_cmd")
let b:netrw_method = 10
let b:netrw_fname  = substitute(a:choice,fileurm,'\1',"")
else
if !exists("g:netrw_quiet")
call netrw#ErrorMsg(s:WARNING,"cannot determine method (format: protocol://[user@]hostname[:port]/[path])",45)
endif
let b:netrw_method  = -1
endif
if g:netrw_port != ""
let g:netrw_port = substitute(g:netrw_port,'[#:]\+','','')
elseif exists("netrw_port")
let g:netrw_port= netrw_port
endif
endfun
if has("win95") && exists("g:netrw_win95ftp") && g:netrw_win95ftp
fun! NetReadFixup(method, line1, line2)
let method = a:method + 0
let line1  = a:line1 + 0
let line2  = a:line2 + 0
if type(method) != 0 || type(line1) != 0 || type(line2) != 0 || method < 0 || line1 <= 0 || line2 <= 0
return
endif
if method == 3   " ftp (no <.netrc>)
let fourblanklines= line2 - 3
if fourblanklines >= line1
exe "sil NetrwKeepj ".fourblanklines.",".line2."g/^\s*$/d"
call histdel("/",-1)
endif
endif
endfun
endif
fun! NetUserPass(...)
if !exists('s:netrw_hup')
let s:netrw_hup= {}
endif
if a:0 == 0
if !exists("g:netrw_machine")
let g:netrw_machine= input('Enter hostname: ')
endif
if !exists("g:netrw_uid") || g:netrw_uid == ""
let g:netrw_uid= input('Enter username: ')
endif
let s:netrw_passwd= inputsecret("Enter Password: ")
let host = substitute(g:netrw_machine,'\..*$','','')
if !exists('s:netrw_hup[host]')
let s:netrw_hup[host]= {}
endif
let s:netrw_hup[host].uid    = g:netrw_uid
let s:netrw_hup[host].passwd = s:netrw_passwd
elseif a:0 == 1
if a:1 =~ '^ftp:'
let host = substitute(a:1,'^ftp:','','')
let host = substitute(host,'\..*','','')
if exists("s:netrw_hup[host]")
let g:netrw_uid    = s:netrw_hup[host].uid
let s:netrw_passwd = s:netrw_hup[host].passwd
else
let g:netrw_uid    = input("Enter UserId: ")
let s:netrw_passwd = inputsecret("Enter Password: ")
endif
else
if exists("g:netrw_machine")
if g:netrw_machine =~ '[0-9.]\+'
let host= g:netrw_machine
else
let host= substitute(g:netrw_machine,'\..*$','','')
endif
else
let g:netrw_machine= input('Enter hostname: ')
endif
let g:netrw_uid = a:1
if exists("g:netrw_passwd")
let s:netrw_passwd= g:netrw_passwd
else
let s:netrw_passwd = inputsecret("Enter Password: ")
endif
endif
if exists("host")
if !exists('s:netrw_hup[host]')
let s:netrw_hup[host]= {}
endif
let s:netrw_hup[host].uid    = g:netrw_uid
let s:netrw_hup[host].passwd = s:netrw_passwd
endif
elseif a:0 == 2
let g:netrw_uid    = a:1
let s:netrw_passwd = a:2
elseif a:0 == 3
let host = substitute(a:1,'^\a\+:','','')
let host = substitute(host,'\..*$','','')
if !exists('s:netrw_hup[host]')
let s:netrw_hup[host]= {}
endif
let s:netrw_hup[host].uid    = a:2
let s:netrw_hup[host].passwd = a:3
let g:netrw_uid              = s:netrw_hup[host].uid
let s:netrw_passwd           = s:netrw_hup[host].passwd
endif
endfun
fun! s:ExplorePatHls(pattern)
let repat= substitute(a:pattern,'^**/\{1,2}','','')
let repat= escape(repat,'][.\')
let repat= '\<'.substitute(repat,'\*','\\(\\S\\+ \\)*\\S\\+','g').'\>'
return repat
endfun
fun! s:NetrwBookHistHandler(chg,curdir)
if !exists("g:netrw_dirhistmax") || g:netrw_dirhistmax <= 0
return
endif
let ykeep    = @@
let curbufnr = bufnr("%")
if a:chg == 0
if exists("s:netrwmarkfilelist_{curbufnr}")
call s:NetrwBookmark(0)
echo "bookmarked marked files"
else
call s:MakeBookmark(a:curdir)
echo "bookmarked the current directory"
endif
elseif a:chg == 1
if exists("g:netrw_bookmarklist[v:count-1]")
exe "NetrwKeepj e ".fnameescape(g:netrw_bookmarklist[v:count-1])
else
echomsg "Sorry, bookmark#".v:count." doesn't exist!"
endif
elseif a:chg == 2
let didwork= 0
if exists("g:netrw_bookmarklist")
let cnt= 1
for bmd in g:netrw_bookmarklist
echo printf("Netrw Bookmark#%-2d: %s",cnt,g:netrw_bookmarklist[cnt-1])
let didwork = 1
let cnt     = cnt + 1
endfor
endif
let cnt     = g:netrw_dirhist_cnt
let first   = 1
let histcnt = 0
if g:netrw_dirhistmax > 0
while ( first || cnt != g:netrw_dirhist_cnt )
if exists("g:netrw_dirhist_{cnt}")
echo printf("Netrw  History#%-2d: %s",histcnt,g:netrw_dirhist_{cnt})
let didwork= 1
endif
let histcnt = histcnt + 1
let first   = 0
let cnt     = ( cnt - 1 ) % g:netrw_dirhistmax
if cnt < 0
let cnt= cnt + g:netrw_dirhistmax
endif
endwhile
else
let g:netrw_dirhist_cnt= 0
endif
if didwork
call inputsave()|call input("Press <cr> to continue")|call inputrestore()
endif
elseif a:chg == 3
if !exists("g:netrw_dirhist_cnt") || !exists("g:netrw_dirhist_{g:netrw_dirhist_cnt}") || g:netrw_dirhist_{g:netrw_dirhist_cnt} != a:curdir
if g:netrw_dirhistmax > 0
let g:netrw_dirhist_cnt                   = ( g:netrw_dirhist_cnt + 1 ) % g:netrw_dirhistmax
let g:netrw_dirhist_{g:netrw_dirhist_cnt} = a:curdir
endif
endif
elseif a:chg == 4
if g:netrw_dirhistmax > 0
let g:netrw_dirhist_cnt= ( g:netrw_dirhist_cnt - v:count1 ) % g:netrw_dirhistmax
if g:netrw_dirhist_cnt < 0
let g:netrw_dirhist_cnt= g:netrw_dirhist_cnt + g:netrw_dirhistmax
endif
else
let g:netrw_dirhist_cnt= 0
endif
if exists("g:netrw_dirhist_{g:netrw_dirhist_cnt}")
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("b:netrw_curdir")
setl ma noro
sil! NetrwKeepj %d _
setl nomod
endif
exe "NetrwKeepj e! ".fnameescape(g:netrw_dirhist_{g:netrw_dirhist_cnt})
else
if g:netrw_dirhistmax > 0
let g:netrw_dirhist_cnt= ( g:netrw_dirhist_cnt + v:count1 ) % g:netrw_dirhistmax
else
let g:netrw_dirhist_cnt= 0
endif
echo "Sorry, no predecessor directory exists yet"
endif
elseif a:chg == 5
if g:netrw_dirhistmax > 0
let g:netrw_dirhist_cnt= ( g:netrw_dirhist_cnt + 1 ) % g:netrw_dirhistmax
if exists("g:netrw_dirhist_{g:netrw_dirhist_cnt}")
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("b:netrw_curdir")
setl ma noro
sil! NetrwKeepj %d _
setl nomod
endif
exe "NetrwKeepj e! ".fnameescape(g:netrw_dirhist_{g:netrw_dirhist_cnt})
else
let g:netrw_dirhist_cnt= ( g:netrw_dirhist_cnt - 1 ) % g:netrw_dirhistmax
if g:netrw_dirhist_cnt < 0
let g:netrw_dirhist_cnt= g:netrw_dirhist_cnt + g:netrw_dirhistmax
endif
echo "Sorry, no successor directory exists yet"
endif
else
let g:netrw_dirhist_cnt= 0
echo "Sorry, no successor directory exists yet (g:netrw_dirhistmax is ".g:netrw_dirhistmax.")"
endif
elseif a:chg == 6
if exists("s:netrwmarkfilelist_{curbufnr}")
call s:NetrwBookmark(1)
echo "removed marked files from bookmarks"
else
let iremove = v:count
let dremove = g:netrw_bookmarklist[iremove - 1]
call s:MergeBookmarks()
NetrwKeepj call remove(g:netrw_bookmarklist,iremove-1)
echo "removed ".dremove." from g:netrw_bookmarklist"
endif
endif
call s:NetrwBookmarkMenu()
call s:NetrwTgtMenu()
let @@= ykeep
endfun
fun! s:NetrwBookHistRead()
if !exists("g:netrw_dirhistmax") || g:netrw_dirhistmax <= 0
return
endif
let ykeep= @@
if !exists("s:netrw_initbookhist")
let home    = s:NetrwHome()
let savefile= home."/.netrwbook"
if filereadable(s:NetrwFile(savefile))
exe "keepalt NetrwKeepj so ".savefile
endif
if g:netrw_dirhistmax > 0
let savefile= home."/.netrwhist"
if filereadable(s:NetrwFile(savefile))
exe "keepalt NetrwKeepj so ".savefile
endif
let s:netrw_initbookhist= 1
au VimLeave * call s:NetrwBookHistSave()
endif
endif
let @@= ykeep
endfun
fun! s:NetrwBookHistSave()
if !exists("g:netrw_dirhistmax") || g:netrw_dirhistmax <= 0
return
endif
let savefile= s:NetrwHome()."/.netrwhist"
1split
call s:NetrwEnew()
if g:netrw_use_noswf
setl cino= com= cpo-=a cpo-=A fo=nroql2 tw=0 report=10000 noswf
else
setl cino= com= cpo-=a cpo-=A fo=nroql2 tw=0 report=10000
endif
setl nocin noai noci magic nospell nohid wig= noaw
setl ma noro write
if exists("+acd") | setl noacd | endif
sil! NetrwKeepj keepalt %d _
sil! keepalt file .netrwhist
call setline(1,"let g:netrw_dirhistmax  =".g:netrw_dirhistmax)
call setline(2,"let g:netrw_dirhist_cnt =".g:netrw_dirhist_cnt)
let lastline = line("$")
let cnt      = 1
while cnt <= g:netrw_dirhist_cnt
call setline((cnt+lastline),'let g:netrw_dirhist_'.cnt."='".g:netrw_dirhist_{cnt}."'")
let cnt= cnt + 1
endwhile
exe "sil! w! ".savefile
sil NetrwKeepj %d _
if exists("g:netrw_bookmarklist") && g:netrw_bookmarklist != []
let savefile= s:NetrwHome()."/.netrwbook"
if filereadable(s:NetrwFile(savefile))
let booklist= deepcopy(g:netrw_bookmarklist)
exe "sil NetrwKeepj keepalt so ".savefile
for bdm in booklist
if index(g:netrw_bookmarklist,bdm) == -1
call add(g:netrw_bookmarklist,bdm)
endif
endfor
call sort(g:netrw_bookmarklist)
endif
call setline(1,"let g:netrw_bookmarklist= ".string(g:netrw_bookmarklist))
exe "sil! w! ".savefile
endif
let bgone= bufnr("%")
q!
exe "keepalt ".bgone."bwipe!"
endfun
fun! s:NetrwBrowse(islocal,dirname)
if !exists("w:netrw_liststyle")|let w:netrw_liststyle= g:netrw_liststyle|endif
if a:islocal && !exists("w:netrw_rexfile") && bufname("#") != ""
let w:netrw_rexfile= bufname("#")
endif
if !exists("s:netrw_initbookhist")
NetrwKeepj call s:NetrwBookHistRead()
endif
if a:dirname !~ '^\a\{3,}://'
let dirname= simplify(a:dirname)
else
let dirname= a:dirname
endif
if exists("s:netrw_skipbrowse")
unlet s:netrw_skipbrowse
return
endif
if !exists("*shellescape")
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"netrw can't run -- your vim is missing shellescape()",69)
return
endif
if !exists("*fnameescape")
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"netrw can't run -- your vim is missing fnameescape()",70)
return
endif
call s:NetrwOptionSave("w:")
if exists("s:netrwmarkfilelist_{bufnr('%')}")
exe "2match netrwMarkFile /".s:netrwmarkfilemtch_{bufnr("%")}."/"
endif
if a:islocal && exists("w:netrw_acdkeep") && w:netrw_acdkeep
call s:NetrwLcd(dirname)
call s:NetrwSafeOptions()
elseif !a:islocal && dirname !~ '[\/]$' && dirname !~ '^"'
if bufname(dirname) != ""
exe "NetrwKeepj b ".bufname(dirname)
else
let path= substitute(dirname,'[*=@|]\r\=$','','e')
call s:RemotePathAnalysis(dirname)
call s:NetrwEnew(dirname)
call s:NetrwSafeOptions()
setl ma noro
let b:netrw_curdir = dirname
let url            = s:method."://".((s:user == "")? "" : s:user."@").s:machine.(s:port ? ":".s:port : "")."/".s:path
exe "sil! NetrwKeepj keepalt file ".fnameescape(url)
exe "sil! NetrwKeepj keepalt doau BufReadPre ".fnameescape(s:fname)
sil call netrw#NetRead(2,url)
if s:path =~ '.bz2'
exe "sil NetrwKeepj keepalt doau BufReadPost ".fnameescape(substitute(s:fname,'\.bz2$','',''))
elseif s:path =~ '.gz'
exe "sil NetrwKeepj keepalt doau BufReadPost ".fnameescape(substitute(s:fname,'\.gz$','',''))
elseif s:path =~ '.gz'
exe "sil NetrwKeepj keepalt doau BufReadPost ".fnameescape(substitute(s:fname,'\.txz$','',''))
else
exe "sil NetrwKeepj keepalt doau BufReadPost ".fnameescape(s:fname)
endif
endif
call s:SetBufWinVars()
call s:NetrwOptionRestore("w:")
setl ma nomod noro
return
endif
call s:UseBufWinVars()
let b:netrw_browser_active = 1
let dirname                = dirname
let s:last_sort_by         = g:netrw_sort_by
NetrwKeepj call s:NetrwMenu(1)
let svpos  = winsaveview()
let reusing= s:NetrwGetBuffer(a:islocal,dirname)
if exists("s:netrwmarkfilemtch_{bufnr('%')}") && s:netrwmarkfilemtch_{bufnr("%")} != ""
exe "2match netrwMarkFile /".s:netrwmarkfilemtch_{bufnr("%")}."/"
else
2match none
endif
if reusing && line("$") > 1
call s:NetrwOptionRestore("w:")
setl noma nomod nowrap
return
endif
let b:netrw_curdir= dirname
if b:netrw_curdir =~ '[/\\]$'
let b:netrw_curdir= substitute(b:netrw_curdir,'[/\\]$','','e')
endif
if b:netrw_curdir =~ '\a:$' && (has("win32") || has("win95") || has("win64") || has("win16"))
let b:netrw_curdir= b:netrw_curdir."/"
endif
if b:netrw_curdir == ''
if has("amiga")
let b:netrw_curdir= getcwd()
else
let b:netrw_curdir= '/'
endif
endif
if !a:islocal && b:netrw_curdir !~ '/$'
let b:netrw_curdir= b:netrw_curdir.'/'
endif
if a:islocal
call s:LocalFastBrowser()
if !g:netrw_keepdir
if !exists("&l:acd") || !&l:acd
call s:NetrwLcd(b:netrw_curdir)
endif
endif
else
if dirname =~# "^NetrwTreeListing\>"
let dirname= b:netrw_curdir
elseif exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("b:netrw_curdir")
let dirname= substitute(b:netrw_curdir,'\\','/','g')
if dirname !~ '/$'
let dirname= dirname.'/'
endif
let b:netrw_curdir = dirname
else
let dirname = substitute(dirname,'\\','/','g')
endif
let dirpat  = '^\(\w\{-}\)://\(\w\+@\)\=\([^/]\+\)/\(.*\)$'
if dirname !~ dirpat
if !exists("g:netrw_quiet")
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"netrw doesn't understand your dirname<".dirname.">",20)
endif
NetrwKeepj call s:NetrwOptionRestore("w:")
setl noma nomod nowrap
return
endif
let b:netrw_curdir= dirname
endif  " (additional remote handling)
NetrwKeepj call s:NetrwMaps(a:islocal)
NetrwKeepj call s:NetrwCommands(a:islocal)
NetrwKeepj call s:PerformListing(a:islocal)
call s:NetrwOptionRestore("w:")
if exists("s:rexposn_".bufnr("%"))
NetrwKeepj call winrestview(s:rexposn_{bufnr('%')})
if exists("w:netrw_bannercnt") && line(".") < w:netrw_bannercnt
NetrwKeepj exe w:netrw_bannercnt
endif
else
NetrwKeepj call s:SetRexDir(a:islocal,b:netrw_curdir)
endif
if v:version >= 700 && has("balloon_eval") && &beval == 0 && &l:bexpr == "" && !exists("g:netrw_nobeval")
let &l:bexpr= "netrw#BalloonHelp()"
setl beval
endif
if reusing
call winrestview(svpos)
endif
return
endfun
fun! s:NetrwFile(fname)
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
let fname= substitute(a:fname,'^'.s:treedepthstring.'\+','','')
else
let fname= a:fname
endif
if g:netrw_keepdir
if !exists("b:netrw_curdir")
let b:netrw_curdir= getcwd()
endif
if !exists("g:netrw_cygwin") && (has("win32") || has("win95") || has("win64") || has("win16"))
if fname =~ '^\' || fname =~ '^\a:\'
let ret= fname
else
let ret= s:ComposePath(b:netrw_curdir,fname)
endif
elseif fname =~ '^/'
let ret= fname
else
let ret= s:ComposePath(b:netrw_curdir,fname)
endif
else
let ret= fname
endif
return ret
endfun
fun! s:NetrwFileInfo(islocal,fname)
let ykeep= @@
if a:islocal
let lsopt= "-lsad"
if g:netrw_sizestyle =~# 'H'
let lsopt= "-lsadh"
elseif g:netrw_sizestyle =~# 'h'
let lsopt= "-lsadh --si"
endif
if (has("unix") || has("macunix")) && executable("/bin/ls")
if getline(".") == "../"
echo system("/bin/ls ".lsopt." ".s:ShellEscape(".."))
elseif w:netrw_liststyle == s:TREELIST && getline(".") !~ '^'.s:treedepthstring
echo system("/bin/ls ".lsopt." ".s:ShellEscape(b:netrw_curdir))
elseif exists("b:netrw_curdir")
echo system("/bin/ls ".lsopt." ".s:ShellEscape(s:ComposePath(b:netrw_curdir,a:fname)))
else
echo system("/bin/ls ".lsopt." ".s:ShellEscape(s:NetrwFile(a:fname)))
endif
else
if !isdirectory(s:NetrwFile(a:fname)) && !filereadable(s:NetrwFile(a:fname)) && a:fname =~ '[*@/]'
let fname= substitute(a:fname,".$","","")
else
let fname= a:fname
endif
let t  = getftime(s:NetrwFile(fname))
let sz = getfsize(s:NetrwFile(fname))
if g:netrw_sizestyle =~# "[hH]"
let sz= s:NetrwHumanReadable(sz)
endif
echo a:fname.":  ".sz."  ".strftime(g:netrw_timefmt,getftime(s:NetrwFile(fname)))
endif
else
echo "sorry, \"qf\" not supported yet for remote files"
endif
let @@= ykeep
endfun
fun! s:NetrwFullPath(filename)
let filename= a:filename
if filename !~ '^/'
let filename= resolve(getcwd().'/'.filename)
endif
if filename != "/" && filename =~ '/$'
let filename= substitute(filename,'/$','','')
endif
return filename
endfun
fun! s:NetrwGetBuffer(islocal,dirname)
let dirname= a:dirname
if !exists("s:netrwbuf")
let s:netrwbuf= {}
endif
if has_key(s:netrwbuf,s:NetrwFullPath(dirname))
let bufnum= s:netrwbuf[s:NetrwFullPath(dirname)]
if !bufexists(bufnum)
call remove(s:netrwbuf,s:NetrwFullPath(dirname))
let bufnum= -1
endif
else
let bufnum= -1
endif
if bufnum < 0      " get enew buffer and name it
call s:NetrwEnew(dirname)
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
if !exists("s:netrw_treelistnum")
let s:netrw_treelistnum= 1
else
let s:netrw_treelistnum= s:netrw_treelistnum + 1
endif
let w:netrw_treebufnr= bufnr("%")
exe 'sil! keepalt file NetrwTreeListing\ '.fnameescape(s:netrw_treelistnum)
if g:netrw_use_noswf
setl nobl bt=nofile noswf
else
setl nobl bt=nofile
endif
nnoremap <silent> <buffer> [[       :sil call <SID>TreeListMove('[[')<cr>
nnoremap <silent> <buffer> ]]       :sil call <SID>TreeListMove(']]')<cr>
nnoremap <silent> <buffer> []       :sil call <SID>TreeListMove('[]')<cr>
nnoremap <silent> <buffer> ][       :sil call <SID>TreeListMove('][')<cr>
else
let escdirname = fnameescape(dirname)
exe 'sil! keepj keepalt file '.escdirname
let s:netrwbuf[s:NetrwFullPath(dirname)]= bufnr("%")
endif
else " Re-use the buffer
let eikeep= &ei
setl ei=all
if getline(2) =~# '^" Netrw Directory Listing'
exe "sil! NetrwKeepj noswapfile keepalt b ".bufnum
else
exe "sil! NetrwKeepj noswapfile keepalt b ".bufnum
endif
if bufname("%") == '.'
exe "sil! NetrwKeepj keepalt file ".fnameescape(getcwd())
endif
let &ei= eikeep
if line("$") <= 1 && getline(1) == ""
NetrwKeepj call s:NetrwListSettings(a:islocal)
return 0
elseif g:netrw_fastbrowse == 0 || (a:islocal && g:netrw_fastbrowse == 1)
NetrwKeepj call s:NetrwListSettings(a:islocal)
sil NetrwKeepj %d _
return 0
elseif exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
sil NetrwKeepj %d _
NetrwKeepj call s:NetrwListSettings(a:islocal)
return 0
else
return 1
endif
endif
let fname= expand("%")
NetrwKeepj call s:NetrwListSettings(a:islocal)
exe "sil! NetrwKeepj keepalt file ".fnameescape(fname)
sil! keepalt NetrwKeepj %d _
return 0
endfun
fun! s:NetrwGetcwd(doesc)
let curdir= substitute(getcwd(),'\\','/','ge')
if curdir !~ '[\/]$'
let curdir= curdir.'/'
endif
if a:doesc
let curdir= fnameescape(curdir)
endif
return curdir
endfun
fun! s:NetrwGetWord()
let keepsol= &l:sol
setl nosol
call s:UseBufWinVars()
if !exists("w:netrw_liststyle")
if exists("g:netrw_liststyle")
let w:netrw_liststyle= g:netrw_liststyle
else
let w:netrw_liststyle= s:THINLIST
endif
endif
if exists("w:netrw_bannercnt") && line(".") < w:netrw_bannercnt
NetrwKeepj norm! 0
let dirname= "./"
let curline= getline('.')
if curline =~# '"\s*Sorted by\s'
NetrwKeepj norm s
let s:netrw_skipbrowse= 1
echo 'Pressing "s" also works'
elseif curline =~# '"\s*Sort sequence:'
let s:netrw_skipbrowse= 1
echo 'Press "S" to edit sorting sequence'
elseif curline =~# '"\s*Quick Help:'
NetrwKeepj norm ?
let s:netrw_skipbrowse= 1
elseif curline =~# '"\s*\%(Hiding\|Showing\):'
NetrwKeepj norm a
let s:netrw_skipbrowse= 1
echo 'Pressing "a" also works'
elseif line("$") > w:netrw_bannercnt
exe 'sil NetrwKeepj '.w:netrw_bannercnt
endif
elseif w:netrw_liststyle == s:THINLIST
NetrwKeepj norm! 0
let dirname= substitute(getline('.'),'\t -->.*$','','')
elseif w:netrw_liststyle == s:LONGLIST
NetrwKeepj norm! 0
let dirname= substitute(getline('.'),'^\(\%(\S\+ \)*\S\+\).\{-}$','\1','e')
elseif exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
let dirname= substitute(getline('.'),'^\('.s:treedepthstring.'\)*','','e')
let dirname= substitute(dirname,'\t -->.*$','','')
else
let dirname= getline('.')
if !exists("b:netrw_cpf")
let b:netrw_cpf= 0
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$g/^./if virtcol("$") > b:netrw_cpf|let b:netrw_cpf= virtcol("$")|endif'
call histdel("/",-1)
endif
let filestart = (virtcol(".")/b:netrw_cpf)*b:netrw_cpf
if filestart == 0
NetrwKeepj norm! 0ma
else
call cursor(line("."),filestart+1)
NetrwKeepj norm! ma
endif
let rega= @a
let eofname= filestart + b:netrw_cpf + 1
if eofname <= col("$")
call cursor(line("."),filestart+b:netrw_cpf+1)
NetrwKeepj norm! "ay`a
else
NetrwKeepj norm! "ay$
endif
let dirname = @a
let @a      = rega
let dirname= substitute(dirname,'\s\+$','','e')
endif
let dirname= substitute(dirname,"@$","","")
let dirname= substitute(dirname,"\*$","","")
let &l:sol= keepsol
return dirname
endfun
fun! s:NetrwListSettings(islocal)
let fname= bufname("%")
setl bt=nofile nobl ma nonu nowrap noro nornu
exe "sil! keepalt file ".fnameescape(fname)
if g:netrw_use_noswf
setl noswf
endif
exe "setl ts=".(g:netrw_maxfilenamelen+1)
setl isk+=.,~,-
if g:netrw_fastbrowse > a:islocal
setl bh=hide
else
setl bh=delete
endif
endfun
fun! s:NetrwListStyle(islocal)
let ykeep             = @@
let fname             = s:NetrwGetWord()
if !exists("w:netrw_liststyle")|let w:netrw_liststyle= g:netrw_liststyle|endif
let svpos            = winsaveview()
let w:netrw_liststyle = (w:netrw_liststyle + 1) % s:MAXLIST
if w:netrw_liststyle == s:THINLIST
let g:netrw_list_cmd = substitute(g:netrw_list_cmd,' -l','','ge')
elseif w:netrw_liststyle == s:LONGLIST
let g:netrw_list_cmd = g:netrw_list_cmd." -l"
elseif w:netrw_liststyle == s:WIDELIST
let g:netrw_list_cmd = substitute(g:netrw_list_cmd,' -l','','ge')
elseif exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
let g:netrw_list_cmd = substitute(g:netrw_list_cmd,' -l','','ge')
else
NetrwKeepj call netrw#ErrorMsg(s:WARNING,"bad value for g:netrw_liststyle (=".w:netrw_liststyle.")",46)
let g:netrw_liststyle = s:THINLIST
let w:netrw_liststyle = g:netrw_liststyle
let g:netrw_list_cmd  = substitute(g:netrw_list_cmd,' -l','','ge')
endif
setl ma noro
sil! NetrwKeepj %d _
setl nomod
NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
NetrwKeepj call s:NetrwCursor()
NetrwKeepj call winrestview(svpos)
let @@= ykeep
endfun
fun! s:NetrwBannerCtrl(islocal)
let ykeep= @@
let g:netrw_banner= !g:netrw_banner
let svpos= winsaveview()
call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
let fname= s:NetrwGetWord()
sil NetrwKeepj $
let result= search('\%(^\%(|\+\s\)\=\|\s\{2,}\)\zs'.escape(fname,'.\[]*$^').'\%(\s\{2,}\|$\)','bc')
if result <= 0 && exists("w:netrw_bannercnt")
exe "NetrwKeepj ".w:netrw_bannercnt
endif
let @@= ykeep
endfun
fun! s:NetrwBookmark(del,...)
if a:0 == 0
if &ft == "netrw"
let curbufnr = bufnr("%")
if exists("s:netrwmarkfilelist_{curbufnr}")
let svpos  = winsaveview()
let islocal= expand("%") !~ '^\a\{3,}://'
for fname in s:netrwmarkfilelist_{curbufnr}
if a:del|call s:DeleteBookmark(fname)|else|call s:MakeBookmark(fname)|endif
endfor
let curdir  = exists("b:netrw_curdir")? b:netrw_curdir : getcwd()
call s:NetrwUnmarkList(curbufnr,curdir)
NetrwKeepj call s:NetrwRefresh(islocal,s:NetrwBrowseChgDir(islocal,'./'))
NetrwKeepj call winrestview(svpos)
else
let fname= s:NetrwGetWord()
if a:del|call s:DeleteBookmark(fname)|else|call s:MakeBookmark(fname)|endif
endif
else
let fname= expand("%")
if a:del|call s:DeleteBookmark(fname)|else|call s:MakeBookmark(fname)|endif
endif
else
let islocal= expand("%") !~ '^\a\{3,}://'
let i = 1
while i <= a:0
if islocal
if v:version > 704 || (v:version == 704 && has("patch656"))
let mbfiles= glob(fnameescape(a:{i}),0,1,1)
else
let mbfiles= glob(fnameescape(a:{i}),0,1)
endif
else
let mbfiles= [a:{i}]
endif
for mbfile in mbfiles
if a:del|call s:DeleteBookmark(mbfile)|else|call s:MakeBookmark(mbfile)|endif
endfor
let i= i + 1
endwhile
endif
call s:NetrwBookmarkMenu()
endfun
fun! s:NetrwBookmarkMenu()
if !exists("s:netrw_menucnt")
return
endif
if has("gui") && has("menu") && has("gui_running") && &go =~# 'm' && g:netrw_menu
if exists("g:NetrwTopLvlMenu")
exe 'sil! unmenu '.g:NetrwTopLvlMenu.'Bookmarks'
exe 'sil! unmenu '.g:NetrwTopLvlMenu.'Bookmarks\ and\ History.Bookmark\ Delete'
endif
if !exists("s:netrw_initbookhist")
call s:NetrwBookHistRead()
endif
if exists("g:netrw_bookmarklist") && g:netrw_bookmarklist != [] && g:netrw_dirhistmax > 0
let cnt= 1
for bmd in g:netrw_bookmarklist
let bmd= escape(bmd,g:netrw_menu_escape)
exe 'sil! menu '.g:NetrwMenuPriority.".2.".cnt." ".g:NetrwTopLvlMenu.'Bookmarks.'.bmd.'	:e '.bmd."\<cr>"
exe 'sil! menu '.g:NetrwMenuPriority.".8.2.".cnt." ".g:NetrwTopLvlMenu.'Bookmarks\ and\ History.Bookmark\ Delete.'.bmd.'	'.cnt."mB"
let cnt= cnt + 1
endfor
endif
if g:netrw_dirhistmax > 0
let cnt     = g:netrw_dirhist_cnt
let first   = 1
let histcnt = 0
while ( first || cnt != g:netrw_dirhist_cnt )
let histcnt  = histcnt + 1
let priority = g:netrw_dirhist_cnt + histcnt
if exists("g:netrw_dirhist_{cnt}")
let histdir= escape(g:netrw_dirhist_{cnt},g:netrw_menu_escape)
exe 'sil! menu '.g:NetrwMenuPriority.".3.".priority." ".g:NetrwTopLvlMenu.'History.'.histdir.'	:e '.histdir."\<cr>"
endif
let first = 0
let cnt   = ( cnt - 1 ) % g:netrw_dirhistmax
if cnt < 0
let cnt= cnt + g:netrw_dirhistmax
endif
endwhile
endif
endif
endfun
fun! s:NetrwBrowseChgDir(islocal,newdir,...)
let ykeep= @@
if !exists("b:netrw_curdir")
let @@= ykeep
return
endif
call s:SavePosn(s:netrw_nbcd)
NetrwKeepj call s:NetrwOptionSave("s:")
NetrwKeepj call s:NetrwSafeOptions()
if (has("win32") || has("win95") || has("win64") || has("win16"))
let dirname = substitute(b:netrw_curdir,'\\','/','ge')
else
let dirname = b:netrw_curdir
endif
let newdir    = a:newdir
let dolockout = 0
let dorestore = 1
if g:netrw_banner
if exists("w:netrw_bannercnt") && line(".") < w:netrw_bannercnt && line("$") >= w:netrw_bannercnt
if getline(".") =~# 'Quick Help'
let g:netrw_quickhelp= (g:netrw_quickhelp + 1)%len(s:QuickHelp)
setl ma noro nowrap
NetrwKeepj call setline(line('.'),'"   Quick Help: <F1>:help  '.s:QuickHelp[g:netrw_quickhelp])
setl noma nomod nowrap
call s:RestorePosn(s:netrw_nbcd)
NetrwKeepj call s:NetrwOptionRestore("s:")
endif
endif
endif
if has("amiga")
let dirpat= '[\/:]$'
else
let dirpat= '[\/]$'
endif
if dirname !~ dirpat
let dirname= dirname.'/'
endif
if newdir !~ dirpat && !(a:islocal && isdirectory(s:NetrwFile(s:ComposePath(dirname,newdir))))
let s:rexposn_{bufnr("%")}= winsaveview()
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("w:netrw_treedict") && newdir !~ '^\(/\|\a:\)'
let dirname= s:NetrwTreeDir(a:islocal)
if dirname =~ '/$'
let dirname= dirname.newdir
else
let dirname= dirname."/".newdir
endif
elseif newdir =~ '^\(/\|\a:\)'
let dirname= newdir
else
let dirname= s:ComposePath(dirname,newdir)
endif
if a:0 < 1
NetrwKeepj call s:NetrwOptionRestore("s:")
let curdir= b:netrw_curdir
if !exists("s:didsplit")
if type(g:netrw_browse_split) == 3
call s:NetrwServerEdit(a:islocal,dirname)
return
elseif g:netrw_browse_split == 1
keepalt new
if !&ea
keepalt wincmd _
endif
call s:SetRexDir(a:islocal,curdir)
elseif g:netrw_browse_split == 2
keepalt rightb vert new
if !&ea
keepalt wincmd |
endif
call s:SetRexDir(a:islocal,curdir)
elseif g:netrw_browse_split == 3
keepalt tabnew
if !exists("b:netrw_curdir")
let b:netrw_curdir= getcwd()
endif
call s:SetRexDir(a:islocal,curdir)
elseif g:netrw_browse_split == 4
if s:NetrwPrevWinOpen(2) == 3
let @@= ykeep
return
endif
call s:SetRexDir(a:islocal,curdir)
else
call s:NetrwMenu(0)
if g:netrw_chgwin >= 1
if winnr("$")+1 == g:netrw_chgwin
let curwin= winnr()
exe "NetrwKeepj keepalt ".winnr("$")."wincmd w"
vs
exe "NetrwKeepj keepalt ".g:netrw_chgwin."wincmd ".curwin
endif
exe "NetrwKeepj keepalt ".g:netrw_chgwin."wincmd w"
endif
call s:SetRexDir(a:islocal,curdir)
endif
endif
if a:islocal
if exists("g:netrw_altfile") && g:netrw_altfile
exe "NetrwKeepj keepalt e! ".fnameescape(dirname)
else
exe "NetrwKeepj e! ".fnameescape(dirname)
endif
call s:NetrwCursor()
if &hidden || &bufhidden == "hide"
let dorestore= 0
endif
else
endif
let dolockout= 1
if exists("g:Netrw_funcref")
if type(g:Netrw_funcref) == 2
NetrwKeepj call g:Netrw_funcref()
elseif type(g:Netrw_funcref) == 3
for Fncref in g:Netrw_funcref
if type(FncRef) == 2
NetrwKeepj call FncRef()
endif
endfor
endif
endif
endif
elseif newdir =~ '^/'
let dirname = newdir
NetrwKeepj call s:SetRexDir(a:islocal,dirname)
NetrwKeepj call s:NetrwOptionRestore("s:")
norm! m`
elseif newdir == './'
NetrwKeepj call s:SetRexDir(a:islocal,dirname)
norm! m`
elseif newdir == '../'
if w:netrw_liststyle == s:TREELIST && exists("w:netrw_treedict")
setl noro ma
NetrwKeepj %d _
endif
if has("amiga")
if a:islocal
let dirname= substitute(dirname,'^\(.*[/:]\)\([^/]\+$\)','\1','')
let dirname= substitute(dirname,'/$','','')
else
let dirname= substitute(dirname,'^\(.*[/:]\)\([^/]\+/$\)','\1','')
endif
elseif !g:netrw_cygwin && (has("win32") || has("win95") || has("win64") || has("win16"))
if a:islocal
let dirname= substitute(dirname,'^\(.*\)/\([^/]\+\)/$','\1','')
if dirname == ""
let dirname= '/'
endif
else
let dirname= substitute(dirname,'^\(\a\{3,}://.\{-}/\{1,2}\)\(.\{-}\)\([^/]\+\)/$','\1\2','')
endif
if dirname =~ '^\a:$'
let dirname= dirname.'/'
endif
else
if a:islocal
let dirname= substitute(dirname,'^\(.*\)/\([^/]\+\)/$','\1','')
if dirname == ""
let dirname= '/'
endif
else
let dirname= substitute(dirname,'^\(\a\{3,}://.\{-}/\{1,2}\)\(.\{-}\)\([^/]\+\)/$','\1\2','')
endif
endif
NetrwKeepj call s:SetRexDir(a:islocal,dirname)
norm m`
elseif exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("w:netrw_treedict")
setl noro ma
if !(exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("b:netrw_curdir"))
NetrwKeepj %d _
endif
let treedir      = s:NetrwTreeDir(a:islocal)
let s:treecurpos = winsaveview()
let haskey       = 0
if has_key(w:netrw_treedict,treedir)
let haskey= 1
else
endif
if !haskey && treedir !~ '[/@]$'
if has_key(w:netrw_treedict,treedir."/")
let treedir= treedir."/"
let haskey = 1
else
endif
endif
if !haskey && treedir =~ '/$'
let treedir= substitute(treedir,'/$','','')
if has_key(w:netrw_treedict,treedir)
let haskey = 1
else
endif
endif
if haskey
call remove(w:netrw_treedict,treedir)
let dirname= w:netrw_treetop
else
let dirname= substitute(treedir,'/*$','/','')
endif
NetrwKeepj call s:SetRexDir(a:islocal,dirname)
let s:treeforceredraw = 1
else
let dirname    = s:ComposePath(dirname,newdir)
NetrwKeepj call s:SetRexDir(a:islocal,dirname)
norm m`
endif
if dorestore
NetrwKeepj call s:NetrwOptionRestore("s:")
endif
call s:RestorePosn(s:netrw_nbcd)
if dolockout && dorestore
if filewritable(dirname)
setl ma noro nomod
else
setl ma ro nomod
endif
endif
let @@= ykeep
return dirname
endfun
fun! s:NetrwBrowseUpDir(islocal)
if exists("w:netrw_bannercnt") && line(".") < w:netrw_bannercnt-1
return
endif
if !exists("w:netrw_liststyle") || w:netrw_liststyle != s:TREELIST
call s:SavePosn(s:netrw_nbcd)
endif
norm! 0
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("w:netrw_treedict")
let curline= getline(".")
let swwline= winline() - 1
if exists("w:netrw_treetop")
let b:netrw_curdir= w:netrw_treetop
endif
let curdir= b:netrw_curdir
if a:islocal
call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(1,'../'))
else
call s:NetrwBrowse(0,s:NetrwBrowseChgDir(0,'../'))
endif
if !search('\c^'.s:treedepthstring.curline,'cw')
if !search('\c^'.curline,'cw')
sil! NetrwKeepj 1
endif
endif
exe "sil! NetrwKeepj norm! z\<cr>"
while winline() < swwline
let curwinline= winline()
exe "sil! NetrwKeepj norm! \<c-y>"
if curwinline == winline()
break
endif
endwhile
else
if exists("b:netrw_curdir")
let curdir= b:netrw_curdir
else
let curdir= expand(getcwd())
endif
if a:islocal
call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(1,'../'))
else
call s:NetrwBrowse(0,s:NetrwBrowseChgDir(0,'../'))
endif
if has_key(s:netrw_nbcd,bufnr("%"))
call s:RestorePosn(s:netrw_nbcd)
elseif exists("w:netrw_bannercnt")
exe w:netrw_bannercnt
else
1
endif
endif
let curdir= substitute(curdir,'^.*[\/]','','')
call search('\<'.curdir.'\>','wc')
endfun
fun! netrw#BrowseX(fname,remote)
if (a:remote == 0 && isdirectory(a:fname)) || (a:remote == 1 && fname =~ '/$' && fname !~ '^https\=:')
norm! gf
endif
let ykeep      = @@
let screenposn = winsaveview()
let awkeep     = &aw
set noaw
if a:fname =~ '/core\(\.\d\+\)\=$'
if exists("g:Netrw_corehandler")
if type(g:Netrw_corehandler) == 2
call g:Netrw_corehandler(s:NetrwFile(a:fname))
elseif type(g:Netrw_corehandler) == 3
for Fncref in g:Netrw_corehandler
if type(FncRef) == 2
call FncRef(a:fname)
endif
endfor
endif
call winrestview(screenposn)
let @@= ykeep
let &aw= awkeep
return
endif
endif
let exten= substitute(a:fname,'.*\.\(.\{-}\)','\1','e')
if has("win32") || has("win95") || has("win64") || has("win16")
let exten= substitute(exten,'^.*$','\L&\E','')
endif
if a:remote == 1
setl bh=delete
call netrw#NetRead(3,a:fname)
let basename= substitute(a:fname,'^\(.*\)/\(.*\)\.\([^.]*\)$','\2','')
let newname = substitute(s:netrw_tmpfile,'^\(.*\)/\(.*\)\.\([^.]*\)$','\1/'.basename.'.\3','')
if rename(s:netrw_tmpfile,newname) == 0
let fname= newname
else
let fname= s:netrw_tmpfile
endif
else
let fname= a:fname
if fname =~ '^\~' && expand("$HOME") != ""
let fname= s:NetrwFile(substitute(fname,'^\~',expand("$HOME"),''))
endif
endif
if g:netrw_suppress_gx_mesg
if &srr =~ "%s"
if (has("win32") || has("win95") || has("win64") || has("win16"))
let redir= substitute(&srr,"%s","nul","")
else
let redir= substitute(&srr,"%s","/dev/null","")
endif
elseif (has("win32") || has("win95") || has("win64") || has("win16"))
let redir= &srr . "nul"
else
let redir= &srr . "/dev/null"
endif
endif
if exists("g:netrw_browsex_viewer")
if g:netrw_browsex_viewer =~ '\s'
let viewer  = substitute(g:netrw_browsex_viewer,'\s.*$','','')
let viewopt = substitute(g:netrw_browsex_viewer,'^\S\+\s*','','')." "
let oviewer = ''
let cnt     = 1
while !executable(viewer) && viewer != oviewer
let viewer  = substitute(g:netrw_browsex_viewer,'^\(\(^\S\+\s\+\)\{'.cnt.'}\S\+\)\(.*\)$','\1','')
let viewopt = substitute(g:netrw_browsex_viewer,'^\(\(^\S\+\s\+\)\{'.cnt.'}\S\+\)\(.*\)$','\3','')." "
let cnt     = cnt + 1
let oviewer = viewer
endwhile
else
let viewer  = g:netrw_browsex_viewer
let viewopt = ""
endif
endif
if exists("g:netrw_browsex_viewer") && g:netrw_browsex_viewer == '-'
let ret= netrwFileHandlers#Invoke(exten,fname)
elseif exists("g:netrw_browsex_viewer") && executable(viewer)
call s:NetrwExe("sil !".viewer." ".viewopt.s:ShellEscape(fname,1).redir)
let ret= v:shell_error
elseif has("win32") || has("win64")
if executable("start")
call s:NetrwExe('sil! !start rundll32 url.dll,FileProtocolHandler '.s:ShellEscape(fname,1))
elseif executable("rundll32")
call s:NetrwExe('sil! !rundll32 url.dll,FileProtocolHandler '.s:ShellEscape(fname,1))
else
call netrw#ErrorMsg(s:WARNING,"rundll32 not on path",74)
endif
call inputsave()|call input("Press <cr> to continue")|call inputrestore()
let ret= v:shell_error
elseif has("win32unix")
let winfname= 'c:\cygwin'.substitute(fname,'/','\\','g')
if executable("start")
call s:NetrwExe('sil !start rundll32 url.dll,FileProtocolHandler '.s:ShellEscape(winfname,1))
elseif executable("rundll32")
call s:NetrwExe('sil !rundll32 url.dll,FileProtocolHandler '.s:ShellEscape(winfname,1))
elseif executable("cygstart")
call s:NetrwExe('sil !cygstart '.s:ShellEscape(fname,1))
else
call netrw#ErrorMsg(s:WARNING,"rundll32 not on path",74)
endif
call inputsave()|call input("Press <cr> to continue")|call inputrestore()
let ret= v:shell_error
elseif has("unix") && executable("kfmclient") && s:CheckIfKde()
call s:NetrwExe("sil !kfmclient exec ".s:ShellEscape(fname,1)." ".redir)
let ret= v:shell_error
elseif has("unix") && executable("exo-open") && executable("xdg-open") && executable("setsid")
call s:NetrwExe("sil !setsid xdg-open ".s:ShellEscape(fname,1).redir)
let ret= v:shell_error
elseif has("unix") && executable("xdg-open")
call s:NetrwExe("sil !xdg-open ".s:ShellEscape(fname,1).redir)
let ret= v:shell_error
elseif has("macunix") && executable("open")
call s:NetrwExe("sil !open ".s:ShellEscape(fname,1)." ".redir)
let ret= v:shell_error
else
let ret= netrwFileHandlers#Invoke(exten,fname)
endif
if ret
let ret= netrwFileHandlers#Invoke(exten,fname)
endif
redraw!
if a:remote == 1
setl bh=delete bt=nofile
if g:netrw_use_noswf
setl noswf
endif
exe "sil! NetrwKeepj norm! \<c-o>"
endif
call winrestview(screenposn)
let @@ = ykeep
let &aw= awkeep
endfun
fun! netrw#BrowseXVis()
let atkeep = @@
norm! gvy
call netrw#BrowseX(@@,netrw#CheckIfRemote())
let @@     = atkeep
endfun
fun! netrw#CheckIfRemote()
if expand("%") =~ '^\a\{3,}://'
return 1
else
return 0
endif
endfun
fun! s:NetrwChgPerm(islocal,curdir)
let ykeep  = @@
call inputsave()
let newperm= input("Enter new permission: ")
call inputrestore()
let chgperm= substitute(g:netrw_chgperm,'\<FILENAME\>',s:ShellEscape(expand("<cfile>")),'')
let chgperm= substitute(chgperm,'\<PERM\>',s:ShellEscape(newperm),'')
call system(chgperm)
if v:shell_error != 0
NetrwKeepj call netrw#ErrorMsg(1,"changing permission on file<".expand("<cfile>")."> seems to have failed",75)
endif
if a:islocal
NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
endif
let @@= ykeep
endfun
fun! s:CheckIfKde()
if !exists("s:haskdeinit")
if has("unix") && executable("ps") && !has("win32unix")
let s:haskdeinit= system("ps -e") =~ '\<kdeinit'
if v:shell_error
let s:haskdeinit = 0
endif
else
let s:haskdeinit= 0
endif
endif
return s:haskdeinit
endfun
fun! s:NetrwClearExplore()
2match none
if exists("s:explore_match")        |unlet s:explore_match        |endif
if exists("s:explore_indx")         |unlet s:explore_indx         |endif
if exists("s:netrw_explore_prvdir") |unlet s:netrw_explore_prvdir |endif
if exists("s:dirstarstar")          |unlet s:dirstarstar          |endif
if exists("s:explore_prvdir")       |unlet s:explore_prvdir       |endif
if exists("w:netrw_explore_indx")   |unlet w:netrw_explore_indx   |endif
if exists("w:netrw_explore_listlen")|unlet w:netrw_explore_listlen|endif
if exists("w:netrw_explore_list")   |unlet w:netrw_explore_list   |endif
if exists("w:netrw_explore_bufnr")  |unlet w:netrw_explore_bufnr  |endif
echo " "
echo " "
endfun
fun! s:NetrwExploreListUniq(explist)
let newexplist= []
for member in a:explist
if !exists("uniqmember") || member != uniqmember
let uniqmember = member
let newexplist = newexplist + [ member ]
endif
endfor
return newexplist
endfun
fun! s:NetrwForceChgDir(islocal,newdir)
let ykeep= @@
if a:newdir !~ '/$'
if a:newdir =~ '@$'
let newdir= substitute(a:newdir,'@$','/','')
elseif a:newdir =~ '[*=|\\]$'
let newdir= substitute(a:newdir,'.$','/','')
else
let newdir= a:newdir.'/'
endif
else
let newdir= a:newdir
endif
let newdir= s:NetrwBrowseChgDir(a:islocal,newdir)
call s:NetrwBrowse(a:islocal,newdir)
let @@= ykeep
endfun
fun! s:NetrwGlob(direntry,expr,pare)
if netrw#CheckIfRemote()
keepalt 1sp
keepalt enew
let keep_liststyle    = w:netrw_liststyle
let w:netrw_liststyle = s:THINLIST
if s:NetrwRemoteListing() == 0
keepj keepalt %s@/@@
let filelist= getline(1,$)
q!
else
let filelist= w:netrw_treedict[a:direntry]
endif
let w:netrw_liststyle= keep_liststyle
elseif v:version > 704 || (v:version == 704 && has("patch656"))
let filelist= glob(s:ComposePath(fnameescape(a:direntry),a:expr),0,1,1)
if a:pare
let filelist= map(filelist,'substitute(v:val, "^.*/", "", "")')
endif
else
let filelist= glob(s:ComposePath(fnameescape(a:direntry),a:expr),0,1)
if a:pare
let filelist= map(filelist,'substitute(v:val, "^.*/", "", "")')
endif
endif
return filelist
endfun
fun! s:NetrwForceFile(islocal,newfile)
if a:newfile =~ '[/@*=|\\]$'
let newfile= substitute(a:newfile,'.$','','')
else
let newfile= a:newfile
endif
if a:islocal
call s:NetrwBrowseChgDir(a:islocal,newfile)
else
call s:NetrwBrowse(a:islocal,s:NetrwBrowseChgDir(a:islocal,newfile))
endif
endfun
fun! s:NetrwHide(islocal)
let ykeep= @@
let svpos= winsaveview()
if exists("s:netrwmarkfilelist_{bufnr('%')}")
for fname in s:netrwmarkfilelist_{bufnr("%")}
if match(g:netrw_list_hide,'\<'.fname.'\>') != -1
let g:netrw_list_hide= substitute(g:netrw_list_hide,'..\<'.escape(fname,g:netrw_fname_escape).'\>..','','')
let g:netrw_list_hide= substitute(g:netrw_list_hide,',,',',','g')
let g:netrw_list_hide= substitute(g:netrw_list_hide,'^,\|,$','','')
else
if exists("g:netrw_list_hide") && g:netrw_list_hide != ""
let g:netrw_list_hide= g:netrw_list_hide.',\<'.escape(fname,g:netrw_fname_escape).'\>'
else
let g:netrw_list_hide= '\<'.escape(fname,g:netrw_fname_escape).'\>'
endif
endif
endfor
NetrwKeepj call s:NetrwUnmarkList(bufnr("%"),b:netrw_curdir)
let g:netrw_hide= 1
else
let g:netrw_hide=(g:netrw_hide+1)%3
exe "NetrwKeepj norm! 0"
if g:netrw_hide && g:netrw_list_hide == ""
NetrwKeepj call netrw#ErrorMsg(s:WARNING,"your hiding list is empty!",49)
let @@= ykeep
return
endif
endif
NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
NetrwKeepj call winrestview(svpos)
let @@= ykeep
endfun
fun! s:NetrwHideEdit(islocal)
let ykeep= @@
let svpos= winsaveview()
call inputsave()
let newhide= input("Edit Hiding List: ",g:netrw_list_hide)
call inputrestore()
let g:netrw_list_hide= newhide
sil NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,"./"))
call winrestview(svpos)
let @@= ykeep
endfun
fun! s:NetrwHidden(islocal)
let ykeep= @@
let svpos= winsaveview()
if g:netrw_list_hide =~ '\(^\|,\)\\(^\\|\\s\\s\\)\\zs\\.\\S\\+'
let g:netrw_list_hide= substitute(g:netrw_list_hide,'\(^\|,\)\\(^\\|\\s\\s\\)\\zs\\.\\S\\+','','')
elseif s:Strlen(g:netrw_list_hide) >= 1
let g:netrw_list_hide= g:netrw_list_hide . ',\(^\|\s\s\)\zs\.\S\+'
else
let g:netrw_list_hide= '\(^\|\s\s\)\zs\.\S\+'
endif
NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
NetrwKeepj call winrestview(svpos)
let @@= ykeep
endfun
fun! s:NetrwHome()
if exists("g:netrw_home")
let home= g:netrw_home
else
for home in split(&rtp,',') + ['']
if isdirectory(s:NetrwFile(home)) && filewritable(s:NetrwFile(home)) | break | endif
let basehome= substitute(home,'[/\\]\.vim$','','')
if isdirectory(s:NetrwFile(basehome)) && filewritable(s:NetrwFile(basehome))
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
if g:netrw_dirhistmax > 0 && !isdirectory(s:NetrwFile(home))
if exists("g:netrw_mkdir")
call system(g:netrw_mkdir." ".s:ShellEscape(s:NetrwFile(home)))
else
call mkdir(home)
endif
endif
let g:netrw_home= home
return home
endfun
fun! s:NetrwLeftmouse(islocal)
if exists("s:netrwdrag")
return
endif
let ykeep= @@
while getchar(0) != 0
endwhile
call feedkeys("\<LeftMouse>")
let c          = getchar()
let mouse_lnum = v:mouse_lnum
let wlastline  = line('w$')
let lastline   = line('$')
if mouse_lnum >= wlastline + 1 || v:mouse_win != winnr()
let @@= ykeep
return
endif
if v:mouse_col > virtcol('.')
let @@= ykeep
return
endif
if a:islocal
if exists("b:netrw_curdir")
NetrwKeepj call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(1,s:NetrwGetWord()))
endif
else
if exists("b:netrw_curdir")
NetrwKeepj call s:NetrwBrowse(0,s:NetrwBrowseChgDir(0,s:NetrwGetWord()))
endif
endif
let @@= ykeep
endfun
fun! s:NetrwCLeftmouse(islocal)
call s:NetrwMarkFileTgt(a:islocal)
endfun
fun! s:NetrwServerEdit(islocal,fname)
let islocal = a:islocal%2      " =0: remote           =1: local
let ctrlr   = a:islocal >= 2   " =0: <c-r> not used   =1: <c-r> used
if (islocal && isdirectory(s:NetrwFile(a:fname))) || (!islocal && a:fname =~ '/$')
let g:netrw_browse_split= 0
if exists("s:netrw_browse_split") && exists("s:netrw_browse_split_".winnr())
let g:netrw_browse_split= s:netrw_browse_split_{winnr()}
unlet s:netrw_browse_split_{winnr()}
endif
call s:NetrwBrowse(islocal,s:NetrwBrowseChgDir(islocal,a:fname))
return
endif
if has("clientserver") && executable("gvim")
if exists("g:netrw_browse_split") && type(g:netrw_browse_split) == 3
let srvrname = g:netrw_browse_split[0]
let tabnum   = g:netrw_browse_split[1]
let winnum   = g:netrw_browse_split[2]
if serverlist() !~ '\<'.srvrname.'\>'
if !ctrlr
if exists("g:netrw_browse_split")
unlet g:netrw_browse_split
endif
let g:netrw_browse_split= 0
if exists("s:netrw_browse_split_".winnr())
let g:netrw_browse_split= s:netrw_browse_split_{winnr()}
endif
call s:NetrwBrowseChgDir(islocal,a:fname)
return
elseif has("win32") && executable("start")
call system("start gvim --servername ".srvrname)
else
call system("gvim --servername ".srvrname)
endif
endif
call remote_send(srvrname,":tabn ".tabnum."\<cr>")
call remote_send(srvrname,":".winnum."wincmd w\<cr>")
call remote_send(srvrname,":e ".fnameescape(s:NetrwFile(a:fname))."\<cr>")
else
if serverlist() !~ '\<'.g:netrw_servername.'\>'
if !ctrlr
if exists("g:netrw_browse_split")
unlet g:netrw_browse_split
endif
let g:netrw_browse_split= 0
call s:NetrwBrowse(islocal,s:NetrwBrowseChgDir(islocal,a:fname))
return
else
if has("win32") && executable("start")
call system("start gvim --servername ".g:netrw_servername)
else
call system("gvim --servername ".g:netrw_servername)
endif
endif
endif
while 1
try
call remote_send(g:netrw_servername,":e ".fnameescape(s:NetrwFile(a:fname))."\<cr>")
break
catch /^Vim\%((\a\+)\)\=:E241/
sleep 200m
endtry
endwhile
if exists("g:netrw_browse_split")
if type(g:netrw_browse_split) != 3
let s:netrw_browse_split_{winnr()}= g:netrw_browse_split
endif
unlet g:netrw_browse_split
endif
let g:netrw_browse_split= [g:netrw_servername,1,1]
endif
else
call netrw#ErrorMsg(s:ERROR,"you need a gui-capable vim and client-server to use <ctrl-r>",98)
endif
endfun
fun! s:NetrwSLeftmouse(islocal)
let s:ngw= s:NetrwGetWord()
call s:NetrwMarkFile(a:islocal,s:ngw)
endfun
fun! s:NetrwSLeftdrag(islocal)
if !exists("s:netrwdrag")
let s:netrwdrag = winnr()
if a:islocal
nno <silent> <s-leftrelease> <leftmouse>:<c-u>call <SID>NetrwSLeftrelease(1)<cr>
else
nno <silent> <s-leftrelease> <leftmouse>:<c-u>call <SID>NetrwSLeftrelease(0)<cr>
endif
endif
let ngw = s:NetrwGetWord()
if !exists("s:ngw") || s:ngw != ngw
call s:NetrwMarkFile(a:islocal,ngw)
endif
let s:ngw= ngw
endfun
fun! s:NetrwSLeftrelease(islocal)
if exists("s:netrwdrag")
nunmap <s-leftrelease>
let ngw = s:NetrwGetWord()
if !exists("s:ngw") || s:ngw != ngw
call s:NetrwMarkFile(a:islocal,ngw)
endif
if exists("s:ngw")
unlet s:ngw
endif
unlet s:netrwdrag
endif
endfun
fun! s:NetrwListHide()
let ykeep= @@
let listhide= g:netrw_list_hide
let sep     = strpart(substitute('/~@#$%^&*{};:,<.>?|1234567890','['.escape(listhide,'-]^\').']','','ge'),1,1)
while listhide != ""
if listhide =~ ','
let hide     = substitute(listhide,',.*$','','e')
let listhide = substitute(listhide,'^.\{-},\(.*\)$','\1','e')
else
let hide     = listhide
let listhide = ""
endif
if g:netrw_hide == 1
exe 'sil! NetrwKeepj '.w:netrw_bannercnt.',$g'.sep.hide.sep.'d'
elseif g:netrw_hide == 2
exe 'sil! NetrwKeepj '.w:netrw_bannercnt.',$g'.sep.hide.sep.'s@^@ /-KEEP-/ @'
endif
endwhile
if g:netrw_hide == 2
exe 'sil! NetrwKeepj '.w:netrw_bannercnt.',$v@^ /-KEEP-/ @d'
exe 'sil! NetrwKeepj '.w:netrw_bannercnt.',$s@^\%( /-KEEP-/ \)\+@@e'
endif
exe 'sil! NetrwKeepj 1,$g@^\s*$@d'
let @@= ykeep
endfun
fun! s:NetrwMakeDir(usrhost)
let ykeep= @@
call inputsave()
let newdirname= input("Please give directory name: ")
call inputrestore()
if newdirname == ""
let @@= ykeep
return
endif
if a:usrhost == ""
let fullnewdir= b:netrw_curdir.'/'.newdirname
if isdirectory(s:NetrwFile(fullnewdir))
if !exists("g:netrw_quiet")
NetrwKeepj call netrw#ErrorMsg(s:WARNING,"<".newdirname."> is already a directory!",24)
endif
let @@= ykeep
return
endif
if s:FileReadable(fullnewdir)
if !exists("g:netrw_quiet")
NetrwKeepj call netrw#ErrorMsg(s:WARNING,"<".newdirname."> is already a file!",25)
endif
let @@= ykeep
return
endif
if exists("*mkdir")
if has("unix")
call mkdir(fullnewdir,"p",xor(0777, system("umask")))
else
call mkdir(fullnewdir,"p")
endif
else
let netrw_origdir= s:NetrwGetcwd(1)
call s:NetrwLcd(b:netrw_curdir)
call s:NetrwExe("sil! !".g:netrw_localmkdir.' '.s:ShellEscape(newdirname,1))
if v:shell_error != 0
let @@= ykeep
call netrw#ErrorMsg(s:ERROR,"consider setting g:netrw_localmkdir<".g:netrw_localmkdir."> to something that works",80)
return
endif
if !g:netrw_keepdir
call s:NetrwLcd(netrw_origdir)
endif
endif
if v:shell_error == 0
let svpos= winsaveview()
call s:NetrwRefresh(1,s:NetrwBrowseChgDir(1,'./'))
call winrestview(svpos)
elseif !exists("g:netrw_quiet")
call netrw#ErrorMsg(s:ERROR,"unable to make directory<".newdirname.">",26)
endif
elseif !exists("b:netrw_method") || b:netrw_method == 4
let mkdircmd  = s:MakeSshCmd(g:netrw_mkdir_cmd)
let newdirname= substitute(b:netrw_curdir,'^\%(.\{-}/\)\{3}\(.*\)$','\1','').newdirname
call s:NetrwExe("sil! !".mkdircmd." ".s:ShellEscape(newdirname,1))
if v:shell_error == 0
let svpos= winsaveview()
NetrwKeepj call s:NetrwRefresh(0,s:NetrwBrowseChgDir(0,'./'))
NetrwKeepj call winrestview(svpos)
elseif !exists("g:netrw_quiet")
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"unable to make directory<".newdirname.">",27)
endif
elseif b:netrw_method == 2
let svpos= winsaveview()
if exists("b:netrw_fname")
let remotepath= b:netrw_fname
else
let remotepath= ""
endif
call s:NetrwRemoteFtpCmd(remotepath,g:netrw_remote_mkdir.' "'.newdirname.'"')
NetrwKeepj call s:NetrwRefresh(0,s:NetrwBrowseChgDir(0,'./'))
NetrwKeepj call winrestview(svpos)
elseif b:netrw_method == 3
let svpos= winsaveview()
if exists("b:netrw_fname")
let remotepath= b:netrw_fname
else
let remotepath= ""
endif
call s:NetrwRemoteFtpCmd(remotepath,g:netrw_remote_mkdir.' "'.newdirname.'"')
NetrwKeepj call s:NetrwRefresh(0,s:NetrwBrowseChgDir(0,'./'))
NetrwKeepj call winrestview(svpos)
endif
let @@= ykeep
endfun
fun! s:TreeSqueezeDir(islocal)
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("w:netrw_treedict")
let curdepth = substitute(getline('.'),'^\(\%('.s:treedepthstring.'\)*\)[^'.s:treedepthstring.'].\{-}$','\1','e')
let stopline = (exists("w:netrw_bannercnt")? (w:netrw_bannercnt + 1) : 1)
let depth    = strchars(substitute(curdepth,' ','','g'))
let srch     = -1
if depth >= 2
NetrwKeepj norm! 0
let curdepthm1= substitute(curdepth,'^'.s:treedepthstring,'','')
let srch      = search('^'.curdepthm1.'\%('.s:treedepthstring.'\)\@!','bW',stopline)
elseif depth == 1
NetrwKeepj norm! 0
let treedepthchr= substitute(s:treedepthstring,' ','','')
let srch        = search('^[^'.treedepthchr.']','bW',stopline)
endif
if srch > 0
call s:NetrwBrowse(a:islocal,s:NetrwBrowseChgDir(a:islocal,s:NetrwGetWord()))
exe srch
endif
endif
endfun
fun! s:NetrwMaps(islocal)
if g:netrw_mousemaps && g:netrw_retmap
if !hasmapto("<Plug>NetrwReturn")
if maparg("<2-leftmouse>","n") == "" || maparg("<2-leftmouse>","n") =~ '^-$'
nmap <unique> <silent> <2-leftmouse>	<Plug>NetrwReturn
elseif maparg("<c-leftmouse>","n") == ""
nmap <unique> <silent> <c-leftmouse>	<Plug>NetrwReturn
endif
endif
nno <silent> <Plug>NetrwReturn	:Rexplore<cr>
endif
if a:islocal
nnoremap <buffer> <silent> <nowait> a	:<c-u>call <SID>NetrwHide(1)<cr>
nnoremap <buffer> <silent> <nowait> -	:<c-u>call <SID>NetrwBrowseUpDir(1)<cr>
nnoremap <buffer> <silent> <nowait> %	:<c-u>call <SID>NetrwOpenFile(1)<cr>
nnoremap <buffer> <silent> <nowait> c	:<c-u>call <SID>NetrwLcd(b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> C	:<c-u>call <SID>NetrwSetChgwin()<cr>
nnoremap <buffer> <silent> <nowait> <cr>	:<c-u>call netrw#LocalBrowseCheck(<SID>NetrwBrowseChgDir(1,<SID>NetrwGetWord()))<cr>
nnoremap <buffer> <silent> <nowait> <c-r>	:<c-u>call <SID>NetrwServerEdit(3,<SID>NetrwGetWord())<cr>
nnoremap <buffer> <silent> <nowait> d	:<c-u>call <SID>NetrwMakeDir("")<cr>
nnoremap <buffer> <silent> <nowait> gb	:<c-u>call <SID>NetrwBookHistHandler(1,b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> gd	:<c-u>call <SID>NetrwForceChgDir(1,<SID>NetrwGetWord())<cr>
nnoremap <buffer> <silent> <nowait> gf	:<c-u>call <SID>NetrwForceFile(1,<SID>NetrwGetWord())<cr>
nnoremap <buffer> <silent> <nowait> gh	:<c-u>call <SID>NetrwHidden(1)<cr>
nnoremap <buffer> <silent> <nowait> gn	:<c-u>call netrw#SetTreetop(<SID>NetrwGetWord())<cr>
nnoremap <buffer> <silent> <nowait> gp	:<c-u>call <SID>NetrwChgPerm(1,b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> I	:<c-u>call <SID>NetrwBannerCtrl(1)<cr>
nnoremap <buffer> <silent> <nowait> i	:<c-u>call <SID>NetrwListStyle(1)<cr>
nnoremap <buffer> <silent> <nowait> ma	:<c-u>call <SID>NetrwMarkFileArgList(1,0)<cr>
nnoremap <buffer> <silent> <nowait> mA	:<c-u>call <SID>NetrwMarkFileArgList(1,1)<cr>
nnoremap <buffer> <silent> <nowait> mb	:<c-u>call <SID>NetrwBookHistHandler(0,b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> mB	:<c-u>call <SID>NetrwBookHistHandler(6,b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> mc	:<c-u>call <SID>NetrwMarkFileCopy(1)<cr>
nnoremap <buffer> <silent> <nowait> md	:<c-u>call <SID>NetrwMarkFileDiff(1)<cr>
nnoremap <buffer> <silent> <nowait> me	:<c-u>call <SID>NetrwMarkFileEdit(1)<cr>
nnoremap <buffer> <silent> <nowait> mf	:<c-u>call <SID>NetrwMarkFile(1,<SID>NetrwGetWord())<cr>
nnoremap <buffer> <silent> <nowait> mF	:<c-u>call <SID>NetrwUnmarkList(bufnr("%"),b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> mg	:<c-u>call <SID>NetrwMarkFileGrep(1)<cr>
nnoremap <buffer> <silent> <nowait> mh	:<c-u>call <SID>NetrwMarkHideSfx(1)<cr>
nnoremap <buffer> <silent> <nowait> mm	:<c-u>call <SID>NetrwMarkFileMove(1)<cr>
nnoremap <buffer> <silent> <nowait> mp	:<c-u>call <SID>NetrwMarkFilePrint(1)<cr>
nnoremap <buffer> <silent> <nowait> mr	:<c-u>call <SID>NetrwMarkFileRegexp(1)<cr>
nnoremap <buffer> <silent> <nowait> ms	:<c-u>call <SID>NetrwMarkFileSource(1)<cr>
nnoremap <buffer> <silent> <nowait> mT	:<c-u>call <SID>NetrwMarkFileTag(1)<cr>
nnoremap <buffer> <silent> <nowait> mt	:<c-u>call <SID>NetrwMarkFileTgt(1)<cr>
nnoremap <buffer> <silent> <nowait> mu	:<c-u>call <SID>NetrwUnMarkFile(1)<cr>
nnoremap <buffer> <silent> <nowait> mv	:<c-u>call <SID>NetrwMarkFileVimCmd(1)<cr>
nnoremap <buffer> <silent> <nowait> mx	:<c-u>call <SID>NetrwMarkFileExe(1,0)<cr>
nnoremap <buffer> <silent> <nowait> mX	:<c-u>call <SID>NetrwMarkFileExe(1,1)<cr>
nnoremap <buffer> <silent> <nowait> mz	:<c-u>call <SID>NetrwMarkFileCompress(1)<cr>
nnoremap <buffer> <silent> <nowait> O	:<c-u>call <SID>NetrwObtain(1)<cr>
nnoremap <buffer> <silent> <nowait> o	:call <SID>NetrwSplit(3)<cr>
nnoremap <buffer> <silent> <nowait> p	:<c-u>call <SID>NetrwPreview(<SID>NetrwBrowseChgDir(1,<SID>NetrwGetWord(),1))<cr>
nnoremap <buffer> <silent> <nowait> P	:<c-u>call <SID>NetrwPrevWinOpen(1)<cr>
nnoremap <buffer> <silent> <nowait> qb	:<c-u>call <SID>NetrwBookHistHandler(2,b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> qf	:<c-u>call <SID>NetrwFileInfo(1,<SID>NetrwGetWord())<cr>
nnoremap <buffer> <silent> <nowait> qF	:<c-u>call <SID>NetrwMarkFileQFEL(1,getqflist())<cr>
nnoremap <buffer> <silent> <nowait> qL	:<c-u>call <SID>NetrwMarkFileQFEL(1,getloclist(v:count))<cr>
nnoremap <buffer> <silent> <nowait> r	:<c-u>let g:netrw_sort_direction= (g:netrw_sort_direction =~# 'n')? 'r' : 'n'<bar>exe "norm! 0"<bar>call <SID>NetrwRefresh(1,<SID>NetrwBrowseChgDir(1,'./'))<cr>
nnoremap <buffer> <silent> <nowait> s	:call <SID>NetrwSortStyle(1)<cr>
nnoremap <buffer> <silent> <nowait> S	:<c-u>call <SID>NetSortSequence(1)<cr>
nnoremap <buffer> <silent> <nowait> Tb	:<c-u>call <SID>NetrwSetTgt(1,'b',v:count1)<cr>
nnoremap <buffer> <silent> <nowait> t	:call <SID>NetrwSplit(4)<cr>
nnoremap <buffer> <silent> <nowait> Th	:<c-u>call <SID>NetrwSetTgt(1,'h',v:count)<cr>
nnoremap <buffer> <silent> <nowait> u	:<c-u>call <SID>NetrwBookHistHandler(4,expand("%"))<cr>
nnoremap <buffer> <silent> <nowait> U	:<c-u>call <SID>NetrwBookHistHandler(5,expand("%"))<cr>
nnoremap <buffer> <silent> <nowait> v	:call <SID>NetrwSplit(5)<cr>
nnoremap <buffer> <silent> <nowait> x	:<c-u>call netrw#BrowseX(<SID>NetrwBrowseChgDir(1,<SID>NetrwGetWord(),0),0)"<cr>
nnoremap <buffer> <silent> <nowait> X	:<c-u>call <SID>NetrwLocalExecute(expand("<cword>"))"<cr>
if !hasmapto('<Plug>NetrwHideEdit')
nmap <buffer> <unique> <c-h> <Plug>NetrwHideEdit
endif
nnoremap <buffer> <silent> <Plug>NetrwHideEdit		:call <SID>NetrwHideEdit(1)<cr>
if !hasmapto('<Plug>NetrwRefresh')
nmap <buffer> <unique> <c-l> <Plug>NetrwRefresh
endif
nnoremap <buffer> <silent> <Plug>NetrwRefresh		<c-l>:call <SID>NetrwRefresh(1,<SID>NetrwBrowseChgDir(1,(w:netrw_liststyle == 3)? w:netrw_treetop : './'))<cr>
if s:didstarstar || !mapcheck("<s-down>","n")
nnoremap <buffer> <silent> <s-down>	:Nexplore<cr>
endif
if s:didstarstar || !mapcheck("<s-up>","n")
nnoremap <buffer> <silent> <s-up>	:Pexplore<cr>
endif
if !hasmapto('<Plug>NetrwTreeSqueeze')
nmap <buffer> <silent> <nowait> <s-cr>			<Plug>NetrwTreeSqueeze
endif
nnoremap <buffer> <silent> <Plug>NetrwTreeSqueeze		:call <SID>TreeSqueezeDir(1)<cr>
let mapsafecurdir = escape(b:netrw_curdir, s:netrw_map_escape)
if g:netrw_mousemaps == 1
nmap <buffer> <leftmouse>   				<Plug>NetrwLeftmouse
nno  <buffer> <silent>		<Plug>NetrwLeftmouse	<leftmouse>:call <SID>NetrwLeftmouse(1)<cr>
nmap <buffer> <c-leftmouse>		<Plug>NetrwCLeftmouse
nno  <buffer> <silent>		<Plug>NetrwCLeftmouse	<leftmouse>:call <SID>NetrwCLeftmouse(1)<cr>
nmap <buffer> <middlemouse>		<Plug>NetrwMiddlemouse
nno  <buffer> <silent>		<Plug>NetrwMiddlemouse	<leftmouse>:call <SID>NetrwPrevWinOpen(1)<cr>
nmap <buffer> <s-leftmouse>		<Plug>NetrwSLeftmouse
nno  <buffer> <silent>		<Plug>NetrwSLeftmouse 	<leftmouse>:call <SID>NetrwSLeftmouse(1)<cr>
nmap <buffer> <s-leftdrag>		<Plug>NetrwSLeftdrag
nno  <buffer> <silent>		<Plug>NetrwSLeftdrag	<leftmouse>:call <SID>NetrwSLeftdrag(1)<cr>
nmap <buffer> <2-leftmouse>		<Plug>Netrw2Leftmouse
nmap <buffer> <silent>		<Plug>Netrw2Leftmouse	-
imap <buffer> <leftmouse>		<Plug>ILeftmouse
imap <buffer> <middlemouse>		<Plug>IMiddlemouse
exe 'nnoremap <buffer> <silent> <rightmouse>  <leftmouse>:call <SID>NetrwLocalRm("'.mapsafecurdir.'")<cr>'
exe 'vnoremap <buffer> <silent> <rightmouse>  <leftmouse>:call <SID>NetrwLocalRm("'.mapsafecurdir.'")<cr>'
endif
exe 'nnoremap <buffer> <silent> <nowait> <del>	:call <SID>NetrwLocalRm("'.mapsafecurdir.'")<cr>'
exe 'nnoremap <buffer> <silent> <nowait> D		:call <SID>NetrwLocalRm("'.mapsafecurdir.'")<cr>'
exe 'nnoremap <buffer> <silent> <nowait> R		:call <SID>NetrwLocalRename("'.mapsafecurdir.'")<cr>'
exe 'nnoremap <buffer> <silent> <nowait> d		:call <SID>NetrwMakeDir("")<cr>'
exe 'vnoremap <buffer> <silent> <nowait> <del>	:call <SID>NetrwLocalRm("'.mapsafecurdir.'")<cr>'
exe 'vnoremap <buffer> <silent> <nowait> D		:call <SID>NetrwLocalRm("'.mapsafecurdir.'")<cr>'
exe 'vnoremap <buffer> <silent> <nowait> R		:call <SID>NetrwLocalRename("'.mapsafecurdir.'")<cr>'
nnoremap <buffer> <F1>			:he netrw-quickhelp<cr>
call netrw#UserMaps(1)
else " remote
call s:RemotePathAnalysis(b:netrw_curdir)
nnoremap <buffer> <silent> <nowait> a	:<c-u>call <SID>NetrwHide(0)<cr>
nnoremap <buffer> <silent> <nowait> -	:<c-u>call <SID>NetrwBrowseUpDir(0)<cr>
nnoremap <buffer> <silent> <nowait> %	:<c-u>call <SID>NetrwOpenFile(0)<cr>
nnoremap <buffer> <silent> <nowait> C	:<c-u>call <SID>NetrwSetChgwin()<cr>
nnoremap <buffer> <silent> <nowait> <c-l>	:<c-u>call <SID>NetrwRefresh(0,<SID>NetrwBrowseChgDir(0,'./'))<cr>
nnoremap <buffer> <silent> <nowait> <cr>	:<c-u>call <SID>NetrwBrowse(0,<SID>NetrwBrowseChgDir(0,<SID>NetrwGetWord()))<cr>
nnoremap <buffer> <silent> <nowait> <c-r>	:<c-u>call <SID>NetrwServerEdit(2,<SID>NetrwGetWord())<cr>
nnoremap <buffer> <silent> <nowait> gb	:<c-u>call <SID>NetrwBookHistHandler(1,b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> gd	:<c-u>call <SID>NetrwForceChgDir(0,<SID>NetrwGetWord())<cr>
nnoremap <buffer> <silent> <nowait> gf	:<c-u>call <SID>NetrwForceFile(0,<SID>NetrwGetWord())<cr>
nnoremap <buffer> <silent> <nowait> gh	:<c-u>call <SID>NetrwHidden(0)<cr>
nnoremap <buffer> <silent> <nowait> gp	:<c-u>call <SID>NetrwChgPerm(0,b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> I	:<c-u>call <SID>NetrwBannerCtrl(1)<cr>
nnoremap <buffer> <silent> <nowait> i	:<c-u>call <SID>NetrwListStyle(0)<cr>
nnoremap <buffer> <silent> <nowait> ma	:<c-u>call <SID>NetrwMarkFileArgList(0,0)<cr>
nnoremap <buffer> <silent> <nowait> mA	:<c-u>call <SID>NetrwMarkFileArgList(0,1)<cr>
nnoremap <buffer> <silent> <nowait> mb	:<c-u>call <SID>NetrwBookHistHandler(0,b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> mB	:<c-u>call <SID>NetrwBookHistHandler(6,b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> mc	:<c-u>call <SID>NetrwMarkFileCopy(0)<cr>
nnoremap <buffer> <silent> <nowait> md	:<c-u>call <SID>NetrwMarkFileDiff(0)<cr>
nnoremap <buffer> <silent> <nowait> me	:<c-u>call <SID>NetrwMarkFileEdit(0)<cr>
nnoremap <buffer> <silent> <nowait> mf	:<c-u>call <SID>NetrwMarkFile(0,<SID>NetrwGetWord())<cr>
nnoremap <buffer> <silent> <nowait> mF	:<c-u>call <SID>NetrwUnmarkList(bufnr("%"),b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> mg	:<c-u>call <SID>NetrwMarkFileGrep(0)<cr>
nnoremap <buffer> <silent> <nowait> mh	:<c-u>call <SID>NetrwMarkHideSfx(0)<cr>
nnoremap <buffer> <silent> <nowait> mm	:<c-u>call <SID>NetrwMarkFileMove(0)<cr>
nnoremap <buffer> <silent> <nowait> mp	:<c-u>call <SID>NetrwMarkFilePrint(0)<cr>
nnoremap <buffer> <silent> <nowait> mr	:<c-u>call <SID>NetrwMarkFileRegexp(0)<cr>
nnoremap <buffer> <silent> <nowait> ms	:<c-u>call <SID>NetrwMarkFileSource(0)<cr>
nnoremap <buffer> <silent> <nowait> mT	:<c-u>call <SID>NetrwMarkFileTag(0)<cr>
nnoremap <buffer> <silent> <nowait> mt	:<c-u>call <SID>NetrwMarkFileTgt(0)<cr>
nnoremap <buffer> <silent> <nowait> mu	:<c-u>call <SID>NetrwUnMarkFile(0)<cr>
nnoremap <buffer> <silent> <nowait> mv	:<c-u>call <SID>NetrwMarkFileVimCmd(0)<cr>
nnoremap <buffer> <silent> <nowait> mx	:<c-u>call <SID>NetrwMarkFileExe(0,0)<cr>
nnoremap <buffer> <silent> <nowait> mX	:<c-u>call <SID>NetrwMarkFileExe(0,1)<cr>
nnoremap <buffer> <silent> <nowait> mz	:<c-u>call <SID>NetrwMarkFileCompress(0)<cr>
nnoremap <buffer> <silent> <nowait> O	:<c-u>call <SID>NetrwObtain(0)<cr>
nnoremap <buffer> <silent> <nowait> o	:call <SID>NetrwSplit(0)<cr>
nnoremap <buffer> <silent> <nowait> p	:<c-u>call <SID>NetrwPreview(<SID>NetrwBrowseChgDir(1,<SID>NetrwGetWord(),1))<cr>
nnoremap <buffer> <silent> <nowait> P	:<c-u>call <SID>NetrwPrevWinOpen(0)<cr>
nnoremap <buffer> <silent> <nowait> qb	:<c-u>call <SID>NetrwBookHistHandler(2,b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> qf	:<c-u>call <SID>NetrwFileInfo(0,<SID>NetrwGetWord())<cr>
nnoremap <buffer> <silent> <nowait> qF	:<c-u>call <SID>NetrwMarkFileQFEL(0,getqflist())<cr>
nnoremap <buffer> <silent> <nowait> qL	:<c-u>call <SID>NetrwMarkFileQFEL(0,getloclist(v:count))<cr>
nnoremap <buffer> <silent> <nowait> r	:<c-u>let g:netrw_sort_direction= (g:netrw_sort_direction =~# 'n')? 'r' : 'n'<bar>exe "norm! 0"<bar>call <SID>NetrwBrowse(0,<SID>NetrwBrowseChgDir(0,'./'))<cr>
nnoremap <buffer> <silent> <nowait> s	:call <SID>NetrwSortStyle(0)<cr>
nnoremap <buffer> <silent> <nowait> S	:<c-u>call <SID>NetSortSequence(0)<cr>
nnoremap <buffer> <silent> <nowait> Tb	:<c-u>call <SID>NetrwSetTgt(0,'b',v:count1)<cr>
nnoremap <buffer> <silent> <nowait> t	:call <SID>NetrwSplit(1)<cr>
nnoremap <buffer> <silent> <nowait> Th	:<c-u>call <SID>NetrwSetTgt(0,'h',v:count)<cr>
nnoremap <buffer> <silent> <nowait> u	:<c-u>call <SID>NetrwBookHistHandler(4,b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> U	:<c-u>call <SID>NetrwBookHistHandler(5,b:netrw_curdir)<cr>
nnoremap <buffer> <silent> <nowait> v	:call <SID>NetrwSplit(2)<cr>
nnoremap <buffer> <silent> <nowait> x	:<c-u>call netrw#BrowseX(<SID>NetrwBrowseChgDir(0,<SID>NetrwGetWord()),1)<cr>
if !hasmapto('<Plug>NetrwHideEdit')
nmap <buffer> <c-h> <Plug>NetrwHideEdit
endif
nnoremap <buffer> <silent> <Plug>NetrwHideEdit	:call <SID>NetrwHideEdit(0)<cr>
if !hasmapto('<Plug>NetrwRefresh')
nmap <buffer> <c-l> <Plug>NetrwRefresh
endif
if !hasmapto('<Plug>NetrwTreeSqueeze')
nmap <buffer> <silent> <nowait> <s-cr>	<Plug>NetrwTreeSqueeze
endif
nnoremap <buffer> <silent> <Plug>NetrwTreeSqueeze	:call <SID>TreeSqueezeDir(0)<cr>
let mapsafepath     = escape(s:path, s:netrw_map_escape)
let mapsafeusermach = escape(((s:user == "")? "" : s:user."@").s:machine, s:netrw_map_escape)
nnoremap <buffer> <silent> <Plug>NetrwRefresh	:call <SID>NetrwRefresh(0,<SID>NetrwBrowseChgDir(0,'./'))<cr>
if g:netrw_mousemaps == 1
nmap <buffer> <leftmouse>		<Plug>NetrwLeftmouse
nno  <buffer> <silent>		<Plug>NetrwLeftmouse	<leftmouse>:call <SID>NetrwLeftmouse(0)<cr>
nmap <buffer> <c-leftmouse>		<Plug>NetrwCLeftmouse
nno  <buffer> <silent>		<Plug>NetrwCLeftmouse	<leftmouse>:call <SID>NetrwCLeftmouse(0)<cr>
nmap <buffer> <s-leftmouse>		<Plug>NetrwSLeftmouse
nno  <buffer> <silent>		<Plug>NetrwSLeftmouse 	<leftmouse>:call <SID>NetrwSLeftmouse(0)<cr>
nmap <buffer> <s-leftdrag>		<Plug>NetrwSLeftdrag
nno  <buffer> <silent>		<Plug>NetrwSLeftdrag	<leftmouse>:call <SID>NetrwSLeftdrag(0)<cr>
nmap <middlemouse>			<Plug>NetrwMiddlemouse
nno  <buffer> <silent>		<middlemouse>		<Plug>NetrwMiddlemouse <leftmouse>:call <SID>NetrwPrevWinOpen(0)<cr>
nmap <buffer> <2-leftmouse>		<Plug>Netrw2Leftmouse
nmap <buffer> <silent>		<Plug>Netrw2Leftmouse	-
imap <buffer> <leftmouse>		<Plug>ILeftmouse
imap <buffer> <middlemouse>		<Plug>IMiddlemouse
imap <buffer> <s-leftmouse>		<Plug>ISLeftmouse
exe 'nnoremap <buffer> <silent> <rightmouse> <leftmouse>:call <SID>NetrwRemoteRm("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
exe 'vnoremap <buffer> <silent> <rightmouse> <leftmouse>:call <SID>NetrwRemoteRm("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
endif
exe 'nnoremap <buffer> <silent> <nowait> <del>	:call <SID>NetrwRemoteRm("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
exe 'nnoremap <buffer> <silent> <nowait> d		:call <SID>NetrwMakeDir("'.mapsafeusermach.'")<cr>'
exe 'nnoremap <buffer> <silent> <nowait> D		:call <SID>NetrwRemoteRm("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
exe 'nnoremap <buffer> <silent> <nowait> R		:call <SID>NetrwRemoteRename("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
exe 'vnoremap <buffer> <silent> <nowait> <del>	:call <SID>NetrwRemoteRm("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
exe 'vnoremap <buffer> <silent> <nowait> D		:call <SID>NetrwRemoteRm("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
exe 'vnoremap <buffer> <silent> <nowait> R		:call <SID>NetrwRemoteRename("'.mapsafeusermach.'","'.mapsafepath.'")<cr>'
nnoremap <buffer> <F1>			:he netrw-quickhelp<cr>
call netrw#UserMaps(0)
endif
endfun
fun! s:NetrwCommands(islocal)
com! -nargs=* -complete=file -bang	NetrwMB	call s:NetrwBookmark(<bang>0,<f-args>)
com! -nargs=*			    	NetrwC	call s:NetrwSetChgwin(<q-args>)
com! Rexplore if exists("w:netrw_rexlocal")|call s:NetrwRexplore(w:netrw_rexlocal,exists("w:netrw_rexdir")? w:netrw_rexdir : ".")|else|call netrw#ErrorMsg(s:WARNING,"win#".winnr()." not a former netrw window",79)|endif
if a:islocal
com! -buffer -nargs=+ -complete=file	MF	call s:NetrwMarkFiles(1,<f-args>)
else
com! -buffer -nargs=+ -complete=file	MF	call s:NetrwMarkFiles(0,<f-args>)
endif
com! -buffer -nargs=? -complete=file	MT	call s:NetrwMarkTarget(<q-args>)
endfun
fun! s:NetrwMarkFiles(islocal,...)
let curdir = s:NetrwGetCurdir(a:islocal)
let i      = 1
while i <= a:0
if a:islocal
if v:version > 704 || (v:version == 704 && has("patch656"))
let mffiles= glob(fnameescape(a:{i}),0,1,1)
else
let mffiles= glob(fnameescape(a:{i}),0,1)
endif
else
let mffiles= [a:{i}]
endif
for mffile in mffiles
call s:NetrwMarkFile(a:islocal,mffile)
endfor
let i= i + 1
endwhile
endfun
fun! s:NetrwMarkTarget(...)
if a:0 == 0 || (a:0 == 1 && a:1 == "")
let curdir = s:NetrwGetCurdir(1)
let tgt    = b:netrw_curdir
else
let curdir = s:NetrwGetCurdir((a:1 =~ '^\a\{3,}://')? 0 : 1)
let tgt    = a:1
endif
let s:netrwmftgt         = tgt
let s:netrwmftgt_islocal = tgt !~ '^\a\{3,}://'
let curislocal           = b:netrw_curdir !~ '^\a\{3,}://'
let svpos                = winsaveview()
call s:NetrwRefresh(curislocal,s:NetrwBrowseChgDir(curislocal,'./'))
call winrestview(svpos)
endfun
fun! s:NetrwMarkFile(islocal,fname)
if empty(a:fname)
return
endif
let curdir = s:NetrwGetCurdir(a:islocal)
let ykeep   = @@
let curbufnr= bufnr("%")
if a:fname =~ '^\a'
let leader= '\<'
else
let leader= ''
endif
if a:fname =~ '\a$'
let trailer = '\>[@=|\/\*]\=\ze\%(  \|\t\|$\)'
else
let trailer = '[@=|\/\*]\=\ze\%(  \|\t\|$\)'
endif
if exists("s:netrwmarkfilelist_".curbufnr)
let b:netrw_islocal= a:islocal
if index(s:netrwmarkfilelist_{curbufnr},a:fname) == -1
call add(s:netrwmarkfilelist_{curbufnr},a:fname)
let s:netrwmarkfilemtch_{curbufnr}= s:netrwmarkfilemtch_{curbufnr}.'\|'.leader.escape(a:fname,g:netrw_markfileesc).trailer
else
call filter(s:netrwmarkfilelist_{curbufnr},'v:val != a:fname')
if s:netrwmarkfilelist_{curbufnr} == []
call s:NetrwUnmarkList(curbufnr,curdir)
else
let s:netrwmarkfilemtch_{curbufnr}= ""
let first                         = 1
for fname in s:netrwmarkfilelist_{curbufnr}
if first
let s:netrwmarkfilemtch_{curbufnr}= s:netrwmarkfilemtch_{curbufnr}.leader.escape(fname,g:netrw_markfileesc).trailer
else
let s:netrwmarkfilemtch_{curbufnr}= s:netrwmarkfilemtch_{curbufnr}.'\|'.leader.escape(fname,g:netrw_markfileesc).trailer
endif
let first= 0
endfor
endif
endif
else
let s:netrwmarkfilelist_{curbufnr}= []
call add(s:netrwmarkfilelist_{curbufnr},substitute(a:fname,'[|@]$','',''))
if a:fname =~ '/$'
let s:netrwmarkfilemtch_{curbufnr}= leader.escape(a:fname,g:netrw_markfileesc)
else
let s:netrwmarkfilemtch_{curbufnr}= leader.escape(a:fname,g:netrw_markfileesc).trailer
endif
endif
if exists("s:netrwmarkfilelist")
let dname= s:ComposePath(b:netrw_curdir,a:fname)
if index(s:netrwmarkfilelist,dname) == -1
call add(s:netrwmarkfilelist,s:ComposePath(b:netrw_curdir,a:fname))
else
call filter(s:netrwmarkfilelist,'v:val != "'.dname.'"')
if s:netrwmarkfilelist == []
unlet s:netrwmarkfilelist
endif
endif
else
let s:netrwmarkfilelist= []
call add(s:netrwmarkfilelist,s:ComposePath(b:netrw_curdir,a:fname))
endif
if exists("s:netrwmarkfilemtch_{curbufnr}") && s:netrwmarkfilemtch_{curbufnr} != ""
if exists("g:did_drchip_netrwlist_syntax")
exe "2match netrwMarkFile /".s:netrwmarkfilemtch_{curbufnr}."/"
endif
else
2match none
endif
let @@= ykeep
endfun
fun! s:NetrwMarkFileArgList(islocal,tomflist)
let svpos    = winsaveview()
let curdir   = s:NetrwGetCurdir(a:islocal)
let curbufnr = bufnr("%")
if a:tomflist
while argc()
let fname= argv(0)
exe "argdel ".fnameescape(fname)
call s:NetrwMarkFile(a:islocal,fname)
endwhile
else
if exists("s:netrwmarkfilelist")
for fname in s:netrwmarkfilelist
exe "argadd ".fnameescape(fname)
endfor	" for every file in the marked list
call s:NetrwUnmarkList(curbufnr,curdir)
NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
NetrwKeepj call winrestview(svpos)
endif
endif
endfun
fun! s:NetrwMarkFileCompress(islocal)
let svpos    = winsaveview()
let curdir   = s:NetrwGetCurdir(a:islocal)
let curbufnr = bufnr("%")
if !exists("s:netrwmarkfilelist_{curbufnr}") || empty(s:netrwmarkfilelist_{curbufnr})
NetrwKeepj call netrw#ErrorMsg(2,"there are no marked files in this window (:help netrw-mf)",66)
return
endif
if exists("s:netrwmarkfilelist_{curbufnr}") && exists("g:netrw_compress") && exists("g:netrw_decompress")
for fname in s:netrwmarkfilelist_{curbufnr}
let sfx= substitute(fname,'^.\{-}\(\.\a\+\)$','\1','')
if exists("g:netrw_decompress['".sfx."']")
let exe= g:netrw_decompress[sfx]
let exe= netrw#WinPath(exe)
if a:islocal
if g:netrw_keepdir
let fname= s:ShellEscape(s:ComposePath(curdir,fname))
endif
else
let fname= s:ShellEscape(b:netrw_curdir.fname,1)
endif
if executable(exe)
if a:islocal
call system(exe." ".fname)
else
NetrwKeepj call s:RemoteSystem(exe." ".fname)
endif
else
NetrwKeepj call netrw#ErrorMsg(s:WARNING,"unable to apply<".exe."> to file<".fname.">",50)
endif
endif
unlet sfx
if exists("exe")
unlet exe
elseif a:islocal
call system(netrw#WinPath(g:netrw_compress)." ".s:ShellEscape(s:ComposePath(b:netrw_curdir,fname)))
else
NetrwKeepj call s:RemoteSystem(netrw#WinPath(g:netrw_compress)." ".s:ShellEscape(fname))
endif
endfor	" for every file in the marked list
call s:NetrwUnmarkList(curbufnr,curdir)
NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
NetrwKeepj call winrestview(svpos)
endif
endfun
fun! s:NetrwMarkFileCopy(islocal,...)
let curdir   = s:NetrwGetCurdir(a:islocal)
let curbufnr = bufnr("%")
if b:netrw_curdir !~ '/$'
if !exists("b:netrw_curdir")
let b:netrw_curdir= curdir
endif
let b:netrw_curdir= b:netrw_curdir."/"
endif
if !exists("s:netrwmarkfilelist_{curbufnr}") || empty(s:netrwmarkfilelist_{curbufnr})
NetrwKeepj call netrw#ErrorMsg(2,"there are no marked files in this window (:help netrw-mf)",66)
return
endif
if !exists("s:netrwmftgt")
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"your marked file target is empty! (:help netrw-mt)",67)
return 0
endif
if a:islocal &&  s:netrwmftgt_islocal
if !executable(g:netrw_localcopycmd) && g:netrw_localcopycmd !~ '^'.expand("$COMSPEC").'\s'
call netrw#ErrorMsg(s:ERROR,"g:netrw_localcopycmd<".g:netrw_localcopycmd."> not executable on your system, aborting",91)
return
endif
if simplify(s:netrwmftgt) == simplify(b:netrw_curdir)
if len(s:netrwmarkfilelist_{bufnr('%')}) == 1
let args    = s:ShellEscape(b:netrw_curdir.s:netrwmarkfilelist_{bufnr('%')}[0])
let oldname = s:netrwmarkfilelist_{bufnr('%')}[0]
elseif a:0 == 1
let args    = s:ShellEscape(b:netrw_curdir.a:1)
let oldname = a:1
else
let s:recursive= 1
for oldname in s:netrwmarkfilelist_{bufnr("%")}
let ret= s:NetrwMarkFileCopy(a:islocal,oldname)
if ret == 0
break
endif
endfor
unlet s:recursive
call s:NetrwUnmarkList(curbufnr,curdir)
return ret
endif
call inputsave()
let newname= input("Copy ".oldname." to : ",oldname,"file")
call inputrestore()
if newname == ""
return 0
endif
let args= s:ShellEscape(oldname)
let tgt = s:ShellEscape(s:netrwmftgt.'/'.newname)
else
let args= join(map(deepcopy(s:netrwmarkfilelist_{bufnr('%')}),"s:ShellEscape(b:netrw_curdir.\"/\".v:val)"))
let tgt = s:ShellEscape(s:netrwmftgt)
endif
if !g:netrw_cygwin && (has("win32") || has("win95") || has("win64") || has("win16"))
let args= substitute(args,'/','\\','g')
let tgt = substitute(tgt, '/','\\','g')
endif
if args =~ "'" |let args= substitute(args,"'\\(.*\\)'",'\1','')|endif
if tgt  =~ "'" |let tgt = substitute(tgt ,"'\\(.*\\)'",'\1','')|endif
if args =~ '//'|let args= substitute(args,'//','/','g')|endif
if tgt  =~ '//'|let tgt = substitute(tgt ,'//','/','g')|endif
if isdirectory(s:NetrwFile(args))
let copycmd= g:netrw_localcopydircmd
if !g:netrw_cygwin && (has("win32") || has("win95") || has("win64") || has("win16"))
let tgt= tgt.'\'.substitute(a:1,'^.*[\\/]','','')
endif
else
let copycmd= g:netrw_localcopycmd
endif
if g:netrw_localcopycmd =~ '\s'
let copycmd     = substitute(copycmd,'\s.*$','','')
let copycmdargs = substitute(copycmd,'^.\{-}\(\s.*\)$','\1','')
let copycmd     = netrw#WinPath(copycmd).copycmdargs
else
let copycmd = netrw#WinPath(copycmd)
endif
call system(copycmd." '".args."' '".tgt."'")
if v:shell_error != 0
if exists("b:netrw_curdir") && b:netrw_curdir != getcwd() && !g:netrw_keepdir
call netrw#ErrorMsg(s:ERROR,"copy failed; perhaps due to vim's current directory<".getcwd()."> not matching netrw's (".b:netrw_curdir.") (see :help netrw-c)",101)
else
call netrw#ErrorMsg(s:ERROR,"tried using g:netrw_localcopycmd<".g:netrw_localcopycmd.">; it doesn't work!",80)
endif
return 0
endif
elseif  a:islocal && !s:netrwmftgt_islocal
NetrwKeepj call s:NetrwUpload(s:netrwmarkfilelist_{bufnr('%')},s:netrwmftgt)
elseif !a:islocal &&  s:netrwmftgt_islocal
NetrwKeepj call netrw#Obtain(a:islocal,s:netrwmarkfilelist_{bufnr('%')},s:netrwmftgt)
elseif !a:islocal && !s:netrwmftgt_islocal
let curdir = getcwd()
let tmpdir = s:GetTempfile("")
if tmpdir !~ '/'
let tmpdir= curdir."/".tmpdir
endif
if exists("*mkdir")
call mkdir(tmpdir)
else
call s:NetrwExe("sil! !".g:netrw_localmkdir.' '.s:ShellEscape(tmpdir,1))
if v:shell_error != 0
call netrw#ErrorMsg(s:WARNING,"consider setting g:netrw_localmkdir<".g:netrw_localmkdir."> to something that works",80)
return
endif
endif
if isdirectory(s:NetrwFile(tmpdir))
call s:NetrwLcd(tmpdir)
NetrwKeepj call netrw#Obtain(a:islocal,s:netrwmarkfilelist_{bufnr('%')},tmpdir)
let localfiles= map(deepcopy(s:netrwmarkfilelist_{bufnr('%')}),'substitute(v:val,"^.*/","","")')
NetrwKeepj call s:NetrwUpload(localfiles,s:netrwmftgt)
if getcwd() == tmpdir
for fname in s:netrwmarkfilelist_{bufnr('%')}
NetrwKeepj call s:NetrwDelete(fname)
endfor
call s:NetrwLcd(curdir)
if v:version < 704 || !has("patch1109")
call s:NetrwExe("sil !".g:netrw_localrmdir." ".s:ShellEscape(tmpdir,1))
if v:shell_error != 0
call netrw#ErrorMsg(s:WARNING,"consider setting g:netrw_localrmdir<".g:netrw_localrmdir."> to something that works",80)
return
endif
else
if delete(tmpdir,"d")
call netrw#ErrorMsg(s:ERROR,"unable to delete directory <".tmpdir.">!",103)
endif
endif
else
call s:NetrwLcd(curdir)
endif
endif
endif
call s:NetrwUnmarkList(curbufnr,curdir)                   " remove markings from local buffer
if exists("s:recursive")
else
endif
if g:netrw_fastbrowse <= 1
NetrwKeepj call s:LocalBrowseRefresh()
else
if !exists("s:recursive")
NetrwKeepj call s:NetrwUnmarkList(curbufnr,curdir)
endif
if s:netrwmftgt_islocal
NetrwKeepj call s:NetrwRefreshDir(s:netrwmftgt_islocal,s:netrwmftgt)
endif
if a:islocal && s:netrwmftgt != curdir
NetrwKeepj call s:NetrwRefreshDir(a:islocal,curdir)
endif
endif
return 1
endfun
fun! s:NetrwMarkFileDiff(islocal)
let curbufnr= bufnr("%")
if !exists("s:netrwmarkfilelist_{curbufnr}") || empty(s:netrwmarkfilelist_{curbufnr})
NetrwKeepj call netrw#ErrorMsg(2,"there are no marked files in this window (:help netrw-mf)",66)
return
endif
let curdir= s:NetrwGetCurdir(a:islocal)
if exists("s:netrwmarkfilelist_{".curbufnr."}")
let cnt    = 0
for fname in s:netrwmarkfilelist
let cnt= cnt + 1
if cnt == 1
exe "NetrwKeepj e ".fnameescape(fname)
diffthis
elseif cnt == 2 || cnt == 3
vsplit
wincmd l
exe "NetrwKeepj e ".fnameescape(fname)
diffthis
else
break
endif
endfor
call s:NetrwUnmarkList(curbufnr,curdir)
endif
endfun
fun! s:NetrwMarkFileEdit(islocal)
let curdir   = s:NetrwGetCurdir(a:islocal)
let curbufnr = bufnr("%")
if !exists("s:netrwmarkfilelist_{curbufnr}") || empty(s:netrwmarkfilelist_{curbufnr})
NetrwKeepj call netrw#ErrorMsg(2,"there are no marked files in this window (:help netrw-mf)",66)
return
endif
if exists("s:netrwmarkfilelist_{curbufnr}")
call s:SetRexDir(a:islocal,curdir)
let flist= join(map(deepcopy(s:netrwmarkfilelist), "fnameescape(v:val)"))
call s:NetrwUnmarkAll()
exe "sil args ".flist
endif
echo "(use :bn, :bp to navigate files; :Rex to return)"
endfun
fun! s:NetrwMarkFileQFEL(islocal,qfel)
call s:NetrwUnmarkAll()
let curbufnr= bufnr("%")
if !empty(a:qfel)
for entry in a:qfel
let bufnmbr= entry["bufnr"]
if !exists("s:netrwmarkfilelist_{curbufnr}")
call s:NetrwMarkFile(a:islocal,bufname(bufnmbr))
elseif index(s:netrwmarkfilelist_{curbufnr},bufname(bufnmbr)) == -1
call s:NetrwMarkFile(a:islocal,bufname(bufnmbr))
else
endif
endfor
echo "(use me to edit marked files)"
else
call netrw#ErrorMsg(s:WARNING,"can't convert quickfix error list; its empty!",92)
endif
endfun
fun! s:NetrwMarkFileExe(islocal,enbloc)
let svpos    = winsaveview()
let curdir   = s:NetrwGetCurdir(a:islocal)
let curbufnr = bufnr("%")
if a:enbloc == 0
if !exists("s:netrwmarkfilelist_{curbufnr}") || empty(s:netrwmarkfilelist_{curbufnr})
NetrwKeepj call netrw#ErrorMsg(2,"there are no marked files in this window (:help netrw-mf)",66)
return
endif
if exists("s:netrwmarkfilelist_{curbufnr}")
call inputsave()
let cmd= input("Enter command: ","","file")
call inputrestore()
if cmd == ""
return
endif
for fname in s:netrwmarkfilelist_{curbufnr}
if a:islocal
if g:netrw_keepdir
let fname= s:ShellEscape(netrw#WinPath(s:ComposePath(curdir,fname)))
endif
else
let fname= s:ShellEscape(netrw#WinPath(b:netrw_curdir.fname))
endif
if cmd =~ '%'
let xcmd= substitute(cmd,'%',fname,'g')
else
let xcmd= cmd.' '.fname
endif
if a:islocal
let ret= system(xcmd)
else
let ret= s:RemoteSystem(xcmd)
endif
if v:shell_error < 0
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"command<".xcmd."> failed, aborting",54)
break
else
echo ret
endif
endfor
call s:NetrwUnmarkList(curbufnr,curdir)
NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
NetrwKeepj call winrestview(svpos)
else
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"no files marked!",59)
endif
else " apply command to global list of files, en bloc
call inputsave()
let cmd= input("Enter command: ","","file")
call inputrestore()
if cmd == ""
return
endif
if cmd =~ '%'
let cmd= substitute(cmd,'%',join(map(s:netrwmarkfilelist,'s:ShellEscape(v:val)'),' '),'g')
else
let cmd= cmd.' '.join(map(s:netrwmarkfilelist,'s:ShellEscape(v:val)'),' ')
endif
if a:islocal
call system(cmd)
if v:shell_error < 0
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"command<".xcmd."> failed, aborting",54)
endif
else
let ret= s:RemoteSystem(cmd)
endif
call s:NetrwUnmarkAll()
NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
NetrwKeepj call winrestview(svpos)
endif
endfun
fun! s:NetrwMarkHideSfx(islocal)
let svpos    = winsaveview()
let curbufnr = bufnr("%")
if exists("s:netrwmarkfilelist_{curbufnr}")
for fname in s:netrwmarkfilelist_{curbufnr}
if fname =~ '\.'
let sfxpat= "^.*".substitute(fname,'^.*\(\.[^. ]\+\)$','\1','')
else
let sfxpat= '^\%(\%(\.\)\@!.\)*$'
endif
let inhidelist= 0
if g:netrw_list_hide != ""
let itemnum = 0
let hidelist= split(g:netrw_list_hide,',')
for hidepat in hidelist
if sfxpat == hidepat
let inhidelist= 1
break
endif
let itemnum= itemnum + 1
endfor
endif
if inhidelist
call remove(hidelist,itemnum)
let g:netrw_list_hide= join(hidelist,",")
elseif g:netrw_list_hide != ""
let g:netrw_list_hide= g:netrw_list_hide.",".sfxpat
else
let g:netrw_list_hide= sfxpat
endif
endfor
NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
NetrwKeepj call winrestview(svpos)
else
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"no files marked!",59)
endif
endfun
fun! s:NetrwMarkFileVimCmd(islocal)
let svpos    = winsaveview()
let curdir   = s:NetrwGetCurdir(a:islocal)
let curbufnr = bufnr("%")
if !exists("s:netrwmarkfilelist_{curbufnr}") || empty(s:netrwmarkfilelist_{curbufnr})
NetrwKeepj call netrw#ErrorMsg(2,"there are no marked files in this window (:help netrw-mf)",66)
return
endif
if exists("s:netrwmarkfilelist_{curbufnr}")
call inputsave()
let cmd= input("Enter vim command: ","","file")
call inputrestore()
if cmd == ""
return
endif
for fname in s:netrwmarkfilelist_{curbufnr}
if a:islocal
1split
exe "sil! NetrwKeepj keepalt e ".fnameescape(fname)
exe cmd
exe "sil! keepalt wq!"
else
echo "sorry, \"mv\" not supported yet for remote files"
endif
endfor
call s:NetrwUnmarkList(curbufnr,curdir)
NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
NetrwKeepj call winrestview(svpos)
else
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"no files marked!",59)
endif
endfun
fun! s:NetrwMarkHideSfx(islocal)
let svpos    = winsaveview()
let curbufnr = bufnr("%")
if exists("s:netrwmarkfilelist_{curbufnr}")
for fname in s:netrwmarkfilelist_{curbufnr}
if fname =~ '\.'
let sfxpat= "^.*".substitute(fname,'^.*\(\.[^. ]\+\)$','\1','')
else
let sfxpat= '^\%(\%(\.\)\@!.\)*$'
endif
let inhidelist= 0
if g:netrw_list_hide != ""
let itemnum = 0
let hidelist= split(g:netrw_list_hide,',')
for hidepat in hidelist
if sfxpat == hidepat
let inhidelist= 1
break
endif
let itemnum= itemnum + 1
endfor
endif
if inhidelist
call remove(hidelist,itemnum)
let g:netrw_list_hide= join(hidelist,",")
elseif g:netrw_list_hide != ""
let g:netrw_list_hide= g:netrw_list_hide.",".sfxpat
else
let g:netrw_list_hide= sfxpat
endif
endfor
NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
NetrwKeepj call winrestview(svpos)
else
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"no files marked!",59)
endif
endfun
fun! s:NetrwMarkFileGrep(islocal)
let svpos    = winsaveview()
let curbufnr = bufnr("%")
let curdir   = s:NetrwGetCurdir(a:islocal)
if exists("s:netrwmarkfilelist")
let netrwmarkfilelist= join(map(deepcopy(s:netrwmarkfilelist), "fnameescape(v:val)"))
call s:NetrwUnmarkAll()
else
let netrwmarkfilelist= "*"
endif
call inputsave()
let pat= input("Enter pattern: ","")
call inputrestore()
let patbang = ""
if pat =~ '^!'
let patbang = "!"
let pat     = strpart(pat,2)
endif
if pat =~ '^\i'
let pat    = escape(pat,'/')
let pat    = '/'.pat.'/'
else
let nonisi = pat[0]
endif
try
exe "NetrwKeepj noautocmd vimgrep".patbang." ".pat." ".netrwmarkfilelist
catch /^Vim\%((\a\+)\)\=:E480/
NetrwKeepj call netrw#ErrorMsg(s:WARNING,"no match with pattern<".pat.">",76)
return
endtry
echo "(use :cn, :cp to navigate, :Rex to return)"
2match none
NetrwKeepj call winrestview(svpos)
if exists("nonisi")
if pat =~# nonisi.'j$\|'.nonisi.'gj$\|'.nonisi.'jg$'
call s:NetrwMarkFileQFEL(a:islocal,getqflist())
endif
endif
endfun
fun! s:NetrwMarkFileMove(islocal)
let curdir   = s:NetrwGetCurdir(a:islocal)
let curbufnr = bufnr("%")
if !exists("s:netrwmarkfilelist_{curbufnr}") || empty(s:netrwmarkfilelist_{curbufnr})
NetrwKeepj call netrw#ErrorMsg(2,"there are no marked files in this window (:help netrw-mf)",66)
return
endif
if !exists("s:netrwmftgt")
NetrwKeepj call netrw#ErrorMsg(2,"your marked file target is empty! (:help netrw-mt)",67)
return 0
endif
if      a:islocal &&  s:netrwmftgt_islocal
if !executable(g:netrw_localmovecmd) && g:netrw_localmovecmd !~ '^'.expand("$COMSPEC").'\s'
call netrw#ErrorMsg(s:ERROR,"g:netrw_localmovecmd<".g:netrw_localmovecmd."> not executable on your system, aborting",90)
return
endif
let tgt         = s:ShellEscape(s:netrwmftgt)
if !g:netrw_cygwin && (has("win32") || has("win95") || has("win64") || has("win16"))
let tgt         = substitute(tgt, '/','\\','g')
if g:netrw_localmovecmd =~ '\s'
let movecmd     = substitute(g:netrw_localmovecmd,'\s.*$','','')
let movecmdargs = substitute(g:netrw_localmovecmd,'^.\{-}\(\s.*\)$','\1','')
let movecmd     = netrw#WinPath(movecmd).movecmdargs
else
let movecmd = netrw#WinPath(movecmd)
endif
else
let movecmd = netrw#WinPath(g:netrw_localmovecmd)
endif
for fname in s:netrwmarkfilelist_{bufnr("%")}
if !g:netrw_cygwin && (has("win32") || has("win95") || has("win64") || has("win16"))
let fname= substitute(fname,'/','\\','g')
endif
let ret= system(movecmd." ".s:ShellEscape(fname)." ".tgt)
if v:shell_error != 0
if exists("b:netrw_curdir") && b:netrw_curdir != getcwd() && !g:netrw_keepdir
call netrw#ErrorMsg(s:ERROR,"move failed; perhaps due to vim's current directory<".getcwd()."> not matching netrw's (".b:netrw_curdir.") (see :help netrw-c)",100)
else
call netrw#ErrorMsg(s:ERROR,"tried using g:netrw_localmovecmd<".g:netrw_localmovecmd.">; it doesn't work!",54)
endif
break
endif
endfor
elseif  a:islocal && !s:netrwmftgt_islocal
let mflist= s:netrwmarkfilelist_{bufnr("%")}
NetrwKeepj call s:NetrwMarkFileCopy(a:islocal)
for fname in mflist
let barefname = substitute(fname,'^\(.*/\)\(.\{-}\)$','\2','')
let ok        = s:NetrwLocalRmFile(b:netrw_curdir,barefname,1)
endfor
unlet mflist
elseif !a:islocal &&  s:netrwmftgt_islocal
let mflist= s:netrwmarkfilelist_{bufnr("%")}
NetrwKeepj call s:NetrwMarkFileCopy(a:islocal)
for fname in mflist
let barefname = substitute(fname,'^\(.*/\)\(.\{-}\)$','\2','')
let ok        = s:NetrwRemoteRmFile(b:netrw_curdir,barefname,1)
endfor
unlet mflist
elseif !a:islocal && !s:netrwmftgt_islocal
let mflist= s:netrwmarkfilelist_{bufnr("%")}
NetrwKeepj call s:NetrwMarkFileCopy(a:islocal)
for fname in mflist
let barefname = substitute(fname,'^\(.*/\)\(.\{-}\)$','\2','')
let ok        = s:NetrwRemoteRmFile(b:netrw_curdir,barefname,1)
endfor
unlet mflist
endif
call s:NetrwUnmarkList(curbufnr,curdir)                   " remove markings from local buffer
if !s:netrwmftgt_islocal
NetrwKeepj call s:NetrwRefreshDir(s:netrwmftgt_islocal,s:netrwmftgt)
endif
if a:islocal
NetrwKeepj call s:NetrwRefreshDir(a:islocal,b:netrw_curdir)
endif
if g:netrw_fastbrowse <= 1
NetrwKeepj call s:LocalBrowseRefresh()
endif
endfun
fun! s:NetrwMarkFilePrint(islocal)
let curbufnr= bufnr("%")
if !exists("s:netrwmarkfilelist_{curbufnr}") || empty(s:netrwmarkfilelist_{curbufnr})
NetrwKeepj call netrw#ErrorMsg(2,"there are no marked files in this window (:help netrw-mf)",66)
return
endif
let curdir= s:NetrwGetCurdir(a:islocal)
if exists("s:netrwmarkfilelist_{curbufnr}")
let netrwmarkfilelist = s:netrwmarkfilelist_{curbufnr}
call s:NetrwUnmarkList(curbufnr,curdir)
for fname in netrwmarkfilelist
if a:islocal
if g:netrw_keepdir
let fname= s:ComposePath(curdir,fname)
endif
else
let fname= curdir.fname
endif
1split
exe "sil NetrwKeepj e ".fnameescape(fname)
hardcopy
q
endfor
2match none
endif
endfun
fun! s:NetrwMarkFileRegexp(islocal)
call inputsave()
let regexp= input("Enter regexp: ","","file")
call inputrestore()
if a:islocal
let curdir= s:NetrwGetCurdir(a:islocal)
let dirname = escape(b:netrw_curdir,g:netrw_glob_escape)
if v:version > 704 || (v:version == 704 && has("patch656"))
let files   = glob(s:ComposePath(dirname,regexp),0,0,1)
else
let files   = glob(s:ComposePath(dirname,regexp),0,0)
endif
let filelist= split(files,"\n")
for fname in filelist
NetrwKeepj call s:NetrwMarkFile(a:islocal,substitute(fname,'^.*/','',''))
endfor
else
let eikeep = &ei
let areg   = @a
sil NetrwKeepj %y a
setl ei=all ma
1split
NetrwKeepj call s:NetrwEnew()
NetrwKeepj call s:NetrwSafeOptions()
sil NetrwKeepj norm! "ap
NetrwKeepj 2
let bannercnt= search('^" =====','W')
exe "sil NetrwKeepj 1,".bannercnt."d"
setl bt=nofile
if     g:netrw_liststyle == s:LONGLIST
sil NetrwKeepj %s/\s\{2,}\S.*$//e
call histdel("/",-1)
elseif g:netrw_liststyle == s:WIDELIST
sil NetrwKeepj %s/\s\{2,}/\r/ge
call histdel("/",-1)
elseif g:netrw_liststyle == s:TREELIST
exe 'sil NetrwKeepj %s/^'.s:treedepthstring.' //e'
sil! NetrwKeepj g/^ .*$/d
call histdel("/",-1)
call histdel("/",-1)
endif
let regexp= substitute(regexp,'\*','.*','g')
exe "sil! NetrwKeepj v/".escape(regexp,'/')."/d"
call histdel("/",-1)
let filelist= getline(1,line("$"))
q!
for filename in filelist
NetrwKeepj call s:NetrwMarkFile(a:islocal,substitute(filename,'^.*/','',''))
endfor
unlet filelist
let @a  = areg
let &ei = eikeep
endif
echo "  (use me to edit marked files)"
endfun
fun! s:NetrwMarkFileSource(islocal)
let curbufnr= bufnr("%")
if !exists("s:netrwmarkfilelist_{curbufnr}") || empty(s:netrwmarkfilelist_{curbufnr})
NetrwKeepj call netrw#ErrorMsg(2,"there are no marked files in this window (:help netrw-mf)",66)
return
endif
let curdir= s:NetrwGetCurdir(a:islocal)
if exists("s:netrwmarkfilelist_{curbufnr}")
let netrwmarkfilelist = s:netrwmarkfilelist_{bufnr("%")}
call s:NetrwUnmarkList(curbufnr,curdir)
for fname in netrwmarkfilelist
if a:islocal
if g:netrw_keepdir
let fname= s:ComposePath(curdir,fname)
endif
else
let fname= curdir.fname
endif
exe "so ".fnameescape(fname)
endfor
2match none
endif
endfun
fun! s:NetrwMarkFileTag(islocal)
let svpos    = winsaveview()
let curdir   = s:NetrwGetCurdir(a:islocal)
let curbufnr = bufnr("%")
if !exists("s:netrwmarkfilelist_{curbufnr}") || empty(s:netrwmarkfilelist_{curbufnr})
NetrwKeepj call netrw#ErrorMsg(2,"there are no marked files in this window (:help netrw-mf)",66)
return
endif
if exists("s:netrwmarkfilelist")
let netrwmarkfilelist= join(map(deepcopy(s:netrwmarkfilelist), "s:ShellEscape(v:val,".!a:islocal.")"))
call s:NetrwUnmarkAll()
if a:islocal
if executable(g:netrw_ctags)
call system(g:netrw_ctags." ".netrwmarkfilelist)
else
call netrw#ErrorMsg(s:ERROR,"g:netrw_ctags<".g:netrw_ctags."> is not executable!",51)
endif
else
let cmd   = s:RemoteSystem(g:netrw_ctags." ".netrwmarkfilelist)
call netrw#Obtain(a:islocal,"tags")
let curdir= b:netrw_curdir
1split
NetrwKeepj e tags
let path= substitute(curdir,'^\(.*\)/[^/]*$','\1/','')
exe 'NetrwKeepj %s/\t\(\S\+\)\t/\t'.escape(path,"/\n\r\\").'\1\t/e'
call histdel("/",-1)
wq!
endif
2match none
call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
call winrestview(svpos)
endif
endfun
fun! s:NetrwMarkFileTgt(islocal)
let svpos  = winsaveview()
let curdir = s:NetrwGetCurdir(a:islocal)
let hadtgt = exists("s:netrwmftgt")
if !exists("w:netrw_bannercnt")
let w:netrw_bannercnt= b:netrw_bannercnt
endif
if line(".") < w:netrw_bannercnt
if exists("s:netrwmftgt") && exists("s:netrwmftgt_islocal") && s:netrwmftgt == b:netrw_curdir
unlet s:netrwmftgt s:netrwmftgt_islocal
if g:netrw_fastbrowse <= 1
call s:LocalBrowseRefresh()
endif
call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
call winrestview(svpos)
return
else
let s:netrwmftgt= b:netrw_curdir
endif
else
let curword= s:NetrwGetWord()
let tgtdir = s:ComposePath(curdir,curword)
if a:islocal && isdirectory(s:NetrwFile(tgtdir))
let s:netrwmftgt = tgtdir
elseif !a:islocal && tgtdir =~ '/$'
let s:netrwmftgt = tgtdir
else
let s:netrwmftgt = curdir
endif
endif
if a:islocal
let s:netrwmftgt= simplify(s:netrwmftgt)
endif
if g:netrw_cygwin
let s:netrwmftgt= substitute(system("cygpath ".s:ShellEscape(s:netrwmftgt)),'\n$','','')
let s:netrwmftgt= substitute(s:netrwmftgt,'\n$','','')
endif
let s:netrwmftgt_islocal= a:islocal
if g:netrw_fastbrowse <= 1
call s:LocalBrowseRefresh()
endif
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,w:netrw_treetop))
else
call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
endif
call winrestview(svpos)
if !hadtgt
sil! NetrwKeepj norm! j
endif
endfun
fun! s:NetrwGetCurdir(islocal)
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
let b:netrw_curdir = s:NetrwTreePath(w:netrw_treetop)
elseif !exists("b:netrw_curdir")
let b:netrw_curdir= getcwd()
endif
if b:netrw_curdir !~ '\<\a\{3,}://'
let curdir= b:netrw_curdir
if g:netrw_keepdir == 0
call s:NetrwLcd(curdir)
endif
endif
return b:netrw_curdir
endfun
fun! s:NetrwOpenFile(islocal)
let ykeep= @@
call inputsave()
let fname= input("Enter filename: ")
call inputrestore()
if fname !~ '[/\\]'
if exists("b:netrw_curdir")
if exists("g:netrw_quiet")
let netrw_quiet_keep = g:netrw_quiet
endif
let g:netrw_quiet = 1
let s:rexposn_{bufnr("%")}= winsaveview()
if b:netrw_curdir =~ '/$'
exe "NetrwKeepj e ".fnameescape(b:netrw_curdir.fname)
else
exe "e ".fnameescape(b:netrw_curdir."/".fname)
endif
if exists("netrw_quiet_keep")
let g:netrw_quiet= netrw_quiet_keep
else
unlet g:netrw_quiet
endif
endif
else
exe "NetrwKeepj e ".fnameescape(fname)
endif
let @@= ykeep
endfun
fun! netrw#Shrink()
let curwin  = winnr()
let wiwkeep = &wiw
set wiw=1
if &ft == "netrw"
if winwidth(0) > g:netrw_wiw
let t:netrw_winwidth= winwidth(0)
exe "vert resize ".g:netrw_wiw
wincmd l
if winnr() == curwin
wincmd h
endif
else
exe "vert resize ".t:netrw_winwidth
endif
elseif exists("t:netrw_lexbufnr")
exe bufwinnr(t:netrw_lexbufnr)."wincmd w"
if     winwidth(bufwinnr(t:netrw_lexbufnr)) >  g:netrw_wiw
let t:netrw_winwidth= winwidth(0)
exe "vert resize ".g:netrw_wiw
wincmd l
if winnr() == curwin
wincmd h
endif
elseif winwidth(bufwinnr(t:netrw_lexbufnr)) >= 0
exe "vert resize ".t:netrw_winwidth
else 
call netrw#Lexplore(0,0)
endif
else
call netrw#Lexplore(0,0)
endif
let wiw= wiwkeep
endfun
fun! s:NetSortSequence(islocal)
let ykeep= @@
let svpos= winsaveview()
call inputsave()
let newsortseq= input("Edit Sorting Sequence: ",g:netrw_sort_sequence)
call inputrestore()
let g:netrw_sort_sequence= newsortseq
NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
NetrwKeepj call winrestview(svpos)
let @@= ykeep
endfun
fun! s:NetrwUnmarkList(curbufnr,curdir)
if exists("s:netrwmarkfilelist")
for mfile in s:netrwmarkfilelist_{a:curbufnr}
let dfile = s:ComposePath(a:curdir,mfile)       " prepend directory to mfile
let idx   = index(s:netrwmarkfilelist,dfile)    " get index in list of dfile
call remove(s:netrwmarkfilelist,idx)            " remove from global list
endfor
if s:netrwmarkfilelist == []
unlet s:netrwmarkfilelist
endif
unlet s:netrwmarkfilelist_{a:curbufnr}
endif
if exists("s:netrwmarkfilemtch_{a:curbufnr}")
unlet s:netrwmarkfilemtch_{a:curbufnr}
endif
2match none
endfun
fun! s:NetrwUnmarkAll()
if exists("s:netrwmarkfilelist")
unlet s:netrwmarkfilelist
endif
sil call s:NetrwUnmarkAll2()
2match none
endfun
fun! s:NetrwUnmarkAll2()
redir => netrwmarkfilelist_let
let
redir END
let netrwmarkfilelist_list= split(netrwmarkfilelist_let,'\n')          " convert let string into a let list
call filter(netrwmarkfilelist_list,"v:val =~ '^s:netrwmarkfilelist_'") " retain only those vars that start as s:netrwmarkfilelist_
call map(netrwmarkfilelist_list,"substitute(v:val,'\\s.*$','','')")    " remove what the entries are equal to
for flist in netrwmarkfilelist_list
let curbufnr= substitute(flist,'s:netrwmarkfilelist_','','')
unlet s:netrwmarkfilelist_{curbufnr}
unlet s:netrwmarkfilemtch_{curbufnr}
endfor
endfun
fun! s:NetrwUnMarkFile(islocal)
let svpos    = winsaveview()
let curbufnr = bufnr("%")
if exists("s:netrwmarkfilelist")
unlet s:netrwmarkfilelist
endif
let ibuf= 1
while ibuf < bufnr("$")
if exists("s:netrwmarkfilelist_".ibuf)
unlet s:netrwmarkfilelist_{ibuf}
unlet s:netrwmarkfilemtch_{ibuf}
endif
let ibuf = ibuf + 1
endwhile
2match none
call winrestview(svpos)
endfun
fun! s:NetrwMenu(domenu)
if !exists("g:NetrwMenuPriority")
let g:NetrwMenuPriority= 80
endif
if has("menu") && has("gui_running") && &go =~# 'm' && g:netrw_menu
if !exists("s:netrw_menu_enabled") && a:domenu
let s:netrw_menu_enabled= 1
exe 'sil! menu '.g:NetrwMenuPriority.'.1      '.g:NetrwTopLvlMenu.'Help<tab><F1>	<F1>'
exe 'sil! menu '.g:NetrwMenuPriority.'.5      '.g:NetrwTopLvlMenu.'-Sep1-	:'
exe 'sil! menu '.g:NetrwMenuPriority.'.6      '.g:NetrwTopLvlMenu.'Go\ Up\ Directory<tab>-	-'
exe 'sil! menu '.g:NetrwMenuPriority.'.7      '.g:NetrwTopLvlMenu.'Apply\ Special\ Viewer<tab>x	x'
if g:netrw_dirhistmax > 0
exe 'sil! menu '.g:NetrwMenuPriority.'.8.1   '.g:NetrwTopLvlMenu.'Bookmarks\ and\ History.Bookmark\ Current\ Directory<tab>mb	mb'
exe 'sil! menu '.g:NetrwMenuPriority.'.8.4   '.g:NetrwTopLvlMenu.'Bookmarks\ and\ History.Goto\ Prev\ Dir\ (History)<tab>u	u'
exe 'sil! menu '.g:NetrwMenuPriority.'.8.5   '.g:NetrwTopLvlMenu.'Bookmarks\ and\ History.Goto\ Next\ Dir\ (History)<tab>U	U'
exe 'sil! menu '.g:NetrwMenuPriority.'.8.6   '.g:NetrwTopLvlMenu.'Bookmarks\ and\ History.List<tab>qb	qb'
else
exe 'sil! menu '.g:NetrwMenuPriority.'.8     '.g:NetrwTopLvlMenu.'Bookmarks\ and\ History	:echo "(disabled)"'."\<cr>"
endif
exe 'sil! menu '.g:NetrwMenuPriority.'.9.1    '.g:NetrwTopLvlMenu.'Browsing\ Control.Horizontal\ Split<tab>o	o'
exe 'sil! menu '.g:NetrwMenuPriority.'.9.2    '.g:NetrwTopLvlMenu.'Browsing\ Control.Vertical\ Split<tab>v	v'
exe 'sil! menu '.g:NetrwMenuPriority.'.9.3    '.g:NetrwTopLvlMenu.'Browsing\ Control.New\ Tab<tab>t	t'
exe 'sil! menu '.g:NetrwMenuPriority.'.9.4    '.g:NetrwTopLvlMenu.'Browsing\ Control.Preview<tab>p	p'
exe 'sil! menu '.g:NetrwMenuPriority.'.9.5    '.g:NetrwTopLvlMenu.'Browsing\ Control.Edit\ File\ Hiding\ List<tab><ctrl-h>'."	\<c-h>'"
exe 'sil! menu '.g:NetrwMenuPriority.'.9.6    '.g:NetrwTopLvlMenu.'Browsing\ Control.Edit\ Sorting\ Sequence<tab>S	S'
exe 'sil! menu '.g:NetrwMenuPriority.'.9.7    '.g:NetrwTopLvlMenu.'Browsing\ Control.Quick\ Hide/Unhide\ Dot\ Files<tab>'."gh	gh"
exe 'sil! menu '.g:NetrwMenuPriority.'.9.8    '.g:NetrwTopLvlMenu.'Browsing\ Control.Refresh\ Listing<tab>'."<ctrl-l>	\<c-l>"
exe 'sil! menu '.g:NetrwMenuPriority.'.9.9    '.g:NetrwTopLvlMenu.'Browsing\ Control.Settings/Options<tab>:NetrwSettings	'.":NetrwSettings\<cr>"
exe 'sil! menu '.g:NetrwMenuPriority.'.10     '.g:NetrwTopLvlMenu.'Delete\ File/Directory<tab>D	D'
exe 'sil! menu '.g:NetrwMenuPriority.'.11.1   '.g:NetrwTopLvlMenu.'Edit\ File/Dir.Create\ New\ File<tab>%	%'
exe 'sil! menu '.g:NetrwMenuPriority.'.11.1   '.g:NetrwTopLvlMenu.'Edit\ File/Dir.In\ Current\ Window<tab><cr>	'."\<cr>"
exe 'sil! menu '.g:NetrwMenuPriority.'.11.2   '.g:NetrwTopLvlMenu.'Edit\ File/Dir.Preview\ File/Directory<tab>p	p'
exe 'sil! menu '.g:NetrwMenuPriority.'.11.3   '.g:NetrwTopLvlMenu.'Edit\ File/Dir.In\ Previous\ Window<tab>P	P'
exe 'sil! menu '.g:NetrwMenuPriority.'.11.4   '.g:NetrwTopLvlMenu.'Edit\ File/Dir.In\ New\ Window<tab>o	o'
exe 'sil! menu '.g:NetrwMenuPriority.'.11.5   '.g:NetrwTopLvlMenu.'Edit\ File/Dir.In\ New\ Tab<tab>t	t'
exe 'sil! menu '.g:NetrwMenuPriority.'.11.5   '.g:NetrwTopLvlMenu.'Edit\ File/Dir.In\ New\ Vertical\ Window<tab>v	v'
exe 'sil! menu '.g:NetrwMenuPriority.'.12.1   '.g:NetrwTopLvlMenu.'Explore.Directory\ Name	:Explore '
exe 'sil! menu '.g:NetrwMenuPriority.'.12.2   '.g:NetrwTopLvlMenu.'Explore.Filenames\ Matching\ Pattern\ (curdir\ only)<tab>:Explore\ */	:Explore */'
exe 'sil! menu '.g:NetrwMenuPriority.'.12.2   '.g:NetrwTopLvlMenu.'Explore.Filenames\ Matching\ Pattern\ (+subdirs)<tab>:Explore\ **/	:Explore **/'
exe 'sil! menu '.g:NetrwMenuPriority.'.12.3   '.g:NetrwTopLvlMenu.'Explore.Files\ Containing\ String\ Pattern\ (curdir\ only)<tab>:Explore\ *//	:Explore *//'
exe 'sil! menu '.g:NetrwMenuPriority.'.12.4   '.g:NetrwTopLvlMenu.'Explore.Files\ Containing\ String\ Pattern\ (+subdirs)<tab>:Explore\ **//	:Explore **//'
exe 'sil! menu '.g:NetrwMenuPriority.'.12.4   '.g:NetrwTopLvlMenu.'Explore.Next\ Match<tab>:Nexplore	:Nexplore<cr>'
exe 'sil! menu '.g:NetrwMenuPriority.'.12.4   '.g:NetrwTopLvlMenu.'Explore.Prev\ Match<tab>:Pexplore	:Pexplore<cr>'
exe 'sil! menu '.g:NetrwMenuPriority.'.13     '.g:NetrwTopLvlMenu.'Make\ Subdirectory<tab>d	d'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.1   '.g:NetrwTopLvlMenu.'Marked\ Files.Mark\ File<tab>mf	mf'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.2   '.g:NetrwTopLvlMenu.'Marked\ Files.Mark\ Files\ by\ Regexp<tab>mr	mr'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.3   '.g:NetrwTopLvlMenu.'Marked\ Files.Hide-Show-List\ Control<tab>a	a'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.4   '.g:NetrwTopLvlMenu.'Marked\ Files.Copy\ To\ Target<tab>mc	mc'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.5   '.g:NetrwTopLvlMenu.'Marked\ Files.Delete<tab>D	D'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.6   '.g:NetrwTopLvlMenu.'Marked\ Files.Diff<tab>md	md'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.7   '.g:NetrwTopLvlMenu.'Marked\ Files.Edit<tab>me	me'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.8   '.g:NetrwTopLvlMenu.'Marked\ Files.Exe\ Cmd<tab>mx	mx'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.9   '.g:NetrwTopLvlMenu.'Marked\ Files.Move\ To\ Target<tab>mm	mm'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.10  '.g:NetrwTopLvlMenu.'Marked\ Files.Obtain<tab>O	O'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.11  '.g:NetrwTopLvlMenu.'Marked\ Files.Print<tab>mp	mp'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.12  '.g:NetrwTopLvlMenu.'Marked\ Files.Replace<tab>R	R'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.13  '.g:NetrwTopLvlMenu.'Marked\ Files.Set\ Target<tab>mt	mt'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.14  '.g:NetrwTopLvlMenu.'Marked\ Files.Tag<tab>mT	mT'
exe 'sil! menu '.g:NetrwMenuPriority.'.14.15  '.g:NetrwTopLvlMenu.'Marked\ Files.Zip/Unzip/Compress/Uncompress<tab>mz	mz'
exe 'sil! menu '.g:NetrwMenuPriority.'.15     '.g:NetrwTopLvlMenu.'Obtain\ File<tab>O	O'
exe 'sil! menu '.g:NetrwMenuPriority.'.16.1.1 '.g:NetrwTopLvlMenu.'Style.Listing.thin<tab>i	:let w:netrw_liststyle=0<cr><c-L>'
exe 'sil! menu '.g:NetrwMenuPriority.'.16.1.1 '.g:NetrwTopLvlMenu.'Style.Listing.long<tab>i	:let w:netrw_liststyle=1<cr><c-L>'
exe 'sil! menu '.g:NetrwMenuPriority.'.16.1.1 '.g:NetrwTopLvlMenu.'Style.Listing.wide<tab>i	:let w:netrw_liststyle=2<cr><c-L>'
exe 'sil! menu '.g:NetrwMenuPriority.'.16.1.1 '.g:NetrwTopLvlMenu.'Style.Listing.tree<tab>i	:let w:netrw_liststyle=3<cr><c-L>'
exe 'sil! menu '.g:NetrwMenuPriority.'.16.2.1 '.g:NetrwTopLvlMenu.'Style.Normal-Hide-Show.Show\ All<tab>a	:let g:netrw_hide=0<cr><c-L>'
exe 'sil! menu '.g:NetrwMenuPriority.'.16.2.3 '.g:NetrwTopLvlMenu.'Style.Normal-Hide-Show.Normal<tab>a	:let g:netrw_hide=1<cr><c-L>'
exe 'sil! menu '.g:NetrwMenuPriority.'.16.2.2 '.g:NetrwTopLvlMenu.'Style.Normal-Hide-Show.Hidden\ Only<tab>a	:let g:netrw_hide=2<cr><c-L>'
exe 'sil! menu '.g:NetrwMenuPriority.'.16.3   '.g:NetrwTopLvlMenu.'Style.Reverse\ Sorting\ Order<tab>'."r	r"
exe 'sil! menu '.g:NetrwMenuPriority.'.16.4.1 '.g:NetrwTopLvlMenu.'Style.Sorting\ Method.Name<tab>s       :let g:netrw_sort_by="name"<cr><c-L>'
exe 'sil! menu '.g:NetrwMenuPriority.'.16.4.2 '.g:NetrwTopLvlMenu.'Style.Sorting\ Method.Time<tab>s       :let g:netrw_sort_by="time"<cr><c-L>'
exe 'sil! menu '.g:NetrwMenuPriority.'.16.4.3 '.g:NetrwTopLvlMenu.'Style.Sorting\ Method.Size<tab>s       :let g:netrw_sort_by="size"<cr><c-L>'
exe 'sil! menu '.g:NetrwMenuPriority.'.16.4.3 '.g:NetrwTopLvlMenu.'Style.Sorting\ Method.Exten<tab>s      :let g:netrw_sort_by="exten"<cr><c-L>'
exe 'sil! menu '.g:NetrwMenuPriority.'.17     '.g:NetrwTopLvlMenu.'Rename\ File/Directory<tab>R	R'
exe 'sil! menu '.g:NetrwMenuPriority.'.18     '.g:NetrwTopLvlMenu.'Set\ Current\ Directory<tab>c	c'
let s:netrw_menucnt= 28
call s:NetrwBookmarkMenu() " provide some history!  uses priorities 2,3, reserves 4, 8.2.x
call s:NetrwTgtMenu()      " let bookmarks and history be easy targets
elseif !a:domenu
let s:netrwcnt = 0
let curwin     = winnr()
windo if getline(2) =~# "Netrw" | let s:netrwcnt= s:netrwcnt + 1 | endif
exe curwin."wincmd w"
if s:netrwcnt <= 1
exe 'sil! unmenu '.g:NetrwTopLvlMenu
sil! unlet s:netrw_menu_enabled
endif
endif
return
endif
endfun
fun! s:NetrwObtain(islocal)
let ykeep= @@
if exists("s:netrwmarkfilelist_{bufnr('%')}")
let islocal= s:netrwmarkfilelist_{bufnr('%')}[1] !~ '^\a\{3,}://'
call netrw#Obtain(islocal,s:netrwmarkfilelist_{bufnr('%')})
call s:NetrwUnmarkList(bufnr('%'),b:netrw_curdir)
else
call netrw#Obtain(a:islocal,expand("<cWORD>"))
endif
let @@= ykeep
endfun
fun! s:NetrwPrevWinOpen(islocal)
let ykeep= @@
let curdir = b:netrw_curdir
let origwin   = winnr()
let lastwinnr = winnr("$")
let curword   = s:NetrwGetWord()
let choice    = 0
let s:treedir = s:NetrwTreeDir(a:islocal)
let curdir    = s:treedir
let didsplit = 0
if lastwinnr == 1
if g:netrw_preview
let winsz= (g:netrw_winsize > 0)? (g:netrw_winsize*winheight(0))/100 : -g:netrw_winsize
exe (g:netrw_alto? "top " : "bot ")."vert ".winsz."wincmd s"
else
let winsz= (g:netrw_winsize > 0)? (g:netrw_winsize*winwidth(0))/100 : -g:netrw_winsize
exe (g:netrw_alto? "bel " : "abo ").winsz."wincmd s"
endif
let didsplit = 1
else
NetrwKeepj call s:SaveBufVars()
let eikeep= &ei
setl ei=all
wincmd p
let prevwinnr   = winnr()
let prevbufnr   = bufnr("%")
let prevbufname = bufname("%")
let prevmod     = &mod
let bnrcnt      = 0
NetrwKeepj call s:RestoreBufVars()
if prevmod
windo if winbufnr(0) == prevbufnr | let bnrcnt=bnrcnt+1 | endif
exe prevwinnr."wincmd w"
if bnrcnt == 1 && &hidden == 0
let choice = confirm("Save modified buffer<".prevbufname."> first?","&Yes\n&No\n&Cancel")
let &ei= eikeep
if choice == 1
let v:errmsg= ""
sil w
if v:errmsg != ""
call netrw#ErrorMsg(s:ERROR,"unable to write <".(exists("prevbufname")? prevbufname : 'n/a').">!",30)
exe origwin."wincmd w"
let &ei = eikeep
let @@  = ykeep
return choice
endif
elseif choice == 2
echomsg "**note** changes to ".prevbufname." abandoned"
else
exe origwin."wincmd w"
let &ei= eikeep
let @@ = ykeep
return choice
endif
endif
endif
let &ei= eikeep
endif
let b:netrw_curdir= curdir
if a:islocal < 2
if a:islocal
call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(a:islocal,curword))
else
call s:NetrwBrowse(a:islocal,s:NetrwBrowseChgDir(a:islocal,curword))
endif
endif
let @@= ykeep
return choice
endfun
fun! s:NetrwUpload(fname,tgt,...)
if a:tgt =~ '^\a\{3,}://'
let tgtdir= substitute(a:tgt,'^\a\{3,}://[^/]\+/\(.\{-}\)$','\1','')
else
let tgtdir= substitute(a:tgt,'^\(.*\)/[^/]*$','\1','')
endif
if a:0 > 0
let fromdir= a:1
else
let fromdir= getcwd()
endif
if type(a:fname) == 1
1split
exe "NetrwKeepj e ".fnameescape(s:NetrwFile(a:fname))
if a:tgt =~ '/$'
let wfname= substitute(a:fname,'^.*/','','')
exe "w! ".fnameescape(a:tgt.wfname)
else
exe "w ".fnameescape(a:tgt)
endif
q!
elseif type(a:fname) == 3
let curdir= getcwd()
if a:tgt =~ '^scp:'
call s:NetrwLcd(fromdir)
let filelist= deepcopy(s:netrwmarkfilelist_{bufnr('%')})
let args    = join(map(filelist,"s:ShellEscape(v:val, 1)"))
if exists("g:netrw_port") && g:netrw_port != ""
let useport= " ".g:netrw_scpport." ".g:netrw_port
else
let useport= ""
endif
let machine = substitute(a:tgt,'^scp://\([^/:]\+\).*$','\1','')
let tgt     = substitute(a:tgt,'^scp://[^/]\+/\(.*\)$','\1','')
call s:NetrwExe(s:netrw_silentxfer."!".g:netrw_scp_cmd.s:ShellEscape(useport,1)." ".args." ".s:ShellEscape(machine.":".tgt,1))
call s:NetrwLcd(curdir)
elseif a:tgt =~ '^ftp:'
call s:NetrwMethod(a:tgt)
if b:netrw_method == 2
let netrw_fname = b:netrw_fname
sil NetrwKeepj new
NetrwKeepj put =g:netrw_ftpmode
if exists("g:netrw_ftpextracmd")
NetrwKeepj put =g:netrw_ftpextracmd
endif
NetrwKeepj call setline(line("$")+1,'lcd "'.fromdir.'"')
if tgtdir == ""
let tgtdir= '/'
endif
NetrwKeepj call setline(line("$")+1,'cd "'.tgtdir.'"')
for fname in a:fname
NetrwKeepj call setline(line("$")+1,'put "'.s:NetrwFile(fname).'"')
endfor
if exists("g:netrw_port") && g:netrw_port != ""
call s:NetrwExe(s:netrw_silentxfer."%!".s:netrw_ftp_cmd." -i ".s:ShellEscape(g:netrw_machine,1)." ".s:ShellEscape(g:netrw_port,1))
else
call s:NetrwExe(s:netrw_silentxfer."%!".s:netrw_ftp_cmd." -i ".s:ShellEscape(g:netrw_machine,1))
endif
sil NetrwKeepj g/Local directory now/d
call histdel("/",-1)
if getline(1) !~ "^$" && !exists("g:netrw_quiet") && getline(1) !~ '^Trying '
call netrw#ErrorMsg(s:ERROR,getline(1),14)
else
bw!|q
endif
elseif b:netrw_method == 3
let netrw_fname= b:netrw_fname
NetrwKeepj call s:SaveBufVars()|sil NetrwKeepj new|NetrwKeepj call s:RestoreBufVars()
let tmpbufnr= bufnr("%")
setl ff=unix
if exists("g:netrw_port") && g:netrw_port != ""
NetrwKeepj put ='open '.g:netrw_machine.' '.g:netrw_port
else
NetrwKeepj put ='open '.g:netrw_machine
endif
if exists("g:netrw_uid") && g:netrw_uid != ""
if exists("g:netrw_ftp") && g:netrw_ftp == 1
NetrwKeepj put =g:netrw_uid
if exists("s:netrw_passwd")
NetrwKeepj call setline(line("$")+1,'"'.s:netrw_passwd.'"')
endif
elseif exists("s:netrw_passwd")
NetrwKeepj put ='user \"'.g:netrw_uid.'\" \"'.s:netrw_passwd.'\"'
endif
endif
NetrwKeepj call setline(line("$")+1,'lcd "'.fromdir.'"')
if exists("b:netrw_fname") && b:netrw_fname != ""
NetrwKeepj call setline(line("$")+1,'cd "'.b:netrw_fname.'"')
endif
if exists("g:netrw_ftpextracmd")
NetrwKeepj put =g:netrw_ftpextracmd
endif
for fname in a:fname
NetrwKeepj call setline(line("$")+1,'put "'.fname.'"')
endfor
NetrwKeepj norm! 1Gdd
call s:NetrwExe(s:netrw_silentxfer."%!".s:netrw_ftp_cmd." ".g:netrw_ftp_options)
sil NetrwKeepj g/Local directory now/d
call histdel("/",-1)
if getline(1) !~ "^$" && !exists("g:netrw_quiet") && getline(1) !~ '^Trying '
let debugkeep= &debug
setl debug=msg
call netrw#ErrorMsg(s:ERROR,getline(1),15)
let &debug = debugkeep
let mod    = 1
else
bw!|q
endif
elseif !exists("b:netrw_method") || b:netrw_method < 0
return
endif
else
call netrw#ErrorMsg(s:ERROR,"can't obtain files with protocol from<".a:tgt.">",63)
endif
endif
endfun
fun! s:NetrwPreview(path) range
let ykeep= @@
NetrwKeepj call s:NetrwOptionSave("s:")
NetrwKeepj call s:NetrwSafeOptions()
if has("quickfix")
if !isdirectory(s:NetrwFile(a:path))
if g:netrw_preview && !g:netrw_alto
let pvhkeep = &pvh
let winsz   = (g:netrw_winsize > 0)? (g:netrw_winsize*winwidth(0))/100 : -g:netrw_winsize
let &pvh    = winwidth(0) - winsz
endif
exe (g:netrw_alto? "top " : "bot ").(g:netrw_preview? "vert " : "")."pedit ".fnameescape(a:path)
if exists("pvhkeep")
let &pvh= pvhkeep
endif
elseif !exists("g:netrw_quiet")
NetrwKeepj call netrw#ErrorMsg(s:WARNING,"sorry, cannot preview a directory such as <".a:path.">",38)
endif
elseif !exists("g:netrw_quiet")
NetrwKeepj call netrw#ErrorMsg(s:WARNING,"sorry, to preview your vim needs the quickfix feature compiled in",39)
endif
NetrwKeepj call s:NetrwOptionRestore("s:")
let @@= ykeep
endfun
fun! s:NetrwRefresh(islocal,dirname)
setl ma noro
let ykeep      = @@
let screenposn = winsaveview()
sil! NetrwKeepj %d _
if a:islocal
NetrwKeepj call netrw#LocalBrowseCheck(a:dirname)
else
NetrwKeepj call s:NetrwBrowse(a:islocal,a:dirname)
endif
NetrwKeepj call winrestview(screenposn)
if exists("s:netrwmarkfilemtch_{bufnr('%')}") && s:netrwmarkfilemtch_{bufnr("%")} != ""
exe "2match netrwMarkFile /".s:netrwmarkfilemtch_{bufnr("%")}."/"
else
2match none
endif
let @@= ykeep
endfun
fun! s:NetrwRefreshDir(islocal,dirname)
if g:netrw_fastbrowse == 0
let tgtwin= bufwinnr(a:dirname)
if tgtwin > 0
let curwin= winnr()
exe tgtwin."wincmd w"
NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
exe curwin."wincmd w"
elseif bufnr(a:dirname) > 0
let bn= bufnr(a:dirname)
exe "sil keepj bd ".bn
endif
elseif g:netrw_fastbrowse <= 1
NetrwKeepj call s:LocalBrowseRefresh()
endif
endfun
fun! s:NetrwSetChgwin(...)
if a:0 > 0
if a:1 == ""    " :NetrwC win#
let g:netrw_chgwin= winnr()
else              " :NetrwC
let g:netrw_chgwin= a:1
endif
elseif v:count > 0 " [count]C
let g:netrw_chgwin= v:count
else               " C
let g:netrw_chgwin= winnr()
endif
echo "editing window now set to window#".g:netrw_chgwin
endfun
fun! s:NetrwSetSort()
let ykeep= @@
if w:netrw_liststyle == s:LONGLIST
let seqlist  = substitute(g:netrw_sort_sequence,'\$','\\%(\t\\|\$\\)','ge')
else
let seqlist  = g:netrw_sort_sequence
endif
if seqlist == ""
let seqlist= '*'
elseif seqlist !~ '\*'
let seqlist= seqlist.',*'
endif
let priority = 1
while seqlist != ""
if seqlist =~ ','
let seq     = substitute(seqlist,',.*$','','e')
let seqlist = substitute(seqlist,'^.\{-},\(.*\)$','\1','e')
else
let seq     = seqlist
let seqlist = ""
endif
if priority < 10
let spriority= "00".priority.g:netrw_sepchr
elseif priority < 100
let spriority= "0".priority.g:netrw_sepchr
else
let spriority= priority.g:netrw_sepchr
endif
if w:netrw_bannercnt > line("$")
return
endif
if seq == '*'
let starpriority= spriority
else
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$g/'.seq.'/s/^/'.spriority.'/'
call histdel("/",-1)
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$g/^\d\{3}'.g:netrw_sepchr.'\d\{3}\//s/^\d\{3}'.g:netrw_sepchr.'\(\d\{3}\/\).\@=/\1/e'
NetrwKeepj call histdel("/",-1)
endif
let priority = priority + 1
endwhile
if exists("starpriority")
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$v/^\d\{3}'.g:netrw_sepchr.'/s/^/'.starpriority.'/e'
NetrwKeepj call histdel("/",-1)
endif
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$s/^\(\d\{3}'.g:netrw_sepchr.'\)\%(\d\{3}'.g:netrw_sepchr.'\)\+\ze./\1/e'
NetrwKeepj call histdel("/",-1)
let @@= ykeep
endfun
fun! s:NetrwSetTgt(islocal,bookhist,choice)
if     a:bookhist == 'b'
let choice= a:choice - 1
if exists("g:netrw_bookmarklist[".choice."]")
call netrw#MakeTgt(g:netrw_bookmarklist[choice])
else
echomsg "Sorry, bookmark#".a:choice." doesn't exist!"
endif
elseif a:bookhist == 'h'
let choice= (a:choice % g:netrw_dirhistmax) + 1
if exists("g:netrw_dirhist_".choice)
let histentry = g:netrw_dirhist_{choice}
call netrw#MakeTgt(histentry)
else
echomsg "Sorry, history#".a:choice." not available!"
endif
endif
if !exists("b:netrw_curdir")
let b:netrw_curdir= getcwd()
endif
call s:NetrwRefresh(a:islocal,b:netrw_curdir)
endfun
fun! s:NetrwSortStyle(islocal)
NetrwKeepj call s:NetrwSaveWordPosn()
let svpos= winsaveview()
let g:netrw_sort_by= (g:netrw_sort_by =~# '^n')? 'time' : (g:netrw_sort_by =~# '^t')? 'size' : (g:netrw_sort_by =~# '^siz')? 'exten' : 'name'
NetrwKeepj norm! 0
NetrwKeepj call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
NetrwKeepj call winrestview(svpos)
endfun
fun! s:NetrwSplit(mode)
let ykeep= @@
call s:SaveWinVars()
if a:mode == 0
let winsz= (g:netrw_winsize > 0)? (g:netrw_winsize*winheight(0))/100 : -g:netrw_winsize
if winsz == 0|let winsz= ""|endif
exe (g:netrw_alto? "bel " : "abo ").winsz."wincmd s"
let s:didsplit= 1
NetrwKeepj call s:RestoreWinVars()
NetrwKeepj call s:NetrwBrowse(0,s:NetrwBrowseChgDir(0,s:NetrwGetWord()))
unlet s:didsplit
elseif a:mode == 1
let newdir  = s:NetrwBrowseChgDir(0,s:NetrwGetWord())
tabnew
let s:didsplit= 1
NetrwKeepj call s:RestoreWinVars()
NetrwKeepj call s:NetrwBrowse(0,newdir)
unlet s:didsplit
elseif a:mode == 2
let winsz= (g:netrw_winsize > 0)? (g:netrw_winsize*winwidth(0))/100 : -g:netrw_winsize
if winsz == 0|let winsz= ""|endif
exe (g:netrw_altv? "rightb " : "lefta ").winsz."wincmd v"
let s:didsplit= 1
NetrwKeepj call s:RestoreWinVars()
NetrwKeepj call s:NetrwBrowse(0,s:NetrwBrowseChgDir(0,s:NetrwGetWord()))
unlet s:didsplit
elseif a:mode == 3
let winsz= (g:netrw_winsize > 0)? (g:netrw_winsize*winheight(0))/100 : -g:netrw_winsize
if winsz == 0|let winsz= ""|endif
exe (g:netrw_alto? "bel " : "abo ").winsz."wincmd s"
let s:didsplit= 1
NetrwKeepj call s:RestoreWinVars()
NetrwKeepj call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(1,s:NetrwGetWord()))
unlet s:didsplit
elseif a:mode == 4
let cursorword  = s:NetrwGetWord()
let eikeep      = &ei
let netrw_winnr = winnr()
let netrw_line  = line(".")
let netrw_col   = virtcol(".")
NetrwKeepj norm! H0
let netrw_hline = line(".")
setl ei=all
exe "NetrwKeepj norm! ".netrw_hline."G0z\<CR>"
exe "NetrwKeepj norm! ".netrw_line."G0".netrw_col."\<bar>"
let &ei          = eikeep
let netrw_curdir = s:NetrwTreeDir(0)
tabnew
let b:netrw_curdir = netrw_curdir
let s:didsplit     = 1
NetrwKeepj call s:RestoreWinVars()
NetrwKeepj call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(1,cursorword))
if &ft == "netrw"
setl ei=all
exe "NetrwKeepj norm! ".netrw_hline."G0z\<CR>"
exe "NetrwKeepj norm! ".netrw_line."G0".netrw_col."\<bar>"
let &ei= eikeep
endif
unlet s:didsplit
elseif a:mode == 5
let winsz= (g:netrw_winsize > 0)? (g:netrw_winsize*winwidth(0))/100 : -g:netrw_winsize
if winsz == 0|let winsz= ""|endif
exe (g:netrw_altv? "rightb " : "lefta ").winsz."wincmd v"
let s:didsplit= 1
NetrwKeepj call s:RestoreWinVars()
NetrwKeepj call netrw#LocalBrowseCheck(s:NetrwBrowseChgDir(1,s:NetrwGetWord()))
unlet s:didsplit
else
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"(NetrwSplit) unsupported mode=".a:mode,45)
endif
let @@= ykeep
endfun
fun! s:NetrwTgtMenu()
if !exists("s:netrw_menucnt")
return
endif
if has("gui") && has("menu") && has("gui_running") && &go =~# 'm' && g:netrw_menu
if exists("g:NetrwTopLvlMenu")
exe 'sil! unmenu '.g:NetrwTopLvlMenu.'Targets'
endif
if !exists("s:netrw_initbookhist")
call s:NetrwBookHistRead()
endif
let tgtdict={}
if exists("g:netrw_bookmarklist") && g:netrw_bookmarklist != [] && g:netrw_dirhistmax > 0
let cnt= 1
for bmd in g:netrw_bookmarklist
if has_key(tgtdict,bmd)
let cnt= cnt + 1
continue
endif
let tgtdict[bmd]= cnt
let ebmd= escape(bmd,g:netrw_menu_escape)
exe 'sil! menu <silent> '.g:NetrwMenuPriority.".19.1.".cnt." ".g:NetrwTopLvlMenu.'Targets.'.ebmd."	:call netrw#MakeTgt('".bmd."')\<cr>"
let cnt= cnt + 1
endfor
endif
if exists("g:netrw_dirhistmax") && g:netrw_dirhistmax > 0
let histcnt = 1
while histcnt <= g:netrw_dirhistmax
let priority = g:netrw_dirhist_cnt + histcnt
if exists("g:netrw_dirhist_{histcnt}")
let histentry  = g:netrw_dirhist_{histcnt}
if has_key(tgtdict,histentry)
let histcnt = histcnt + 1
continue
endif
let tgtdict[histentry] = histcnt
let ehistentry         = escape(histentry,g:netrw_menu_escape)
exe 'sil! menu <silent> '.g:NetrwMenuPriority.".19.2.".priority." ".g:NetrwTopLvlMenu.'Targets.'.ehistentry."	:call netrw#MakeTgt('".histentry."')\<cr>"
endif
let histcnt = histcnt + 1
endwhile
endif
endif
endfun
fun! s:NetrwTreeDir(islocal)
if exists("s:treedir")
let treedir= s:treedir
unlet s:treedir
return treedir
endif
if !exists("b:netrw_curdir") || b:netrw_curdir == ""
let b:netrw_curdir= getcwd()
endif
let treedir = b:netrw_curdir
let s:treecurpos= winsaveview()
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
let curline= substitute(getline('.'),"\t -->.*$",'','')
if curline =~ '/$'
let treedir= substitute(getline('.'),'^\%('.s:treedepthstring.'\)*\([^'.s:treedepthstring.'].\{-}\)$','\1','e')
elseif curline =~ '@$'
let treedir= resolve(substitute(substitute(getline('.'),'@.*$','','e'),'^|*\s*','','e'))
else
let treedir= ""
endif
if curline !~ '^'.s:treedepthstring && getline('.') != '..'
sil! NetrwKeepj %d _
return b:netrw_curdir
endif
let potentialdir= s:NetrwFile(substitute(curline,'^'.s:treedepthstring.'\+ \(.*\)@$','\1',''))
let treedir = s:NetrwTreePath(w:netrw_treetop)
endif
let treedir= substitute(treedir,'//$','/','')
return treedir
endfun
fun! s:NetrwTreeDisplay(dir,depth)
setl nofen
if a:depth == ""
call setline(line("$")+1,'../')
endif
if a:dir =~ '^\a\{3,}://'
if a:dir == w:netrw_treetop
let shortdir= a:dir
else
let shortdir= substitute(a:dir,'^.*/\([^/]\+\)/$','\1/','e')
endif
call setline(line("$")+1,a:depth.shortdir)
else
let shortdir= substitute(a:dir,'^.*/','','e')
call setline(line("$")+1,a:depth.shortdir.'/')
endif
let dir= a:dir
let depth= s:treedepthstring.a:depth
for entry in w:netrw_treedict[dir]
if dir =~ '/$'
let direntry= substitute(dir.entry,'[@/]$','','e')
else
let direntry= substitute(dir.'/'.entry,'[@/]$','','e')
endif
if entry =~ '/$' && has_key(w:netrw_treedict,direntry)
NetrwKeepj call s:NetrwTreeDisplay(direntry,depth)
elseif entry =~ '/$' && has_key(w:netrw_treedict,direntry.'/')
NetrwKeepj call s:NetrwTreeDisplay(direntry.'/',depth)
elseif entry =~ '@$' && has_key(w:netrw_treedict,direntry.'@')
NetrwKeepj call s:NetrwTreeDisplay(direntry.'/',depth)
else
sil! NetrwKeepj call setline(line("$")+1,depth.entry)
endif
endfor
endfun
fun! s:NetrwRefreshTreeDict(dir)
for entry in w:netrw_treedict[a:dir]
let direntry= substitute(a:dir.'/'.entry,'[@/]$','','e')
if entry =~ '/$' && has_key(w:netrw_treedict,direntry)
NetrwKeepj call s:NetrwRefreshTreeDict(direntry)
let liststar                   = s:NetrwGlob(direntry,'*',1)
let listdotstar                = s:NetrwGlob(direntry,'.*',1)
let w:netrw_treedict[direntry] = liststar + listdotstar
elseif entry =~ '/$' && has_key(w:netrw_treedict,direntry.'/')
NetrwKeepj call s:NetrwRefreshTreeDict(direntry.'/')
let liststar   = s:NetrwGlob(direntry.'/','*',1)
let listdotstar= s:NetrwGlob(direntry.'/','.*',1)
let w:netrw_treedict[direntry]= liststar + listdotstar
elseif entry =~ '@$' && has_key(w:netrw_treedict,direntry.'@')
NetrwKeepj call s:NetrwRefreshTreeDict(direntry.'/')
let liststar   = s:NetrwGlob(direntry.'/','*',1)
let listdotstar= s:NetrwGlob(direntry.'/','.*',1)
else
endif
endfor
endfun
fun! s:NetrwTreeListing(dirname)
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
if !exists("w:netrw_treetop")
let w:netrw_treetop= a:dirname
elseif (w:netrw_treetop =~ ('^'.a:dirname) && s:Strlen(a:dirname) < s:Strlen(w:netrw_treetop)) || a:dirname !~ ('^'.w:netrw_treetop)
let w:netrw_treetop= a:dirname
endif
if !exists("w:netrw_treedict")
let w:netrw_treedict= {}
endif
exe "sil! NetrwKeepj ".w:netrw_bannercnt.',$g@^\.\.\=/$@d _'
let w:netrw_treedict[a:dirname]= getline(w:netrw_bannercnt,line("$"))
exe "sil! NetrwKeepj ".w:netrw_bannercnt.",$d _"
if exists("w:netrw_bannercnt") && line(".") > w:netrw_bannercnt
let fname= expand("<cword>")
else
let fname= ""
endif
NetrwKeepj call s:NetrwTreeDisplay(w:netrw_treetop,"")
while getline(1) =~ '^\s*$' && byte2line(1) > 0
1d
endwhile
exe "setl ".g:netrw_bufsettings
return
endif
endfun
fun! s:NetrwTreePath(treetop)
let svpos = winsaveview()
let depth = substitute(getline('.'),'^\(\%('.s:treedepthstring.'\)*\)[^'.s:treedepthstring.'].\{-}$','\1','e')
let depth = substitute(depth,'^'.s:treedepthstring,'','')
let curline= getline('.')
if curline =~ '/$'
let treedir= substitute(curline,'^\%('.s:treedepthstring.'\)*\([^'.s:treedepthstring.'].\{-}\)$','\1','e')
elseif curline =~ '@\s\+-->'
let treedir= substitute(curline,'^\%('.s:treedepthstring.'\)*\([^'.s:treedepthstring.'].\{-}\)$','\1','e')
let treedir= substitute(treedir,'@\s\+-->.*$','','e')
else
let treedir= ""
endif
while depth != "" && search('^'.depth.'[^'.s:treedepthstring.'].\{-}/$','bW')
let dirname= substitute(getline('.'),'^\('.s:treedepthstring.'\)*','','e')
let treedir= dirname.treedir
let depth  = substitute(depth,'^'.s:treedepthstring,'','')
endwhile
if a:treetop =~ '/$'
let treedir= a:treetop.treedir
else
let treedir= a:treetop.'/'.treedir
endif
let treedir= substitute(treedir,'//$','/','')
call winrestview(svpos)
return treedir
endfun
fun! s:NetrwWideListing()
if w:netrw_liststyle == s:WIDELIST
setl ma noro
let b:netrw_cpf= 0
if line("$") >= w:netrw_bannercnt
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$g/^./if virtcol("$") > b:netrw_cpf|let b:netrw_cpf= virtcol("$")|endif'
NetrwKeepj call histdel("/",-1)
else
return
endif
let b:netrw_cpf= b:netrw_cpf + 2
let w:netrw_fpl= winwidth(0)/b:netrw_cpf
if w:netrw_fpl <= 0
let w:netrw_fpl= 1
endif
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$s/^.*$/\=escape(printf("%-'.b:netrw_cpf.'S",submatch(0)),"\\")/'
NetrwKeepj call histdel("/",-1)
let fpc         = (line("$") - w:netrw_bannercnt + w:netrw_fpl)/w:netrw_fpl
let newcolstart = w:netrw_bannercnt + fpc
let newcolend   = newcolstart + fpc - 1
if has("clipboard")
sil! let keepregstar = @*
sil! let keepregplus = @+
endif
while line("$") >= newcolstart
if newcolend > line("$") | let newcolend= line("$") | endif
let newcolqty= newcolend - newcolstart
exe newcolstart
if newcolqty == 0
exe "sil! NetrwKeepj norm! 0\<c-v>$hx".w:netrw_bannercnt."G$p"
else
exe "sil! NetrwKeepj norm! 0\<c-v>".newcolqty.'j$hx'.w:netrw_bannercnt.'G$p'
endif
exe "sil! NetrwKeepj ".newcolstart.','.newcolend.'d _'
exe 'sil! NetrwKeepj '.w:netrw_bannercnt
endwhile
if has("clipboard")
sil! let @*= keepregstar
sil! let @+= keepregplus
endif
exe "sil! NetrwKeepj ".w:netrw_bannercnt.',$s/\s\+$//e'
NetrwKeepj call histdel("/",-1)
exe 'nno <buffer> <silent> w	:call search(''^.\\|\s\s\zs\S'',''W'')'."\<cr>"
exe 'nno <buffer> <silent> b	:call search(''^.\\|\s\s\zs\S'',''bW'')'."\<cr>"
exe "setl ".g:netrw_bufsettings
return
else
if hasmapto("w","n")
sil! nunmap <buffer> w
endif
if hasmapto("b","n")
sil! nunmap <buffer> b
endif
endif
endfun
fun! s:PerformListing(islocal)
sil! setl ft=netrw
NetrwKeepj call s:NetrwSafeOptions()
setl noro ma
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST && exists("w:netrw_treedict")
sil! NetrwKeepj %d _
endif
NetrwKeepj call s:NetrwBookHistHandler(3,b:netrw_curdir)
if g:netrw_banner
NetrwKeepj call setline(1,'" ============================================================================')
if exists("g:netrw_pchk")
NetrwKeepj call setline(2,'" Netrw Directory Listing')
else
NetrwKeepj call setline(2,'" Netrw Directory Listing                                        (netrw '.g:loaded_netrw.')')
endif
if exists("g:netrw_pchk")
let curdir= substitute(b:netrw_curdir,expand("$HOME"),'~','')
else
let curdir= b:netrw_curdir
endif
if exists("g:netrw_bannerbackslash") && g:netrw_bannerbackslash
NetrwKeepj call setline(3,'"   '.substitute(curdir,'/','\\','g'))
else
NetrwKeepj call setline(3,'"   '.curdir)
endif
let w:netrw_bannercnt= 3
NetrwKeepj exe "sil! NetrwKeepj ".w:netrw_bannercnt
else
NetrwKeepj 1
let w:netrw_bannercnt= 1
endif
let sortby= g:netrw_sort_by
if g:netrw_sort_direction =~# "^r"
let sortby= sortby." reversed"
endif
if g:netrw_banner
if g:netrw_sort_by =~# "^n"
NetrwKeepj put ='\"   Sorted by      '.sortby
NetrwKeepj put ='\"   Sort sequence: '.g:netrw_sort_sequence
let w:netrw_bannercnt= w:netrw_bannercnt + 2
else
NetrwKeepj put ='\"   Sorted by '.sortby
let w:netrw_bannercnt= w:netrw_bannercnt + 1
endif
exe "sil! NetrwKeepj ".w:netrw_bannercnt
endif
if g:netrw_banner
if exists("s:netrwmftgt") && exists("s:netrwmftgt_islocal")
NetrwKeepj put =''
if s:netrwmftgt_islocal
sil! NetrwKeepj call setline(line("."),'"   Copy/Move Tgt: '.s:netrwmftgt.' (local)')
else
sil! NetrwKeepj call setline(line("."),'"   Copy/Move Tgt: '.s:netrwmftgt.' (remote)')
endif
let w:netrw_bannercnt= w:netrw_bannercnt + 1
else
endif
exe "sil! NetrwKeepj ".w:netrw_bannercnt
endif
if g:netrw_banner
if g:netrw_list_hide != "" && g:netrw_hide
if g:netrw_hide == 1
NetrwKeepj put ='\"   Hiding:        '.g:netrw_list_hide
else
NetrwKeepj put ='\"   Showing:       '.g:netrw_list_hide
endif
let w:netrw_bannercnt= w:netrw_bannercnt + 1
endif
exe "NetrwKeepj ".w:netrw_bannercnt
let quickhelp   = g:netrw_quickhelp%len(s:QuickHelp)
NetrwKeepj put ='\"   Quick Help: <F1>:help  '.s:QuickHelp[quickhelp]
NetrwKeepj put ='\" =============================================================================='
let w:netrw_bannercnt= w:netrw_bannercnt + 2
endif
if g:netrw_banner
let w:netrw_bannercnt= w:netrw_bannercnt + 1
exe "sil! NetrwKeepj ".w:netrw_bannercnt
endif
if a:islocal
NetrwKeepj call s:LocalListing()
else " remote
NetrwKeepj let badresult= s:NetrwRemoteListing()
if badresult
return
endif
endif
if !exists("w:netrw_bannercnt")
let w:netrw_bannercnt= 0
endif
if !g:netrw_banner || line("$") >= w:netrw_bannercnt
if g:netrw_hide && g:netrw_list_hide != ""
NetrwKeepj call s:NetrwListHide()
endif
if !g:netrw_banner || line("$") >= w:netrw_bannercnt
if g:netrw_sort_by =~# "^n"
NetrwKeepj call s:NetrwSetSort()
if !g:netrw_banner || w:netrw_bannercnt < line("$")
if g:netrw_sort_direction =~# 'n'
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$sort'.' '.g:netrw_sort_options
else
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$sort!'.' '.g:netrw_sort_options
endif
endif
exe 'sil! NetrwKeepj '.w:netrw_bannercnt.',$s/^\d\{3}'.g:netrw_sepchr.'//e'
NetrwKeepj call histdel("/",-1)
elseif g:netrw_sort_by =~# "^ext"
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$g+/+s/^/001'.g:netrw_sepchr.'/'
NetrwKeepj call histdel("/",-1)
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$v+[./]+s/^/002'.g:netrw_sepchr.'/'
NetrwKeepj call histdel("/",-1)
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$v+['.g:netrw_sepchr.'/]+s/^\(.*\.\)\(.\{-\}\)$/\2'.g:netrw_sepchr.'&/e'
NetrwKeepj call histdel("/",-1)
if !g:netrw_banner || w:netrw_bannercnt < line("$")
if g:netrw_sort_direction =~# 'n'
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$sort'.' '.g:netrw_sort_options
else
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$sort!'.' '.g:netrw_sort_options
endif
endif
exe 'sil! NetrwKeepj '.w:netrw_bannercnt.',$s/^.\{-}'.g:netrw_sepchr.'//e'
NetrwKeepj call histdel("/",-1)
elseif a:islocal
if !g:netrw_banner || w:netrw_bannercnt < line("$")
if g:netrw_sort_direction =~# 'n'
exe 'sil! NetrwKeepj '.w:netrw_bannercnt.',$sort'.' '.g:netrw_sort_options
else
exe 'sil! NetrwKeepj '.w:netrw_bannercnt.',$sort!'.' '.g:netrw_sort_options
endif
exe 'sil! NetrwKeepj '.w:netrw_bannercnt.',$s/^\d\{-}\///e'
NetrwKeepj call histdel("/",-1)
endif
endif
elseif g:netrw_sort_direction =~# 'r'
if !g:netrw_banner || w:netrw_bannercnt < line('$')
exe 'sil! NetrwKeepj '.w:netrw_bannercnt.',$g/^/m '.w:netrw_bannercnt
call histdel("/",-1)
endif
endif
endif
NetrwKeepj call s:NetrwWideListing()
NetrwKeepj call s:NetrwTreeListing(b:netrw_curdir)
if a:islocal && (w:netrw_liststyle == s:THINLIST || (exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST))
g/@$/call s:ShowLink()
endif
if exists("w:netrw_bannercnt") && (line("$") >= w:netrw_bannercnt || !g:netrw_banner)
exe 'sil! '.w:netrw_bannercnt
sil! NetrwKeepj norm! 0
else
endif
let w:netrw_prvdir= b:netrw_curdir
NetrwKeepj call s:SetBufWinVars()
NetrwKeepj call s:NetrwOptionRestore("w:")
exe "setl ".g:netrw_bufsettings
if g:netrw_liststyle == s:LONGLIST
exe "setl ts=".(g:netrw_maxfilenamelen+1)
endif
if exists("s:treecurpos")
NetrwKeepj call winrestview(s:treecurpos)
unlet s:treecurpos
endif
endfun
fun! s:SetupNetrwStatusLine(statline)
if !exists("s:netrw_setup_statline")
let s:netrw_setup_statline= 1
if !exists("s:netrw_users_stl")
let s:netrw_users_stl= &stl
endif
if !exists("s:netrw_users_ls")
let s:netrw_users_ls= &laststatus
endif
let keepa= @a
redir @a
try
hi User9
catch /^Vim\%((\a\{3,})\)\=:E411/
if &bg == "dark"
hi User9 ctermfg=yellow ctermbg=blue guifg=yellow guibg=blue
else
hi User9 ctermbg=yellow ctermfg=blue guibg=yellow guifg=blue
endif
endtry
redir END
let @a= keepa
endif
let &stl=a:statline
setl laststatus=2
redraw
endfun
fun! s:NetrwRemoteFtpCmd(path,listcmd)
if !exists("w:netrw_method")
if exists("b:netrw_method")
let w:netrw_method= b:netrw_method
else
call netrw#ErrorMsg(2,"(s:NetrwRemoteFtpCmd) internal netrw error",93)
return
endif
endif
let ffkeep= &ff
setl ma ff=unix noro
exe "sil! NetrwKeepj ".w:netrw_bannercnt.",$d _"
if w:netrw_method == 2 || w:netrw_method == 5	" {{{3
if a:path != ""
NetrwKeepj put ='cd \"'.a:path.'\"'
endif
if exists("g:netrw_ftpextracmd")
NetrwKeepj put =g:netrw_ftpextracmd
endif
NetrwKeepj call setline(line("$")+1,a:listcmd)
if exists("g:netrw_port") && g:netrw_port != ""
exe s:netrw_silentxfer." NetrwKeepj ".w:netrw_bannercnt.",$!".s:netrw_ftp_cmd." -i ".s:ShellEscape(g:netrw_machine,1)." ".s:ShellEscape(g:netrw_port,1)
else
exe s:netrw_silentxfer." NetrwKeepj ".w:netrw_bannercnt.",$!".s:netrw_ftp_cmd." -i ".s:ShellEscape(g:netrw_machine,1)
endif
elseif w:netrw_method == 3	" {{{3
setl ff=unix
if exists("g:netrw_port") && g:netrw_port != ""
NetrwKeepj put ='open '.g:netrw_machine.' '.g:netrw_port
else
NetrwKeepj put ='open '.g:netrw_machine
endif
let host= substitute(g:netrw_machine,'\..*$','','')
if exists("s:netrw_hup") && exists("s:netrw_hup[host]")
call NetUserPass("ftp:".host)
endif
if exists("g:netrw_uid") && g:netrw_uid != ""
if exists("g:netrw_ftp") && g:netrw_ftp == 1
NetrwKeepj put =g:netrw_uid
if exists("s:netrw_passwd") && s:netrw_passwd != ""
NetrwKeepj put ='\"'.s:netrw_passwd.'\"'
endif
elseif exists("s:netrw_passwd")
NetrwKeepj put ='user \"'.g:netrw_uid.'\" \"'.s:netrw_passwd.'\"'
endif
endif
if a:path != ""
NetrwKeepj put ='cd \"'.a:path.'\"'
endif
if exists("g:netrw_ftpextracmd")
NetrwKeepj put =g:netrw_ftpextracmd
endif
NetrwKeepj call setline(line("$")+1,a:listcmd)
if exists("w:netrw_bannercnt")
call s:NetrwExe(s:netrw_silentxfer.w:netrw_bannercnt.",$!".s:netrw_ftp_cmd." ".g:netrw_ftp_options)
endif
elseif w:netrw_method == 9	" {{{3
setl ff=unix
let &ff= ffkeep
return
else	" {{{3
NetrwKeepj call netrw#ErrorMsg(s:WARNING,"unable to comply with your request<" . bufname("%") . ">",23)
endif
if has("win32") || has("win95") || has("win64") || has("win16")
sil! NetrwKeepj %s/\r$//e
NetrwKeepj call histdel("/",-1)
endif
if a:listcmd == "dir"
sil! NetrwKeepj g/d\%([-r][-w][-x]\)\{3}/NetrwKeepj s@$@/@e
sil! NetrwKeepj g/l\%([-r][-w][-x]\)\{3}/NetrwKeepj s/$/@/e
NetrwKeepj call histdel("/",-1)
NetrwKeepj call histdel("/",-1)
if w:netrw_liststyle == s:THINLIST || w:netrw_liststyle == s:WIDELIST || (exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST)
exe "sil! NetrwKeepj ".w:netrw_bannercnt.',$s/^\%(\S\+\s\+\)\{8}//e'
NetrwKeepj call histdel("/",-1)
endif
endif
if !search('^\.\/$\|\s\.\/$','wn')
exe 'NetrwKeepj '.w:netrw_bannercnt
NetrwKeepj put ='./'
endif
if !search('^\.\.\/$\|\s\.\.\/$','wn')
exe 'NetrwKeepj '.w:netrw_bannercnt
NetrwKeepj put ='../'
endif
let &ff= ffkeep
endfun
fun! s:NetrwRemoteListing()
if !exists("w:netrw_bannercnt") && exists("s:bannercnt")
let w:netrw_bannercnt= s:bannercnt
endif
if !exists("w:netrw_bannercnt") && exists("b:bannercnt")
let w:netrw_bannercnt= s:bannercnt
endif
call s:RemotePathAnalysis(b:netrw_curdir)
if exists("b:netrw_method") && b:netrw_method =~ '[235]'
if !executable("ftp")
if !exists("g:netrw_quiet")
call netrw#ErrorMsg(s:ERROR,"this system doesn't support remote directory listing via ftp",18)
endif
call s:NetrwOptionRestore("w:")
return -1
endif
elseif !exists("g:netrw_list_cmd") || g:netrw_list_cmd == ''
if !exists("g:netrw_quiet")
if g:netrw_list_cmd == ""
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"your g:netrw_list_cmd is empty; perhaps ".g:netrw_ssh_cmd." is not executable on your system",47)
else
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"this system doesn't support remote directory listing via ".g:netrw_list_cmd,19)
endif
endif
NetrwKeepj call s:NetrwOptionRestore("w:")
return -1
endif  " (remote handling sanity check)
if exists("b:netrw_method")
let w:netrw_method= b:netrw_method
endif
if s:method == "ftp"
let s:method  = "ftp"
let listcmd = g:netrw_ftp_list_cmd
if g:netrw_sort_by =~# '^t'
let listcmd= g:netrw_ftp_timelist_cmd
elseif g:netrw_sort_by =~# '^s'
let listcmd= g:netrw_ftp_sizelist_cmd
endif
call s:NetrwRemoteFtpCmd(s:path,listcmd)
if search('[Nn]o such file or directory\|Failed to change directory')
let mesg= getline(".")
if exists("w:netrw_bannercnt")
setl ma
exe w:netrw_bannercnt.",$d _"
setl noma
endif
NetrwKeepj call s:NetrwOptionRestore("w:")
call netrw#ErrorMsg(s:WARNING,mesg,96)
return -1
endif
if w:netrw_liststyle == s:THINLIST || w:netrw_liststyle == s:WIDELIST || (exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST)
exe "sil! keepalt NetrwKeepj ".w:netrw_bannercnt
if g:netrw_ftp_browse_reject != ""
exe "sil! keepalt NetrwKeepj g/".g:netrw_ftp_browse_reject."/NetrwKeepj d"
NetrwKeepj call histdel("/",-1)
endif
sil! NetrwKeepj %s/\r$//e
NetrwKeepj call histdel("/",-1)
let line1= line(".")
exe "sil! NetrwKeepj ".w:netrw_bannercnt
let line2= search('\.\.\/\%(\s\|$\)','cnW')
if line2 == 0
sil! NetrwKeepj put='../'
endif
exe "sil! NetrwKeepj ".line1
sil! NetrwKeepj norm! 0
if search('^\d\{2}-\d\{2}-\d\{2}\s','n') " M$ ftp site cleanup
exe 'sil! NetrwKeepj '.w:netrw_bannercnt.',$s/^\d\{2}-\d\{2}-\d\{2}\s\+\d\+:\d\+[AaPp][Mm]\s\+\%(<DIR>\|\d\+\)\s\+//'
NetrwKeepj call histdel("/",-1)
else " normal ftp cleanup
exe 'sil! NetrwKeepj '.w:netrw_bannercnt.',$s/^\(\%(\S\+\s\+\)\{7}\S\+\)\s\+\(\S.*\)$/\2/e'
exe "sil! NetrwKeepj ".w:netrw_bannercnt.',$g/ -> /s# -> .*/$#/#e'
exe "sil! NetrwKeepj ".w:netrw_bannercnt.',$g/ -> /s# -> .*$#/#e'
NetrwKeepj call histdel("/",-1)
NetrwKeepj call histdel("/",-1)
NetrwKeepj call histdel("/",-1)
endif
endif
else
let listcmd= s:MakeSshCmd(g:netrw_list_cmd)
if g:netrw_scp_cmd =~ '^pscp'
exe "NetrwKeepj r! ".listcmd.s:ShellEscape(s:path, 1)
sil! NetrwKeepj g/^Listing directory/NetrwKeepj d
sil! NetrwKeepj g/^d[-rwx][-rwx][-rwx]/NetrwKeepj s+$+/+e
sil! NetrwKeepj g/^l[-rwx][-rwx][-rwx]/NetrwKeepj s+$+@+e
NetrwKeepj call histdel("/",-1)
NetrwKeepj call histdel("/",-1)
NetrwKeepj call histdel("/",-1)
if g:netrw_liststyle != s:LONGLIST
sil! NetrwKeepj g/^[dlsp-][-rwx][-rwx][-rwx]/NetrwKeepj s/^.*\s\(\S\+\)$/\1/e
NetrwKeepj call histdel("/",-1)
endif
else
if s:path == ""
exe "NetrwKeepj keepalt r! ".listcmd
else
exe "NetrwKeepj keepalt r! ".listcmd.' '.s:ShellEscape(fnameescape(s:path),1)
endif
endif
if g:netrw_ssh_browse_reject != ""
exe "sil! g/".g:netrw_ssh_browse_reject."/NetrwKeepj d"
NetrwKeepj call histdel("/",-1)
endif
endif
if w:netrw_liststyle == s:LONGLIST
if s:method == "ftp"
exe "sil! NetrwKeepj ".w:netrw_bannercnt
while getline('.') =~# g:netrw_ftp_browse_reject
sil! NetrwKeepj d
endwhile
let line1= line(".")
sil! NetrwKeepj 1
sil! NetrwKeepj call search('^\.\.\/\%(\s\|$\)','W')
let line2= line(".")
if line2 == 0
if b:netrw_curdir != '/'
exe 'sil! NetrwKeepj '.w:netrw_bannercnt."put='../'"
endif
endif
exe "sil! NetrwKeepj ".line1
sil! NetrwKeepj norm! 0
endif
if search('^\d\{2}-\d\{2}-\d\{2}\s','n') " M$ ftp site cleanup
exe 'sil! NetrwKeepj '.w:netrw_bannercnt.',$s/^\(\d\{2}-\d\{2}-\d\{2}\s\+\d\+:\d\+[AaPp][Mm]\s\+\%(<DIR>\|\d\+\)\s\+\)\(\w.*\)$/\2\t\1/'
elseif exists("w:netrw_bannercnt") && w:netrw_bannercnt <= line("$")
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$s/ -> .*$//e'
exe 'sil NetrwKeepj '.w:netrw_bannercnt.',$s/^\(\%(\S\+\s\+\)\{7}\S\+\)\s\+\(\S.*\)$/\2 \t\1/e'
exe 'sil NetrwKeepj '.w:netrw_bannercnt
NetrwKeepj call histdel("/",-1)
NetrwKeepj call histdel("/",-1)
NetrwKeepj call histdel("/",-1)
endif
endif
return 0
endfun
fun! s:NetrwRemoteRm(usrhost,path) range
let svpos= winsaveview()
let all= 0
if exists("s:netrwmarkfilelist_{bufnr('%')}")
for fname in s:netrwmarkfilelist_{bufnr("%")}
let ok= s:NetrwRemoteRmFile(a:path,fname,all)
if ok =~# 'q\%[uit]'
break
elseif ok =~# 'a\%[ll]'
let all= 1
endif
endfor
call s:NetrwUnmarkList(bufnr("%"),b:netrw_curdir)
else
let keepsol = &l:sol
setl nosol
let ctr    = a:firstline
while ctr <= a:lastline
exe "NetrwKeepj ".ctr
let ok= s:NetrwRemoteRmFile(a:path,s:NetrwGetWord(),all)
if ok =~# 'q\%[uit]'
break
elseif ok =~# 'a\%[ll]'
let all= 1
endif
let ctr= ctr + 1
endwhile
let &l:sol = keepsol
endif
NetrwKeepj call s:NetrwRefresh(0,s:NetrwBrowseChgDir(0,'./'))
NetrwKeepj call winrestview(svpos)
endfun
fun! s:NetrwRemoteRmFile(path,rmfile,all)
let all= a:all
let ok = ""
if a:rmfile !~ '^"' && (a:rmfile =~ '@$' || a:rmfile !~ '[\/]$')
if !all
echohl Statement
call inputsave()
let ok= input("Confirm deletion of file<".a:rmfile."> ","[{y(es)},n(o),a(ll),q(uit)] ")
call inputrestore()
echohl NONE
if ok == ""
let ok="no"
endif
let ok= substitute(ok,'\[{y(es)},n(o),a(ll),q(uit)]\s*','','e')
if ok =~# 'a\%[ll]'
let all= 1
endif
endif
if all || ok =~# 'y\%[es]' || ok == ""
if exists("w:netrw_method") && (w:netrw_method == 2 || w:netrw_method == 3)
let path= a:path
if path =~ '^\a\{3,}://'
let path= substitute(path,'^\a\{3,}://[^/]\+/','','')
endif
sil! NetrwKeepj .,$d _
call s:NetrwRemoteFtpCmd(path,"delete ".'"'.a:rmfile.'"')
else
let netrw_rm_cmd= s:MakeSshCmd(g:netrw_rm_cmd)
if !exists("b:netrw_curdir")
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"for some reason b:netrw_curdir doesn't exist!",53)
let ok="q"
else
let remotedir= substitute(b:netrw_curdir,'^.*//[^/]\+/\(.*\)$','\1','')
if remotedir != ""
let netrw_rm_cmd= netrw_rm_cmd." ".s:ShellEscape(fnameescape(remotedir.a:rmfile))
else
let netrw_rm_cmd= netrw_rm_cmd." ".s:ShellEscape(fnameescape(a:rmfile))
endif
let ret= system(netrw_rm_cmd)
if v:shell_error != 0
if exists("b:netrw_curdir") && b:netrw_curdir != getcwd() && !g:netrw_keepdir
call netrw#ErrorMsg(s:ERROR,"remove failed; perhaps due to vim's current directory<".getcwd()."> not matching netrw's (".b:netrw_curdir.") (see :help netrw-c)",102)
else
call netrw#ErrorMsg(s:WARNING,"cmd<".netrw_rm_cmd."> failed",60)
endif
elseif ret != 0
call netrw#ErrorMsg(s:WARNING,"cmd<".netrw_rm_cmd."> failed",60)
endif
endif
endif
elseif ok =~# 'q\%[uit]'
endif
else
if !all
call inputsave()
let ok= input("Confirm deletion of directory<".a:rmfile."> ","[{y(es)},n(o),a(ll),q(uit)] ")
call inputrestore()
if ok == ""
let ok="no"
endif
let ok= substitute(ok,'\[{y(es)},n(o),a(ll),q(uit)]\s*','','e')
if ok =~# 'a\%[ll]'
let all= 1
endif
endif
if all || ok =~# 'y\%[es]' || ok == ""
if exists("w:netrw_method") && (w:netrw_method == 2 || w:netrw_method == 3)
NetrwKeepj call s:NetrwRemoteFtpCmd(a:path,"rmdir ".a:rmfile)
else
let rmfile          = substitute(a:path.a:rmfile,'/$','','')
let netrw_rmdir_cmd = s:MakeSshCmd(netrw#WinPath(g:netrw_rmdir_cmd)).' '.s:ShellEscape(netrw#WinPath(rmfile))
let ret= system(netrw_rmdir_cmd)
if v:shell_error != 0
let netrw_rmf_cmd= s:MakeSshCmd(netrw#WinPath(g:netrw_rmf_cmd)).' '.s:ShellEscape(netrw#WinPath(substitute(rmfile,'[\/]$','','e')))
let ret= system(netrw_rmf_cmd)
if v:shell_error != 0 && !exists("g:netrw_quiet")
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"unable to remove directory<".rmfile."> -- is it empty?",22)
endif
endif
endif
elseif ok =~# 'q\%[uit]'
endif
endif
return ok
endfun
fun! s:NetrwRemoteRename(usrhost,path) range
let svpos      = winsaveview()
let ctr        = a:firstline
let rename_cmd = s:MakeSshCmd(g:netrw_rename_cmd)
if exists("s:netrwmarkfilelist_{bufnr('%')}")
for oldname in s:netrwmarkfilelist_{bufnr("%")}
if exists("subfrom")
let newname= substitute(oldname,subfrom,subto,'')
else
call inputsave()
let newname= input("Moving ".oldname." to : ",oldname)
call inputrestore()
if newname =~ '^s/'
let subfrom = substitute(newname,'^s/\([^/]*\)/.*/$','\1','')
let subto   = substitute(newname,'^s/[^/]*/\(.*\)/$','\1','')
let newname = substitute(oldname,subfrom,subto,'')
endif
endif
if exists("w:netrw_method") && (w:netrw_method == 2 || w:netrw_method == 3)
NetrwKeepj call s:NetrwRemoteFtpCmd(a:path,"rename ".oldname." ".newname)
else
let oldname= s:ShellEscape(a:path.oldname)
let newname= s:ShellEscape(a:path.newname)
let ret    = system(netrw#WinPath(rename_cmd).' '.oldname.' '.newname)
endif
endfor
call s:NetrwUnMarkFile(1)
else
let keepsol= &l:sol
setl nosol
while ctr <= a:lastline
exe "NetrwKeepj ".ctr
let oldname= s:NetrwGetWord()
call inputsave()
let newname= input("Moving ".oldname." to : ",oldname)
call inputrestore()
if exists("w:netrw_method") && (w:netrw_method == 2 || w:netrw_method == 3)
call s:NetrwRemoteFtpCmd(a:path,"rename ".oldname." ".newname)
else
let oldname= s:ShellEscape(a:path.oldname)
let newname= s:ShellEscape(a:path.newname)
let ret    = system(netrw#WinPath(rename_cmd).' '.oldname.' '.newname)
endif
let ctr= ctr + 1
endwhile
let &l:sol= keepsol
endif
NetrwKeepj call s:NetrwRefresh(0,s:NetrwBrowseChgDir(0,'./'))
NetrwKeepj call winrestview(svpos)
endfun
fun! netrw#FileUrlRead(fname)
let fname = a:fname
if fname =~ '^file://localhost/'
let fname= substitute(fname,'^file://localhost/','file:///','')
endif
if (has("win32") || has("win95") || has("win64") || has("win16"))
if fname  =~ '^file:///\=\a[|:]/'
let fname = substitute(fname,'^file:///\=\(\a\)[|:]/','file://\1:/','')
endif
endif
let fname2396 = netrw#RFC2396(fname)
let fname2396e= fnameescape(fname2396)
let plainfname= substitute(fname2396,'file://\(.*\)','\1',"")
if (has("win32") || has("win95") || has("win64") || has("win16"))
if plainfname =~ '^/\+\a:'
let plainfname= substitute(plainfname,'^/\+\(\a:\)','\1','')
endif
endif
exe "sil doau BufReadPre ".fname2396e
exe 'NetrwKeepj r '.plainfname
exe 'sil! bdelete '.plainfname
exe 'keepalt file! '.plainfname
NetrwKeepj 1d
setl nomod
exe "sil doau BufReadPost ".fname2396e
endfun
fun! netrw#LocalBrowseCheck(dirname)
let ykeep= @@
if isdirectory(s:NetrwFile(a:dirname))
if &ft != "netrw" || (exists("b:netrw_curdir") && b:netrw_curdir != a:dirname) || g:netrw_fastbrowse <= 1
sil! NetrwKeepj keepalt call s:NetrwBrowse(1,a:dirname)
elseif &ft == "netrw" && line("$") == 1
sil! NetrwKeepj keepalt call s:NetrwBrowse(1,a:dirname)
elseif exists("s:treeforceredraw")
unlet s:treeforceredraw
sil! NetrwKeepj keepalt call s:NetrwBrowse(1,a:dirname)
endif
return
endif
if exists("g:netrw_fastbrowse") && g:netrw_fastbrowse == 0 && g:netrw_liststyle != s:TREELIST
let ibuf    = 1
let buflast = bufnr("$")
while ibuf <= buflast
if bufwinnr(ibuf) == -1 && isdirectory(s:NetrwFile(bufname(ibuf)))
exe "sil! keepj keepalt ".ibuf."bw!"
endif
let ibuf= ibuf + 1
endwhile
endif
let @@= ykeep
endfun
fun! s:LocalBrowseRefresh()
if !exists("s:netrw_browselist")
return
endif
if !exists("w:netrw_bannercnt")
return
endif
if exists("s:netrw_events") && s:netrw_events == 1
let s:netrw_events= 2
return
endif
let itab       = 1
let buftablist = []
let ykeep      = @@
while itab <= tabpagenr("$")
let buftablist = buftablist + tabpagebuflist()
let itab       = itab + 1
tabn
endwhile
let curwin = winnr()
let ibl    = 0
for ibuf in s:netrw_browselist
if bufwinnr(ibuf) == -1 && index(buftablist,ibuf) == -1
exe "sil! keepj bd ".fnameescape(ibuf)
call remove(s:netrw_browselist,ibl)
continue
elseif index(tabpagebuflist(),ibuf) != -1
exe bufwinnr(ibuf)."wincmd w"
if getline(".") =~# 'Quick Help'
let g:netrw_quickhelp= g:netrw_quickhelp - 1
endif
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
NetrwKeepj call s:NetrwRefreshTreeDict(w:netrw_treetop)
endif
NetrwKeepj call s:NetrwRefresh(1,s:NetrwBrowseChgDir(1,'./'))
endif
let ibl= ibl + 1
endfor
exe curwin."wincmd w"
let @@= ykeep
endfun
fun! s:LocalFastBrowser()
if !exists("s:netrw_browselist")
let s:netrw_browselist= []
endif
if empty(s:netrw_browselist) || bufnr("%") > s:netrw_browselist[-1]
call add(s:netrw_browselist,bufnr("%"))
endif
if g:netrw_fastbrowse <= 1 && !exists("#ShellCmdPost") && !exists("s:netrw_events")
let s:netrw_events= 1
augroup AuNetrwEvent
au!
if (has("win32") || has("win95") || has("win64") || has("win16"))
au ShellCmdPost			*	call s:LocalBrowseRefresh()
else
au ShellCmdPost,FocusGained	*	call s:LocalBrowseRefresh()
endif
augroup END
elseif g:netrw_fastbrowse > 1 && exists("#ShellCmdPost") && exists("s:netrw_events")
unlet s:netrw_events
augroup AuNetrwEvent
au!
augroup END
augroup! AuNetrwEvent
endif
endfun
fun! s:LocalListing()
let dirname    = b:netrw_curdir
let dirnamelen = strlen(b:netrw_curdir)
let filelist   = s:NetrwGlob(dirname,"*",0)
let filelist   = filelist + s:NetrwGlob(dirname,".*",0)
if g:netrw_cygwin == 0 && (has("win32") || has("win95") || has("win64") || has("win16"))
elseif index(filelist,'..') == -1 && b:netrw_curdir !~ '/'
let filelist= filelist+[s:ComposePath(b:netrw_curdir,"../")]
endif
if get(g:, 'netrw_dynamic_maxfilenamelen', 0)
let filelistcopy           = map(deepcopy(filelist),'fnamemodify(v:val, ":t")')
let g:netrw_maxfilenamelen = max(map(filelistcopy,'len(v:val)')) + 1
endif
for filename in filelist
if getftype(filename) == "link"
let pfile= filename."@"
elseif getftype(filename) == "socket"
let pfile= filename."="
elseif getftype(filename) == "fifo"
let pfile= filename."|"
elseif isdirectory(s:NetrwFile(filename))
let pfile= filename."/"
elseif exists("b:netrw_curdir") && b:netrw_curdir !~ '^.*://' && !isdirectory(s:NetrwFile(filename))
if (has("win32") || has("win95") || has("win64") || has("win16"))
if filename =~ '\.[eE][xX][eE]$' || filename =~ '\.[cC][oO][mM]$' || filename =~ '\.[bB][aA][tT]$'
let pfile= filename."*"
else
let pfile= filename
endif
elseif executable(filename)
let pfile= filename."*"
else
let pfile= filename
endif
else
let pfile= filename
endif
if pfile =~ '//$'
let pfile= substitute(pfile,'//$','/','e')
endif
let pfile= strpart(pfile,dirnamelen)
let pfile= substitute(pfile,'^[/\\]','','e')
if w:netrw_liststyle == s:LONGLIST
let sz   = getfsize(filename)
if g:netrw_sizestyle =~# "[hH]"
let sz= s:NetrwHumanReadable(sz)
endif
let fsz  = strpart("               ",1,15-strlen(sz)).sz
let pfile= pfile."\t".fsz." ".strftime(g:netrw_timefmt,getftime(filename))
endif
if     g:netrw_sort_by =~# "^t"
let t  = getftime(filename)
let ft = strpart("000000000000000000",1,18-strlen(t)).t
let ftpfile= ft.'/'.pfile
sil! NetrwKeepj put=ftpfile
elseif g:netrw_sort_by =~ "^s"
let sz   = getfsize(filename)
if g:netrw_sizestyle =~# "[hH]"
let sz= s:NetrwHumanReadable(sz)
endif
let fsz  = strpart("000000000000000000",1,18-strlen(sz)).sz
let fszpfile= fsz.'/'.pfile
sil! NetrwKeepj put =fszpfile
else
sil! NetrwKeepj put=pfile
endif
endfor
sil! NetrwKeepj g/^$/d
sil! NetrwKeepj %s/\r$//e
call histdel("/",-1)
exe "setl ts=".(g:netrw_maxfilenamelen+1)
endfun
fun! s:NetrwLocalExecute(cmd)
let ykeep= @@
if !executable(a:cmd)
call netrw#ErrorMsg(s:ERROR,"the file<".a:cmd."> is not executable!",89)
let @@= ykeep
return
endif
let optargs= input(":!".a:cmd,"","file")
let result= system(a:cmd.optargs)
let result = substitute(result,"\e\\[[0-9;]*m","","g")
echomsg result
let @@= ykeep
endfun
fun! s:NetrwLocalRename(path) range
let ykeep    = @@
let ctr      = a:firstline
let svpos    = winsaveview()
if exists("s:netrwmarkfilelist_{bufnr('%')}")
for oldname in s:netrwmarkfilelist_{bufnr("%")}
if exists("subfrom")
let newname= substitute(oldname,subfrom,subto,'')
else
call inputsave()
let newname= input("Moving ".oldname." to : ",oldname,"file")
call inputrestore()
if newname =~ ''
let newname = substitute(newname,'^.*','','')
elseif newname =~ ''
let newname = substitute(newname,'[^/]*','','')
endif
if newname =~ '^s/'
let subfrom = substitute(newname,'^s/\([^/]*\)/.*/$','\1','')
let subto   = substitute(newname,'^s/[^/]*/\(.*\)/$','\1','')
let newname = substitute(oldname,subfrom,subto,'')
endif
endif
call rename(oldname,newname)
endfor
call s:NetrwUnmarkList(bufnr("%"),b:netrw_curdir)
else
while ctr <= a:lastline
exe "NetrwKeepj ".ctr
if line(".") < w:netrw_bannercnt
let ctr= ctr + 1
continue
endif
let curword= s:NetrwGetWord()
if curword == "./" || curword == "../"
let ctr= ctr + 1
continue
endif
NetrwKeepj norm! 0
let oldname= s:ComposePath(a:path,curword)
call inputsave()
let newname= input("Moving ".oldname." to : ",substitute(oldname,'/*$','','e'))
call inputrestore()
call rename(oldname,newname)
let ctr= ctr + 1
endwhile
endif
NetrwKeepj call s:NetrwRefresh(1,s:NetrwBrowseChgDir(1,'./'))
NetrwKeepj call winrestview(svpos)
let @@= ykeep
endfun
fun! s:NetrwLocalRm(path) range
let ykeep = @@
let ret   = 0
let all   = 0
let svpos = winsaveview()
if exists("s:netrwmarkfilelist_{bufnr('%')}")
for fname in s:netrwmarkfilelist_{bufnr("%")}
let ok= s:NetrwLocalRmFile(a:path,fname,all)
if ok =~# 'q\%[uit]' || ok == "no"
break
elseif ok =~# 'a\%[ll]'
let all= 1
endif
endfor
call s:NetrwUnMarkFile(1)
else
let keepsol= &l:sol
setl nosol
let ctr = a:firstline
while ctr <= a:lastline
exe "NetrwKeepj ".ctr
if line(".") < w:netrw_bannercnt
let ctr= ctr + 1
continue
endif
let curword= s:NetrwGetWord()
if curword == "./" || curword == "../"
let ctr= ctr + 1
continue
endif
let ok= s:NetrwLocalRmFile(a:path,curword,all)
if ok =~# 'q\%[uit]' || ok == "no"
break
elseif ok =~# 'a\%[ll]'
let all= 1
endif
let ctr= ctr + 1
endwhile
let &l:sol= keepsol
endif
if bufname("%") != "NetrwMessage"
NetrwKeepj call s:NetrwRefresh(1,s:NetrwBrowseChgDir(1,'./'))
NetrwKeepj call winrestview(svpos)
endif
let @@= ykeep
endfun
fun! s:NetrwLocalRmFile(path,fname,all)
let all= a:all
let ok = ""
NetrwKeepj norm! 0
let rmfile= s:NetrwFile(s:ComposePath(a:path,a:fname))
if rmfile !~ '^"' && (rmfile =~ '@$' || rmfile !~ '[\/]$')
if !all
echohl Statement
call inputsave()
let ok= input("Confirm deletion of file<".rmfile."> ","[{y(es)},n(o),a(ll),q(uit)] ")
call inputrestore()
echohl NONE
if ok == ""
let ok="no"
endif
let ok= substitute(ok,'\[{y(es)},n(o),a(ll),q(uit)]\s*','','e')
if ok =~# 'a\%[ll]'
let all= 1
endif
endif
if all || ok =~# 'y\%[es]' || ok == ""
let ret= s:NetrwDelete(rmfile)
endif
else
if !all
echohl Statement
call inputsave()
let ok= input("Confirm deletion of directory<".rmfile."> ","[{y(es)},n(o),a(ll),q(uit)] ")
call inputrestore()
let ok= substitute(ok,'\[{y(es)},n(o),a(ll),q(uit)]\s*','','e')
if ok == ""
let ok="no"
endif
if ok =~# 'a\%[ll]'
let all= 1
endif
endif
let rmfile= substitute(rmfile,'[\/]$','','e')
if all || ok =~# 'y\%[es]' || ok == ""
if v:version < 704 || !has("patch1109")
call system(netrw#WinPath(g:netrw_localrmdir).' '.s:ShellEscape(rmfile))
if v:shell_error != 0
let errcode= s:NetrwDelete(rmfile)
if errcode != 0
if has("unix")
call system("rm ".s:ShellEscape(rmfile))
if v:shell_error != 0 && !exists("g:netrw_quiet")
call netrw#ErrorMsg(s:ERROR,"unable to remove directory<".rmfile."> -- is it empty?",34)
let ok="no"
endif
elseif !exists("g:netrw_quiet")
call netrw#ErrorMsg(s:ERROR,"unable to remove directory<".rmfile."> -- is it empty?",35)
let ok="no"
endif
endif
endif
else
if delete(rmfile,"d")
call netrw#ErrorMsg(s:ERROR,"unable to delete directory <".rmfile.">!",103)
endif
endif
endif
endif
return ok
endfun
fun! s:WinNames(id)
let curwin= winnr()
1wincmd w
exe curwin."wincmd w"
endfun
fun! netrw#Access(ilist)
if     a:ilist == 0
if exists("s:netrwmarkfilelist_".bufnr('%'))
return s:netrwmarkfilelist_{bufnr('%')}
else
return "no-list-buf#".bufnr('%')
endif
elseif a:ilist == 1
return s:netrwmftgt
endfun
fun! netrw#Call(funcname,...)
if a:0 > 0
exe "call s:".a:funcname."(".string(a:000).")"
else
exe "call s:".a:funcname."()"
endif
endfun
fun! netrw#Expose(varname)
if exists("s:".a:varname)
exe "let retval= s:".a:varname
if exists("g:netrw_pchk")
if type(retval) == 3
let retval = copy(retval)
let i      = 0
while i < len(retval)
let retval[i]= substitute(retval[i],expand("$HOME"),'~','')
let i        = i + 1
endwhile
endif
return string(retval)
endif
else
let retval= "n/a"
endif
return retval
endfun
fun! netrw#Modify(varname,newvalue)
exe "let s:".a:varname."= ".string(a:newvalue)
endfun
fun! netrw#RFC2396(fname)
let fname = escape(substitute(a:fname,'%\(\x\x\)','\=nr2char("0x".submatch(1))','ge')," \t")
return fname
endfun
fun! netrw#UserMaps(islocal)
if exists("g:Netrw_UserMaps") && type(g:Netrw_UserMaps) == 3
for umap in g:Netrw_UserMaps
if type(umap[0]) == 1 && type(umap[1]) == 1
exe "nno <buffer> <silent> ".umap[0]." :call <SID>UserMaps(".a:islocal.",'".umap[1]."')<cr>"
else
call netrw#ErrorMsg(s:WARNING,"ignoring usermap <".string(umap[0])."> -- not a [string,funcref] entry",99)
endif
endfor
endif
endfun
fun! netrw#WinPath(path)
if (!g:netrw_cygwin || &shell !~ '\%(\<bash\>\|\<zsh\>\)\%(\.exe\)\=$') && (has("win32") || has("win95") || has("win64") || has("win16"))
let path = substitute(a:path,g:netrw_cygdrive.'/\(.\)','\1:','')
let path = substitute(path, '\(\\\|/\)$', '', 'g')
let path = substitute(path, '\ ', ' ', 'g')
let path = substitute(path, '/', '\', 'g')
else
let path= a:path
endif
return path
endfun
fun! s:ComposePath(base,subdir)
if has("amiga")
let ec = a:base[s:Strlen(a:base)-1]
if ec != '/' && ec != ':'
let ret = a:base."/" . a:subdir
else
let ret = a:base.a:subdir
endif
elseif a:subdir =~ '^\a:[/\\][^/\\]' && (has("win32") || has("win95") || has("win64") || has("win16"))
let ret= a:subdir
elseif a:base =~ '^\a:[/\\][^/\\]' && (has("win32") || has("win95") || has("win64") || has("win16"))
if a:base =~ '[/\\]$'
let ret= a:base.a:subdir
else
let ret= a:base.'/'.a:subdir
endif
elseif a:base =~ '^\a\{3,}://'
let urlbase = substitute(a:base,'^\(\a\+://.\{-}/\)\(.*\)$','\1','')
let curpath = substitute(a:base,'^\(\a\+://.\{-}/\)\(.*\)$','\2','')
if a:subdir == '../'
if curpath =~ '[^/]/[^/]\+/$'
let curpath= substitute(curpath,'[^/]\+/$','','')
else
let curpath=""
endif
let ret= urlbase.curpath
else
let ret= urlbase.curpath.a:subdir
endif
else
let ret = substitute(a:base."/".a:subdir,"//","/","g")
if a:base =~ '^//'
let ret= '/'.ret
endif
let ret= simplify(ret)
endif
return ret
endfun
fun! s:DeleteBookmark(fname)
call s:MergeBookmarks()
if exists("g:netrw_bookmarklist")
let indx= index(g:netrw_bookmarklist,a:fname)
if indx == -1
let indx= 0
while indx < len(g:netrw_bookmarklist)
if g:netrw_bookmarklist[indx] =~ a:fname
call remove(g:netrw_bookmarklist,indx)
let indx= indx - 1
endif
let indx= indx + 1
endwhile
else
call remove(g:netrw_bookmarklist,indx)
endif
endif
endfun
fun! s:FileReadable(fname)
if g:netrw_cygwin
let ret= filereadable(s:NetrwFile(substitute(a:fname,g:netrw_cygdrive.'/\(.\)','\1:/','')))
else
let ret= filereadable(s:NetrwFile(a:fname))
endif
return ret
endfun
fun! s:GetTempfile(fname)
if !exists("b:netrw_tmpfile")
let tmpfile= tempname()
let tmpfile= substitute(tmpfile,'\','/','ge')
if !isdirectory(s:NetrwFile(substitute(tmpfile,'[^/]\+$','','e')))
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"your <".substitute(tmpfile,'[^/]\+$','','e')."> directory is missing!",2)
return ""
endif
let s:netrw_tmpfile= tmpfile " used by netrw#NetSource() and netrw#BrowseX()
if g:netrw_cygwin != 0
let tmpfile = substitute(tmpfile,'^\(\a\):',g:netrw_cygdrive.'/\1','e')
elseif has("win32") || has("win95") || has("win64") || has("win16")
if !exists("+shellslash") || !&ssl
let tmpfile = substitute(tmpfile,'/','\','g')
endif
else
let tmpfile = tmpfile
endif
let b:netrw_tmpfile= tmpfile
else
let tmpfile= b:netrw_tmpfile
endif
if a:fname != ""
if a:fname =~ '\.[^./]\+$'
if a:fname =~ '\.tar\.gz$' || a:fname =~ '\.tar\.bz2$' || a:fname =~ '\.tar\.xz$'
let suffix = ".tar".substitute(a:fname,'^.*\(\.[^./]\+\)$','\1','e')
elseif a:fname =~ '.txz$'
let suffix = ".txz".substitute(a:fname,'^.*\(\.[^./]\+\)$','\1','e')
else
let suffix = substitute(a:fname,'^.*\(\.[^./]\+\)$','\1','e')
endif
let tmpfile= substitute(tmpfile,'\.tmp$','','e')
let tmpfile .= suffix
let s:netrw_tmpfile= tmpfile " supports netrw#NetSource()
endif
endif
return tmpfile
endfun
fun! s:MakeSshCmd(sshcmd)
if s:user == ""
let sshcmd = substitute(a:sshcmd,'\<HOSTNAME\>',s:machine,'')
else
let sshcmd = substitute(a:sshcmd,'\<HOSTNAME\>',s:user."@".s:machine,'')
endif
if exists("g:netrw_port") && g:netrw_port != ""
let sshcmd= substitute(sshcmd,"USEPORT",g:netrw_sshport.' '.g:netrw_port,'')
elseif exists("s:port") && s:port != ""
let sshcmd= substitute(sshcmd,"USEPORT",g:netrw_sshport.' '.s:port,'')
else
let sshcmd= substitute(sshcmd,"USEPORT ",'','')
endif
return sshcmd
endfun
fun! s:MakeBookmark(fname)
if !exists("g:netrw_bookmarklist")
let g:netrw_bookmarklist= []
endif
if index(g:netrw_bookmarklist,a:fname) == -1
if isdirectory(s:NetrwFile(a:fname)) && a:fname !~ '/$'
call add(g:netrw_bookmarklist,a:fname.'/')
elseif a:fname !~ '/'
call add(g:netrw_bookmarklist,getcwd()."/".a:fname)
else
call add(g:netrw_bookmarklist,a:fname)
endif
call sort(g:netrw_bookmarklist)
endif
endfun
fun! s:MergeBookmarks()
let savefile= s:NetrwHome()."/.netrwbook"
if filereadable(s:NetrwFile(savefile))
NetrwKeepj call s:NetrwBookHistSave()
NetrwKeepj call delete(savefile)
endif
endfun
fun! s:NetrwBMShow()
redir => bmshowraw
menu
redir END
let bmshowlist = split(bmshowraw,'\n')
if bmshowlist != []
let bmshowfuncs= filter(bmshowlist,'v:val =~# "<SNR>\\d\\+_BMShow()"')
if bmshowfuncs != []
let bmshowfunc = substitute(bmshowfuncs[0],'^.*:\(call.*BMShow()\).*$','\1','')
if bmshowfunc =~# '^call.*BMShow()'
exe "sil! NetrwKeepj ".bmshowfunc
endif
endif
endif
endfun
fun! s:NetrwCursor()
if !exists("w:netrw_liststyle")
let w:netrw_liststyle= g:netrw_liststyle
endif
if &ft != "netrw"
let &l:cursorline   = s:netrw_usercul
let &l:cursorcolumn = s:netrw_usercuc
elseif g:netrw_cursor == 4
setl cursorline
setl cursorcolumn
elseif g:netrw_cursor == 3
if w:netrw_liststyle == s:WIDELIST
setl cursorline
setl cursorcolumn
else
setl cursorline
let &l:cursorcolumn   = s:netrw_usercuc
endif
elseif g:netrw_cursor == 2
let &l:cursorcolumn = s:netrw_usercuc
setl cursorline
elseif g:netrw_cursor == 1
let &l:cursorcolumn = s:netrw_usercuc
if w:netrw_liststyle == s:WIDELIST
setl cursorline
else
let &l:cursorline   = s:netrw_usercul
endif
else
let &l:cursorline   = s:netrw_usercul
let &l:cursorcolumn = s:netrw_usercuc
endif
endfun
fun! s:RestoreCursorline()
if exists("s:netrw_usercul")
let &l:cursorline   = s:netrw_usercul
endif
if exists("s:netrw_usercuc")
let &l:cursorcolumn = s:netrw_usercuc
endif
endfun
fun! s:NetrwDelete(path)
let path = netrw#WinPath(a:path)
if !g:netrw_cygwin && (has("win32") || has("win95") || has("win64") || has("win16"))
if exists("+shellslash")
let sskeep= &shellslash
setl noshellslash
let result      = delete(path)
let &shellslash = sskeep
else
let result= delete(path)
endif
else
let result= delete(path)
endif
if result < 0
NetrwKeepj call netrw#ErrorMsg(s:WARNING,"delete(".path.") failed!",71)
endif
return result
endfun
fun! s:NetrwEnew(...)
if exists("b:netrw_bannercnt")      |let netrw_bannercnt       = b:netrw_bannercnt      |endif
if exists("b:netrw_browser_active") |let netrw_browser_active  = b:netrw_browser_active |endif
if exists("b:netrw_cpf")            |let netrw_cpf             = b:netrw_cpf            |endif
if exists("b:netrw_curdir")         |let netrw_curdir          = b:netrw_curdir         |endif
if exists("b:netrw_explore_bufnr")  |let netrw_explore_bufnr   = b:netrw_explore_bufnr  |endif
if exists("b:netrw_explore_indx")   |let netrw_explore_indx    = b:netrw_explore_indx   |endif
if exists("b:netrw_explore_line")   |let netrw_explore_line    = b:netrw_explore_line   |endif
if exists("b:netrw_explore_list")   |let netrw_explore_list    = b:netrw_explore_list   |endif
if exists("b:netrw_explore_listlen")|let netrw_explore_listlen = b:netrw_explore_listlen|endif
if exists("b:netrw_explore_mtchcnt")|let netrw_explore_mtchcnt = b:netrw_explore_mtchcnt|endif
if exists("b:netrw_fname")          |let netrw_fname           = b:netrw_fname          |endif
if exists("b:netrw_lastfile")       |let netrw_lastfile        = b:netrw_lastfile       |endif
if exists("b:netrw_liststyle")      |let netrw_liststyle       = b:netrw_liststyle      |endif
if exists("b:netrw_method")         |let netrw_method          = b:netrw_method         |endif
if exists("b:netrw_option")         |let netrw_option          = b:netrw_option         |endif
if exists("b:netrw_prvdir")         |let netrw_prvdir          = b:netrw_prvdir         |endif
NetrwKeepj call s:NetrwOptionRestore("w:")
let netrw_keepdiff= &l:diff
noswapfile NetrwKeepj keepalt enew!
let &l:diff= netrw_keepdiff
NetrwKeepj call s:NetrwOptionSave("w:")
if exists("netrw_bannercnt")      |let b:netrw_bannercnt       = netrw_bannercnt      |endif
if exists("netrw_browser_active") |let b:netrw_browser_active  = netrw_browser_active |endif
if exists("netrw_cpf")            |let b:netrw_cpf             = netrw_cpf            |endif
if exists("netrw_curdir")         |let b:netrw_curdir          = netrw_curdir         |endif
if exists("netrw_explore_bufnr")  |let b:netrw_explore_bufnr   = netrw_explore_bufnr  |endif
if exists("netrw_explore_indx")   |let b:netrw_explore_indx    = netrw_explore_indx   |endif
if exists("netrw_explore_line")   |let b:netrw_explore_line    = netrw_explore_line   |endif
if exists("netrw_explore_list")   |let b:netrw_explore_list    = netrw_explore_list   |endif
if exists("netrw_explore_listlen")|let b:netrw_explore_listlen = netrw_explore_listlen|endif
if exists("netrw_explore_mtchcnt")|let b:netrw_explore_mtchcnt = netrw_explore_mtchcnt|endif
if exists("netrw_fname")          |let b:netrw_fname           = netrw_fname          |endif
if exists("netrw_lastfile")       |let b:netrw_lastfile        = netrw_lastfile       |endif
if exists("netrw_liststyle")      |let b:netrw_liststyle       = netrw_liststyle      |endif
if exists("netrw_method")         |let b:netrw_method          = netrw_method         |endif
if exists("netrw_option")         |let b:netrw_option          = netrw_option         |endif
if exists("netrw_prvdir")         |let b:netrw_prvdir          = netrw_prvdir         |endif
if a:0 > 0
let b:netrw_curdir= a:1
if b:netrw_curdir =~ '/$'
if exists("w:netrw_liststyle") && w:netrw_liststyle == s:TREELIST
setl nobl
file NetrwTreeListing
setl nobl bt=nowrite bh=hide
nno <silent> <buffer> [	:sil call <SID>TreeListMove('[')<cr>
nno <silent> <buffer> ]	:sil call <SID>TreeListMove(']')<cr>
else
exe "sil! keepalt file ".fnameescape(b:netrw_curdir)
endif
endif
endif
endfun
fun! s:NetrwExe(cmd)
if has("win32") && &shell !~? 'cmd' && !g:netrw_cygwin
let savedShell=[&shell,&shellcmdflag,&shellxquote,&shellxescape,&shellquote,&shellpipe,&shellredir,&shellslash]
set shell& shellcmdflag& shellxquote& shellxescape&
set shellquote& shellpipe& shellredir& shellslash&
exe a:cmd
let [&shell,&shellcmdflag,&shellxquote,&shellxescape,&shellquote,&shellpipe,&shellredir,&shellslash] = savedShell
else
exe a:cmd
endif
endfun
fun! s:NetrwInsureWinVars()
if !exists("w:netrw_liststyle")
let curbuf = bufnr("%")
let curwin = winnr()
let iwin   = 1
while iwin <= winnr("$")
exe iwin."wincmd w"
if winnr() != curwin && bufnr("%") == curbuf && exists("w:netrw_liststyle")
let winvars= w:
break
endif
let iwin= iwin + 1
endwhile
exe "keepalt ".curwin."wincmd w"
if exists("winvars")
for k in keys(winvars)
let w:{k}= winvars[k]
endfor
endif
endif
endfun
fun! s:NetrwLcd(newdir)
try
exe 'NetrwKeepj sil lcd '.fnameescape(a:newdir)
catch /^Vim\%((\a\+)\)\=:E344/
if (has("win32") || has("win95") || has("win64") || has("win16")) && !g:netrw_cygwin
if a:newdir =~ '^\\\\\w\+' || a:newdir =~ '^//\w\+'
let dirname = '\'
exe 'NetrwKeepj sil lcd '.fnameescape(dirname)
endif
endif
catch /^Vim\%((\a\+)\)\=:E472/
call netrw#ErrorMsg(s:ERROR,"unable to change directory to <".a:newdir."> (permissions?)",61)
if exists("w:netrw_prvdir")
let a:newdir= w:netrw_prvdir
else
call s:NetrwOptionRestore("w:")
exe "setl ".g:netrw_bufsettings
let a:newdir= dirname
return
endif
endtry
endfun
fun! s:NetrwSaveWordPosn()
let s:netrw_saveword= '^'.fnameescape(getline('.')).'$'
endfun
fun! s:NetrwHumanReadable(sz)
if g:netrw_sizestyle == 'h'
if a:sz >= 1000000000 
let sz = printf("%.1f",a:sz/1000000000.0)."g"
elseif a:sz >= 10000000
let sz = printf("%d",a:sz/1000000)."m"
elseif a:sz >= 1000000
let sz = printf("%.1f",a:sz/1000000.0)."m"
elseif a:sz >= 10000
let sz = printf("%d",a:sz/1000)."k"
elseif a:sz >= 1000
let sz = printf("%.1f",a:sz/1000.0)."k"
else
let sz= a:sz
endif
elseif g:netrw_sizestyle == 'H'
if a:sz >= 1073741824
let sz = printf("%.1f",a:sz/1073741824.0)."G"
elseif a:sz >= 10485760
let sz = printf("%d",a:sz/1048576)."M"
elseif a:sz >= 1048576
let sz = printf("%.1f",a:sz/1048576.0)."M"
elseif a:sz >= 10240
let sz = printf("%d",a:sz/1024)."K"
elseif a:sz >= 1024
let sz = printf("%.1f",a:sz/1024.0)."K"
else
let sz= a:sz
endif
else
let sz= a:sz
endif
return sz
endfun
fun! s:NetrwRestoreWordPosn()
sil! call search(s:netrw_saveword,'w')
endfun
fun! s:RestoreBufVars()
if exists("s:netrw_curdir")        |let b:netrw_curdir         = s:netrw_curdir        |endif
if exists("s:netrw_lastfile")      |let b:netrw_lastfile       = s:netrw_lastfile      |endif
if exists("s:netrw_method")        |let b:netrw_method         = s:netrw_method        |endif
if exists("s:netrw_fname")         |let b:netrw_fname          = s:netrw_fname         |endif
if exists("s:netrw_machine")       |let b:netrw_machine        = s:netrw_machine       |endif
if exists("s:netrw_browser_active")|let b:netrw_browser_active = s:netrw_browser_active|endif
endfun
fun! s:RemotePathAnalysis(dirname)
let dirpat  = '^\(\w\{-}\)://\(\(\w\+\)@\)\=\([^/:#]\+\)\%([:#]\(\d\+\)\)\=/\(.*\)$'
let s:method  = substitute(a:dirname,dirpat,'\1','')
let s:user    = substitute(a:dirname,dirpat,'\3','')
let s:machine = substitute(a:dirname,dirpat,'\4','')
let s:port    = substitute(a:dirname,dirpat,'\5','')
let s:path    = substitute(a:dirname,dirpat,'\6','')
let s:fname   = substitute(s:path,'^.*/\ze.','','')
if s:machine =~ '@'
let dirpat    = '^\(.*\)@\(.\{-}\)$'
let s:user    = s:user.'@'.substitute(s:machine,dirpat,'\1','')
let s:machine = substitute(s:machine,dirpat,'\2','')
endif
endfun
fun! s:RemoteSystem(cmd)
if !executable(g:netrw_ssh_cmd)
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"g:netrw_ssh_cmd<".g:netrw_ssh_cmd."> is not executable!",52)
elseif !exists("b:netrw_curdir")
NetrwKeepj call netrw#ErrorMsg(s:ERROR,"for some reason b:netrw_curdir doesn't exist!",53)
else
let cmd      = s:MakeSshCmd(g:netrw_ssh_cmd." USEPORT HOSTNAME")
let remotedir= substitute(b:netrw_curdir,'^.*//[^/]\+/\(.*\)$','\1','')
if remotedir != ""
let cmd= cmd.' cd '.s:ShellEscape(remotedir).";"
else
let cmd= cmd.' '
endif
let cmd= cmd.a:cmd
let ret= system(cmd)
endif
return ret
endfun
fun! s:RestoreWinVars()
if exists("s:bannercnt")      |let w:netrw_bannercnt       = s:bannercnt      |unlet s:bannercnt      |endif
if exists("s:col")            |let w:netrw_col             = s:col            |unlet s:col            |endif
if exists("s:curdir")         |let w:netrw_curdir          = s:curdir         |unlet s:curdir         |endif
if exists("s:explore_bufnr")  |let w:netrw_explore_bufnr   = s:explore_bufnr  |unlet s:explore_bufnr  |endif
if exists("s:explore_indx")   |let w:netrw_explore_indx    = s:explore_indx   |unlet s:explore_indx   |endif
if exists("s:explore_line")   |let w:netrw_explore_line    = s:explore_line   |unlet s:explore_line   |endif
if exists("s:explore_listlen")|let w:netrw_explore_listlen = s:explore_listlen|unlet s:explore_listlen|endif
if exists("s:explore_list")   |let w:netrw_explore_list    = s:explore_list   |unlet s:explore_list   |endif
if exists("s:explore_mtchcnt")|let w:netrw_explore_mtchcnt = s:explore_mtchcnt|unlet s:explore_mtchcnt|endif
if exists("s:fpl")            |let w:netrw_fpl             = s:fpl            |unlet s:fpl            |endif
if exists("s:hline")          |let w:netrw_hline           = s:hline          |unlet s:hline          |endif
if exists("s:line")           |let w:netrw_line            = s:line           |unlet s:line           |endif
if exists("s:liststyle")      |let w:netrw_liststyle       = s:liststyle      |unlet s:liststyle      |endif
if exists("s:method")         |let w:netrw_method          = s:method         |unlet s:method         |endif
if exists("s:prvdir")         |let w:netrw_prvdir          = s:prvdir         |unlet s:prvdir         |endif
if exists("s:treedict")       |let w:netrw_treedict        = s:treedict       |unlet s:treedict       |endif
if exists("s:treetop")        |let w:netrw_treetop         = s:treetop        |unlet s:treetop        |endif
if exists("s:winnr")          |let w:netrw_winnr           = s:winnr          |unlet s:winnr          |endif
endfun
fun! s:NetrwRexplore(islocal,dirname)
if exists("s:netrwdrag")
return
endif
if &ft == "netrw" && exists("w:netrw_rexfile") && w:netrw_rexfile != ""
exe "NetrwKeepj e ".w:netrw_rexfile
unlet w:netrw_rexfile
return
endif
let w:netrw_rexfile= expand("%")
if !exists("w:netrw_rexlocal")
return
endif
if w:netrw_rexlocal
NetrwKeepj call netrw#LocalBrowseCheck(w:netrw_rexdir)
else
NetrwKeepj call s:NetrwBrowse(0,w:netrw_rexdir)
endif
if exists("s:initbeval")
setl beval
endif
if exists("s:rexposn_".bufnr("%"))
NetrwKeepj call winrestview(s:rexposn_{bufnr('%')})
if exists("s:rexposn_".bufnr('%'))
unlet s:rexposn_{bufnr('%')}
endif
else
endif
if exists("s:explore_match")
exe "2match netrwMarkFile /".s:explore_match."/"
endif
endfun
fun! s:SaveBufVars()
if exists("b:netrw_curdir")        |let s:netrw_curdir         = b:netrw_curdir        |endif
if exists("b:netrw_lastfile")      |let s:netrw_lastfile       = b:netrw_lastfile      |endif
if exists("b:netrw_method")        |let s:netrw_method         = b:netrw_method        |endif
if exists("b:netrw_fname")         |let s:netrw_fname          = b:netrw_fname         |endif
if exists("b:netrw_machine")       |let s:netrw_machine        = b:netrw_machine       |endif
if exists("b:netrw_browser_active")|let s:netrw_browser_active = b:netrw_browser_active|endif
endfun
fun! s:SavePosn(posndict)
let a:posndict[bufnr("%")]= winsaveview()
return a:posndict
endfun
fun! s:RestorePosn(posndict)
if has_key(a:posndict,bufnr("%"))
call winrestview(a:posndict[bufnr("%")])
endif
endfun
fun! s:SaveWinVars()
if exists("w:netrw_bannercnt")      |let s:bannercnt       = w:netrw_bannercnt      |endif
if exists("w:netrw_col")            |let s:col             = w:netrw_col            |endif
if exists("w:netrw_curdir")         |let s:curdir          = w:netrw_curdir         |endif
if exists("w:netrw_explore_bufnr")  |let s:explore_bufnr   = w:netrw_explore_bufnr  |endif
if exists("w:netrw_explore_indx")   |let s:explore_indx    = w:netrw_explore_indx   |endif
if exists("w:netrw_explore_line")   |let s:explore_line    = w:netrw_explore_line   |endif
if exists("w:netrw_explore_listlen")|let s:explore_listlen = w:netrw_explore_listlen|endif
if exists("w:netrw_explore_list")   |let s:explore_list    = w:netrw_explore_list   |endif
if exists("w:netrw_explore_mtchcnt")|let s:explore_mtchcnt = w:netrw_explore_mtchcnt|endif
if exists("w:netrw_fpl")            |let s:fpl             = w:netrw_fpl            |endif
if exists("w:netrw_hline")          |let s:hline           = w:netrw_hline          |endif
if exists("w:netrw_line")           |let s:line            = w:netrw_line           |endif
if exists("w:netrw_liststyle")      |let s:liststyle       = w:netrw_liststyle      |endif
if exists("w:netrw_method")         |let s:method          = w:netrw_method         |endif
if exists("w:netrw_prvdir")         |let s:prvdir          = w:netrw_prvdir         |endif
if exists("w:netrw_treedict")       |let s:treedict        = w:netrw_treedict       |endif
if exists("w:netrw_treetop")        |let s:treetop         = w:netrw_treetop        |endif
if exists("w:netrw_winnr")          |let s:winnr           = w:netrw_winnr          |endif
endfun
fun! s:SetBufWinVars()
if exists("w:netrw_liststyle")      |let b:netrw_liststyle      = w:netrw_liststyle      |endif
if exists("w:netrw_bannercnt")      |let b:netrw_bannercnt      = w:netrw_bannercnt      |endif
if exists("w:netrw_method")         |let b:netrw_method         = w:netrw_method         |endif
if exists("w:netrw_prvdir")         |let b:netrw_prvdir         = w:netrw_prvdir         |endif
if exists("w:netrw_explore_indx")   |let b:netrw_explore_indx   = w:netrw_explore_indx   |endif
if exists("w:netrw_explore_listlen")|let b:netrw_explore_listlen= w:netrw_explore_listlen|endif
if exists("w:netrw_explore_mtchcnt")|let b:netrw_explore_mtchcnt= w:netrw_explore_mtchcnt|endif
if exists("w:netrw_explore_bufnr")  |let b:netrw_explore_bufnr  = w:netrw_explore_bufnr  |endif
if exists("w:netrw_explore_line")   |let b:netrw_explore_line   = w:netrw_explore_line   |endif
if exists("w:netrw_explore_list")   |let b:netrw_explore_list   = w:netrw_explore_list   |endif
endfun
fun! s:SetRexDir(islocal,dirname)
let w:netrw_rexdir         = a:dirname
let w:netrw_rexlocal       = a:islocal
let s:rexposn_{bufnr("%")} = winsaveview()
endfun
fun! s:ShowLink()
if exists("b:netrw_curdir")
norm! $?\a
let fname   = b:netrw_curdir.'/'.s:NetrwGetWord()
let resname = resolve(fname)
if resname =~ '^\M'.b:netrw_curdir.'/'
let dirlen  = strlen(b:netrw_curdir)
let resname = strpart(resname,dirlen+1)
endif
let modline = getline(".")."\t --> ".resname
setl noro ma
call setline(".",modline)
setl ro noma nomod
endif
endfun
fun! s:ShowStyle()
if !exists("w:netrw_liststyle")
let liststyle= g:netrw_liststyle
else
let liststyle= w:netrw_liststyle
endif
if     liststyle == s:THINLIST
return s:THINLIST.":thin"
elseif liststyle == s:LONGLIST
return s:LONGLIST.":long"
elseif liststyle == s:WIDELIST
return s:WIDELIST.":wide"
elseif liststyle == s:TREELIST
return s:TREELIST.":tree"
else
return 'n/a'
endif
endfun
fun! s:Strlen(x)
if v:version >= 703 && exists("*strdisplaywidth")
let ret= strdisplaywidth(a:x)
elseif type(g:Align_xstrlen) == 1
exe "let ret= ".g:Align_xstrlen."('".substitute(a:x,"'","''","g")."')"
elseif g:Align_xstrlen == 1
let ret= strlen(substitute(a:x,'.','c','g'))
elseif g:Align_xstrlen == 2
let ret=strlen(substitute(a:x, '.\Z', 'x', 'g'))
elseif g:Align_xstrlen == 3
let modkeep= &l:mod
exe "norm! o\<esc>"
call setline(line("."),a:x)
let ret= virtcol("$") - 1
d
NetrwKeepj norm! k
let &l:mod= modkeep
else
let ret= strlen(a:x)
endif
return ret
endfun
fun! s:ShellEscape(s, ...)
if (has('win32') || has('win64')) && $SHELL == '' && &shellslash
return printf('"%s"', substitute(a:s, '"', '""', 'g'))
endif 
let f = a:0 > 0 ? a:1 : 0
return shellescape(a:s, f)
endfun
fun! s:TreeListMove(dir)
let curline      = getline('.')
let prvline      = (line(".") > 1)?         getline(line(".")-1) : ''
let nxtline      = (line(".") < line("$"))? getline(line(".")+1) : ''
let curindent    = substitute(getline('.'),'^\(\%('.s:treedepthstring.'\)*\)[^'.s:treedepthstring.'].\{-}$','\1','e')
let indentm1     = substitute(curindent,'^'.s:treedepthstring,'','')
let treedepthchr = substitute(s:treedepthstring,' ','','g')
let stopline     = exists("w:netrw_bannercnt")? w:netrw_bannercnt : 1
if curline !~ '/$'
if     a:dir == '[[' && prvline != ''
NetrwKeepj norm! 0
let nl = search('^'.indentm1.'\%('.s:treedepthstring.'\)\@!','bWe',stopline) " search backwards
elseif a:dir == '[]' && nxtline != ''
NetrwKeepj norm! 0
let nl = search('^\%('.curindent.'\)\@!','We') " search forwards
if nl != 0
NetrwKeepj norm! k
else
NetrwKeepj norm! G
endif
endif
endif
endfun
fun! s:UpdateBuffersMenu()
if has("gui") && has("menu") && has("gui_running") && &go =~# 'm' && g:netrw_menu
try
sil emenu Buffers.Refresh\ menu
catch /^Vim\%((\a\+)\)\=:E/
let v:errmsg= ""
sil NetrwKeepj call s:NetrwBMShow()
endtry
endif
endfun
fun! s:UseBufWinVars()
if exists("b:netrw_liststyle")       && !exists("w:netrw_liststyle")      |let w:netrw_liststyle       = b:netrw_liststyle      |endif
if exists("b:netrw_bannercnt")       && !exists("w:netrw_bannercnt")      |let w:netrw_bannercnt       = b:netrw_bannercnt      |endif
if exists("b:netrw_method")          && !exists("w:netrw_method")         |let w:netrw_method          = b:netrw_method         |endif
if exists("b:netrw_prvdir")          && !exists("w:netrw_prvdir")         |let w:netrw_prvdir          = b:netrw_prvdir         |endif
if exists("b:netrw_explore_indx")    && !exists("w:netrw_explore_indx")   |let w:netrw_explore_indx    = b:netrw_explore_indx   |endif
if exists("b:netrw_explore_listlen") && !exists("w:netrw_explore_listlen")|let w:netrw_explore_listlen = b:netrw_explore_listlen|endif
if exists("b:netrw_explore_mtchcnt") && !exists("w:netrw_explore_mtchcnt")|let w:netrw_explore_mtchcnt = b:netrw_explore_mtchcnt|endif
if exists("b:netrw_explore_bufnr")   && !exists("w:netrw_explore_bufnr")  |let w:netrw_explore_bufnr   = b:netrw_explore_bufnr  |endif
if exists("b:netrw_explore_line")    && !exists("w:netrw_explore_line")   |let w:netrw_explore_line    = b:netrw_explore_line   |endif
if exists("b:netrw_explore_list")    && !exists("w:netrw_explore_list")   |let w:netrw_explore_list    = b:netrw_explore_list   |endif
endfun
fun! s:UserMaps(islocal,funcname)
if !exists("b:netrw_curdir")
let b:netrw_curdir= getcwd()
endif
let Funcref = function(a:funcname)
let result  = Funcref(a:islocal)
if     type(result) == 1
if result == "refresh"
call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
elseif result != ""
exe result
endif
elseif type(result) == 3
for action in result
if action == "refresh"
call s:NetrwRefresh(a:islocal,s:NetrwBrowseChgDir(a:islocal,'./'))
elseif action != ""
exe action
endif
endfor
endif
endfun
let &cpo= s:keepcpo
unlet s:keepcpo
