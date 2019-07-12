if exists ("b:did_ftplugin") || version < 700
finish
endif
let b:did_ftplugin = 45
let s:cpoptions = &cpoptions
set cpoptions-=C
setlocal comments=O:--,:--\ \ 
setlocal commentstring=--\ \ %s
setlocal complete=.,w,b,u,t,i
setlocal nosmartcase
setlocal ignorecase
setlocal formatoptions+=ron
if exists ("g:ada_extended_tagging")
if g:ada_extended_tagging == 'jump'
if mapcheck('<C-]>','n') == ''
nnoremap <unique> <buffer> <C-]>    :call ada#Jump_Tag ('', 'tjump')<cr>
endif
if mapcheck('g<C-]>','n') == ''
nnoremap <unique> <buffer> g<C-]>   :call ada#Jump_Tag ('','stjump')<cr>
endif
elseif g:ada_extended_tagging == 'list'
if mapcheck('<C-]>','n') == ''
nnoremap <unique> <buffer> <C-]>    :call ada#List_Tag ()<cr>
endif
if mapcheck('g<C-]>','n') == ''
nnoremap <unique> <buffer> g<C-]>   :call ada#List_Tag ()<cr>
endif
endif
endif
setlocal completefunc=ada#User_Complete
setlocal omnifunc=adacomplete#Complete
if exists ("g:ada_extended_completion")
if mapcheck ('<C-N>','i') == ''
inoremap <unique> <buffer> <C-N> <C-R>=ada#Completion("\<lt>C-N>")<cr>
endif
if mapcheck ('<C-P>','i') == ''
inoremap <unique> <buffer> <C-P> <C-R>=ada#Completion("\<lt>C-P>")<cr>
endif
if mapcheck ('<C-X><C-]>','i') == ''
inoremap <unique> <buffer> <C-X><C-]> <C-R>=<SID>ada#Completion("\<lt>C-X>\<lt>C-]>")<cr>
endif
if mapcheck ('<bs>','i') == ''
inoremap <silent> <unique> <buffer> <bs> <C-R>=ada#Insert_Backspace ()<cr>
endif
endif
if !exists ("b:match_words")  &&
\ exists ("loaded_matchit")
let s:notend      = '\%(\<end\s\+\)\@<!'
let b:match_words =
\ s:notend . '\<if\>:\<elsif\>:\<else\>:\<end\>\s\+\<if\>,' .
\ s:notend . '\<case\>:\<when\>:\<end\>\s\+\<case\>,' .
\ '\%(\<while\>.*\|\<for\>.*\|'.s:notend.'\)\<loop\>:\<end\>\s\+\<loop\>,' .
\ '\%(\<do\>\|\<begin\>\):\<exception\>:\<end\>\s*\%($\|[;A-Z]\),' .
\ s:notend . '\<record\>:\<end\>\s\+\<record\>'
endif
if ! exists("g:ada_default_compiler")
if has("vms")
let g:ada_default_compiler = 'decada'
else
let g:ada_default_compiler = 'gnat'
endif
endif
if ! exists("current_compiler")			||
\ current_compiler != g:ada_default_compiler
execute "compiler " . g:ada_default_compiler
endif
if exists("g:ada_folding")
if g:ada_folding[0] == 'i'
setlocal foldmethod=indent
setlocal foldignore=--
setlocal foldnestmax=5
elseif g:ada_folding[0] == 'g'
setlocal foldmethod=expr
setlocal foldexpr=ada#Pretty_Print_Folding(v:lnum)
elseif g:ada_folding[0] == 's'
setlocal foldmethod=syntax
endif
setlocal tabstop=8
setlocal softtabstop=3
setlocal shiftwidth=3
endif
if exists("g:ada_abbrev")
iabbrev ret	return
iabbrev proc procedure
iabbrev pack package
iabbrev func function
endif
call ada#Map_Popup (
\ 'Tag.List',
\  'l',
\ 'call ada#List_Tag ()')
call ada#Map_Popup (
\'Tag.Jump',
\'j',
\'call ada#Jump_Tag ()')
call ada#Map_Menu (
\'Tag.Create File',
\':AdaTagFile',
\'call ada#Create_Tags (''file'')')
call ada#Map_Menu (
\'Tag.Create Dir',
\':AdaTagDir',
\'call ada#Create_Tags (''dir'')')
call ada#Map_Menu (
\'Highlight.Toggle Space Errors',
\ ':AdaSpaces',
\'call ada#Switch_Syntax_Option (''space_errors'')')
call ada#Map_Menu (
\'Highlight.Toggle Lines Errors',
\ ':AdaLines',
\'call ada#Switch_Syntax_Option (''line_errors'')')
call ada#Map_Menu (
\'Highlight.Toggle Rainbow Color',
\ ':AdaRainbow',
\'call ada#Switch_Syntax_Option (''rainbow_color'')')
call ada#Map_Menu (
\'Highlight.Toggle Standard Types',
\ ':AdaTypes',
\'call ada#Switch_Syntax_Option (''standard_types'')')
let &cpoptions = s:cpoptions
unlet s:cpoptions
finish " 1}}}
