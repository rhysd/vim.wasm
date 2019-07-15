if exists("b:did_indent") "{{{
finish
endif
if !exists('*GetJavascriptIndent')
runtime! indent/javascript.vim
endif
let b:did_indent = 1
setlocal indentexpr=HtmlIndent()
setlocal indentkeys=o,O,<Return>,<>>,{,},!^F
setlocal matchpairs+=<:>
let b:undo_indent = "setlocal inde< indk<"
let b:hi_indent = {"lnum": -1}
if exists("*HtmlIndent") && !exists('g:force_reload_html')
call HtmlIndent_CheckUserSettings()
finish
endif
let s:cpo_save = &cpo
set cpo-=C
let s:tagname = '\w\+\(-\w\+\)*'
func! HtmlIndent_CheckUserSettings()
let inctags = ''
if exists("b:html_indent_inctags")
let inctags = b:html_indent_inctags
elseif exists("g:html_indent_inctags")
let inctags = g:html_indent_inctags
endif
let b:hi_tags = {}
if len(inctags) > 0
call s:AddITags(b:hi_tags, split(inctags, ","))
endif
let autotags = ''
if exists("b:html_indent_autotags")
let autotags = b:html_indent_autotags
elseif exists("g:html_indent_autotags")
let autotags = g:html_indent_autotags
endif
let b:hi_removed_tags = {}
if len(autotags) > 0
call s:RemoveITags(b:hi_removed_tags, split(autotags, ","))
endif
let string_names = []
if exists("b:html_indent_string_names")
let string_names = b:html_indent_string_names
elseif exists("g:html_indent_string_names")
let string_names = g:html_indent_string_names
endif
let b:hi_insideStringNames = ['htmlString']
if len(string_names) > 0
for s in string_names
call add(b:hi_insideStringNames, s)
endfor
endif
let tag_names = []
if exists("b:html_indent_tag_names")
let tag_names = b:html_indent_tag_names
elseif exists("g:html_indent_tag_names")
let tag_names = g:html_indent_tag_names
endif
let b:hi_insideTagNames = ['htmlTag', 'htmlScriptTag']
if len(tag_names) > 0
for s in tag_names
call add(b:hi_insideTagNames, s)
endfor
endif
let indone = {"zero": 0
\,"auto": "indent(prevnonblank(v:lnum-1))"
\,"inc": "b:hi_indent.blocktagind + shiftwidth()"}
let script1 = ''
if exists("b:html_indent_script1")
let script1 = b:html_indent_script1
elseif exists("g:html_indent_script1")
let script1 = g:html_indent_script1
endif
if len(script1) > 0
let b:hi_js1indent = get(indone, script1, indone.zero)
else
let b:hi_js1indent = 0
endif
let style1 = ''
if exists("b:html_indent_style1")
let style1 = b:html_indent_style1
elseif exists("g:html_indent_style1")
let style1 = g:html_indent_style1
endif
if len(style1) > 0
let b:hi_css1indent = get(indone, style1, indone.zero)
else
let b:hi_css1indent = 0
endif
if !exists('b:html_indent_line_limit')
if exists('g:html_indent_line_limit')
let b:html_indent_line_limit = g:html_indent_line_limit
else
let b:html_indent_line_limit = 200
endif
endif
endfunc "}}}
let b:hi_lasttick = 0
let b:hi_newstate = {}
let s:countonly = 0
let s:indent_tags = {}
let s:endtags = [0,0,0,0,0,0,0]   " long enough for the highest index
func! s:AddITags(tags, taglist)
for itag in a:taglist
let a:tags[itag] = 1
let a:tags['/' . itag] = -1
endfor
endfunc "}}}
func! s:RemoveITags(tags, taglist)
for itag in a:taglist
let a:tags[itag] = 1
let a:tags['/' . itag] = 1
endfor
endfunc "}}}
func! s:AddBlockTag(tag, id, ...)
if !(a:id >= 2 && a:id < len(s:endtags))
echoerr 'AddBlockTag ' . a:id
return
endif
let s:indent_tags[a:tag] = a:id
if a:0 == 0
let s:indent_tags['/' . a:tag] = -a:id
let s:endtags[a:id] = "</" . a:tag . ">"
else
let s:indent_tags[a:1] = -a:id
let s:endtags[a:id] = a:1
endif
endfunc "}}}
call s:AddITags(s:indent_tags, [
\ 'a', 'abbr', 'acronym', 'address', 'b', 'bdo', 'big',
\ 'blockquote', 'body', 'button', 'caption', 'center', 'cite', 'code',
\ 'colgroup', 'del', 'dfn', 'dir', 'div', 'dl', 'em', 'fieldset', 'font',
\ 'form', 'frameset', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'head', 'html',
\ 'i', 'iframe', 'ins', 'kbd', 'label', 'legend', 'li',
\ 'map', 'menu', 'noframes', 'noscript', 'object', 'ol',
\ 'optgroup', 'q', 's', 'samp', 'select', 'small', 'span', 'strong', 'sub',
\ 'sup', 'table', 'textarea', 'title', 'tt', 'u', 'ul', 'var', 'th', 'td',
\ 'tr', 'tbody', 'tfoot', 'thead'])
call s:AddITags(s:indent_tags, [
\ 'article', 'aside', 'audio', 'bdi', 'canvas', 'command', 'data',
\ 'datalist', 'details', 'dialog', 'embed', 'figcaption', 'figure',
\ 'footer', 'header', 'hgroup', 'main', 'mark', 'meter', 'nav', 'output',
\ 'picture', 'progress', 'rp', 'rt', 'ruby', 'section', 'summary',
\ 'svg', 'time', 'video'])
call s:AddITags(s:indent_tags, [
\ 'content', 'shadow', 'template'])
call s:AddBlockTag('pre', 2)
call s:AddBlockTag('script', 3)
call s:AddBlockTag('style', 4)
call s:AddBlockTag('<!--', 5, '-->')
call s:AddBlockTag('<!--[', 6, '![endif]-->')
func! HtmlIndent_IsOpenTag(tagname)
if get(s:indent_tags, a:tagname) == 1
return 1
endif
return get(b:hi_tags, a:tagname) == 1
endfunc "}}}
func! s:get_tag(tagname)
let i = get(s:indent_tags, a:tagname)
if (i == 1 || i == -1) && get(b:hi_removed_tags, a:tagname) != 0
return 0
endif
if i == 0
let i = get(b:hi_tags, a:tagname)
endif
return i
endfunc "}}}
func! s:CountITags(text)
let s:curind = 0  " relative indent steps for current line [unit &sw]:
let s:nextrel = 0  " relative indent steps for next line [unit &sw]:
let s:block = 0		" assume starting outside of a block
let s:countonly = 1	" don't change state
call substitute(a:text, '<\zs/\=' . s:tagname . '\>\|<!--\[\|\[endif\]-->\|<!--\|-->', '\=s:CheckTag(submatch(0))', 'g')
let s:countonly = 0
endfunc "}}}
func! s:CountTagsAndState(text)
let s:curind = 0  " relative indent steps for current line [unit &sw]:
let s:nextrel = 0  " relative indent steps for next line [unit &sw]:
let s:block = b:hi_newstate.block
let tmp = substitute(a:text, '<\zs/\=' . s:tagname . '\>\|<!--\[\|\[endif\]-->\|<!--\|-->', '\=s:CheckTag(submatch(0))', 'g')
if s:block == 3
let b:hi_newstate.scripttype = s:GetScriptType(matchstr(tmp, '\C.*<SCRIPT\>\zs[^>]*'))
endif
let b:hi_newstate.block = s:block
endfunc "}}}
func! s:CheckTag(itag)
if (s:CheckCustomTag(a:itag))
return ""
endif
let ind = s:get_tag(a:itag)
if ind == -1
if s:block != 0
return ""
endif
if s:nextrel == 0
let s:curind -= 1
else
let s:nextrel -= 1
endif
elseif ind == 1
if s:block != 0
return ""
endif
let s:nextrel += 1
elseif ind != 0
return s:CheckBlockTag(a:itag, ind)
endif
return ""
endfunc "}}}
func! s:CheckBlockTag(blocktag, ind)
if a:ind > 0
if s:block != 0
return ""
endif
let s:block = a:ind		" block type
if s:countonly
return ""
endif
let b:hi_newstate.blocklnr = v:lnum
let b:hi_newstate.blocktagind = b:hi_indent.baseindent + (s:nextrel + s:curind) * shiftwidth()
if a:ind == 3
return "SCRIPT"    " all except this must be lowercase
endif
else
let s:block = 0
endif
return ""
endfunc "}}}
func! s:CheckCustomTag(ctag)
let pattern = '\%\(\w\+-\)\+\w\+'
if match(a:ctag, pattern) == -1
return 0
endif
if matchstr(a:ctag, '\/\ze.\+') == "/"
if s:block != 0
return 1
endif
if s:nextrel == 0
let s:curind -= 1
else
let s:nextrel -= 1
endif
else
if s:block != 0
return 1
endif
let s:nextrel += 1
endif
return 1
endfunc "}}}
func! s:GetScriptType(str)
if a:str == "" || a:str =~ "java"
return "javascript"
else
return ""
endif
endfunc "}}}
func! s:FreshState(lnum)
let state = {}
let state.lnum = prevnonblank(a:lnum - 1)
let state.scripttype = ""
let state.blocktagind = -1
let state.block = 0
let state.baseindent = 0
let state.blocklnr = 0
let state.inattr = 0
if state.lnum == 0
return state
endif
let stopline2 = v:lnum + 1
if has_key(b:hi_indent, 'block') && b:hi_indent.block > 5
let [stopline2, stopcol2] = searchpos('<!--', 'bnW')
endif
let [stopline, stopcol] = searchpos('\c<\zs\/\=\%(pre\>\|script\>\|style\>\)', "bnW")
if stopline > 0 && stopline < stopline2
let tagline = tolower(getline(stopline))
let blocktag = matchstr(tagline, '\/\=\%(pre\>\|script\>\|style\>\)', stopcol - 1)
if blocktag[0] != "/"
let state.block = s:indent_tags[blocktag]
if state.block == 3
let state.scripttype = s:GetScriptType(matchstr(tagline, '\>[^>]*', stopcol))
endif
let state.blocklnr = stopline
call s:CountITags(tagline[: stopcol-2])
let state.blocktagind = indent(stopline) + (s:curind + s:nextrel) * shiftwidth()
return state
elseif stopline == state.lnum
let swendtag = match(tagline, '^\s*</') >= 0
if !swendtag
let [bline, bcol] = searchpos('<'.blocktag[1:].'\>', "bnW")
call s:CountITags(tolower(getline(bline)[: bcol-2]))
let state.baseindent = indent(bline) + (s:curind + s:nextrel) * shiftwidth()
return state
endif
endif
endif
if stopline > stopline2
let stopline = stopline2
let stopcol = stopcol2
endif
let [comlnum, comcol, found] = searchpos('\(<!--\[\)\|\(<!--\)\|-->', 'bpnW', stopline)
if found == 2 || found == 3
let state.block = (found == 3 ? 5 : 6)
let state.blocklnr = comlnum
call s:CountITags(tolower(getline(comlnum)[: comcol-2]))
if found == 2
let state.baseindent = b:hi_indent.baseindent
endif
let state.blocktagind = indent(comlnum) + (s:curind + s:nextrel) * shiftwidth()
return state
endif
let text = tolower(getline(state.lnum))
let comcol = stridx(text, '-->')
if comcol >= 0 && match(text, '[<>]', comcol) <= 0
call cursor(state.lnum, comcol + 1)
let [comlnum, comcol] = searchpos('<!--', 'bW')
if comlnum == state.lnum
let text = text[: comcol-2]
else
let text = tolower(getline(comlnum)[: comcol-2])
endif
call s:CountITags(text)
let state.baseindent = indent(comlnum) + (s:curind + s:nextrel) * shiftwidth()
return state
endif
let swendtag = match(text, '^\s*</') >= 0
if !swendtag && text =~ '</' . s:tagname . '\s*>\s*$'
call cursor(state.lnum, 99999)
normal! F<
let start_lnum = HtmlIndent_FindStartTag()
if start_lnum > 0
let state.baseindent = indent(start_lnum)
if col('.') > 2
let text = getline(start_lnum)
let swendtag = match(text, '^\s*</') >= 0
call s:CountITags(text[: col('.') - 2])
let state.baseindent += s:nextrel * shiftwidth()
if !swendtag
let state.baseindent += s:curind * shiftwidth()
endif
endif
return state
endif
endif
let [state.lnum, found] = HtmlIndent_FindTagStart(state.lnum)
let text = getline(state.lnum)
let swendtag = match(text, '^\s*</') >= 0
call s:CountITags(tolower(text))
let state.baseindent = indent(state.lnum) + s:nextrel * shiftwidth()
if !swendtag
let state.baseindent += s:curind * shiftwidth()
endif
return state
endfunc "}}}
func! s:Alien2()
return -1
endfunc "}}}
func! s:Alien3()
let lnum = prevnonblank(v:lnum - 1)
while lnum > 1 && getline(lnum) =~ '^\s*/[/*]'
let lnum = prevnonblank(lnum - 1)
endwhile
if lnum == b:hi_indent.blocklnr
return eval(b:hi_js1indent)
endif
if b:hi_indent.scripttype == "javascript"
return GetJavascriptIndent()
else
return -1
endif
endfunc "}}}
func! s:Alien4()
if prevnonblank(v:lnum-1) == b:hi_indent.blocklnr
return eval(b:hi_css1indent)
endif
return s:CSSIndent()
endfunc "}}}
func! s:CSSIndent()
let curtext = getline(v:lnum)
if curtext =~ '^\s*[*]'
\ || (v:lnum > 1 && getline(v:lnum - 1) =~ '\s*/\*'
\     && getline(v:lnum - 1) !~ '\*/\s*$')
return cindent(v:lnum)
endif
let min_lnum = b:hi_indent.blocklnr
let prev_lnum = s:CssPrevNonComment(v:lnum - 1, min_lnum)
let [prev_lnum, found] = HtmlIndent_FindTagStart(prev_lnum)
if prev_lnum <= min_lnum
return eval(b:hi_css1indent)
endif
if curtext =~ '^\s*}'
call cursor(v:lnum, 1)
try
normal! %
let align_lnum = s:CssFirstUnfinished(line('.'), min_lnum)
return indent(align_lnum)
catch
endtry
endif
let brace_counts = HtmlIndent_CountBraces(prev_lnum)
let extra = brace_counts.c_open * shiftwidth()
let prev_text = getline(prev_lnum)
let below_end_brace = prev_text =~ '}\s*$'
let align_lnum = s:CssFirstUnfinished(prev_lnum, min_lnum)
if extra == 0 && align_lnum == prev_lnum && !below_end_brace
let prev_hasfield = prev_text =~ '^\s*[a-zA-Z0-9-]\+:'
let prev_special = prev_text =~ '^\s*\(/\*\|@\)'
if curtext =~ '^\s*\(/\*\|@\)'
if !prev_hasfield && !prev_special
let extra = -shiftwidth()
endif
else
let cur_hasfield = curtext =~ '^\s*[a-zA-Z0-9-]\+:'
let prev_unfinished = s:CssUnfinished(prev_text)
if prev_unfinished
let extra = shiftwidth()
if prev_text =~ '^\s*@if '
let extra = 4
endif
elseif cur_hasfield && !prev_hasfield && !prev_special
let extra = -shiftwidth()
endif
endif
endif
if below_end_brace
call cursor(prev_lnum, 1)
call search('}\s*$')
try
normal! %
let align_lnum = s:CssFirstUnfinished(line('.'), min_lnum)
let special = getline(align_lnum) =~ '^\s*@'
catch
let special = 0
endtry
if special
if extra < 0
let extra += shiftwidth()
endif
else
let extra -= (brace_counts.c_close - (prev_text =~ '^\s*}')) * shiftwidth()
endif
endif
if extra == 0
if brace_counts.p_open > brace_counts.p_close
let extra = shiftwidth()
elseif brace_counts.p_open < brace_counts.p_close
let extra = -shiftwidth()
endif
endif
return indent(align_lnum) + extra
endfunc "}}}
func! s:CssUnfinished(text)
return a:text =~ '\(||\|&&\|:\|\k\)\s*$'
endfunc "}}}
func! s:CssFirstUnfinished(lnum, min_lnum)
let align_lnum = a:lnum
while align_lnum > a:min_lnum && s:CssUnfinished(getline(align_lnum - 1))
let align_lnum -= 1
endwhile
return align_lnum
endfunc "}}}
func! s:CssPrevNonComment(lnum, stopline)
let lnum = prevnonblank(a:lnum)
while 1
let ccol = match(getline(lnum), '\*/')
if ccol < 0
return lnum
endif
call cursor(lnum, ccol + 1)
let lnum = search('/\*', 'bW', a:stopline)
if indent(".") == virtcol(".") - 1
let lnum = prevnonblank(lnum - 1)
else
return lnum
endif
endwhile
endfunc "}}}
func! HtmlIndent_CountBraces(lnum)
let brs = substitute(getline(a:lnum), '[''"].\{-}[''"]\|/\*.\{-}\*/\|/\*.*$\|[^{}()]', '', 'g')
let c_open = 0
let c_close = 0
let p_open = 0
let p_close = 0
for brace in split(brs, '\zs')
if brace == "{"
let c_open += 1
elseif brace == "}"
if c_open > 0
let c_open -= 1
else
let c_close += 1
endif
elseif brace == '('
let p_open += 1
elseif brace == ')'
if p_open > 0
let p_open -= 1
else
let p_close += 1
endif
endif
endfor
return {'c_open': c_open,
\ 'c_close': c_close,
\ 'p_open': p_open,
\ 'p_close': p_close}
endfunc "}}}
func! s:Alien5()
let curtext = getline(v:lnum)
if curtext =~ '^\s*\zs-->'
call cursor(v:lnum, 0)
let lnum = search('<!--', 'b')
if lnum > 0
return indent(lnum)
endif
return -1
endif
let prevlnum = prevnonblank(v:lnum - 1)
let prevtext = getline(prevlnum)
let idx = match(prevtext, '^\s*\zs<!--')
if idx >= 0
return idx + shiftwidth()
endif
return indent(prevlnum)
endfunc "}}}
func! s:Alien6()
let curtext = getline(v:lnum)
if curtext =~ '\s*\zs<!\[endif\]-->'
let lnum = search('<!--', 'bn')
if lnum > 0
return indent(lnum)
endif
endif
return b:hi_indent.baseindent + shiftwidth()
endfunc "}}}
func! HtmlIndent_FindTagStart(lnum)
let idx = match(getline(a:lnum), '\S>\s*$')
if idx > 0
call cursor(a:lnum, idx)
let lnum = searchpair('<\w', '' , '\S>', 'bW', '', max([a:lnum - b:html_indent_line_limit, 0]))
if lnum > 0
return [lnum, 1]
endif
endif
return [a:lnum, 0]
endfunc "}}}
func! HtmlIndent_FindStartTag()
let tagname = matchstr(getline('.')[col('.') - 1:], '</\zs' . s:tagname . '\ze')
let start_lnum = searchpair('<' . tagname . '\>', '', '</' . tagname . '\>', 'bW')
if start_lnum > 0
return start_lnum
endif
return 0
endfunc "}}}
func! HtmlIndent_FindTagEnd()
let text = getline('.')
let tagname = matchstr(text, s:tagname . '\|!--', col('.'))
if tagname == '!--'
call search('--\zs>')
elseif s:get_tag('/' . tagname) != 0
call searchpair('<' . tagname, '', '</' . tagname . '\zs>', 'W', '', line('.') + b:html_indent_line_limit)
else
call search('\S\zs>')
endif
endfunc "}}}
func! s:InsideTag(foundHtmlString)
if a:foundHtmlString
let lnum = v:lnum - 1
if lnum > 1
if exists('b:html_indent_tag_string_func')
return b:html_indent_tag_string_func(lnum)
endif
if getline(lnum) =~ '"'
call cursor(lnum, 0)
normal f"
return virtcol('.')
endif
return indent(lnum)
endif
endif
let lnum = v:lnum
while lnum > 1
let lnum -= 1
let text = getline(lnum)
if len(text) < 300
let idx = match(text, '.*\s\zs[_a-zA-Z0-9-]\+="')
else
let idx = match(text, '\s\zs[_a-zA-Z0-9-]\+="')
endif
if idx == -1
let idx = match(text, '<' . s:tagname . '\s\+\zs\w')
endif
if idx == -1
let idx = match(text, '<' . s:tagname . '$')
if idx >= 0
call cursor(lnum, idx)
return virtcol('.') + shiftwidth()
endif
endif
if idx > 0
call cursor(lnum, idx)
return virtcol('.')
endif
endwhile
return -1
endfunc "}}}
func! HtmlIndent()
if prevnonblank(v:lnum - 1) < 1
return 0
endif
let curtext = tolower(getline(v:lnum))
let indentunit = shiftwidth()
let b:hi_newstate = {}
let b:hi_newstate.lnum = v:lnum
if curtext !~ '^\s*<'
normal! ^
let stack = synstack(v:lnum, col('.'))  " assumes there are no tabs
let foundHtmlString = 0
for synid in reverse(stack)
let name = synIDattr(synid, "name")
if index(b:hi_insideStringNames, name) >= 0
let foundHtmlString = 1
elseif index(b:hi_insideTagNames, name) >= 0
let indent = s:InsideTag(foundHtmlString)
if indent >= 0
let b:hi_indent.lnum = 0
return indent
endif
endif
endfor
endif
let swendtag = match(curtext, '^\s*</') >= 0
if prevnonblank(v:lnum - 1) == b:hi_indent.lnum && b:hi_lasttick == b:changedtick - 1
else
let b:hi_indent = s:FreshState(v:lnum)
endif
if b:hi_indent.block >= 2
let endtag = s:endtags[b:hi_indent.block]
let blockend = stridx(curtext, endtag)
if blockend >= 0
let b:hi_newstate.block = 0
call s:CountTagsAndState(strpart(curtext, blockend + strlen(endtag)))
if swendtag && b:hi_indent.block != 5
let indent = b:hi_indent.blocktagind + s:curind * indentunit
let b:hi_newstate.baseindent = indent + s:nextrel * indentunit
else
let indent = s:Alien{b:hi_indent.block}()
let b:hi_newstate.baseindent = b:hi_indent.blocktagind + s:nextrel * indentunit
endif
else
let indent = s:Alien{b:hi_indent.block}()
endif
else
let b:hi_newstate.block = b:hi_indent.block
if swendtag
call cursor(v:lnum, 1)
let start_lnum = HtmlIndent_FindStartTag()
if start_lnum > 0
let text = getline(start_lnum)
let angle = matchstr(text, '[<>]')
if angle == '>'
call cursor(start_lnum, 1)
normal! f>%
let start_lnum = line('.')
let text = getline(start_lnum)
endif
let indent = indent(start_lnum)
if col('.') > 2
let swendtag = match(text, '^\s*</') >= 0
call s:CountITags(text[: col('.') - 2])
let indent += s:nextrel * shiftwidth()
if !swendtag
let indent += s:curind * shiftwidth()
endif
endif
else
let indent = b:hi_indent.baseindent
endif
let b:hi_newstate.baseindent = indent
else
call s:CountTagsAndState(curtext)
let indent = b:hi_indent.baseindent
let b:hi_newstate.baseindent = indent + (s:curind + s:nextrel) * indentunit
endif
endif
let b:hi_lasttick = b:changedtick
call extend(b:hi_indent, b:hi_newstate, "force")
return indent
endfunc "}}}
call HtmlIndent_CheckUserSettings()
let &cpo = s:cpo_save
unlet s:cpo_save
