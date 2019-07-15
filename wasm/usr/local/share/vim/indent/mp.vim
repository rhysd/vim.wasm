if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetMetaPostIndent()
setlocal indentkeys+==end,=else,=fi,=fill,0),0]
let b:undo_indent = "setl indentkeys< indentexpr<"
if exists("*GetMetaPostIndent")
finish
endif
let s:keepcpo= &cpo
set cpo&vim
function GetMetaPostIndent()
let ignorecase_save = &ignorecase
try
let &ignorecase = 0
return GetMetaPostIndentIntern()
finally
let &ignorecase = ignorecase_save
endtry
endfunc
let g:mp_open_tag = ''
\ . '\<if\>'
\ . '\|\<else\%[if]\>'
\ . '\|\<for\%(\|ever\|suffixes\)\>'
\ . '\|\<begingroup\>'
\ . '\|\<\%(\|var\|primary\|secondary\|tertiary\)def\>'
\ . '\|^\s*\<begin\%(fig\|graph\|glyph\|char\|logochar\)\>'
\ . '\|[([{]'
let g:mp_close_tag = ''
\ . '\<fi\>'
\ . '\|\<else\%[if]\>'
\ . '\|\<end\%(\|for\|group\|def\|fig\|char\|glyph\|graph\)\>'
\ . '\|[)\]}]'
let g:mp_statement = ''
\ . '\<\%(\|un\|cut\)draw\>'
\ . '\|\<\%(\|un\)fill\%[draw]\>'
\ . '\|\<draw\%(dbl\)\=arrow\>'
\ . '\|\<clip\>'
\ . '\|\<addto\>'
\ . '\|\<save\>'
\ . '\|\<setbounds\>'
\ . '\|\<message\>'
\ . '\|\<errmessage\>'
\ . '\|\<errhelp\>'
\ . '\|\<fontmapline\>'
\ . '\|\<pickup\>'
\ . '\|\<show\>'
\ . '\|\<special\>'
\ . '\|\<write\>'
\ . '\|\%(^\|;\)\%([^;=]*\%('.g:mp_open_tag.'\)\)\@!.\{-}:\=='
let s:eol = '\s*\%($\|%\)'
function! s:CommentOrString(line, pos)
let in_string = 0
let q = stridx(a:line, '"')
let c = stridx(a:line, '%')
while q >= 0 && q < a:pos
if c >= 0 && c < q
if in_string " Find next percent symbol
let c = stridx(a:line, '%', q + 1)
else " Inside comment
return 1
endif
endif
let in_string = 1 - in_string
let q = stridx(a:line, '"', q + 1) " Find next quote
endwhile
return in_string || (c >= 0 && c <= a:pos)
endfunction
function! s:PrevNonBlankNonComment(lnum)
let l:lnum = prevnonblank(a:lnum - 1)
while getline(l:lnum) =~# '^\s*%'
let l:lnum = prevnonblank(l:lnum - 1)
endwhile
return l:lnum
endfunction
function! s:LastTagIsOpen(line)
let o = s:LastValidMatchEnd(a:line, g:mp_open_tag, 0)
if o == - 1 | return v:false | endif
return s:LastValidMatchEnd(a:line, g:mp_close_tag, o) < 0
endfunction
function! s:Weight(line)
let [o, i] = [0, s:ValidMatchEnd(a:line, g:mp_open_tag, 0)]
while i > 0
let o += 1
let i = s:ValidMatchEnd(a:line, g:mp_open_tag, i)
endwhile
let [c, i] = [0, matchend(a:line, '^\s*\<else\%[if]\>')] " Skip a leading else[if]
let i = s:ValidMatchEnd(a:line, g:mp_close_tag, i)
while i > 0
let c += 1
let i = s:ValidMatchEnd(a:line, g:mp_close_tag, i)
endwhile
return o - c
endfunction
function! s:ValidMatchEnd(line, pat, start)
let i = matchend(a:line, a:pat, a:start)
while i > 0 && s:CommentOrString(a:line, i)
let i = matchend(a:line, a:pat, i)
endwhile
return i
endfunction
function! s:LastValidMatchEnd(line, pat, start)
let last_found = -1
let i = matchend(a:line, a:pat, a:start)
while i > 0
if !s:CommentOrString(a:line, i)
let last_found = i
endif
let i = matchend(a:line, a:pat, i)
endwhile
return last_found
endfunction
function! s:DecreaseIndentOnClosingTag(curr_indent)
let cur_text = getline(v:lnum)
if cur_text =~# '^\s*\%('.g:mp_close_tag.'\)'
return max([a:curr_indent - shiftwidth(), 0])
endif
return a:curr_indent
endfunction
function! GetMetaPostIndentIntern()
if synIDattr(synID(v:lnum, 1, 1), "name") =~# '^mpTeXinsert$\|^tex\|^Delimiter'
return -1
endif
let lnum = s:PrevNonBlankNonComment(v:lnum)
if lnum == 0
return 0
endif
let prev_text = getline(lnum)
let j = match(prev_text, '%[<>=]')
if j > 0
let i = strlen(matchstr(prev_text, '%>\+', j)) - 1
if i > 0
return indent(lnum) + i * shiftwidth()
endif
let i = strlen(matchstr(prev_text, '%<\+', j)) - 1
if i > 0
return max([indent(lnum) - i * shiftwidth(), 0])
endif
if match(prev_text, '%=', j)
return indent(lnum)
endif
endif
if s:LastTagIsOpen(prev_text)
return s:DecreaseIndentOnClosingTag(indent(lnum) + shiftwidth())
endif
if s:Weight(prev_text) > 0
return s:DecreaseIndentOnClosingTag(indent(lnum) + shiftwidth())
endif
let i = s:LastValidMatchEnd(prev_text, g:mp_statement, 0)
if i >= 0 " Does the line contain a statement?
if s:ValidMatchEnd(prev_text, ';', i) < 0 " Is the statement unterminated?
return indent(lnum) + shiftwidth()
else
return s:DecreaseIndentOnClosingTag(indent(lnum))
endif
endif
if s:ValidMatchEnd(prev_text, ';'.s:eol, 0) >= 0 " L ends with a semicolon
let stm_lnum = s:PrevNonBlankNonComment(lnum)
while stm_lnum > 0
let prev_text = getline(stm_lnum)
let sc_pos = s:LastValidMatchEnd(prev_text, ';', 0)
let stm_pos = s:ValidMatchEnd(prev_text, g:mp_statement, sc_pos)
if stm_pos > sc_pos
let lnum = stm_lnum
break
elseif sc_pos > stm_pos
break
endif
let stm_lnum = s:PrevNonBlankNonComment(stm_lnum)
endwhile
endif
return s:DecreaseIndentOnClosingTag(indent(lnum))
endfunction
let &cpo = s:keepcpo
unlet s:keepcpo
