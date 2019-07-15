if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1
let s:save_cpo = &cpo
set cpo-=C
setlocal formatoptions-=t
setlocal formatoptions+=crqol
setlocal keywordprg=p6doc
setlocal comments=:#
setlocal commentstring=#%s
if has("gui_win32")
let b:browsefilter = "Perl Source Files (*.pl)\t*.pl\n" .
\ "Perl Modules (*.pm)\t*.pm\n" .
\ "Perl Documentation Files (*.pod)\t*.pod\n" .
\ "All Files (*.*)\t*.*\n"
endif
setlocal include=\\<\\(use\\\|require\\)\\>
setlocal includeexpr=substitute(substitute(v:fname,'::','/','g'),'$','.pm','')
setlocal define=[^A-Za-z_]
set isfname+=:
setlocal iskeyword=48-57,_,A-Z,a-z,:,-
if !exists("perlpath")
if executable("perl6")
try
if &shellxquote != '"'
let perlpath = system('perl6 -e  "@*INC.join(q/,/).say"')
else
let perlpath = system("perl6 -e  '@*INC.join(q/,/).say'")
endif
let perlpath = substitute(perlpath,',.$',',,','')
catch /E145:/
let perlpath = ".,,"
endtry
else
let perlpath = ".,,"
endif
endif
let &l:path=perlpath
let b:undo_ftplugin = "setlocal fo< com< cms< inc< inex< def< isk<" .
\         " | unlet! b:browsefilter"
let &cpo = s:save_cpo
unlet s:save_cpo
