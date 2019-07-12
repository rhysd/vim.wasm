if exists("g:loaded_xmlformat") || &cp
finish
endif
let g:loaded_xmlformat = 1
let s:keepcpo       = &cpo
set cpo&vim
func! xmlformat#Format()
if mode() != 'n'
return 0
endif
let sw  = shiftwidth()
let prev = prevnonblank(v:lnum-1)
let s:indent = indent(prev)/sw
let result = []
let lastitem = prev ? getline(prev) : ''
let is_xml_decl = 0
for item in split(join(getline(v:lnum, (v:lnum + v:count - 1))), '.\@<=[>]\zs')
if s:EndTag(item)
let s:indent = s:DecreaseIndent()
call add(result, s:Indent(item))
elseif s:EmptyTag(lastitem)
call add(result, s:Indent(item))
elseif s:StartTag(lastitem) && s:IsTag(item)
let s:indent += 1
call add(result, s:Indent(item))
else
if !s:IsTag(item)
let t=split(item, '.<\@=\zs')
let s:indent+=1
call add(result, s:Indent(t[0]))
let s:indent = s:DecreaseIndent()
call add(result, s:Indent(t[1]))
else
call add(result, s:Indent(item))
endif
endif
let lastitem = item
endfor
if !empty(result)
exe v:lnum. ",". (v:lnum + v:count - 1). 'd'
call append(v:lnum - 1, result)
let last = v:lnum + len(result)
if getline(last) is ''
exe last. 'd'
endif
endif
return 0
endfunc
func! s:IsXMLDecl(tag)
return a:tag =~? '^\s*<?xml\s\?\%(version="[^"]*"\)\?\s\?\%(encoding="[^"]*"\)\? ?>\s*$'
endfunc
func! s:Indent(item)
return repeat(' ', shiftwidth()*s:indent). s:Trim(a:item)
endfu
func! s:Trim(item)
if exists('*trim')
return trim(a:item)
else
return matchstr(a:item, '\S\+.*')
endif
endfunc
func! s:StartTag(tag)
let is_comment = s:IsComment(a:tag)
return a:tag =~? '^\s*<[^/?]' && !is_comment
endfunc
func! s:IsComment(tag)
return a:tag =~? '<!--'
endfunc
func! s:DecreaseIndent()
return (s:indent > 0 ? s:indent - 1 : 0)
endfunc
func! s:EndTag(tag)
return a:tag =~? '^\s*</'
endfunc
func! s:IsTag(tag)
return s:Trim(a:tag)[0] == '<'
endfunc
func! s:EmptyTag(tag)
return a:tag =~ '/>\s*$'
endfunc
let &cpo= s:keepcpo
unlet s:keepcpo
