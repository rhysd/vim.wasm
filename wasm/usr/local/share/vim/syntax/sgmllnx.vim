if exists("b:current_syntax")
finish
endif
syn case ignore
syn region sgmllnxEndTag	start=+</+    end=+>+	contains=sgmllnxTagN,sgmllnxTagError
syn region sgmllnxTag	start=+<[^/]+ end=+>+	contains=sgmllnxTagN,sgmllnxTagError
syn match  sgmllnxTagN	contained +<\s*[-a-zA-Z0-9]\++ms=s+1	contains=sgmllnxTagName
syn match  sgmllnxTagN	contained +</\s*[-a-zA-Z0-9]\++ms=s+2	contains=sgmllnxTagName
syn region sgmllnxTag2	start=+<\s*[a-zA-Z]\+/+ keepend end=+/+	contains=sgmllnxTagN2
syn match  sgmllnxTagN2	contained +/.*/+ms=s+1,me=e-1
syn region sgmllnxSpecial	oneline start="&" end=";"
syn keyword sgmllnxTagName contained article author date toc title sect verb
syn keyword sgmllnxTagName contained abstract tscreen p itemize item enum
syn keyword sgmllnxTagName contained descrip quote htmlurl code ref
syn keyword sgmllnxTagName contained tt tag bf it url
syn match   sgmllnxTagName contained "sect\d\+"
syn region sgmllnxComment start=+<!--+ end=+-->+
syn region sgmllnxDocType start=+<!doctype+ end=+>+
hi def link sgmllnxTag2	    Function
hi def link sgmllnxTagN2	    Function
hi def link sgmllnxTag	    Special
hi def link sgmllnxEndTag	    Special
hi def link sgmllnxParen	    Special
hi def link sgmllnxEntity	    Type
hi def link sgmllnxDocEnt	    Type
hi def link sgmllnxTagName	    Statement
hi def link sgmllnxComment	    Comment
hi def link sgmllnxSpecial	    Special
hi def link sgmllnxDocType	    PreProc
hi def link sgmllnxTagError    Error
let b:current_syntax = "sgmllnx"
