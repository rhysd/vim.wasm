if exists("b:current_syntax")
finish
endif
syn case match
syn region	jgraphComment	start="(\* " end=" \*)"
syn keyword	jgraphCmd	newcurve newgraph marktype
syn keyword	jgraphType	xaxis yaxis
syn keyword	jgraphType	circle box diamond triangle x cross ellipse
syn keyword	jgraphType	xbar ybar text postscript eps none general
syn keyword	jgraphType	solid dotted dashed longdash dotdash dodotdash
syn keyword	jgraphType	dotdotdashdash pts
syn match  jgraphNumber		 "\<-\=\d\+\>"
syn match  jgraphNumber		 "\<-\=\d\+\.\d*\>"
syn match  jgraphNumber		 "\-\=\.\d\+\>"
hi def link jgraphComment	Comment
hi def link jgraphCmd	Identifier
hi def link jgraphType	Type
hi def link jgraphNumber	Number
let b:current_syntax = "jgraph"
