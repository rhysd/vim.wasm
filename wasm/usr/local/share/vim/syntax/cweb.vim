if exists("b:current_syntax")
finish
endif
runtime! syntax/tex.vim
unlet b:current_syntax
syntax include @webIncludedC <sfile>:p:h/cpp.vim
let s:cpo_save = &cpo
set cpo&vim
syntax region webInnerCcontext start="\(^\|[ \t\~`(]\)|" end="|" contains=@webIncludedC,webSectionName,webRestrictedTeX,webIgnoredStuff
syntax region webCpart start="@[dfscp<(]" end="@[ \*]" contains=@webIncludedC,webSectionName,webRestrictedTeX,webIgnoredStuff
syntax region webSectionName start="@[<(]" end="@>" contains=webInnerCcontext contained
syntax region webRestrictedTeX start="@[\^\.:t=q]" end="@>" oneline
syntax match webIgnoredStuff "@@"
hi def link webRestrictedTeX String
let b:current_syntax = "cweb"
let &cpo = s:cpo_save
unlet s:cpo_save
