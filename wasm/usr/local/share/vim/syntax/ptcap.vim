if exists("b:current_syntax")
finish
endif
syn case ignore
if exists("ptcap_minlines")
exe "syn sync lines=".ptcap_minlines
else
syn sync lines=20
endif
syn match ptcapError	    "^.*\S.*$"
syn match ptcapLeadBlank    "^\s\+" contained
syn match ptcapDelimiter    "[:|]" contained
syn match ptcapEscapedChar  "\\." contained
syn match ptcapEscapedChar  "\^." contained
syn match ptcapEscapedChar  "\\\o\{3}" contained
syn match ptcapLineCont	    "\\$" contained
syn match ptcapNumber	    "#\(+\|-\)\=\d\+"lc=1 contained
syn match ptcapNumberError  "#\d*[^[:digit:]:\\]"lc=1 contained
syn match ptcapNumber	    "#0x\x\{1,8}"lc=1 contained
syn match ptcapNumberError  "#0x\X"me=e-1,lc=1 contained
syn match ptcapNumberError  "#0x\x\{9}"lc=1 contained
syn match ptcapNumberError  "#0x\x*[^[:xdigit:]:\\]"lc=1 contained
syn match ptcapOperator	    "[@#=]" contained
syn match ptcapSpecialCap   "\W[#@]\d" contains=ptcapDelimiter contained
if exists("b:ptcap_type") && b:ptcap_type[0] == 't'
syn region ptcapEntry   start="^\s*[^[:space:]:]" end="[^\\]\(\\\\\)*$" end="^$" contains=ptcapNames,ptcapField,ptcapLeadBlank keepend
else
syn region ptcapEntry   start="^\s*[^[:space:]:]"me=e-1 end="^\s*[^[:space:]:#]"me=e-1 contains=ptcapNames,ptcapField,ptcapLeadBlank,ptcapComment
endif
syn region ptcapNames	    start="^\s*[^[:space:]:]" skip="[^\\]\(\\\\\)*\\:" end=":"me=e-1 contains=ptcapDelimiter,ptcapEscapedChar,ptcapLineCont,ptcapLeadBlank,ptcapComment keepend contained
syn region ptcapField	    start=":" skip="[^\\]\(\\\\\)*\\$" end="[^\\]\(\\\\\)*:"me=e-1 end="$" contains=ptcapDelimiter,ptcapString,ptcapNumber,ptcapNumberError,ptcapOperator,ptcapLineCont,ptcapSpecialCap,ptcapLeadBlank,ptcapComment keepend contained
syn region ptcapString	    matchgroup=ptcapOperator start="=" skip="[^\\]\(\\\\\)*\\:" matchgroup=ptcapDelimiter end=":"me=e-1 matchgroup=NONE end="[^\\]\(\\\\\)*[^\\]$" end="^$" contains=ptcapEscapedChar,ptcapLineCont keepend contained
syn region ptcapComment	    start="^\s*#" end="$" contains=ptcapLeadBlank
hi def link ptcapComment		Comment
hi def link ptcapDelimiter	Delimiter
hi def link ptcapEntry		Todo
hi def link ptcapError		Error
hi def link ptcapEscapedChar	SpecialChar
hi def link ptcapField		Type
hi def link ptcapLeadBlank	NONE
hi def link ptcapLineCont	Special
hi def link ptcapNames		Label
hi def link ptcapNumber		NONE
hi def link ptcapNumberError	Error
hi def link ptcapOperator	Operator
hi def link ptcapSpecialCap	Type
hi def link ptcapString		NONE
let b:current_syntax = "ptcap"
