if exists("g:loaded_netrwFileHandlers") || &cp
finish
endif
let g:loaded_netrwFileHandlers= "v11b"
if v:version < 702
echohl WarningMsg
echo "***warning*** this version of netrwFileHandlers needs vim 7.2"
echohl Normal
finish
endif
let s:keepcpo= &cpo
set cpo&vim
fun! netrwFileHandlers#Invoke(exten,fname)
let exten= a:exten
if exten =~ '[@:,$!=\-+%?;~]'
let specials= {
\   '@' : 'AT',
\   ':' : 'COLON',
\   ',' : 'COMMA',
\   '$' : 'DOLLAR',
\   '!' : 'EXCLAMATION',
\   '=' : 'EQUAL',
\   '-' : 'MINUS',
\   '+' : 'PLUS',
\   '%' : 'PERCENT',
\   '?' : 'QUESTION',
\   ';' : 'SEMICOLON',
\   '~' : 'TILDE'}
let exten= substitute(a:exten,'[@:,$!=\-+%?;~]','\=specials[submatch(0)]','ge')
endif
if a:exten != "" && exists("*NFH_".exten)
exe "let ret= NFH_".exten.'("'.a:fname.'")'
elseif a:exten != "" && exists("*s:NFH_".exten)
exe "let ret= s:NFH_".a:exten.'("'.a:fname.'")'
endif
return 0
endfun
fun! s:NFH_html(pagefile)
let page= substitute(a:pagefile,'^','file://','')
if executable("mozilla")
exe "!mozilla ".shellescape(page,1)
elseif executable("netscape")
exe "!netscape ".shellescape(page,1)
else
return 0
endif
return 1
endfun
fun! s:NFH_htm(pagefile)
let page= substitute(a:pagefile,'^','file://','')
if executable("mozilla")
exe "!mozilla ".shellescape(page,1)
elseif executable("netscape")
exe "!netscape ".shellescape(page,1)
else
return 0
endif
return 1
endfun
fun! s:NFH_jpg(jpgfile)
if executable("gimp")
exe "silent! !gimp -s ".shellescape(a:jpgfile,1)
elseif executable(expand("$SystemRoot")."/SYSTEM32/MSPAINT.EXE")
exe "!".expand("$SystemRoot")."/SYSTEM32/MSPAINT ".shellescape(a:jpgfile,1)
else
return 0
endif
return 1
endfun
fun! s:NFH_gif(giffile)
if executable("gimp")
exe "silent! !gimp -s ".shellescape(a:giffile,1)
elseif executable(expand("$SystemRoot")."/SYSTEM32/MSPAINT.EXE")
exe "silent! !".expand("$SystemRoot")."/SYSTEM32/MSPAINT ".shellescape(a:giffile,1)
else
return 0
endif
return 1
endfun
fun! s:NFH_png(pngfile)
if executable("gimp")
exe "silent! !gimp -s ".shellescape(a:pngfile,1)
elseif executable(expand("$SystemRoot")."/SYSTEM32/MSPAINT.EXE")
exe "silent! !".expand("$SystemRoot")."/SYSTEM32/MSPAINT ".shellescape(a:pngfile,1)
else
return 0
endif
return 1
endfun
fun! s:NFH_pnm(pnmfile)
if executable("gimp")
exe "silent! !gimp -s ".shellescape(a:pnmfile,1)
elseif executable(expand("$SystemRoot")."/SYSTEM32/MSPAINT.EXE")
exe "silent! !".expand("$SystemRoot")."/SYSTEM32/MSPAINT ".shellescape(a:pnmfile,1)
else
return 0
endif
return 1
endfun
fun! s:NFH_bmp(bmpfile)
if executable("gimp")
exe "silent! !gimp -s ".a:bmpfile
elseif executable(expand("$SystemRoot")."/SYSTEM32/MSPAINT.EXE")
exe "silent! !".expand("$SystemRoot")."/SYSTEM32/MSPAINT ".shellescape(a:bmpfile,1)
else
return 0
endif
return 1
endfun
fun! s:NFH_pdf(pdf)
if executable("gs")
exe 'silent! !gs '.shellescape(a:pdf,1)
elseif executable("pdftotext")
exe 'silent! pdftotext -nopgbrk '.shellescape(a:pdf,1)
else
return 0
endif
return 1
endfun
fun! s:NFH_doc(doc)
if executable("oowriter")
exe 'silent! !oowriter '.shellescape(a:doc,1)
redraw!
else
return 0
endif
return 1
endfun
fun! s:NFH_sxw(sxw)
if executable("oowriter")
exe 'silent! !oowriter '.shellescape(a:sxw,1)
redraw!
else
return 0
endif
return 1
endfun
fun! s:NFH_xls(xls)
if executable("oocalc")
exe 'silent! !oocalc '.shellescape(a:xls,1)
redraw!
else
return 0
endif
return 1
endfun
fun! s:NFH_ps(ps)
if executable("gs")
exe "silent! !gs ".shellescape(a:ps,1)
redraw!
elseif executable("ghostscript")
exe "silent! !ghostscript ".shellescape(a:ps,1)
redraw!
elseif executable("gswin32")
exe "silent! !gswin32 ".shellescape(a:ps,1)
redraw!
else
return 0
endif
return 1
endfun
fun! s:NFH_eps(eps)
if executable("gs")
exe "silent! !gs ".shellescape(a:eps,1)
redraw!
elseif executable("ghostscript")
exe "silent! !ghostscript ".shellescape(a:eps,1)
redraw!
elseif executable("ghostscript")
exe "silent! !ghostscript ".shellescape(a:eps,1)
redraw!
elseif executable("gswin32")
exe "silent! !gswin32 ".shellescape(a:eps,1)
redraw!
else
return 0
endif
return 1
endfun
fun! s:NFH_fig(fig)
if executable("xfig")
exe "silent! !xfig ".a:fig
redraw!
else
return 0
endif
return 1
endfun
fun! s:NFH_obj(obj)
if has("unix") && executable("tgif")
exe "silent! !tgif ".a:obj
redraw!
else
return 0
endif
return 1
endfun
let &cpo= s:keepcpo
unlet s:keepcpo
