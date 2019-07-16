let s:cpo_save = &cpo
set cpo&vim
func dist#ft#Check_inp()
if getline(1) =~ '^\*'
setf abaqus
else
let n = 1
if line("$") > 500
let nmax = 500
else
let nmax = line("$")
endif
while n <= nmax
if getline(n) =~? "^header surface data"
setf trasys
break
endif
let n = n + 1
endwhile
endif
endfunc
func dist#ft#FTasm()
if !exists("b:asmsyntax")
let b:asmsyntax = ""
endif
if b:asmsyntax == ""
call dist#ft#FTasmsyntax()
endif
if b:asmsyntax == ""
if exists("g:asmsyntax")
let b:asmsyntax = g:asmsyntax
else
let b:asmsyntax = "asm"
endif
endif
exe "setf " . fnameescape(b:asmsyntax)
endfunc
func dist#ft#FTasmsyntax()
let head = " ".getline(1)." ".getline(2)." ".getline(3)." ".getline(4).
\" ".getline(5)." "
let match = matchstr(head, '\sasmsyntax=\zs[a-zA-Z0-9]\+\ze\s')
if match != ''
let b:asmsyntax = match
elseif ((head =~? '\.title') || (head =~? '\.ident') || (head =~? '\.macro') || (head =~? '\.subtitle') || (head =~? '\.library'))
let b:asmsyntax = "vmasm"
endif
endfunc
func dist#ft#FTVB(alt)
if getline(1).getline(2).getline(3).getline(4).getline(5) =~? 'VB_Name\|Begin VB\.\(Form\|MDIForm\|UserControl\)'
setf vb
else
exe "setf " . a:alt
endif
endfunc
func dist#ft#FTbtm()
if exists("g:dosbatch_syntax_for_btm") && g:dosbatch_syntax_for_btm
setf dosbatch
else
setf btm
endif
endfunc
func dist#ft#BindzoneCheck(default)
if getline(1).getline(2).getline(3).getline(4) =~ '^; <<>> DiG [0-9.]\+.* <<>>\|$ORIGIN\|$TTL\|IN\s\+SOA'
setf bindzone
elseif a:default != ''
exe 'setf ' . a:default
endif
endfunc
func dist#ft#FTlpc()
if exists("g:lpc_syntax_for_c")
let lnum = 1
while lnum <= 12
if getline(lnum) =~# '^\(//\|inherit\|private\|protected\|nosave\|string\|object\|mapping\|mixed\)'
setf lpc
return
endif
let lnum = lnum + 1
endwhile
endif
setf c
endfunc
func dist#ft#FTheader()
if match(getline(1, min([line("$"), 200])), '^@\(interface\|end\|class\)') > -1
if exists("g:c_syntax_for_h")
setf objc
else
setf objcpp
endif
elseif exists("g:c_syntax_for_h")
setf c
elseif exists("g:ch_syntax_for_h")
setf ch
else
setf cpp
endif
endfunc
func dist#ft#FTchange()
let lnum = 1
while lnum <= 10
if getline(lnum)[0] == '@'
setf change
return
endif
if lnum == 1 && (getline(1)[0] == '#' || getline(1)[0] == '!')
setf ch
return
endif
if getline(lnum) =~ "MODULE"
setf chill
return
endif
if getline(lnum) =~ 'main\s*(\|#\s*include\|//'
setf ch
return
endif
let lnum = lnum + 1
endwhile
setf chill
endfunc
func dist#ft#FTent()
let lnum = 1
while lnum < 6
let line = getline(lnum)
if line =~ '^\s*[#{]'
setf cl
return
elseif line !~ '^\s*$'
break
endif
let lnum = lnum + 1
endw
setf dtd
endfunc
func dist#ft#EuphoriaCheck()
if exists('g:filetype_euphoria')
exe 'setf ' . g:filetype_euphoria
else
setf euphoria3
endif
endfunc
func dist#ft#DtraceCheck()
let lines = getline(1, min([line("$"), 100]))
if match(lines, '^module\>\|^import\>') > -1
setf d
elseif match(lines, '^#!\S\+dtrace\|#pragma\s\+D\s\+option\|:\S\{-}:\S\{-}:') > -1
setf dtrace
else
setf d
endif
endfunc
func dist#ft#FTe()
if exists('g:filetype_euphoria')
exe 'setf ' . g:filetype_euphoria
else
let n = 1
while n < 100 && n <= line("$")
if getline(n) =~ "^\\s*\\(<'\\|'>\\)\\s*$"
setf specman
return
endif
let n = n + 1
endwhile
setf eiffel
endif
endfunc
func dist#ft#FThtml()
let n = 1
while n < 10 && n <= line("$")
if getline(n) =~ '\<DTD\s\+XHTML\s'
setf xhtml
return
endif
if getline(n) =~ '{%\s*\(extends\|block\|load\)\>\|{#\s\+'
setf htmldjango
return
endif
let n = n + 1
endwhile
setf FALLBACK html
endfunc
func dist#ft#FTidl()
let n = 1
while n < 50 && n <= line("$")
if getline(n) =~ '^\s*import\s\+"\(unknwn\|objidl\)\.idl"'
setf msidl
return
endif
let n = n + 1
endwhile
setf idl
endfunc
func dist#ft#ProtoCheck(default)
if getline(2) =~ '.;$'
setf cpp
else
exe 'setf ' . a:default
endif
endfunc
func dist#ft#FTm()
let n = 1
let saw_comment = 0 " Whether we've seen a multiline comment leader.
while n < 100
let line = getline(n)
if line =~ '^\s*/\*'
let saw_comment = 1
endif
if line =~ '^\s*\(#\s*\(include\|import\)\>\|@import\>\|//\)'
setf objc
return
endif
if line =~ '^\s*%'
setf matlab
return
endif
if line =~ '^\s*(\*'
setf mma
return
endif
if line =~ '^\c\s*\(\(type\|var\)\>\|--\)'
setf murphi
return
endif
let n = n + 1
endwhile
if saw_comment
setf objc
elseif exists("g:filetype_m")
exe "setf " . g:filetype_m
else
setf matlab
endif
endfunc
func dist#ft#FTmms()
let n = 1
while n < 10
let line = getline(n)
if line =~ '^\s*\(%\|//\)' || line =~ '^\*'
setf mmix
return
endif
if line =~ '^\s*#'
setf make
return
endif
let n = n + 1
endwhile
setf mmix
endfunc
func dist#ft#FTnroff()
if getline(1)[0] . getline(2)[0] . getline(3)[0] . getline(4)[0] . getline(5)[0] =~ '\.'
setf nroff
return 1
endif
return 0
endfunc
func dist#ft#FTmm()
let n = 1
while n < 10
let line = getline(n)
if line =~ '^\s*\(#\s*\(include\|import\)\>\|@import\>\|/\*\)'
setf objcpp
return
endif
let n = n + 1
endwhile
setf nroff
endfunc
func dist#ft#FTpl()
if exists("g:filetype_pl")
exe "setf " . g:filetype_pl
else
let l = getline(nextnonblank(1))
if l =~ '\<prolog\>' || l =~ '^\s*\(%\+\(\s\|$\)\|/\*\)' || l =~ ':-'
setf prolog
else
setf perl
endif
endif
endfunc
func dist#ft#FTinc()
if exists("g:filetype_inc")
exe "setf " . g:filetype_inc
else
let lines = getline(1).getline(2).getline(3)
if lines =~? "perlscript"
setf aspperl
elseif lines =~ "<%"
setf aspvbs
elseif lines =~ "<?"
setf php
else
call dist#ft#FTasmsyntax()
if exists("b:asmsyntax")
exe "setf " . fnameescape(b:asmsyntax)
else
setf pov
endif
endif
endif
endfunc
func dist#ft#FTprogress_cweb()
if exists("g:filetype_w")
exe "setf " . g:filetype_w
return
endif
if getline(1) =~ '&ANALYZE' || getline(3) =~ '&GLOBAL-DEFINE'
setf progress
else
setf cweb
endif
endfunc
func dist#ft#FTprogress_asm()
if exists("g:filetype_i")
exe "setf " . g:filetype_i
return
endif
let lnum = 1
while lnum <= 10 && lnum < line('$')
let line = getline(lnum)
if line =~ '^\s*;' || line =~ '^\*'
call dist#ft#FTasm()
return
elseif line !~ '^\s*$' || line =~ '^/\*'
break
endif
let lnum = lnum + 1
endw
setf progress
endfunc
func dist#ft#FTprogress_pascal()
if exists("g:filetype_p")
exe "setf " . g:filetype_p
return
endif
let lnum = 1
while lnum <= 10 && lnum < line('$')
let line = getline(lnum)
if line =~ '^\s*\(program\|unit\|procedure\|function\|const\|type\|var\)\>'
\ || line =~ '^\s*{' || line =~ '^\s*(\*'
setf pascal
return
elseif line !~ '^\s*$' || line =~ '^/\*'
break
endif
let lnum = lnum + 1
endw
setf progress
endfunc
func dist#ft#FTr()
let max = line("$") > 50 ? 50 : line("$")
for n in range(1, max)
if getline(n) =~? '\<REBOL\>'
setf rebol
return
endif
endfor
for n in range(1, max)
if getline(n) =~ '^\s*#'
setf r
return
endif
if getline(n) =~ '^\s*/\*'
setf rexx
return
endif
endfor
if exists("g:filetype_r")
exe "setf " . g:filetype_r
else
setf r
endif
endfunc
func dist#ft#McSetf()
for lnum in range(1, min([line("$"), 20]))
let line = getline(lnum)
if line =~ '^\s*\(#\|dnl\)'
setf m4  " Sendmail .mc file
return
elseif line =~ '^\s*;'
setf msmessages  " MS Message text file
return
endif
endfor
setf m4  " Default: Sendmail .mc file
endfunc
func dist#ft#SetFileTypeSH(name)
if did_filetype()
return
endif
if expand("<amatch>") =~ g:ft_ignore_pat
return
endif
if a:name =~ '\<csh\>'
call dist#ft#SetFileTypeShell("csh")
return
elseif a:name =~ '\<tcsh\>'
call dist#ft#SetFileTypeShell("tcsh")
return
elseif a:name =~ '\<zsh\>'
call dist#ft#SetFileTypeShell("zsh")
return
elseif a:name =~ '\<ksh\>'
let b:is_kornshell = 1
if exists("b:is_bash")
unlet b:is_bash
endif
if exists("b:is_sh")
unlet b:is_sh
endif
elseif exists("g:bash_is_sh") || a:name =~ '\<bash\>' || a:name =~ '\<bash2\>'
let b:is_bash = 1
if exists("b:is_kornshell")
unlet b:is_kornshell
endif
if exists("b:is_sh")
unlet b:is_sh
endif
elseif a:name =~ '\<sh\>'
let b:is_sh = 1
if exists("b:is_kornshell")
unlet b:is_kornshell
endif
if exists("b:is_bash")
unlet b:is_bash
endif
endif
call dist#ft#SetFileTypeShell("sh")
endfunc
func dist#ft#SetFileTypeShell(name)
if did_filetype()
return
endif
if expand("<amatch>") =~ g:ft_ignore_pat
return
endif
let l = 2
while l < 20 && l < line("$") && getline(l) =~ '^\s*\(#\|$\)'
let l = l + 1
endwhile
if l < line("$") && getline(l) =~ '\s*exec\s' && getline(l - 1) =~ '^\s*#.*\\$'
let n = substitute(getline(l),'\s*exec\s\+\([^ ]*/\)\=', '', '')
if n =~ '\<tclsh\|\<wish'
setf tcl
return
endif
endif
exe "setf " . a:name
endfunc
func dist#ft#CSH()
if did_filetype()
return
endif
if exists("g:filetype_csh")
call dist#ft#SetFileTypeShell(g:filetype_csh)
elseif &shell =~ "tcsh"
call dist#ft#SetFileTypeShell("tcsh")
else
call dist#ft#SetFileTypeShell("csh")
endif
endfunc
let s:ft_rules_udev_rules_pattern = '^\s*\cudev_rules\s*=\s*"\([^"]\{-1,}\)/*".*'
func dist#ft#FTRules()
let path = expand('<amatch>:p')
if path =~ '^/\(etc/udev/\%(rules\.d/\)\=.*\.rules\|lib/udev/\%(rules\.d/\)\=.*\.rules\)$'
setf udevrules
return
endif
if path =~ '^/etc/ufw/'
setf conf  " Better than hog
return
endif
if path =~ '^/\(etc\|usr/share\)/polkit-1/rules\.d'
setf javascript
return
endif
try
let config_lines = readfile('/etc/udev/udev.conf')
catch /^Vim\%((\a\+)\)\=:E484/
setf hog
return
endtry
let dir = expand('<amatch>:p:h')
for line in config_lines
if line =~ s:ft_rules_udev_rules_pattern
let udev_rules = substitute(line, s:ft_rules_udev_rules_pattern, '\1', "")
if dir == udev_rules
setf udevrules
endif
break
endif
endfor
setf hog
endfunc
func dist#ft#SQL()
if exists("g:filetype_sql")
exe "setf " . g:filetype_sql
else
setf sql
endif
endfunc
func dist#ft#FTperl()
let dirname = expand("%:p:h:t")
if expand("%:e") == 't' && (dirname == 't' || dirname == 'xt')
setf perl
return 1
endif
if getline(1)[0] == '#' && getline(1) =~ 'perl'
setf perl
return 1
endif
let save_cursor = getpos('.')
call cursor(1,1)
let has_use = search('^use\s\s*\k', 'c', 30)
call setpos('.', save_cursor)
if has_use
setf perl
return 1
endif
return 0
endfunc
func dist#ft#FTtex()
let firstline = getline(1)
if firstline =~ '^%&\s*\a\+'
let format = tolower(matchstr(firstline, '\a\+'))
let format = substitute(format, 'pdf', '', '')
if format == 'tex'
let format = 'latex'
elseif format == 'plaintex'
let format = 'plain'
endif
elseif expand('%') =~ 'tex/context/.*/.*.tex'
let format = 'context'
else
let format = exists("g:tex_flavor") ? g:tex_flavor : 'plain'
let save_cursor = getpos('.')
call cursor(1,1)
let firstNC = search('^\s*[^[:space:]%]', 'c', 1000)
if firstNC " Check the next thousand lines for a LaTeX or ConTeXt keyword.
let lpat = 'documentclass\>\|usepackage\>\|begin{\|newcommand\>\|renewcommand\>'
let cpat = 'start\a\+\|setup\a\+\|usemodule\|enablemode\|enableregime\|setvariables\|useencoding\|usesymbols\|stelle\a\+\|verwende\a\+\|stel\a\+\|gebruik\a\+\|usa\a\+\|imposta\a\+\|regle\a\+\|utilisemodule\>'
let kwline = search('^\s*\\\%(' . lpat . '\)\|^\s*\\\(' . cpat . '\)',
\ 'cnp', firstNC + 1000)
if kwline == 1	" lpat matched
let format = 'latex'
elseif kwline == 2	" cpat matched
let format = 'context'
endif		" If neither matched, keep default set above.
endif " firstNC
call setpos('.', save_cursor)
endif " firstline =~ '^%&\s*\a\+'
if format == 'plain'
setf plaintex
elseif format == 'context'
setf context
else " probably LaTeX
setf tex
endif
return
endfunc
func dist#ft#FTxml()
let n = 1
while n < 100 && n <= line("$")
let line = getline(n)
let is_docbook4 = line =~ '<!DOCTYPE.*DocBook'
let is_docbook5 = line =~ ' xmlns="http://docbook.org/ns/docbook"'
if is_docbook4 || is_docbook5
let b:docbk_type = "xml"
if is_docbook5
let b:docbk_ver = 5
else
let b:docbk_ver = 4
endif
setf docbk
return
endif
if line =~ 'xmlns:xbl="http://www.mozilla.org/xbl"'
setf xbl
return
endif
let n += 1
endwhile
setf xml
endfunc
func dist#ft#FTy()
let n = 1
while n < 100 && n <= line("$")
let line = getline(n)
if line =~ '^\s*%'
setf yacc
return
endif
if getline(n) =~ '^\s*\(#\|class\>\)' && getline(n) !~ '^\s*#\s*include'
setf racc
return
endif
let n = n + 1
endwhile
setf yacc
endfunc
func dist#ft#Redif()
let lnum = 1
while lnum <= 5 && lnum < line('$')
if getline(lnum) =~ "^\ctemplate-type:"
setf redif
return
endif
let lnum = lnum + 1
endwhile
endfunc
let &cpo = s:cpo_save
unlet s:cpo_save
