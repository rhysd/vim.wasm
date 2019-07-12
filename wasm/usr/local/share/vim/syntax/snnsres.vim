if exists("b:current_syntax")
finish
endif
syn match	snnsresNoHeader	"No\. of patterns\s*:\s*" contained
syn match	snnsresNoHeader	"No\. of input units\s*:\s*" contained
syn match	snnsresNoHeader	"No\. of output units\s*:\s*" contained
syn match	snnsresNoHeader	"No\. of variable input dimensions\s*:\s*" contained
syn match	snnsresNoHeader	"No\. of variable output dimensions\s*:\s*" contained
syn match	snnsresNoHeader	"Maximum input dimensions\s*:\s*" contained
syn match	snnsresNoHeader	"Maximum output dimensions\s*:\s*" contained
syn match	snnsresNoHeader	"startpattern\s*:\s*" contained
syn match	snnsresNoHeader "endpattern\s*:\s*" contained
syn match	snnsresNoHeader "input patterns included" contained
syn match	snnsresNoHeader "teaching output included" contained
syn match	snnsresGen	"generated at.*" contained contains=snnsresNumbers
syn match	snnsresGen	"SNNS result file [Vv]\d\.\d" contained contains=snnsresNumbers
syn region	snnsresHeader	start="^SNNS" end="^\s*[-+\.]\=[0-9#]"me=e-2 contains=snnsresNoHeader,snnsresNumbers,snnsresGen
syn match	snnsresNumbers	"\d" contained
syn match	snnsresComment	"#.*$" contains=snnsresTodo
syn keyword	snnsresTodo	TODO XXX FIXME contained
hi def link snnsresGen		Statement
hi def link snnsresHeader		Statement
hi def link snnsresNoHeader	Define
hi def link snnsresNumbers		Number
hi def link snnsresComment		Comment
hi def link snnsresTodo		Todo
let b:current_syntax = "snnsres"
