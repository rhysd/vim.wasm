if exists("b:current_syntax")
finish
endif
let s:cpo_save=&cpo
set cpo&vim
syn case match
syn sync lines=1000
setlocal iskeyword=@,48-57,.,@-@,_,192-255
syn keyword loutTodo contained TODO lout Lout LOUT
syn keyword loutDefine def macro
syn keyword loutKeyword @Begin @End @Figure @Tab
syn keyword loutKeyword @Book @Doc @Document @Report
syn keyword loutKeyword @Introduction @Abstract @Appendix
syn keyword loutKeyword @Chapter @Section @BeginSections @EndSections
syn match loutFunction '\<@[^ \t{}]\+\>'
syn match loutMBraces '[{}]'
syn match loutIBraces '[{}]'
syn match loutBBrace '[{}]'
syn match loutBIBraces '[{}]'
syn match loutHeads '[{}]'
syn match loutBraceError '}'
syn match loutEOmlDef '^//$'
syn region loutObject transparent matchgroup=Delimiter start='{' matchgroup=Delimiter end='}' contains=ALLBUT,loutBraceError
syn keyword loutNULL {}
syn region loutComment start='\#' end='$' contains=loutTodo
syn region loutSpecial start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match loutSymbols '@\(\(Char\)\|\(Sym\)\)\s\+[A-Za-z]\+'
syn match loutInclude '@IncludeGraphic\s\+\k\+'
syn region loutInclude start='@\(\(SysInclude\)\|\(IncludeGraphic\)\|\(Include\)\)\s*{' end='}'
syn match loutTag '@\(\(Tag\)\|\(PageMark\)\|\(PageOf\)\|\(NumberOf\)\)\s\+\k\+'
syn region loutTag start='@Tag\s*{' end='}'
syn match loutMath '@Eq\s\+\k\+'
syn region loutMath matchgroup=loutMBraces start='@Eq\s*{' matchgroup=loutMBraces end='}' contains=ALLBUT,loutBraceError
syn match loutItalic '@I\s\+\k\+'
syn region loutItalic matchgroup=loutIBraces start='@I\s*{' matchgroup=loutIBraces end='}' contains=ALLBUT,loutBraceError
syn match loutBold '@B\s\+\k\+'
syn region loutBold matchgroup=loutBBraces start='@B\s*{' matchgroup=loutBBraces end='}' contains=ALLBUT,loutBraceError
syn match loutBoldItalic '@BI\s\+\k\+'
syn region loutBoldItalic matchgroup=loutBIBraces start='@BI\s*{' matchgroup=loutBIBraces end='}' contains=ALLBUT,loutBraceError
syn region loutHeadings matchgroup=loutHeads start='@\(\(Title\)\|\(Caption\)\)\s*{' matchgroup=loutHeads end='}' contains=ALLBUT,loutBraceError
hi def link loutTodo Todo
hi def link loutDefine Define
hi def link loutEOmlDef Define
hi def link loutFunction Function
hi def link loutBraceError Error
hi def link loutNULL Special
hi def link loutComment Comment
hi def link loutSpecial Special
hi def link loutSymbols Character
hi def link loutInclude Include
hi def link loutKeyword Keyword
hi def link loutTag Tag
hi def link loutMath Number
hi def link loutMBraces loutMath
hi loutItalic term=italic cterm=italic gui=italic
hi def link loutIBraces loutItalic
hi loutBold term=bold cterm=bold gui=bold
hi def link loutBBraces loutBold
hi loutBoldItalic term=bold,italic cterm=bold,italic gui=bold,italic
hi def link loutBIBraces loutBoldItalic
hi loutHeadings term=bold cterm=bold guifg=indianred
hi def link loutHeads loutHeadings
let b:current_syntax = "lout"
let &cpo=s:cpo_save
unlet s:cpo_save
