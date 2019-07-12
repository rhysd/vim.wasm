if exists("b:did_indent")
finish
endif
let b:did_indent = 1
let s:keepcpo= &cpo
set cpo&vim
setlocal indentexpr=XmlIndentGet(v:lnum,1)
setlocal indentkeys=o,O,*<Return>,<>>,<<>,/,{,},!^F
if !exists('b:xml_indent_open')
let b:xml_indent_open = '.\{-}<[:A-Z_a-z]'
endif
if !exists('b:xml_indent_close')
let b:xml_indent_close = '.\{-}</'
endif
let &cpo = s:keepcpo
unlet s:keepcpo
if exists('*XmlIndentGet')
finish
endif
let s:keepcpo= &cpo
set cpo&vim
fun! <SID>XmlIndentWithPattern(line, pat)
let s = substitute('x'.a:line, a:pat, "\1", 'g')
return strlen(substitute(s, "[^\1].*$", '', ''))
endfun
fun! <SID>XmlIndentSynCheck(lnum)
if &syntax != ''
let syn1 = synIDattr(synID(a:lnum, 1, 1), 'name')
let syn2 = synIDattr(synID(a:lnum, strlen(getline(a:lnum)) - 1, 1), 'name')
if syn1 != '' && syn1 !~ 'xml' && syn2 != '' && syn2 !~ 'xml'
return 0
endif
endif
return 1
endfun
fun! <SID>XmlIndentSum(line, style, add)
if <SID>IsXMLContinuation(a:line) && a:style == 0
return a:add + shiftwidth()
elseif <SID>HasNoTagEnd(a:line)
return a:add
endif
if a:style == match(a:line, '^\s*</')
return (shiftwidth() *
\  (<SID>XmlIndentWithPattern(a:line, b:xml_indent_open)
\ - <SID>XmlIndentWithPattern(a:line, b:xml_indent_close)
\ - <SID>XmlIndentWithPattern(a:line, '.\{-}/>'))) + a:add
else
return a:add
endif
endfun
fun! XmlIndentGet(lnum, use_syntax_check)
if prevnonblank(a:lnum - 1) == 0
return 0
endif
let ptag_pattern = '\%(.\{-}<[/:A-Z_a-z]\)'. '\%(\&\%<'. line('.').'l\)'
let ptag = search(ptag_pattern, 'bnW')
if ptag == 0
return 0
endif
let syn_name = ''
if a:use_syntax_check
let check_lnum = <SID>XmlIndentSynCheck(ptag)
let check_alnum = <SID>XmlIndentSynCheck(a:lnum)
if check_lnum == 0 || check_alnum == 0
return indent(a:lnum)
endif
let syn_name = synIDattr(synID(a:lnum, strlen(getline(a:lnum)) - 1, 1), 'name')
endif
if syn_name =~ 'Comment'
return <SID>XmlIndentComment(a:lnum)
endif
let pline = getline(ptag)
let pind  = indent(ptag)
let ind = <SID>XmlIndentSum(pline, -1, pind)
let t_ind = ind
let ind = <SID>XmlIndentSum(getline(a:lnum), 0, ind)
return ind
endfun
func! <SID>IsXMLContinuation(line)
return a:line !~ '^\s*<'
endfunc
func! <SID>HasNoTagEnd(line)
return a:line !~ '>\s*$'
endfunc
func! <SID>XmlIndentComment(lnum)
let ptagopen = search(b:xml_indent_open, 'bnW')
let ptagclose = search(b:xml_indent_close, 'bnW')
if getline(a:lnum) =~ '<!--'
if ptagclose > ptagopen && a:lnum > ptagclose
return indent(ptagclose)
else
return indent(ptagopen) + shiftwidth()
endif
elseif getline(a:lnum) =~ '-->'
return indent(search('<!--', 'bnW'))
else
return indent(search('<!--', 'bnW')) + shiftwidth()
endif
endfunc
let &cpo = s:keepcpo
unlet s:keepcpo
