if exists("b:current_syntax")
finish
endif
syn match   wvdialComment   "^;.*$"lc=1
syn match   wvdialComment   "[^\\];.*$"lc=1
syn match   wvdialSection   "^\s*\[.*\]"
syn match   wvdialValue     "=.*$"ms=s+1
syn match   wvdialValue     "\s*[^ ;"' ]\+"lc=1
syn match   wvdialVar       "^\s*\(Inherits\|Modem\|Baud\|Init.\|Phone\|Area\ Code\|Dial\ Prefix\|Dial\ Command\|Login\|Login\| Prompt\|Password\|Password\ Prompt\|PPPD\ Path\|Force\ Address\|Remote\ Name\|Carrier\ Check\|Stupid\ [Mm]ode\|New\ PPPD\|Default\ Reply\|Auto\ Reconnect\|SetVolume\|Username\)"
syn match   wvdialEqual     "="
hi def link wvdialComment   Comment
hi def link wvdialSection   PreProc
hi def link wvdialVar       Identifier
hi def link wvdialValue     String
hi def link wvdialEqual     Statement
let b:current_syntax = "wvdial"
