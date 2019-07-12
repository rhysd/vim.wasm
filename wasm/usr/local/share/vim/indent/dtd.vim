setlocal indentexpr=GetDTDIndent()
setlocal indentkeys=!^F,o,O,>
setlocal nosmartindent
if exists("*GetDTDIndent")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
let s:token_pattern = '^[^[:space:]]\+'
function s:lex1(input, start, ...)
let pattern = a:0 > 0 ? a:1 : s:token_pattern
let start = matchend(a:input, '^\_s*', a:start)
if start == -1
return ["", a:start]
endif
let end = matchend(a:input, pattern, start)
if end == -1
return ["", a:start]
endif
let token = strpart(a:input, start, end - start)
return [token, end]
endfunction
function s:lex(input, start, ...)
let pattern = a:0 > 0 ? a:1 : s:token_pattern
let info = s:lex1(a:input, a:start, pattern)
while info[0] == '--'
let info = s:lex1(a:input, info[1], pattern)
while info[0] != "" && info[0] != '--'
let info = s:lex1(a:input, info[1], pattern)
endwhile
if info[0] == ""
return info
endif
let info = s:lex1(a:input, info[1], pattern)
endwhile
return info
endfunction
function s:indent_to_innermost_parentheses(line, end)
let token = '('
let end = a:end
let parentheses = [end - 1]
while token != ""
let [token, end] = s:lex(a:line, end, '^\%([(),|]\|[A-Za-z0-9_-]\+\|#P\=CDATA\|%[A-Za-z0-9_-]\+;\)[?*+]\=')
if token[0] == '('
call add(parentheses, end - 1)
elseif token[0] == ')'
if len(parentheses) == 1
return [-1, end]
endif
call remove(parentheses, -1)
endif
endwhile
return [parentheses[-1] - strridx(a:line, "\n", parentheses[-1]), end]
endfunction
function GetDTDIndent()
if v:lnum == 1
return 0
endif
if search('<!', 'bceW') == 0
return indent(v:lnum - 1)
endif
let lnum = line('.')
let col = col('.')
let indent = indent('.')
let line = lnum == v:lnum ? getline(lnum) : join(getline(lnum, v:lnum - 1), "\n")
let [declaration, end] = s:lex1(line, col)
if declaration == ""
return indent + shiftwidth()
elseif declaration == '--'
while declaration != ""
let [declaration, end] = s:lex(line, end)
if declaration == "-->"
return indent
endif
endwhile
return -1
elseif declaration == 'ELEMENT'
let [name, end] = s:lex(line, end)
if name == ""
return indent + shiftwidth()
endif
let [token, end] = s:lex(line, end, '^\%([-O(]\|ANY\|EMPTY\)')
let n = 0
while token =~ '[-O]' && n < 2
let [token, end] = s:lex(line, end, '^\%([-O(]\|ANY\|EMPTY\)')
let n += 1
endwhile
if token == ""
return indent + shiftwidth()
endif
if token != '('
return indent
endif
let [indent_of_innermost, end] = s:indent_to_innermost_parentheses(line, end)
if indent_of_innermost != -1
return indent_of_innermost
endif
let seen = { '+(': 0, '-(': 0 }
while 1
let [additions_exceptions, end] = s:lex(line, end, '^[+-](')
if additions_exceptions != '+(' && additions_exceptions != '-('
let [token, end] = s:lex(line, end)
if token == '>'
return indent
endif
return getline(v:lnum) =~ '^\s*>' || count(values(seen), 0) == 0 ? indent : (indent + shiftwidth())
endif
if seen[additions_exceptions]
return indent
endif
let seen[additions_exceptions] = 1
let [indent_of_innermost, end] = s:indent_to_innermost_parentheses(line, end)
if indent_of_innermost != -1
return indent_of_innermost
endif
endwhile
elseif declaration == 'ATTLIST'
let [name, end] = s:lex(line, end)
if name == ""
return indent + shiftwidth()
endif
while 1
let [name, end] = s:lex(line, end)
if name == ""
return getline(v:lnum) =~ '^\s*>' ? indent : (indent + shiftwidth())
elseif name == ">"
return indent
endif
let [value, end] = s:lex(line, end, '^\%((\|[^[:space:]]\+\)')
if value == ""
return indent + shiftwidth() * 2
elseif value == 'NOTATION'
let [value, end] = s:lex(line, end, '^\%((\|[^[:space:]]\+\)')
if value == ""
return indent + shiftwidth() * 3
endif
endif
if value == '('
let [indent_of_innermost, end] = s:indent_to_innermost_parentheses(line, end)
if indent_of_innermost != -1
return indent_of_innermost
endif
endif
let [default, end] = s:lex(line, end, '^\%("\_[^"]*"\|#\(REQUIRED\|IMPLIED\|FIXED\)\)')
if default == ""
return indent + shiftwidth() * 2
elseif default == '#FIXED'
let [default, end] = s:lex(line, end, '^"\_[^"]*"')
if default == ""
return indent + shiftwidth() * 3
endif
endif
endwhile
elseif declaration == 'ENTITY'
let [name, end] = s:lex(line, end)
if name == ""
return indent + shiftwidth()
elseif name == '%'
let [name, end] = s:lex(line, end)
if name == ""
return indent + shiftwidth()
endif
endif
let [value, end] = s:lex(line, end)
if value == ""
return indent + shiftwidth()
elseif value == 'SYSTEM' || value == 'PUBLIC'
let [quoted_string, end] = s:lex(line, end, '\%("[^"]\+"\|''[^'']\+''\)')
if quoted_string == ""
return indent + shiftwidth() * 2
endif
if value == 'PUBLIC'
let [quoted_string, end] = s:lex(line, end, '\%("[^"]\+"\|''[^'']\+''\)')
if quoted_string == ""
return indent + shiftwidth() * 2
endif
endif
let [ndata, end] = s:lex(line, end)
if ndata == ""
return indent + shiftwidth()
endif
let [name, end] = s:lex(line, end)
return name == "" ? (indent + shiftwidth() * 2) : indent
else
return indent
endif
elseif declaration == 'NOTATION'
let [name, end] = s:lex(line, end)
if name == ""
return indent + shiftwidth()
endif
let [id, end] = s:lex(line, end)
if id == ""
return indent + shiftwidth()
elseif id == 'SYSTEM' || id == 'PUBLIC'
let [quoted_string, end] = s:lex(line, end, '\%("[^"]\+"\|''[^'']\+''\)')
if quoted_string == ""
return indent + shiftwidth() * 2
endif
if id == 'PUBLIC'
let [quoted_string, end] = s:lex(line, end, '\%("[^"]\+"\|''[^'']\+''\|>\)')
if quoted_string == ""
return getline(v:lnum) =~ '^\s*>' ? indent : (indent + shiftwidth() * 2)
elseif quoted_string == '>'
return indent
endif
endif
endif
return indent
endif
return -1
endfunction
let &cpo = s:cpo_save
unlet s:cpo_save
