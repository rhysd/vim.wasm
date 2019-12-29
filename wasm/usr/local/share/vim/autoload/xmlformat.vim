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
let count_orig = v:count
let sw  = shiftwidth()
let prev = prevnonblank(v:lnum-1)
let s:indent = indent(prev)/sw
let result = []
let lastitem = prev ? getline(prev) : ''
let is_xml_decl = 0
let list = getline(v:lnum, (v:lnum + count_orig - 1))
let current = 0
for line in list
if empty(line)
call add(result, '')
continue
elseif line !~# '<[/]\?[^>]*>'
let nextmatch = match(list, '<[/]\?[^>]*>', current)
let line .= join(list[(current + 1):(nextmatch-1)], "\n")
call remove(list, current+1, nextmatch-1)
endif
for item in split(line, '.\@<=[>]\zs')
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
if s:IsTag(lastitem)
let s:indent+=1
endif
let result+=s:FormatContent([t[0]])
if s:EndTag(t[1])
let s:indent = s:DecreaseIndent()
endif
let result+=s:FormatContent(t[1:])
else
call add(result, s:Indent(item))
endif
endif
let lastitem = item
endfor
let current += 1
endfor
if !empty(result)
let lastprevline = getline(v:lnum + count_orig)
let delete_lastline = v:lnum + count_orig - 1 == line('$')
exe v:lnum. ",". (v:lnum + count_orig - 1). 'd'
call append(v:lnum - 1, result)
let last = v:lnum + len(result)
if getline(last) is '' && lastprevline is '' && delete_lastline
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
func! s:FormatContent(list)
let result=[]
let limit = 80
if &textwidth > 0
let limit = &textwidth
endif
let column=0
let idx = -1
let add_indent = 0
let cnt = 0
for item in a:list
for word in split(item, '\s\+\S\+\zs') 
let column += strdisplaywidth(word, column)
if match(word, "^\\s*\n\\+\\s*$") > -1
call add(result, '')
let idx += 1
let column = 0
let add_indent = 1
elseif column > limit || cnt == 0
let add = s:Indent(s:Trim(word))
call add(result, add)
let column = strdisplaywidth(add)
let idx += 1
else
if add_indent
let result[idx] = s:Indent(s:Trim(word))
else
let result[idx] .= ' '. s:Trim(word)
endif
let add_indent = 0
endif
let cnt += 1
endfor
endfor
return result
endfunc
let &cpo= s:keepcpo
unlet s:keepcpo
