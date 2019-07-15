if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1
let s:save_cpo = &cpo
set cpo-=C
setlocal formatoptions-=t
setlocal formatoptions+=crqol
setlocal keywordprg=perldoc\ -f
setlocal comments=:#
setlocal commentstring=#%s
if has("gui_win32")
let b:browsefilter = "Perl Source Files (*.pl)\t*.pl\n" .
\ "Perl Modules (*.pm)\t*.pm\n" .
\ "Perl Documentation Files (*.pod)\t*.pod\n" .
\ "All Files (*.*)\t*.*\n"
endif
setlocal include=\\<\\(use\\\|require\\)\\>
setlocal includeexpr=substitute(substitute(substitute(v:fname,'::','/','g'),'->\*','',''),'$','.pm','')
setlocal define=[^A-Za-z_]
setlocal iskeyword+=:
set isfname+=:
if !exists("perlpath")
if executable("perl")
try
if &shellxquote != '"'
let perlpath = system('perl -e "print join(q/,/,@INC)"')
else
let perlpath = system("perl -e 'print join(q/,/,@INC)'")
endif
let perlpath = substitute(perlpath,',.$',',,','')
catch /E145:/
let perlpath = ".,,"
endtry
else
let perlpath = ".,,"
endif
endif
if &l:path == ""
if &g:path == ""
let &l:path=perlpath
else
let &l:path=&g:path.",".perlpath
endif
else
let &l:path=&l:path.",".perlpath
endif
let b:undo_ftplugin = "setlocal fo< com< cms< inc< inex< def< isk< isf< kp< path<" .
\	      " | unlet! b:browsefilter"
let b:match_skip = 's:comment\|string\|perlQQ\|perlShellCommand\|perlHereDoc\|perlSubstitution\|perlTranslation\|perlMatch\|perlFormatField'
let b:match_words = '\<if\>:\<elsif\>:\<else\>'
let &cpo = s:save_cpo
unlet s:save_cpo
