if exists("b:current_syntax")
finish
endif
if !exists("main_syntax")
let main_syntax = 'gsp'
endif
runtime! syntax/html.vim
unlet b:current_syntax
syn case match
syn include @gspJava syntax/java.vim
let s:cpo_save = &cpo
set cpo&vim
syn keyword htmlTagName contained java
syn keyword htmlArg     contained type file page
syn region htmlString contained start=+"+ end=+"+ contains=htmlSpecialChar,javaScriptExpression,@htmlPreproc,gspInLine
syn region htmlString contained start=+'+ end=+'+ contains=htmlSpecialChar,javaScriptExpression,@htmlPreproc,gspInLine
syn match  htmlValue  contained "=[\t ]*[^'" \t>][^ \t>]*"hs=s+1 contains=javaScriptExpression,@htmlPreproc,gspInLine
syn region htmlEndTag		start=+</+    end=+>+ contains=htmlTagN,htmlTagError,gspInLine
syn region htmlTag		start=+<[^/]+ end=+>+ contains=htmlTagN,htmlString,htmlArg,htmlValue,htmlTagError,htmlEvent,htmlCssDefinition,@htmlPreproc,@htmlArgCluster,gspInLine
syn match  htmlTagN   contained +<\s*[-a-zA-Z0-9]\++hs=s+1 contains=htmlTagName,htmlSpecialTagName,@htmlTagNameCluster,gspInLine
syn match  htmlTagN   contained +</\s*[-a-zA-Z0-9]\++hs=s+2 contains=htmlTagName,htmlSpecialTagName,@htmlTagNameCluster,gspInLine
syn region  gspJavaBlock start="<java\>[^>]*\>" end="</java>"me=e-7 contains=@gspJava,htmlTag
syn region  gspInLine    matchgroup=htmlError start="`" end="`" contains=@gspJava
let b:current_syntax = "gsp"
if main_syntax == 'gsp'
unlet main_syntax
endif
let &cpo = s:cpo_save
unlet s:cpo_save
