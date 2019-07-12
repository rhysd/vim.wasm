if exists("b:current_syntax")
finish
endif
runtime! syntax/html.vim
unlet b:current_syntax
if !exists("main_syntax")
let main_syntax = 'wml'
endif
syn match wmlNextLine	"\\$"
syn clear htmlTag
syn region  htmlTag  start=+<[^/<]+ end=+>+  contains=htmlTagN,htmlString,htmlArg,htmlValue,htmlTagError,htmlEvent,htmlCssDefinition
syn keyword htmlTagName contained gfont imgbg imgdot lowsrc
syn keyword htmlTagName contained navbar:define navbar:header
syn keyword htmlTagName contained navbar:footer navbar:prolog
syn keyword htmlTagName contained navbar:epilog navbar:button
syn keyword htmlTagName contained navbar:filter navbar:debug
syn keyword htmlTagName contained navbar:render
syn keyword htmlTagName contained preload rollover
syn keyword htmlTagName contained space hspace vspace over
syn keyword htmlTagName contained ps ds pi ein big sc spaced headline
syn keyword htmlTagName contained ue subheadline zwue verbcode
syn keyword htmlTagName contained isolatin pod sdf text url verbatim
syn keyword htmlTagName contained xtable
syn keyword htmlTagName contained csmap fsview import box
syn keyword htmlTagName contained case:upper case:lower
syn keyword htmlTagName contained grid cell info lang: logo page
syn keyword htmlTagName contained set-var restore
syn keyword htmlTagName contained array:push array:show set-var ifdef
syn keyword htmlTagName contained say m4 symbol dump enter divert
syn keyword htmlTagName contained toc
syn keyword htmlTagName contained wml card do refresh oneevent catch spawn
syn keyword htmlArg contained adjust background base bdcolor bdspace
syn keyword htmlArg contained bdwidth complete copyright created crop
syn keyword htmlArg contained direction description domainname eperlfilter
syn keyword htmlArg contained file hint imgbase imgstar interchar interline
syn keyword htmlArg contained keephr keepindex keywords layout spacing
syn keyword htmlArg contained padding nonetscape noscale notag notypo
syn keyword htmlArg contained onload oversrc pos select slices style
syn keyword htmlArg contained subselected txtcol_select txtcol_normal
syn keyword htmlArg contained txtonly via
syn keyword htmlArg contained mode columns localsrc ordered
syn match   wmlComment     "^\s*#.*"
syn match   wmlSharpBang   "^#!.*"
syn match   wmlUsed	   contained "\s\s*[A-Za-z:_-]*"
syn match   wmlUse	   "^\s*#\s*use\s\+" contains=wmlUsed
syn match   wmlInclude	   "^\s*#\s*include.+"
syn region  wmlBody	   contained start=+<<+ end=+>>+
syn match   wmlLocationId  contained "[A-Za-z]\+"
syn region  wmlLocation    start=+<<+ end=+>>+ contains=wmlLocationId
syn match   wmlDivert      "\.\.[a-zA-Z_]\+>>"
syn match   wmlDivertEnd   "<<\.\."
syn match   wmlDefineName  contained "\s\+[A-Za-z-]\+"
syn region  htmlTagName    start="\<\(define-tag\|define-region\)" end="\>" contains=wmlDefineName
if main_syntax != 'perl'
syn include @wmlPerlScript syntax/perl.vim
unlet b:current_syntax
syn region perlScript   start=+<perl>+ keepend end=+</perl>+ contains=@wmlPerlScript,wmlPerlTag
syn region perlScript   start=+<:+ keepend end=+:>+ contains=@wmlPerlScript,wmlPerlTag
syn match    wmlPerlTag  contained "</*perl>" contains=wmlPerlTagN
syn keyword  wmlPerlTagN contained perl
hi link   wmlPerlTag  htmlTag
hi link   wmlPerlTagN htmlStatement
endif
syn region  wmlVerbatimText start=+<verbatim>+ keepend end=+</verbatim>+ contains=wmlVerbatimTag
syn match   wmlVerbatimTag  contained "</*verbatim>" contains=wmlVerbatimTagN
syn keyword wmlVerbatimTagN contained verbatim
hi link     wmlVerbatimTag  htmlTag
hi link     wmlVerbatimTagN htmlStatement
if main_syntax == "html"
syn sync match wmlHighlight groupthere NONE "</a-zA-Z]"
syn sync match wmlHighlight groupthere perlScript "<perl>"
syn sync match wmlHighlightSkip "^.*['\"].*$"
syn sync minlines=10
endif
hi def link wmlNextLine	Special
hi def link wmlUse		Include
hi def link wmlUsed	String
hi def link wmlBody	Special
hi def link wmlDiverted	Label
hi def link wmlDivert	Delimiter
hi def link wmlDivertEnd	Delimiter
hi def link wmlLocationId	Label
hi def link wmlLocation	Delimiter
hi def link wmlDefineName	String
hi def link wmlComment	Comment
hi def link wmlInclude	Include
hi def link wmlSharpBang	PreProc
let b:current_syntax = "wml"
