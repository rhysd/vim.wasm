if exists ("b:current_syntax")
finish
endif
syn case ignore
syn keyword CfgOnOff  ON OFF YES NO TRUE FALSE  contained
syn match UncPath "\\\\\p*" contained
syn match CfgDirectory "[a-zA-Z]:\\\p*" contained
syn match   CfgParams    ".\{0}="me=e-1 contains=CfgComment
syn match   CfgValues    "=.*"hs=s+1 contains=CfgDirectory,UncPath,CfgComment,CfgString,CfgOnOff
syn match CfgSection	    "\[.*\]"
syn match CfgSection	    "{.*}"
syn match  CfgString	"\".*\"" contained
syn match  CfgString    "'.*'"   contained
syn match  CfgComment	"#.*"
syn match  CfgComment	";.*"
syn match  CfgComment	"\/\/.*"
hi def link CfgOnOff     Label
hi def link CfgComment	Comment
hi def link CfgSection	Type
hi def link CfgString	String
hi def link CfgParams    Keyword
hi def link CfgValues    Constant
hi def link CfgDirectory Directory
hi def link UncPath      Directory
let b:current_syntax = "cfg"
