if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal nosmartindent
setlocal indentexpr=FalconGetIndent(v:lnum)
setlocal indentkeys=0{,0},0),0],!^F,o,O,e
setlocal indentkeys+==~case,=~catch,=~default,=~elif,=~else,=~end,=~\"
if exists("*FalconGetIndent")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
let s:syng_strcom = '\<falcon\%(String\|StringEscape\|Comment\)\>'
let s:syng_string = '\<falcon\%(String\|StringEscape\)\>'
let s:block_regex =
\ '\%(\<do:\@!\>\|%\@<!{\)\s*\%(|\s*(*\s*\%([*@&]\=\h\w*,\=\s*\)\%(,\s*(*\s*[*@&]\=\h\w*\s*)*\s*\)*|\)\=\s*\%(#.*\)\=$'
let s:block_continuation_regex = '^\s*[^])}\t ].*'.s:block_regex
let s:continuation_regex =
\ '\%(%\@<![({[\\.,:*/%+]\|\<and\|\<or\|\%(<%\)\@<![=-]\|\W[|&?]\|||\|&&\)\s*\%(#.*\)\=$'
let s:bracket_continuation_regex = '%\@<!\%([({[]\)\s*\%(#.*\)\=$'
let s:non_bracket_continuation_regex = '\%([\\.,:*/%+]\|\<and\|\<or\|\%(<%\)\@<![=-]\|\W[|&?]\|||\|&&\)\s*\%(#.*\)\=$'
let s:falcon_indent_keywords = '^\s*\(case\|catch\|class\|enum\|default\|elif\|else' .
\ '\|for\|function\|if.*"[^"]*:.*"\|if \(\(:\)\@!.\)*$\|loop\|object\|select' .
\ '\|switch\|try\|while\|\w*\s*=\s*\w*([$\)'
let s:falcon_deindent_keywords = '^\s*\(case\|catch\|default\|elif\|else\|end\)'
function s:IsInStringOrComment(lnum, col)
return synIDattr(synID(a:lnum, a:col, 1), 'name') =~ s:syng_strcom
endfunction
function s:IsInString(lnum, col)
return synIDattr(synID(a:lnum, a:col, 1), 'name') =~ s:syng_string
endfunction
function s:IsInStringDelimiter(lnum, col)
return synIDattr(synID(a:lnum, a:col, 1), 'name') == 'falconStringDelimiter'
endfunction
function s:PrevNonBlankNonString(lnum)
let in_block = 0
let lnum = prevnonblank(a:lnum)
while lnum > 0
let line = getline(lnum)
if line =~ '^=begin'
if in_block
let in_block = 0
else
break
endif
elseif !in_block && line =~ '^=end'
let in_block = 1
elseif !in_block && line !~ '^\s*#.*$' && !(s:IsInStringOrComment(lnum, 1)
\ && s:IsInStringOrComment(lnum, strlen(line)))
break
endif
let lnum = prevnonblank(lnum - 1)
endwhile
return lnum
endfunction
function s:GetMSL(lnum)
let msl = a:lnum
let msl_body = getline(msl)
let lnum = s:PrevNonBlankNonString(a:lnum - 1)
while lnum > 0
let line = getline(lnum)
if s:Match(line, s:non_bracket_continuation_regex) &&
\ s:Match(msl, s:non_bracket_continuation_regex)
let msl = lnum
elseif s:Match(lnum, s:non_bracket_continuation_regex) &&
\ (s:Match(msl, s:bracket_continuation_regex) || s:Match(msl, s:block_continuation_regex))
return lnum
elseif s:Match(lnum, s:bracket_continuation_regex) &&
\ (s:Match(msl, s:bracket_continuation_regex) || s:Match(msl, s:block_continuation_regex))
return msl
elseif s:Match(lnum, s:block_regex) &&
\ !s:Match(msl, s:continuation_regex) &&
\ !s:Match(msl, s:block_continuation_regex)
return msl
else
let col = match(line, s:continuation_regex) + 1
if (col > 0 && !s:IsInStringOrComment(lnum, col))
\ || s:IsInString(lnum, strlen(line))
let msl = lnum
else
break
endif
endif
let msl_body = getline(msl)
let lnum = s:PrevNonBlankNonString(lnum - 1)
endwhile
return msl
endfunction
function s:ExtraBrackets(lnum)
let opening = {'parentheses': [], 'braces': [], 'brackets': []}
let closing = {'parentheses': [], 'braces': [], 'brackets': []}
let line = getline(a:lnum)
let pos  = match(line, '[][(){}]', 0)
while pos != -1
if !s:IsInStringOrComment(a:lnum, pos + 1)
if line[pos] == '('
call add(opening.parentheses, {'type': '(', 'pos': pos})
elseif line[pos] == ')'
if empty(opening.parentheses)
call add(closing.parentheses, {'type': ')', 'pos': pos})
else
let opening.parentheses = opening.parentheses[0:-2]
endif
elseif line[pos] == '{'
call add(opening.braces, {'type': '{', 'pos': pos})
elseif line[pos] == '}'
if empty(opening.braces)
call add(closing.braces, {'type': '}', 'pos': pos})
else
let opening.braces = opening.braces[0:-2]
endif
elseif line[pos] == '['
call add(opening.brackets, {'type': '[', 'pos': pos})
elseif line[pos] == ']'
if empty(opening.brackets)
call add(closing.brackets, {'type': ']', 'pos': pos})
else
let opening.brackets = opening.brackets[0:-2]
endif
endif
endif
let pos = match(line, '[][(){}]', pos + 1)
endwhile
let rightmost_opening = {'type': '(', 'pos': -1}
let rightmost_closing = {'type': ')', 'pos': -1}
for opening in opening.parentheses + opening.braces + opening.brackets
if opening.pos > rightmost_opening.pos
let rightmost_opening = opening
endif
endfor
for closing in closing.parentheses + closing.braces + closing.brackets
if closing.pos > rightmost_closing.pos
let rightmost_closing = closing
endif
endfor
return [rightmost_opening, rightmost_closing]
endfunction
function s:Match(lnum, regex)
let col = match(getline(a:lnum), '\C'.a:regex) + 1
return col > 0 && !s:IsInStringOrComment(a:lnum, col) ? col : 0
endfunction
function s:MatchLast(lnum, regex)
let line = getline(a:lnum)
let col = match(line, '.*\zs' . a:regex)
while col != -1 && s:IsInStringOrComment(a:lnum, col)
let line = strpart(line, 0, col)
let col = match(line, '.*' . a:regex)
endwhile
return col + 1
endfunction
function FalconGetIndent(...)
let clnum = a:0 ? a:1 : v:lnum
if clnum == 0
return 0
endif
let line = getline(clnum)
let ind = -1
let col = matchend(line, '^\s*[]})]')
if col > 0 && !s:IsInStringOrComment(clnum, col)
call cursor(clnum, col)
let bs = strpart('(){}[]', stridx(')}]', line[col - 1]) * 2, 2)
if searchpair(escape(bs[0], '\['), '', bs[1], 'bW', s:skip_expr) > 0
if line[col-1]==')' && col('.') != col('$') - 1
let ind = virtcol('.') - 1
else
let ind = indent(s:GetMSL(line('.')))
endif
endif
return ind
endif
if s:Match(clnum, s:falcon_deindent_keywords)
call cursor(clnum, 1)
if searchpair(s:end_start_regex, s:end_middle_regex, s:end_end_regex, 'bW',
\ s:end_skip_expr) > 0
let msl  = s:GetMSL(line('.'))
let line = getline(line('.'))
if strpart(line, 0, col('.') - 1) =~ '=\s*$' &&
\ strpart(line, col('.') - 1, 2) !~ 'do'
let ind = virtcol('.') - 1
elseif getline(msl) =~ '=\s*\(#.*\)\=$'
let ind = indent(line('.'))
else
let ind = indent(msl)
endif
endif
return ind
endif
if s:IsInString(clnum, matchend(line, '^\s*') + 1)
return indent('.')
endif
let lnum = s:PrevNonBlankNonString(clnum - 1)
if line =~ '^\s*$' && lnum != prevnonblank(clnum - 1)
return indent(prevnonblank(clnum))
endif
if lnum == 0
return 0
endif
let line = getline(lnum)
let ind = indent(lnum)
if s:Match(lnum, s:block_regex)
return indent(s:GetMSL(lnum)) + shiftwidth()
endif
if line =~ '[[({]' || line =~ '[])}]\s*\%(#.*\)\=$'
let [opening, closing] = s:ExtraBrackets(lnum)
if opening.pos != -1
if opening.type == '(' && searchpair('(', '', ')', 'bW', s:skip_expr) > 0
if col('.') + 1 == col('$')
return ind + shiftwidth()
else
return virtcol('.')
endif
else
let nonspace = matchend(line, '\S', opening.pos + 1) - 1
return nonspace > 0 ? nonspace : ind + shiftwidth()
endif
elseif closing.pos != -1
call cursor(lnum, closing.pos + 1)
normal! %
if s:Match(line('.'), s:falcon_indent_keywords)
return indent('.') + shiftwidth()
else
return indent('.')
endif
else
call cursor(clnum, 0)  " FIXME: column was vcol
end
endif
let col = s:Match(lnum, '\%(^\|[^.:@$]\)\<end\>\s*\%(#.*\)\=$')
if col > 0
call cursor(lnum, col)
if searchpair(s:end_start_regex, '', s:end_end_regex, 'bW',
\ s:end_skip_expr) > 0
let n = line('.')
let ind = indent('.')
let msl = s:GetMSL(n)
if msl != n
let ind = indent(msl)
end
return ind
endif
end
let col = s:Match(lnum, s:falcon_indent_keywords)
if col > 0
call cursor(lnum, col)
let ind = virtcol('.') - 1 + shiftwidth()
if s:Match(lnum, s:end_end_regex)
let ind = indent('.')
endif
return ind
endif
let p_lnum = lnum
let lnum = s:GetMSL(lnum)
if p_lnum != lnum
if s:Match(p_lnum, s:non_bracket_continuation_regex) || s:IsInString(p_lnum,strlen(line))
return ind
endif
endif
let line = getline(lnum)
let msl_ind = indent(lnum)
if s:Match(lnum, s:falcon_indent_keywords)
let ind = msl_ind + shiftwidth()
if s:Match(lnum, s:end_end_regex)
let ind = ind - shiftwidth()
endif
return ind
endif
if s:Match(lnum, s:non_bracket_continuation_regex) && !s:Match(lnum, '^\s*\([\])}]\|end\)')
if lnum == p_lnum
let ind = msl_ind + shiftwidth()
else
let ind = msl_ind
endif
return ind
endif
return ind
endfunction
let &cpo = s:cpo_save
unlet s:cpo_save
