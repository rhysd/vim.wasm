if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn match   htmlSpecialChar "&[^;]*;" contained
syn match   HBhtmlTagSk  contained "[A-Za-z]*"
syn match   HBhtmlTagS   contained "<\s*\(hb\s*\.\s*\(sec\|min\|hour\|day\|mon\|year\|input\|html\|time\|getcookie\|streql\|url-enc\)\|wall\s*\.\s*\(show\|info\|id\|new\|rm\|count\)\|auth\s*\.\s*\(chk\|add\|find\|user\)\|math\s*\.\s*exp\)\s*\([^.A-Za-z0-9]\|$\)" contains=HBhtmlTagSk transparent
syn match   HBhtmlTagN   contained "[A-Za-z0-9\/\-]\+"
syn match   HBhtmlTagB   contained "<\s*[A-Za-z0-9\/\-]\+\(\s*\.\s*[A-Za-z0-9\/\-]\+\)*" contains=HBhtmlTagS,HBhtmlTagN
syn region  HBhtmlTag contained start=+<+ end=+>+ contains=HBhtmlTagB,HBDirectiveError
syn match HBFileName ".*" contained
syn match HBDirectiveKeyword	":\s*\(include\|lib\|set\|out\)\s\+" contained
syn match HBDirectiveError	"^:.*$" contained
syn match HBInvalidLine "^.*$"
syn match HBDirectiveInclude "^:\s*include\s\+\S\+.*$" contains=HBFileName,HBDirectiveKeyword
syn match HBDirectiveLib "^:\s*lib\s\+\S\+.*$" contains=HBFileName,HBDirectiveKeyword
syn region HBText matchgroup=HBDirectiveKeyword start=/^:\(set\|out\)\s*\S\+.*$/ end=/^:\s*$/ contains=HBDirectiveError,htmlSpecialChar,HBhtmlTag keepend
syn match HBComment "^#.*$"
hi def link HBhtmlString			 String
hi def link HBhtmlTagN			 Function
hi def link htmlSpecialChar		 String
hi def link HBInvalidLine Error
hi def link HBFoobar Comment
hi HBFileName guibg=lightgray guifg=black
hi def link HBDirectiveError Error
hi def link HBDirectiveBlockEnd HBDirectiveKeyword
hi HBDirectiveKeyword guibg=lightgray guifg=darkgreen
hi def link HBComment Comment
hi def link HBhtmlTagSk Statement
syn sync match Normal grouphere NONE "^:\s*$"
syn sync match Normal grouphere NONE "^:\s*lib\s\+[^ \t]\+$"
syn sync match Normal grouphere NONE "^:\s*include\s\+[^ \t]\+$"
let b:current_syntax = "hb"
let &cpo = s:cpo_save
unlet s:cpo_save
