if &cp || exists("g:loaded_netrwPlugin")
finish
endif
let g:loaded_netrwPlugin = "v167"
let s:keepcpo = &cpo
set cpo&vim
augroup FileExplorer
au!
au BufLeave *  if &ft != "netrw"|let w:netrw_prvfile= expand("%:p")|endif
au BufEnter *	sil call s:LocalBrowse(expand("<amatch>"))
au VimEnter *	sil call s:VimEnter(expand("<amatch>"))
if has("win32") || has("win95") || has("win64") || has("win16")
au BufEnter .* sil call s:LocalBrowse(expand("<amatch>"))
endif
augroup END
augroup Network
au!
au BufReadCmd   file://*											call netrw#FileUrlEdit(expand("<amatch>"))
au BufReadCmd   ftp://*,rcp://*,scp://*,http://*,https://*,dav://*,davs://*,rsync://*,sftp://*	exe "sil doau BufReadPre ".fnameescape(expand("<amatch>"))|call netrw#Nread(2,expand("<amatch>"))|exe "sil doau BufReadPost ".fnameescape(expand("<amatch>"))
au FileReadCmd  ftp://*,rcp://*,scp://*,http://*,file://*,https://*,dav://*,davs://*,rsync://*,sftp://*	exe "sil doau FileReadPre ".fnameescape(expand("<amatch>"))|call netrw#Nread(1,expand("<amatch>"))|exe "sil doau FileReadPost ".fnameescape(expand("<amatch>"))
au BufWriteCmd  ftp://*,rcp://*,scp://*,http://*,file://*,dav://*,davs://*,rsync://*,sftp://*			exe "sil doau BufWritePre ".fnameescape(expand("<amatch>"))|exe 'Nwrite '.fnameescape(expand("<amatch>"))|exe "sil doau BufWritePost ".fnameescape(expand("<amatch>"))
au FileWriteCmd ftp://*,rcp://*,scp://*,http://*,file://*,dav://*,davs://*,rsync://*,sftp://*			exe "sil doau FileWritePre ".fnameescape(expand("<amatch>"))|exe "'[,']".'Nwrite '.fnameescape(expand("<amatch>"))|exe "sil doau FileWritePost ".fnameescape(expand("<amatch>"))
try
au SourceCmd   ftp://*,rcp://*,scp://*,http://*,file://*,https://*,dav://*,davs://*,rsync://*,sftp://*	exe 'Nsource '.fnameescape(expand("<amatch>"))
catch /^Vim\%((\a\+)\)\=:E216/
au SourcePre   ftp://*,rcp://*,scp://*,http://*,file://*,https://*,dav://*,davs://*,rsync://*,sftp://*	exe 'Nsource '.fnameescape(expand("<amatch>"))
endtry
augroup END
com! -count=1 -nargs=*	Nread		let s:svpos= winsaveview()<bar>call netrw#NetRead(<count>,<f-args>)<bar>call winrestview(s:svpos)
com! -range=% -nargs=*	Nwrite		let s:svpos= winsaveview()<bar><line1>,<line2>call netrw#NetWrite(<f-args>)<bar>call winrestview(s:svpos)
com! -nargs=*		NetUserPass	call NetUserPass(<f-args>)
com! -nargs=*	        Nsource		let s:svpos= winsaveview()<bar>call netrw#NetSource(<f-args>)<bar>call winrestview(s:svpos)
com! -nargs=?		Ntree		call netrw#SetTreetop(1,<q-args>)
com! -nargs=* -bar -bang -count=0 -complete=dir	Explore		call netrw#Explore(<count>,0,0+<bang>0,<q-args>)
com! -nargs=* -bar -bang -count=0 -complete=dir	Sexplore	call netrw#Explore(<count>,1,0+<bang>0,<q-args>)
com! -nargs=* -bar -bang -count=0 -complete=dir	Hexplore	call netrw#Explore(<count>,1,2+<bang>0,<q-args>)
com! -nargs=* -bar -bang -count=0 -complete=dir	Vexplore	call netrw#Explore(<count>,1,4+<bang>0,<q-args>)
com! -nargs=* -bar       -count=0 -complete=dir	Texplore	call netrw#Explore(<count>,0,6        ,<q-args>)
com! -nargs=* -bar -bang			Nexplore	call netrw#Explore(-1,0,0,<q-args>)
com! -nargs=* -bar -bang			Pexplore	call netrw#Explore(-2,0,0,<q-args>)
com! -nargs=* -bar -bang -count=0 -complete=dir Lexplore	call netrw#Lexplore(<count>,<bang>0,<q-args>)
com! -nargs=0	NetrwSettings	call netrwSettings#NetrwSettings()
com! -bang	NetrwClean	call netrw#Clean(<bang>0)
if !exists("g:netrw_nogx")
if maparg('gx','n') == ""
if !hasmapto('<Plug>NetrwBrowseX')
nmap <unique> gx <Plug>NetrwBrowseX
endif
nno <silent> <Plug>NetrwBrowseX :call netrw#BrowseX(netrw#GX(),netrw#CheckIfRemote(netrw#GX()))<cr>
endif
if maparg('gx','v') == ""
if !hasmapto('<Plug>NetrwBrowseXVis')
vmap <unique> gx <Plug>NetrwBrowseXVis
endif
vno <silent> <Plug>NetrwBrowseXVis :<c-u>call netrw#BrowseXVis()<cr>
endif
endif
if exists("g:netrw_usetab") && g:netrw_usetab
if maparg('<c-tab>','n') == ""
nmap <unique> <c-tab> <Plug>NetrwShrink
endif
nno <silent> <Plug>NetrwShrink :call netrw#Shrink()<cr>
endif
fun! s:LocalBrowse(dirname)
if !exists("s:vimentered")
return
endif
if has("amiga")
if a:dirname != '' && isdirectory(a:dirname)
sil! call netrw#LocalBrowseCheck(a:dirname)
if exists("w:netrw_bannercnt") && line('.') < w:netrw_bannercnt
exe w:netrw_bannercnt
endif
endif
elseif isdirectory(a:dirname)
sil! call netrw#LocalBrowseCheck(a:dirname)
if exists("w:netrw_bannercnt") && line('.') < w:netrw_bannercnt
exe w:netrw_bannercnt
endif
else
endif
endfun
fun! s:VimEnter(dirname)
let curwin       = winnr()
let s:vimentered = 1
windo call s:LocalBrowse(expand("%:p"))
exe curwin."wincmd w"
endfun
fun! NetrwStatusLine()
if !exists("w:netrw_explore_bufnr") || w:netrw_explore_bufnr != bufnr("%") || !exists("w:netrw_explore_line") || w:netrw_explore_line != line(".") || !exists("w:netrw_explore_list")
let &stl= s:netrw_explore_stl
if exists("w:netrw_explore_bufnr")|unlet w:netrw_explore_bufnr|endif
if exists("w:netrw_explore_line")|unlet w:netrw_explore_line|endif
return ""
else
return "Match ".w:netrw_explore_mtchcnt." of ".w:netrw_explore_listlen
endif
endfun
fun! NetUserPass(...)
if a:0 == 0
if !exists("g:netrw_uid") || g:netrw_uid == ""
let g:netrw_uid= input('Enter username: ')
endif
else	" from command line
let g:netrw_uid= a:1
endif
if a:0 <= 1 " via prompt
let g:netrw_passwd= inputsecret("Enter Password: ")
else " from command line
let g:netrw_passwd=a:2
endif
endfun
let &cpo= s:keepcpo
unlet s:keepcpo
