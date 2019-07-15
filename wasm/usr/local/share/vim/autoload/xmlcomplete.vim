function! xmlcomplete#CreateConnection(canonical, ...) " {{{
if exists("a:1")
let users = a:1
else
let users = 'DEFAULT'
endif
exe "runtime autoload/xml/".a:canonical.".vim"
if !exists("g:xmldata_".a:canonical)
unlet! g:xmldata_connection
return 0
endif
if !exists("g:xmldata_connection")
let g:xmldata_connection = {}
endif
let g:xmldata_connection[users] = a:canonical
endfunction
function! xmlcomplete#CreateEntConnection(...) " {{{
if a:0 > 0
let g:xmldata_entconnect = a:1
else
let g:xmldata_entconnect = 'DEFAULT'
endif
endfunction
function! xmlcomplete#CompleteTags(findstart, base)
if a:findstart
let curline = line('.')
let line = getline('.')
let start = col('.') - 1
let compl_begin = col('.') - 2
while start >= 0 && line[start - 1] =~ '\(\k\|[:.-]\)'
let start -= 1
endwhile
if start >= 0 && line[start - 1] =~ '&'
let b:entitiescompl = 1
let b:compl_context = ''
return start
endif
let b:compl_context = getline('.')[0:(compl_begin)]
if b:compl_context !~ '<[^>]*$'
let i = 1
while 1
let context_line = getline(curline-i)
if context_line =~ '<[^>]*$'
let context_lines = getline(curline-i, curline-1) + [b:compl_context]
let b:compl_context = join(context_lines, ' ')
break
elseif context_line =~ '>[^<]*$' || i == curline
let b:compl_context = ''
break
endif
let i += 1
endwhile
unlet! i
endif
let b:compl_context = matchstr(b:compl_context, '.*\zs<.*')
unlet! b:xml_namespace
let b:xml_namespace = matchstr(b:compl_context, '^<\zs\k*\ze:')
if b:xml_namespace == ''
let b:xml_namespace = 'DEFAULT'
endif
return start
else
let res = []
let res2 = []
if len(b:compl_context) == 0  && !exists("b:entitiescompl")
return []
endif
let context = matchstr(b:compl_context, '^<\zs.*')
unlet! b:compl_context
if !exists("g:xmldata_connection") || g:xmldata_connection == {}
let b:unaryTagsStack = "base meta link hr br param img area input col"
if context =~ '^\/'
let opentag = xmlcomplete#GetLastOpenTag("b:unaryTagsStack")
return [opentag.">"]
else
return []
endif
endif
if exists("b:entitiescompl")
unlet! b:entitiescompl
if !exists("g:xmldata_entconnect") || g:xmldata_entconnect == 'DEFAULT'
let values =  g:xmldata{'_'.g:xmldata_connection['DEFAULT']}['vimxmlentities']
else
let values =  g:xmldata{'_'.g:xmldata_entconnect}['vimxmlentities']
endif
let entdecl = filter(getline(1, "$"), 'v:val =~ "<!ENTITY\\s\\+[^%]"')
if len(entdecl) > 0
let intent = map(copy(entdecl), 'matchstr(v:val, "<!ENTITY\\s\\+\\zs\\(\\k\\|[.-:]\\)\\+\\ze")')
let values = intent + values
endif
if len(a:base) == 1
for m in values
if m =~ '^'.a:base
call add(res, m.';')
endif
endfor
return res
else
for m in values
if m =~? '^'.a:base
call add(res, m.';')
elseif m =~? a:base
call add(res2, m.';')
endif
endfor
return res + res2
endif
endif
if context =~ '>'
return []
endif
if context == ''
let tag = ''
else
let tag = split(context)[0]
endif
let tag = substitute(tag, '^'.b:xml_namespace.':', '', '')
let attr = matchstr(context, '.*\s\zs.*')
if context =~ '\s'
if attr =~ "=\s*[\"']" || attr =~ "=\s*$"
let attrname = matchstr(attr, '.*\ze\s*=')
let entered_value = matchstr(attr, ".*=\\s*[\"']\\?\\zs.*")
if tag =~ '^[?!]'
return []
else
if has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}, tag) && has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[tag][1], attrname)
let values = g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[tag][1][attrname]
else
return []
endif
endif
if len(values) == 0
return []
endif
let attrbase = matchstr(context, ".*[\"']")
let attrquote = matchstr(attrbase, '.$')
if attrquote !~ "['\"]"
let attrquoteopen = '"'
let attrquote = '"'
else
let attrquoteopen = ''
endif
for m in values
if m =~ '^'.entered_value
call add(res, attrquoteopen . m . attrquote.' ')
elseif m =~ entered_value
call add(res2, attrquoteopen . m . attrquote.' ')
endif
endfor
return res + res2
endif
if tag =~ '?xml'
let attrs = ['encoding', 'version="1.0"', 'version']
elseif tag =~ '^!'
return []
else
if !has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}, tag)
return []
endif
let attrs = keys(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[tag][1])
endif
for m in sort(attrs)
if m =~ '^'.attr
call add(res, m)
elseif m =~ attr
call add(res2, m)
endif
endfor
let menu = res + res2
let final_menu = []
if has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}, 'vimxmlattrinfo')
for i in range(len(menu))
let item = menu[i]
if has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}['vimxmlattrinfo'], item)
let m_menu = g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}['vimxmlattrinfo'][item][0]
let m_info = g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}['vimxmlattrinfo'][item][1]
else
let m_menu = ''
let m_info = ''
endif
if tag !~ '^[?!]' && len(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[tag][1][item]) > 0 && g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[tag][1][item][0] =~ '^\(BOOL\|'.item.'\)$'
let item = item
else
let item .= '="'
endif
let final_menu += [{'word':item, 'menu':m_menu, 'info':m_info}]
endfor
else
for i in range(len(menu))
let item = menu[i]
if tag !~ '^[?!]' && len(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[tag][1][item]) > 0 && g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[tag][1][item][0] =~ '^\(BOOL\|'.item.'\)$'
let item = item
else
let item .= '="'
endif
let final_menu += [item]
endfor
endif
return final_menu
endif
let b:unaryTagsStack = "base meta link hr br param img area input col"
if context =~ '^\/'
let opentag = xmlcomplete#GetLastOpenTag("b:unaryTagsStack")
return [opentag.">"]
endif
if context =~ '^!'
let tags = ['!ELEMENT', '!DOCTYPE', '!ATTLIST', '!ENTITY', '!NOTATION', '![CDATA[', '![INCLUDE[', '![IGNORE[']
for m in tags
if m =~ '^'.context
let m = substitute(m, '^!\[\?', '', '')
call add(res, m)
elseif m =~ context
let m = substitute(m, '^!\[\?', '', '')
call add(res2, m)
endif
endfor
return res + res2
endif
if context =~ '^?'
let tags = ['?xml']
for m in tags
if m =~ '^'.context
call add(res, substitute(m, '^?', '', ''))
elseif m =~ context
call add(res, substitute(m, '^?', '', ''))
endif
endfor
return res + res2
endif
let opentag = xmlcomplete#GetLastOpenTag("b:unaryTagsStack")
let opentag = substitute(opentag, '^\k*:', '', '')
if opentag == ''
let tags = keys(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]})
call filter(tags, 'v:val !~ "^vimxml"')
else
if !has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}, opentag)
return []
endif
let tags = g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}[opentag][0]
endif
let context = substitute(context, '^\k*:', '', '')
for m in tags
if m =~ '^'.context
call add(res, m)
elseif m =~ context
call add(res2, m)
endif
endfor
let menu = res + res2
if b:xml_namespace == 'DEFAULT'
let xml_namespace = ''
else
let xml_namespace = b:xml_namespace.':'
endif
if has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}, 'vimxmltaginfo')
let final_menu = []
for i in range(len(menu))
let item = menu[i]
if has_key(g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}['vimxmltaginfo'], item)
let m_menu = g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}['vimxmltaginfo'][item][0]
let m_info = g:xmldata{'_'.g:xmldata_connection[b:xml_namespace]}['vimxmltaginfo'][item][1]
else
let m_menu = ''
let m_info = ''
endif
let final_menu += [{'word':xml_namespace.item, 'menu':m_menu, 'info':m_info}]
endfor
else
let final_menu = map(menu, 'xml_namespace.v:val')
endif
return final_menu
endif
endfunction
function! xmlcomplete#GetLastOpenTag(unaryTagsStack)
let linenum=line('.')
let lineend=col('.') - 1 " start: cursor position
let first=1              " flag for first line searched
let b:TagStack=''        " main stack of tags
let startInComment=s:InComment()
if exists("b:xml_namespace")
if b:xml_namespace == 'DEFAULT'
let tagpat='</\=\(\k\|[.:-]\)\+\|/>'
else
let tagpat='</\='.b:xml_namespace.':\(\k\|[.-]\)\+\|/>'
endif
else
let tagpat='</\=\(\k\|[.:-]\)\+\|/>'
endif
while (linenum>0)
let line=getline(linenum)
if first
let line=strpart(line,0,lineend)
else
let lineend=strlen(line)
endif
let b:lineTagStack=''
let mpos=0
let b:TagCol=0
while (mpos > -1)
let mpos=matchend(line,tagpat)
if mpos > -1
let b:TagCol=b:TagCol+mpos
let tag=matchstr(line,tagpat)
if exists('b:closetag_disable_synID') || startInComment==s:InCommentAt(linenum, b:TagCol)
let b:TagLine=linenum
call s:Push(matchstr(tag,'[^<>]\+'),'b:lineTagStack')
endif
let lineend=lineend-mpos
let line=strpart(line,mpos,lineend)
endif
endwhile
while (!s:EmptystackP('b:lineTagStack'))
let tag=s:Pop('b:lineTagStack')
if match(tag, '^/') == 0		"found end tag
call s:Push(tag,'b:TagStack')
elseif s:EmptystackP('b:TagStack') && !s:Instack(tag, a:unaryTagsStack)	"found unclosed tag
return tag
else
let endtag=s:Peekstack('b:TagStack')
if endtag == '/'.tag || endtag == '/'
call s:Pop('b:TagStack')	"found a open/close tag pair
elseif !s:Instack(tag, a:unaryTagsStack) "we have a mismatch error
return ''
endif
endif
endwhile
let linenum=linenum-1 | let first=0
endwhile
return ''
endfunction
function! s:InComment()
return synIDattr(synID(line('.'), col('.'), 0), 'name') =~ 'Comment\|String'
endfunction
function! s:InCommentAt(line, col)
return synIDattr(synID(a:line, a:col, 0), 'name') =~ 'Comment\|String'
endfunction
function! s:SetKeywords()
let s:IsKeywordBak=&l:iskeyword
let &l:iskeyword='33-255'
endfunction
function! s:RestoreKeywords()
let &l:iskeyword=s:IsKeywordBak
endfunction
function! s:Push(el, sname)
if !s:EmptystackP(a:sname)
exe 'let '.a:sname."=a:el.' '.".a:sname
else
exe 'let '.a:sname.'=a:el'
endif
endfunction
function! s:EmptystackP(sname)
exe 'let stack='.a:sname
if match(stack,'^ *$') == 0
return 1
else
return 0
endif
endfunction
function! s:Instack(el, sname)
exe 'let stack='.a:sname
call s:SetKeywords()
let m=match(stack, '\<'.a:el.'\>')
call s:RestoreKeywords()
if m < 0
return 0
else
return 1
endif
endfunction
function! s:Peekstack(sname)
call s:SetKeywords()
exe 'let stack='.a:sname
let top=matchstr(stack, '\<.\{-1,}\>')
call s:RestoreKeywords()
return top
endfunction
function! s:Pop(sname)
if s:EmptystackP(a:sname)
return ''
endif
exe 'let stack='.a:sname
call s:SetKeywords()
let loc=matchend(stack,'\<.\{-1,}\>')
exe 'let '.a:sname.'=strpart(stack, loc+1, strlen(stack))'
let top=strpart(stack, match(stack, '\<'), loc)
call s:RestoreKeywords()
return top
endfunction
function! s:Clearstack(sname)
exe 'let '.a:sname."=''"
endfunction
