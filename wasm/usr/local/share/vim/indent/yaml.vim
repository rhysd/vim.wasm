if exists('b:did_indent')
finish
endif
let s:save_cpo = &cpo
set cpo&vim
let b:did_indent = 1
setlocal indentexpr=GetYAMLIndent(v:lnum)
setlocal indentkeys=!^F,o,O,0#,0},0],<:>,0-
setlocal nosmartindent
let b:undo_indent = 'setlocal indentexpr< indentkeys< smartindent<'
if exists('*GetYAMLIndent')
finish
endif
function s:FindPrevLessIndentedLine(lnum, ...)
let prevlnum = prevnonblank(a:lnum-1)
let curindent = a:0 ? a:1 : indent(a:lnum)
while           prevlnum
\&&  indent(prevlnum) >=  curindent
\&& getline(prevlnum) =~# '^\s*#'
let prevlnum = prevnonblank(prevlnum-1)
endwhile
return prevlnum
endfunction
function s:FindPrevLEIndentedLineMatchingRegex(lnum, regex)
let plilnum = s:FindPrevLessIndentedLine(a:lnum, indent(a:lnum)+1)
while plilnum && getline(plilnum) !~# a:regex
let plilnum = s:FindPrevLessIndentedLine(plilnum)
endwhile
return plilnum
endfunction
let s:mapkeyregex='\v^\s*\#@!\S@=%(\''%([^'']|\''\'')*\'''.
\                 '|\"%([^"\\]|\\.)*\"'.
\                 '|%(%(\:\ )@!.)*)\:%(\ |$)'
let s:liststartregex='\v^\s*%(\-%(\ |$))'
let s:c_ns_anchor_char = '\v%([\n\r\uFEFF \t,[\]{}]@!\p)'
let s:c_ns_anchor_name = s:c_ns_anchor_char.'+'
let s:c_ns_anchor_property =  '\v\&'.s:c_ns_anchor_name
let s:ns_word_char = '\v[[:alnum:]_\-]'
let s:ns_tag_char  = '\v%(%\x\x|'.s:ns_word_char.'|[#/;?:@&=+$.~*''()])'
let s:c_named_tag_handle     = '\v\!'.s:ns_word_char.'+\!'
let s:c_secondary_tag_handle = '\v\!\!'
let s:c_primary_tag_handle   = '\v\!'
let s:c_tag_handle = '\v%('.s:c_named_tag_handle.
\            '|'.s:c_secondary_tag_handle.
\            '|'.s:c_primary_tag_handle.')'
let s:c_ns_shorthand_tag = '\v'.s:c_tag_handle . s:ns_tag_char.'+'
let s:c_non_specific_tag = '\v\!'
let s:ns_uri_char  = '\v%(%\x\x|'.s:ns_word_char.'\v|[#/;?:@&=+$,.!~*''()[\]])'
let s:c_verbatim_tag = '\v\!\<'.s:ns_uri_char.'+\>'
let s:c_ns_tag_property = '\v'.s:c_verbatim_tag.
\               '\v|'.s:c_ns_shorthand_tag.
\               '\v|'.s:c_non_specific_tag
let s:block_scalar_header = '\v[|>]%([+-]?[1-9]|[1-9]?[+-])?'
function GetYAMLIndent(lnum)
if a:lnum == 1 || !prevnonblank(a:lnum-1)
return 0
endif
let prevlnum = prevnonblank(a:lnum-1)
let previndent = indent(prevlnum)
let line = getline(a:lnum)
if line =~# '^\s*#' && getline(a:lnum-1) =~# '^\s*#'
return previndent
elseif line =~# '^\s*[\]}]'
return indent(s:FindPrevLessIndentedLine(a:lnum))
endif
while getline(prevlnum) =~# '^\s*#'
let prevlnum = prevnonblank(prevlnum-1)
if !prevlnum
return previndent
endif
endwhile
let prevline = getline(prevlnum)
let previndent = indent(prevlnum)
if prevline =~# '\v[{[:]$|[:-]\ [|>][+\-]?%(\s+\#.*|\s*)$'
return previndent+shiftwidth()
elseif prevline =~# '\v[:-]\ [|>]%(\d+[+\-]?|[+\-]?\d+)%(\#.*|\s*)$'
return previndent + str2nr(matchstr(prevline,
\'\v([:-]\ [|>])@<=[+\-]?\d+%([+\-]?%(\s+\#.*|\s*)$)@='))
elseif prevline =~# '\v\"%([^"\\]|\\.)*\\$'
let qidx = match(prevline, '\v\"%([^"\\]|\\.)*\\')
return virtcol([prevlnum, qidx+1])
elseif line =~# s:liststartregex
return indent(s:FindPrevLEIndentedLineMatchingRegex(a:lnum,
\                                       s:liststartregex))
elseif line =~# s:mapkeyregex
let prevmapline = s:FindPrevLEIndentedLineMatchingRegex(a:lnum,
\                                           s:mapkeyregex)
if getline(prevmapline) =~# '^\s*- '
return indent(prevmapline) + 2
else
return indent(prevmapline)
endif
elseif prevline =~# '^\s*- '
return previndent+2
elseif prevline =~# s:mapkeyregex . '\v\s*%(%('.s:c_ns_tag_property.
\                              '\v|'.s:c_ns_anchor_property.
\                              '\v|'.s:block_scalar_header.
\                             '\v)%(\s+|\s*%(\#.*)?$))*'
return previndent+shiftwidth()
endif
return previndent
endfunction
let &cpo = s:save_cpo
