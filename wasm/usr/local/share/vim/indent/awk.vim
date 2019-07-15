if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetAwkIndent()
setlocal indentkeys-=:,0#
if exists("*GetAwkIndent")
finish
endif
function! GetAwkIndent()
let prev_lineno = s:Get_prev_line( v:lnum )
if prev_lineno == 0
return 0
endif
let prev_data = getline( prev_lineno )
let ind = indent( prev_lineno )
if s:Get_brace_balance( prev_data, '{', '}' ) > 0
return ind + shiftwidth()
endif
let brace_balance = s:Get_brace_balance( prev_data, '(', ')' )
if brace_balance > 0 && s:Starts_with_word( prev_data )
return s:Safe_indent( ind, s:First_word_len(prev_data), getline(v:lnum))
endif
if getline( v:lnum ) =~ '^\s*{'
return ind
endif
let continue_mode = s:Seems_continuing( prev_data )
if continue_mode > 0
if s:Seems_continuing( getline(s:Get_prev_line( prev_lineno )) )
return ind
else
if continue_mode == 1
return s:Safe_indent( ind, s:First_word_len(prev_data), getline(v:lnum))
else
return ind + shiftwidth()
endif
endif
endif
if prev_data =~ ')' && brace_balance < 0
while brace_balance != 0 && prev_lineno > 0
let prev_lineno = s:Get_prev_line( prev_lineno )
let prev_data = getline( prev_lineno )
let brace_balance=brace_balance+s:Get_brace_balance(prev_data,'(',')' )
endwhile
let ind = indent( prev_lineno )
else
if s:Seems_continuing( getline( prev_lineno - 1 ) )
let prev_lineno = prev_lineno - 2
let prev_data = getline( prev_lineno )
while prev_lineno > 0 && (s:Seems_continuing( prev_data ) > 0)
let prev_lineno = s:Get_prev_line( prev_lineno )
let prev_data = getline( prev_lineno )
endwhile
let ind = indent( prev_lineno + 1 )
endif
endif
if getline(v:lnum) =~ '^\s*}'
let ind = ind - shiftwidth()
endif
return ind
endfunction
function! s:Get_brace_balance( line, b_open, b_close )
let line2 = substitute( a:line, a:b_open, "", "g" )
let openb = strlen( a:line ) - strlen( line2 )
let line3 = substitute( line2, a:b_close, "", "g" )
let closeb = strlen( line2 ) - strlen( line3 )
return openb - closeb
endfunction
function! s:Starts_with_word( line )
if a:line =~ '^\s*[a-zA-Z_0-9]\+\s*('
return 1
endif
return 0
endfunction
function! s:First_word_len( line )
let white_end = matchend( a:line, '^\s*' )
if match( a:line, '^\s*func' ) != -1
let word_end = matchend( a:line, '[a-z]\+\s\+[a-zA-Z_0-9]\+[ (]*' )
else
let word_end = matchend( a:line, '[a-zA-Z_0-9]\+[ (]*' )
endif
return word_end - white_end
endfunction
function! s:Seems_continuing( line )
if a:line =~ '\(--\|++\)\s*$'
return 0
endif
if a:line =~ '[\\,\|\&\+\-\*\%\^]\s*$'
return 1
endif
if a:line =~ '^\s*\(if\|while\|for\)\s*(.*)\s*$' || a:line =~ '^\s*else\s*'
return 2
endif
return 0
endfunction
function! s:Get_prev_line( lineno )
let lnum = a:lineno - 1
let data = getline( lnum )
while lnum > 0 && (data =~ '^\s*#' || data =~ '^\s*$')
let lnum = lnum - 1
let data = getline( lnum )
endwhile
return lnum
endfunction
function! s:Safe_indent( base, wordlen, this_line )
let line_base = matchend( a:this_line, '^\s*' )
let line_len = strlen( a:this_line ) - line_base
let indent = a:base
if (indent + a:wordlen + line_len) > 80
let indent = indent + 3
endif
return indent + a:wordlen
endfunction
