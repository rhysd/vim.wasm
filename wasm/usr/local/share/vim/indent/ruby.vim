if exists("b:did_indent")
finish
endif
let b:did_indent = 1
if !exists('g:ruby_indent_access_modifier_style')
let g:ruby_indent_access_modifier_style = 'normal'
endif
if !exists('g:ruby_indent_assignment_style')
let g:ruby_indent_assignment_style = 'hanging'
endif
if !exists('g:ruby_indent_block_style')
let g:ruby_indent_block_style = 'expression'
endif
setlocal nosmartindent
setlocal indentexpr=GetRubyIndent(v:lnum)
setlocal indentkeys=0{,0},0),0],!^F,o,O,e,:,.
setlocal indentkeys+==end,=else,=elsif,=when,=ensure,=rescue,==begin,==end
setlocal indentkeys+==private,=protected,=public
if exists("*GetRubyIndent")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
let s:syng_string =
\ ['String', 'Interpolation', 'InterpolationDelimiter', 'NoInterpolation', 'StringEscape']
let s:syng_stringdoc = s:syng_string + ['Documentation']
let s:syng_strcom = s:syng_stringdoc +
\ ['Regexp', 'RegexpDelimiter', 'RegexpEscape',
\ 'Symbol', 'StringDelimiter', 'ASCIICode', 'Comment']
let s:skip_expr =
\ 'index(map('.string(s:syng_strcom).',"hlID(''ruby''.v:val)"), synID(line("."),col("."),1)) >= 0'
let s:ruby_indent_keywords =
\ '^\s*\zs\<\%(module\|class\|if\|for' .
\   '\|while\|until\|else\|elsif\|case\|when\|unless\|begin\|ensure\|rescue' .
\   '\|\%(\K\k*[!?]\?\)\=\s*def\):\@!\>' .
\ '\|\%([=,*/%+-]\|<<\|>>\|:\s\)\s*\zs' .
\    '\<\%(if\|for\|while\|until\|case\|unless\|begin\):\@!\>'
let s:ruby_deindent_keywords =
\ '^\s*\zs\<\%(ensure\|else\|rescue\|elsif\|when\|end\):\@!\>'
let s:end_start_regex =
\ '\C\%(^\s*\|[=,*/%+\-|;{]\|<<\|>>\|:\s\)\s*\zs' .
\ '\<\%(module\|class\|if\|for\|while\|until\|case\|unless\|begin' .
\   '\|\%(\K\k*[!?]\?\)\=\s*def\):\@!\>' .
\ '\|\%(^\|[^.:@$]\)\@<=\<do:\@!\>'
let s:end_middle_regex = '\<\%(ensure\|else\|\%(\%(^\|;\)\s*\)\@<=\<rescue:\@!\>\|when\|elsif\):\@!\>'
let s:end_end_regex = '\%(^\|[^.:@$]\)\@<=\<end:\@!\>'
let s:end_skip_expr = s:skip_expr .
\ ' || (expand("<cword>") == "do"' .
\ ' && getline(".") =~ "^\\s*\\<\\(while\\|until\\|for\\):\\@!\\>")'
let s:non_bracket_continuation_regex =
\ '\%([\\.,:*/%+]\|\<and\|\<or\|\%(<%\)\@<![=-]\|:\@<![^[:alnum:]:][|&?]\|||\|&&\)\s*\%(#.*\)\=$'
let s:continuation_regex =
\ '\%(%\@<![({[\\.,:*/%+]\|\<and\|\<or\|\%(<%\)\@<![=-]\|:\@<![^[:alnum:]:][|&?]\|||\|&&\)\s*\%(#.*\)\=$'
let s:continuable_regex =
\ '\C\%(^\s*\|[=,*/%+\-|;{]\|<<\|>>\|:\s\)\s*\zs' .
\ '\<\%(if\|for\|while\|until\|unless\):\@!\>'
let s:bracket_continuation_regex = '%\@<!\%([({[]\)\s*\%(#.*\)\=$'
let s:dot_continuation_regex = '%\@<!\.\s*\%(#.*\)\=$'
let s:backslash_continuation_regex = '%\@<!\\\s*$'
let s:bracket_switch_continuation_regex = '^\([^(]\+\zs).\+\)\+'.s:continuation_regex
let s:splat_regex = '[[,(]\s*\*\s*\%(#.*\)\=$'
let s:access_modifier_regex = '\C^\s*\%(public\|protected\|private\)\s*\%(#.*\)\=$'
let s:indent_access_modifier_regex = '\C^\s*\%(protected\|private\)\s*\%(#.*\)\=$'
let s:block_regex =
\ '\%(\<do:\@!\>\|%\@<!{\)\s*\%(|[^|]*|\)\=\s*\%(#.*\)\=$'
let s:block_continuation_regex = '^\s*[^])}\t ].*'.s:block_regex
let s:leading_operator_regex = '^\s*[.]'
function! GetRubyIndent(...) abort
let indent_info = {}
if exists('*shiftwidth')
let indent_info.sw = shiftwidth()
else
let indent_info.sw = &sw
endif
let indent_info.clnum = a:0 ? a:1 : v:lnum
let indent_info.cline = getline(indent_info.clnum)
let indent_info.col = col('.')
let indent_callback_names = [
\ 's:AccessModifier',
\ 's:ClosingBracketOnEmptyLine',
\ 's:BlockComment',
\ 's:DeindentingKeyword',
\ 's:MultilineStringOrLineComment',
\ 's:ClosingHeredocDelimiter',
\ 's:LeadingOperator',
\ ]
for callback_name in indent_callback_names
let indent = call(function(callback_name), [indent_info])
if indent >= 0
return indent
endif
endfor
let indent_callback_names = [
\ 's:EmptyInsideString',
\ ]
for callback_name in indent_callback_names
let indent = call(function(callback_name), [indent_info])
if indent >= 0
return indent
endif
endfor
let indent_info.plnum = s:PrevNonBlankNonString(indent_info.clnum - 1)
let indent_info.pline = getline(indent_info.plnum)
let indent_callback_names = [
\ 's:StartOfFile',
\ 's:AfterAccessModifier',
\ 's:ContinuedLine',
\ 's:AfterBlockOpening',
\ 's:AfterHangingSplat',
\ 's:AfterUnbalancedBracket',
\ 's:AfterLeadingOperator',
\ 's:AfterEndKeyword',
\ 's:AfterIndentKeyword',
\ ]
for callback_name in indent_callback_names
let indent = call(function(callback_name), [indent_info])
if indent >= 0
return indent
endif
endfor
let indent_callback_names = [
\ 's:PreviousNotMSL',
\ 's:IndentingKeywordInMSL',
\ 's:ContinuedHangingOperator',
\ ]
let indent_info.plnum_msl = s:GetMSL(indent_info.plnum)
for callback_name in indent_callback_names
let indent = call(function(callback_name), [indent_info])
if indent >= 0
return indent
endif
endfor
return indent(indent_info.plnum)
endfunction
function! s:AccessModifier(cline_info) abort
let info = a:cline_info
if g:ruby_indent_access_modifier_style == 'indent'
if s:Match(info.clnum, s:access_modifier_regex)
let class_lnum = s:FindContainingClass()
if class_lnum > 0
return indent(class_lnum) + info.sw
endif
endif
elseif g:ruby_indent_access_modifier_style == 'outdent'
if s:Match(info.clnum, s:access_modifier_regex)
let class_lnum = s:FindContainingClass()
if class_lnum > 0
return indent(class_lnum)
endif
endif
endif
return -1
endfunction
function! s:ClosingBracketOnEmptyLine(cline_info) abort
let info = a:cline_info
let col = matchend(info.cline, '^\s*[]})]')
if col > 0 && !s:IsInStringOrComment(info.clnum, col)
call cursor(info.clnum, col)
let closing_bracket = info.cline[col - 1]
let bracket_pair = strpart('(){}[]', stridx(')}]', closing_bracket) * 2, 2)
if searchpair(escape(bracket_pair[0], '\['), '', bracket_pair[1], 'bW', s:skip_expr) > 0
if closing_bracket == ')' && col('.') != col('$') - 1
let ind = virtcol('.') - 1
elseif g:ruby_indent_block_style == 'do'
let ind = indent(line('.'))
else " g:ruby_indent_block_style == 'expression'
let ind = indent(s:GetMSL(line('.')))
endif
endif
return ind
endif
return -1
endfunction
function! s:BlockComment(cline_info) abort
if match(a:cline_info.cline, '^\s*\%(=begin\|=end\)$') != -1
return 0
endif
return -1
endfunction
function! s:DeindentingKeyword(cline_info) abort
let info = a:cline_info
if s:Match(info.clnum, s:ruby_deindent_keywords)
call cursor(info.clnum, 1)
if searchpair(s:end_start_regex, s:end_middle_regex, s:end_end_regex, 'bW',
\ s:end_skip_expr) > 0
let msl  = s:GetMSL(line('.'))
let line = getline(line('.'))
if s:IsAssignment(line, col('.')) &&
\ strpart(line, col('.') - 1, 2) !~ 'do'
if g:ruby_indent_assignment_style == 'hanging'
let ind = virtcol('.') - 1
else
let ind = indent(line('.'))
endif
elseif g:ruby_indent_block_style == 'do'
let ind = indent(line('.'))
elseif getline(msl) =~ '=\s*\(#.*\)\=$'
let ind = indent(line('.'))
else
let ind = indent(msl)
endif
endif
return ind
endif
return -1
endfunction
function! s:MultilineStringOrLineComment(cline_info) abort
let info = a:cline_info
if s:IsInStringOrDocumentation(info.clnum, matchend(info.cline, '^\s*') + 1)
return indent(info.clnum)
endif
return -1
endfunction
function! s:ClosingHeredocDelimiter(cline_info) abort
let info = a:cline_info
if info.cline =~ '^\k\+\s*$'
\ && s:IsInStringDelimiter(info.clnum, 1)
\ && search('\V<<'.info.cline, 'nbW') > 0
return 0
endif
return -1
endfunction
function! s:LeadingOperator(cline_info) abort
if s:Match(a:cline_info.clnum, s:leading_operator_regex)
return indent(s:GetMSL(a:cline_info.clnum)) + a:cline_info.sw
endif
return -1
endfunction
function! s:EmptyInsideString(pline_info) abort
let info = a:pline_info
let plnum = prevnonblank(info.clnum - 1)
let pline = getline(plnum)
if info.cline =~ '^\s*$'
\ && s:IsInStringOrComment(plnum, 1)
\ && s:IsInStringOrComment(plnum, strlen(pline))
return indent(plnum)
endif
return -1
endfunction
function! s:StartOfFile(pline_info) abort
if a:pline_info.plnum == 0
return 0
endif
return -1
endfunction
function! s:AfterAccessModifier(pline_info) abort
let info = a:pline_info
if g:ruby_indent_access_modifier_style == 'indent'
if s:Match(info.plnum, s:indent_access_modifier_regex)
return indent(info.plnum) + info.sw
endif
elseif g:ruby_indent_access_modifier_style == 'outdent'
if s:Match(info.plnum, s:access_modifier_regex)
return indent(info.plnum) + info.sw
endif
endif
return -1
endfunction
function! s:ContinuedLine(pline_info) abort
let info = a:pline_info
let col = s:Match(info.plnum, s:ruby_indent_keywords)
if s:Match(info.plnum, s:continuable_regex) &&
\ s:Match(info.plnum, s:continuation_regex)
if col > 0 && s:IsAssignment(info.pline, col)
if g:ruby_indent_assignment_style == 'hanging'
let ind = col - 1
else
let ind = indent(info.plnum)
endif
else
let ind = indent(s:GetMSL(info.plnum))
endif
return ind + info.sw + info.sw
endif
return -1
endfunction
function! s:AfterBlockOpening(pline_info) abort
let info = a:pline_info
if s:Match(info.plnum, s:block_regex)
if g:ruby_indent_block_style == 'do'
let ind = indent(info.plnum) + info.sw
else
let plnum_msl = s:GetMSL(info.plnum)
if getline(plnum_msl) =~ '=\s*\(#.*\)\=$'
let ind = indent(info.plnum) + info.sw
else
let ind = indent(plnum_msl) + info.sw
endif
endif
return ind
endif
return -1
endfunction
function! s:AfterLeadingOperator(pline_info) abort
if s:Match(a:pline_info.plnum, s:leading_operator_regex)
return indent(s:GetMSL(a:pline_info.plnum))
endif
return -1
endfunction
function! s:AfterHangingSplat(pline_info) abort
let info = a:pline_info
if info.pline =~ s:splat_regex
return indent(info.plnum) + info.sw
endif
return -1
endfunction
function! s:AfterUnbalancedBracket(pline_info) abort
let info = a:pline_info
if info.pline =~ '[[({]' || info.pline =~ '[])}]\s*\%(#.*\)\=$'
let [opening, closing] = s:ExtraBrackets(info.plnum)
if opening.pos != -1
if opening.type == '(' && searchpair('(', '', ')', 'bW', s:skip_expr) > 0
if col('.') + 1 == col('$')
return indent(info.plnum) + info.sw
else
return virtcol('.')
endif
else
let nonspace = matchend(info.pline, '\S', opening.pos + 1) - 1
return nonspace > 0 ? nonspace : indent(info.plnum) + info.sw
endif
elseif closing.pos != -1
call cursor(info.plnum, closing.pos + 1)
normal! %
if s:Match(line('.'), s:ruby_indent_keywords)
return indent('.') + info.sw
else
return indent(s:GetMSL(line('.')))
endif
else
call cursor(info.clnum, info.col)
end
endif
return -1
endfunction
function! s:AfterEndKeyword(pline_info) abort
let info = a:pline_info
let col = s:Match(info.plnum, '\%(^\|[^.:@$]\)\<end\>\s*\%(#.*\)\=$')
if col > 0
call cursor(info.plnum, col)
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
return -1
endfunction
function! s:AfterIndentKeyword(pline_info) abort
let info = a:pline_info
let col = s:Match(info.plnum, s:ruby_indent_keywords)
if col > 0
call cursor(info.plnum, col)
let ind = virtcol('.') - 1 + info.sw
if s:Match(info.plnum, s:end_end_regex)
let ind = indent('.')
elseif s:IsAssignment(info.pline, col)
if g:ruby_indent_assignment_style == 'hanging'
let ind = col + info.sw - 1
else
let ind = indent(info.plnum) + info.sw
endif
endif
return ind
endif
return -1
endfunction
function! s:PreviousNotMSL(msl_info) abort
let info = a:msl_info
if info.plnum != info.plnum_msl
if s:Match(info.plnum, s:bracket_switch_continuation_regex)
return indent(info.plnum) - 1
elseif s:Match(info.plnum, s:non_bracket_continuation_regex) || s:IsInString(info.plnum, strlen(line))
return indent(info.plnum)
endif
endif
return -1
endfunction
function! s:IndentingKeywordInMSL(msl_info) abort
let info = a:msl_info
let col = s:Match(info.plnum_msl, s:ruby_indent_keywords)
if col > 0
let ind = indent(info.plnum_msl) + info.sw
if s:Match(info.plnum_msl, s:end_end_regex)
let ind = ind - info.sw
elseif s:IsAssignment(getline(info.plnum_msl), col)
if g:ruby_indent_assignment_style == 'hanging'
let ind = col + info.sw - 1
else
let ind = indent(info.plnum_msl) + info.sw
endif
endif
return ind
endif
return -1
endfunction
function! s:ContinuedHangingOperator(msl_info) abort
let info = a:msl_info
if s:Match(info.plnum_msl, s:non_bracket_continuation_regex) && !s:Match(info.plnum_msl, '^\s*\([\])}]\|end\)')
if info.plnum_msl == info.plnum
let ind = indent(info.plnum_msl) + info.sw
else
let ind = indent(info.plnum_msl)
endif
return ind
endif
return -1
endfunction
function! s:IsInRubyGroup(groups, lnum, col) abort
let ids = map(copy(a:groups), 'hlID("ruby".v:val)')
return index(ids, synID(a:lnum, a:col, 1)) >= 0
endfunction
function! s:IsInStringOrComment(lnum, col) abort
return s:IsInRubyGroup(s:syng_strcom, a:lnum, a:col)
endfunction
function! s:IsInString(lnum, col) abort
return s:IsInRubyGroup(s:syng_string, a:lnum, a:col)
endfunction
function! s:IsInStringOrDocumentation(lnum, col) abort
return s:IsInRubyGroup(s:syng_stringdoc, a:lnum, a:col)
endfunction
function! s:IsInStringDelimiter(lnum, col) abort
return s:IsInRubyGroup(['StringDelimiter'], a:lnum, a:col)
endfunction
function! s:IsAssignment(str, pos) abort
return strpart(a:str, 0, a:pos - 1) =~ '=\s*$'
endfunction
function! s:PrevNonBlankNonString(lnum) abort
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
function! s:GetMSL(lnum) abort
let msl = a:lnum
let lnum = s:PrevNonBlankNonString(a:lnum - 1)
while lnum > 0
let line = getline(lnum)
if !s:Match(msl, s:backslash_continuation_regex) &&
\ s:Match(lnum, s:backslash_continuation_regex)
let msl = lnum
elseif s:Match(msl, s:leading_operator_regex)
let msl = lnum
elseif s:Match(lnum, s:splat_regex)
return msl
elseif s:Match(lnum, s:non_bracket_continuation_regex) &&
\ s:Match(msl, s:non_bracket_continuation_regex)
let msl = lnum
elseif s:Match(lnum, s:dot_continuation_regex) &&
\ (s:Match(msl, s:bracket_continuation_regex) || s:Match(msl, s:block_continuation_regex))
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
let lnum = s:PrevNonBlankNonString(lnum - 1)
endwhile
return msl
endfunction
function! s:ExtraBrackets(lnum) abort
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
function! s:Match(lnum, regex) abort
let line   = getline(a:lnum)
let offset = match(line, '\C'.a:regex)
let col    = offset + 1
while offset > -1 && s:IsInStringOrComment(a:lnum, col)
let offset = match(line, '\C'.a:regex, offset + 1)
let col = offset + 1
endwhile
if offset > -1
return col
else
return 0
endif
endfunction
function! s:FindContainingClass() abort
let saved_position = getpos('.')
while searchpair(s:end_start_regex, s:end_middle_regex, s:end_end_regex, 'bW',
\ s:end_skip_expr) > 0
if expand('<cword>') =~# '\<class\|module\>'
let found_lnum = line('.')
call setpos('.', saved_position)
return found_lnum
endif
endwhile
call setpos('.', saved_position)
return 0
endfunction
let &cpo = s:cpo_save
unlet s:cpo_save
