if exists("b:did_indent")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
let b:did_indent = 1
if !exists("g:tex_indent_items")
let g:tex_indent_items = 1
endif
if !exists("g:tex_indent_brace")
let g:tex_indent_brace = 1
endif
if !exists("g:tex_max_scan_line")
let g:tex_max_scan_line = 60
endif
if g:tex_indent_items
if !exists("g:tex_itemize_env")
let g:tex_itemize_env = 'itemize\|description\|enumerate\|thebibliography'
endif
if !exists('g:tex_items')
let g:tex_items = '\\bibitem\|\\item'
endif
else
let g:tex_items = ''
endif
if !exists("g:tex_noindent_env")
let g:tex_noindent_env = 'document\|verbatim\|lstlisting'
endif "}}}
setlocal autoindent
setlocal nosmartindent
setlocal indentexpr=GetTeXIndent()
setlocal indentkeys&
exec 'setlocal indentkeys+=[,(,{,),},],\&' . substitute(g:tex_items, '^\|\(\\|\)', ',=', 'g')
let g:tex_items = '^\s*' . substitute(g:tex_items, '^\(\^\\s\*\)*', '', '')
function! GetTeXIndent() " {{{
let lnum = prevnonblank(v:lnum - 1)
let cnum = v:lnum
while lnum != 0 && getline(lnum) =~ '^\s*%'
let lnum = prevnonblank(lnum - 1)
endwhile
if lnum == 0
return 0
endif
let line = substitute(getline(lnum), '\s*%.*', '','g')     " last line
let cline = substitute(getline(v:lnum), '\s*%.*', '', 'g') " current line
if synIDattr(synID(v:lnum, indent(v:lnum), 1), "name") == "texZone"
if empty(cline)
return indent(lnum)
else
return indent(v:lnum)
end
endif
if lnum == 0
return 0
endif
let ind = indent(lnum)
let stay = 1
if cline =~ '^\s*%'
return indent(v:lnum)
endif
if line =~ '\\begin{.*}' 
if line !~ g:tex_noindent_env
let ind = ind + shiftwidth()
let stay = 0
endif
if g:tex_indent_items
if line =~ g:tex_itemize_env
let ind = ind + shiftwidth()
let stay = 0
endif
endif
endif
if cline =~ '\\end{.*}'
let retn = s:GetEndIndentation(v:lnum)
if retn != -1
return retn
endif
end
if cline =~ '\\end{.*}'
\ && cline !~ g:tex_noindent_env
\ && cline !~ '\\begin{.*}.*\\end{.*}'
if g:tex_indent_items
if cline =~ g:tex_itemize_env
let ind = ind - shiftwidth()
let stay = 0
endif
endif
let ind = ind - shiftwidth()
let stay = 0
endif
if g:tex_indent_brace
if line =~ '[[{]$'
let ind += shiftwidth()
let stay = 0
endif
if cline =~ '^\s*\\\?[\]}]' && s:CheckPairedIsLastCharacter(v:lnum, indent(v:lnum))
let ind -= shiftwidth()
let stay = 0
endif
if line !~ '^\s*\\\?[\]}]'
for i in range(indent(lnum)+1, strlen(line)-1)
let char = line[i]
if char == ']' || char == '}'
if s:CheckPairedIsLastCharacter(lnum, i)
let ind -= shiftwidth()
let stay = 0
endif
endif
endfor
endif
endif
if g:tex_indent_items
if cline =~ g:tex_items
let ind = ind - shiftwidth()
let stay = 0
endif
if line =~ g:tex_items
let ind = ind + shiftwidth()
let stay = 0
endif
endif
if stay && mode() == 'i'
if empty(cline)
return ind
else
return max([indent(v:lnum), s:GetLastBeginIndentation(v:lnum)])
endif
else
return ind
endif
endfunction "}}}
function! s:GetLastBeginIndentation(lnum) " {{{
let matchend = 1
for lnum in range(a:lnum-1, max([a:lnum - g:tex_max_scan_line, 1]), -1)
let line = getline(lnum)
if line =~ '\\end{.*}'
let matchend += 1
endif
if line =~ '\\begin{.*}'
let matchend -= 1
endif
if matchend == 0
if line =~ g:tex_noindent_env
return indent(lnum)
endif
if line =~ g:tex_itemize_env
return indent(lnum) + 2 * shiftwidth()
endif
return indent(lnum) + shiftwidth()
endif
endfor
return -1
endfunction
function! s:GetEndIndentation(lnum) " {{{
if getline(a:lnum) =~ '\\begin{.*}.*\\end{.*}'
return -1
endif
let min_indent = 100
let matchend = 1
for lnum in range(a:lnum-1, max([a:lnum-g:tex_max_scan_line, 1]), -1)
let line = getline(lnum)
if line =~ '\\end{.*}'
let matchend += 1
endif
if line =~ '\\begin{.*}'
let matchend -= 1
endif
if matchend == 0
return indent(lnum)
endif
if !empty(line)
let min_indent = min([min_indent, indent(lnum)])
endif
endfor
return min_indent - shiftwidth()
endfunction
function! s:CheckPairedIsLastCharacter(lnum, col) "{{{
let c_lnum = a:lnum
let c_col = a:col+1
let line = getline(c_lnum)
if line[c_col-1] == '\'
let c_col = c_col + 1
endif
let c = line[c_col-1]
let plist = split(&matchpairs, '.\zs[:,]')
let i = index(plist, c)
if i < 0
return 0
endif
if i % 2 == 0
let s_flags = 'nW'
let c2 = plist[i + 1]
else
let s_flags = 'nbW'
let c2 = c
let c = plist[i - 1]
endif
if c == '['
let c = '\['
let c2 = '\]'
endif
let save_cursor = winsaveview()
call cursor(c_lnum, c_col)
let s_skip ='synIDattr(synID(line("."), col("."), 0), "name") ' .
\ '=~?  "string\\|character\\|singlequote\\|escape\\|comment"'
execute 'if' s_skip '| let s_skip = 0 | endif'
let stopline = max([0, c_lnum - g:tex_max_scan_line])
try
let [m_lnum, m_col] = searchpairpos(c, '', c2, s_flags, s_skip, stopline, 100)
catch /E118/
endtry
call winrestview(save_cursor)
if m_lnum > 0
let line = getline(m_lnum)
return strlen(line) == m_col
endif
return 0
endfunction "}}}
let &cpo = s:cpo_save
unlet s:cpo_save
