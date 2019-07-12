if exists("b:did_ftplugin")
finish
endif
let s:cposet=&cpoptions
set cpoptions&vim
let b:did_ftplugin = 1
if !exists("b:fortran_fixed_source")
if exists("fortran_free_source")
let b:fortran_fixed_source = 0
elseif exists("fortran_fixed_source")
let b:fortran_fixed_source = 1
elseif expand("%:e") ==? "f\<90\|95\|03\|08\>"
let b:fortran_fixed_source = 0
elseif expand("%:e") ==? "f\|f77\|for"
let b:fortran_fixed_source = 1
else
let s:lmax = 500
if ( s:lmax > line("$") )
let s:lmax = line("$")
endif
let b:fortran_fixed_source = 1
let s:ln=1
while s:ln <= s:lmax
let s:test = strpart(getline(s:ln),0,5)
if s:test !~ '^[Cc*]' && s:test !~ '^ *[!#]' && s:test =~ '[^ 0-9\t]' && s:test !~ '^[ 0-9]*\t'
let b:fortran_fixed_source = 0
break
endif
let s:ln = s:ln + 1
endwhile
unlet! s:lmax s:ln s:test
endif
endif
if (b:fortran_fixed_source == 1)
setlocal comments=:!,:*,:C
setlocal tw=72
else
setlocal comments=:!
setlocal tw=132
endif
setlocal cms=!%s
if !exists("fortran_have_tabs")
setlocal expandtab
endif
setlocal fo+=t
setlocal include=^\\c#\\=\\s*include\\s\\+
setlocal suffixesadd+=.f08,.f03,.f95,.f90,.for,.f,.F,.f77,.ftn,.fpp
if !exists("b:match_words")
let s:notend = '\%(\<end\s\+\)\@<!'
let s:notselect = '\%(\<select\s\+\)\@<!'
let s:notelse = '\%(\<end\s\+\|\<else\s\+\)\@<!'
let s:notprocedure = '\%(\s\+procedure\>\)\@!'
let b:match_ignorecase = 1
let b:match_words =
\ '(:),' .
\ '\<select\s*case\>:' . s:notselect. '\<case\>:\<end\s*select\>,' .
\ s:notelse . '\<if\s*(.\+)\s*then\>:' .
\ '\<else\s*\%(if\s*(.\+)\s*then\)\=\>:\<end\s*if\>,'.
\ 'do\s\+\(\d\+\):\%(^\s*\)\@<=\1\s,'.
\ s:notend . '\<do\>:\<end\s*do\>,'.
\ s:notelse . '\<where\>:\<elsewhere\>:\<end\s*where\>,'.
\ s:notend . '\<type\s*[^(]:\<end\s*type\>,'.
\ s:notend . '\<forall\>:\<end\s*forall\>,'.
\ s:notend . '\<associate\>:\<end\s*associate\>,'.
\ s:notend . '\<enum\>:\<end\s*enum\>,'.
\ s:notend . '\<interface\>:\<end\s*interface\>,'.
\ s:notend . '\<subroutine\>:\<end\s*subroutine\>,'.
\ s:notend . '\<function\>:\<end\s*function\>,'.
\ s:notend . '\<module\>' . s:notprocedure . ':\<end\s*module\>,'.
\ s:notend . '\<program\>:\<end\s*program\>'
endif
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "Fortran Files (*.f;*.for;*.f77;*.f90;*.f95;*.f03;*.f08;*.fpp;*.ftn)\t*.f;*.for;*.f77;*.f90;*.f95;*.f03;*.f08;*.fpp;*.ftn\n" .
\ "All Files (*.*)\t*.*\n"
endif
let b:undo_ftplugin = "setl fo< com< tw< cms< et< inc< sua<"
\ . "| unlet! b:match_ignorecase b:match_words b:browsefilter"
let &cpoptions=s:cposet
unlet s:cposet
