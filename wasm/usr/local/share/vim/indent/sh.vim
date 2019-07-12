if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetShIndent()
setlocal indentkeys+=0=then,0=do,0=else,0=elif,0=fi,0=esac,0=done,0=end,),0=;;,0=;&
setlocal indentkeys+=0=fin,0=fil,0=fip,0=fir,0=fix
setlocal indentkeys-=:,0#
setlocal nosmartindent
let b:undo_indent = 'setlocal indentexpr< indentkeys< smartindent<'
if exists("*GetShIndent")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
let s:sh_indent_defaults = {
\ 'default': function('shiftwidth'),
\ 'continuation-line': function('shiftwidth'),
\ 'case-labels': function('shiftwidth'),
\ 'case-statements': function('shiftwidth'),
\ 'case-breaks': 0 }
function! s:indent_value(option)
let Value = exists('b:sh_indent_options')
\ && has_key(b:sh_indent_options, a:option) ?
\ b:sh_indent_options[a:option] :
\ s:sh_indent_defaults[a:option]
if type(Value) == type(function('type'))
return Value()
endif
return Value
endfunction
function! GetShIndent()
let curline = getline(v:lnum)
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let line = getline(lnum)
let pnum = prevnonblank(lnum - 1)
let pline = getline(pnum)
let ind = indent(lnum)
if line =~ '^\s*\%(if\|then\|do\|else\|elif\|case\|while\|until\|for\|select\|foreach\)\>' ||
\  (&ft is# 'zsh' && line =~ '\<\%(if\|then\|do\|else\|elif\|case\|while\|until\|for\|select\|foreach\)\>')
if !s:is_end_expression(line)
let ind += s:indent_value('default')
endif
elseif s:is_case_label(line, pnum)
if !s:is_case_ended(line)
let ind += s:indent_value('case-statements')
endif
elseif s:is_function_definition(line)
if line !~ '}\s*\%(#.*\)\=$'
let ind += s:indent_value('default')
endif
elseif s:is_array(line) && line !~ ')\s*$' && (&ft is# 'zsh' || s:is_bash())
let ind += s:indent_value('continuation-line')
elseif curline =~ '^\s*)$'
let ind -= s:indent_value('continuation-line')
elseif s:is_continuation_line(line)
if pnum == 0 || !s:is_continuation_line(pline)
let ind += s:indent_value('continuation-line')
endif
elseif s:end_block(line) && !s:start_block(line)
let ind -= s:indent_value('default')
elseif pnum != 0 &&
\ s:is_continuation_line(pline) &&
\ !s:end_block(curline) &&
\ !s:is_end_expression(curline)
let i = v:lnum
let ind2 = indent(s:find_continued_lnum(pnum))
while !s:is_empty(getline(i)) && i > pnum
let i -= 1
endw
if i == pnum
let ind += ind2
else
let ind = ind2
endif
endif
let pine = line
let line = curline
if curline =~ '^\s*\%(fi\);\?\s*\%(#.*\)\=$'
let previous_line = searchpair('\<if\>', '', '\<fi\>\zs', 'bnW')
if previous_line > 0
let ind = indent(previous_line)
endif
elseif line =~ '^\s*\%(then\|do\|else\|elif\|done\|end\)\>' || s:end_block(line)
let ind -= s:indent_value('default')
elseif line =~ '^\s*esac\>' && s:is_case_empty(getline(v:lnum - 1))
let ind -= s:indent_value('default')
elseif line =~ '^\s*esac\>'
let ind -= (s:is_case_label(pine, lnum) && s:is_case_ended(pine) ?
\ 0 : s:indent_value('case-statements')) +
\ s:indent_value('case-labels')
if s:is_case_break(pine)
let ind += s:indent_value('case-breaks')
endif
elseif s:is_case_label(line, lnum)
if s:is_case(pine)
let ind = indent(lnum) + s:indent_value('case-labels')
else
let ind -= (s:is_case_label(pine, lnum) && s:is_case_ended(pine) ?
\ 0 : s:indent_value('case-statements')) -
\ s:indent_value('case-breaks')
endif
elseif s:is_case_break(line)
let ind -= s:indent_value('case-breaks')
elseif s:is_here_doc(line)
let ind = 0
elseif match(map(synstack(v:lnum, 1), 'synIDattr(v:val, "name")'), '\c\mheredoc') > -1
return indent(v:lnum)
elseif s:is_comment(line) && s:is_empty(getline(v:lnum-1))
return indent(v:lnum)
endif
return ind > 0 ? ind : 0
endfunction
function! s:is_continuation_line(line)
if a:line =~ '^\s*#'
return 0
else
return a:line =~ '\%(\%(^\|[^\\]\)\\\|&&\|||\||\)' .
\ '\s*\({\s*\)\=\(#.*\)\=$'
endif
endfunction
function! s:find_continued_lnum(lnum)
let i = a:lnum
while i > 1 && s:is_continuation_line(getline(i - 1))
let i -= 1
endwhile
return i
endfunction
function! s:is_function_definition(line)
return a:line =~ '^\s*\<\k\+\>\s*()\s*{' ||
\ a:line =~ '^\s*{' ||
\ a:line =~ '^\s*function\s*\w\S\+\s*\%(()\)\?\s*{'
endfunction
function! s:is_array(line)
return a:line =~ '^\s*\<\k\+\>=('
endfunction
function! s:is_case_label(line, pnum)
if a:line !~ '^\s*(\=.*)'
return 0
endif
if a:pnum > 0
let pine = getline(a:pnum)
if !(s:is_case(pine) || s:is_case_ended(pine))
return 0
endif
endif
let suffix = substitute(a:line, '^\s*(\=', "", "")
let nesting = 0
let i = 0
let n = strlen(suffix)
while i < n
let c = suffix[i]
let i += 1
if c == '\\'
let i += 1
elseif c == '('
let nesting += 1
elseif c == ')'
if nesting == 0
return 1
endif
let nesting -= 1
endif
endwhile
return 0
endfunction
function! s:is_case(line)
return a:line =~ '^\s*case\>'
endfunction
function! s:is_case_break(line)
return a:line =~ '^\s*;[;&]'
endfunction
function! s:is_here_doc(line)
if a:line =~ '^\w\+$'
let here_pat = '<<-\?'. s:escape(a:line). '\$'
return search(here_pat, 'bnW') > 0
endif
return 0
endfunction
function! s:is_case_ended(line)
return s:is_case_break(a:line) || a:line =~ ';[;&]\s*\%(#.*\)\=$'
endfunction
function! s:is_case_empty(line)
if a:line =~ '^\s*$' || a:line =~ '^\s*#'
return s:is_case_empty(getline(v:lnum - 1))
else
return a:line =~ '^\s*case\>'
endif
endfunction
function! s:escape(pattern)
return '\V'. escape(a:pattern, '\\')
endfunction
function! s:is_empty(line)
return a:line =~ '^\s*$'
endfunction
function! s:end_block(line)
return a:line =~ '^\s*}'
endfunction
function! s:start_block(line)
return a:line =~ '{\s*\(#.*\)\?$'
endfunction
function! s:find_start_block(lnum)
let i = a:lnum
while i > 1 && !s:start_block(getline(i))
let i -= 1
endwhile
return i
endfunction
function! s:is_comment(line)
return a:line =~ '^\s*#'
endfunction
function! s:is_end_expression(line)
return a:line =~ '\<\%(fi\|esac\|done\|end\)\>\s*\%(#.*\)\=$'
endfunction
function! s:is_bash()
return get(g:, 'is_bash', 0) || get(b:, 'is_bash', 0)
endfunction
let &cpo = s:cpo_save
unlet s:cpo_save
