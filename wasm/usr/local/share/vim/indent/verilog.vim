if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=GetVerilogIndent()
setlocal indentkeys=!^F,o,O,0),=begin,=end,=join,=endcase
setlocal indentkeys+==endmodule,=endfunction,=endtask,=endspecify
setlocal indentkeys+==endconfig,=endgenerate,=endprimitive,=endtable
setlocal indentkeys+==`else,=`elsif,=`endif
if exists("*GetVerilogIndent")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
function GetVerilogIndent()
if exists('b:verilog_indent_width')
let offset = b:verilog_indent_width
else
let offset = shiftwidth()
endif
if exists('b:verilog_indent_modules')
let indent_modules = offset
else
let indent_modules = 0
endif
let lnum = prevnonblank(v:lnum - 1)
if lnum == 0
return 0
endif
let lnum2 = prevnonblank(lnum - 1)
let curr_line  = getline(v:lnum)
let last_line  = getline(lnum)
let last_line2 = getline(lnum2)
let ind  = indent(lnum)
let ind2 = indent(lnum - 1)
let offset_comment1 = 1
let vlog_openstat = '\(\<or\>\|\([*/]\)\@<![*(,{><+-/%^&|!=?:]\([*/]\)\@!\)'
let vlog_comment = '\(//.*\|/\*.*\*/\s*\)'
if exists('b:verilog_indent_verbose')
let vverb_str = 'INDENT VERBOSE:'
let vverb = 1
else
let vverb = 0
endif
if last_line =~ '\*/\s*$' && last_line !~ '/\*.\{-}\*/'
let ind = ind - offset_comment1
if vverb
echo vverb_str "De-indent after a multiple-line comment."
endif
elseif last_line =~ '^\s*\(end\)\=\s*`\@<!\<\(if\|else\)\>' ||
\ last_line =~ '^\s*\<\(for\|case\%[[zx]]\)\>' ||
\ last_line =~ '^\s*\<\(always\|initial\)\>' ||
\ last_line =~ '^\s*\<\(specify\|fork\)\>'
if last_line !~ '\(;\|\<end\>\)\s*' . vlog_comment . '*$' ||
\ last_line =~ '\(//\|/\*\).*\(;\|\<end\>\)\s*' . vlog_comment . '*$'
let ind = ind + offset
if vverb | echo vverb_str "Indent after a block statement." | endif
endif
elseif last_line =~ '^\s*\<\(function\|task\|config\|generate\|primitive\|table\)\>'
if last_line !~ '\<end\>\s*' . vlog_comment . '*$' ||
\ last_line =~ '\(//\|/\*\).*\(;\|\<end\>\)\s*' . vlog_comment . '*$'
let ind = ind + offset
if vverb
echo vverb_str "Indent after function/task block statement."
endif
endif
elseif last_line =~ '^\s*\<module\>'
let ind = ind + indent_modules
if vverb && indent_modules
echo vverb_str "Indent after module statement."
endif
if last_line =~ '[(,]\s*' . vlog_comment . '*$' &&
\ last_line !~ '\(//\|/\*\).*[(,]\s*' . vlog_comment . '*$'
let ind = ind + offset
if vverb
echo vverb_str "Indent after a multiple-line module statement."
endif
endif
elseif last_line =~ '\(\<begin\>\)\(\s*:\s*\w\+\)*' . vlog_comment . '*$' &&
\ last_line !~ '\(//\|/\*\).*\(\<begin\>\)' &&
\ ( last_line2 !~ vlog_openstat . '\s*' . vlog_comment . '*$' ||
\ last_line2 =~ '^\s*[^=!]\+\s*:\s*' . vlog_comment . '*$' )
let ind = ind + offset
if vverb | echo vverb_str "Indent after begin statement." | endif
elseif ( last_line !~ '\<begin\>' ||
\ last_line =~ '\(//\|/\*\).*\<begin\>' ) &&
\ last_line2 =~ '\<\(`\@<!if\|`\@<!else\|for\|always\|initial\)\>.*' .
\ vlog_comment . '*$' &&
\ last_line2 !~
\ '\(//\|/\*\).*\<\(`\@<!if\|`\@<!else\|for\|always\|initial\)\>' &&
\ last_line2 !~ vlog_openstat . '\s*' . vlog_comment . '*$' &&
\ ( last_line2 !~ '\<begin\>' ||
\ last_line2 =~ '\(//\|/\*\).*\<begin\>' )
let ind = ind - offset
if vverb
echo vverb_str "De-indent after the end of one-line statement."
endif
elseif  last_line =~ vlog_openstat . '\s*' . vlog_comment . '*$' &&
\ last_line !~ '\(//\|/\*\).*' . vlog_openstat . '\s*$' &&
\ last_line2 !~ vlog_openstat . '\s*' . vlog_comment . '*$'
let ind = ind + offset
if vverb | echo vverb_str "Indent after an open statement." | endif
elseif last_line =~ ')*\s*;\s*' . vlog_comment . '*$' &&
\ last_line !~ '^\s*)*\s*;\s*' . vlog_comment . '*$' &&
\ last_line !~ '\(//\|/\*\).*\S)*\s*;\s*' . vlog_comment . '*$' &&
\ ( last_line2 =~ vlog_openstat . '\s*' . vlog_comment . '*$' &&
\ last_line2 !~ ';\s*//.*$') &&
\ last_line2 !~ '^\s*' . vlog_comment . '$'
let ind = ind - offset
if vverb | echo vverb_str "De-indent after a close statement." | endif
elseif last_line =~ '^\s*`\<\(ifn\?def\|elsif\|else\)\>'
let ind = ind + offset
if vverb
echo vverb_str "Indent after a `ifdef or `ifndef or `elsif or `else statement."
endif
endif
if curr_line =~ '^\s*\<\(join\|end\|endcase\)\>' ||
\ curr_line =~ '^\s*\<\(endfunction\|endtask\|endspecify\)\>' ||
\ curr_line =~ '^\s*\<\(endconfig\|endgenerate\|endprimitive\|endtable\)\>'
let ind = ind - offset
if vverb | echo vverb_str "De-indent the end of a block." | endif
elseif curr_line =~ '^\s*\<endmodule\>'
let ind = ind - indent_modules
if vverb && indent_modules
echo vverb_str "De-indent the end of a module."
endif
elseif curr_line =~ '^\s*\<begin\>'
if last_line !~ '^\s*\<\(function\|task\|specify\|module\|config\|generate\|primitive\|table\)\>' &&
\ last_line !~ '^\s*\()*\s*;\|)\+\)\s*' . vlog_comment . '*$' &&
\ ( last_line =~
\ '\<\(`\@<!if\|`\@<!else\|for\|case\%[[zx]]\|always\|initial\)\>' ||
\ last_line =~ ')\s*' . vlog_comment . '*$' ||
\ last_line =~ vlog_openstat . '\s*' . vlog_comment . '*$' )
let ind = ind - offset
if vverb
echo vverb_str "De-indent a stand alone begin statement."
endif
endif
elseif curr_line =~ '^\s*)' &&
\ ( last_line =~ vlog_openstat . '\s*' . vlog_comment . '*$' ||
\ last_line !~ vlog_openstat . '\s*' . vlog_comment . '*$' &&
\ last_line2 =~ vlog_openstat . '\s*' . vlog_comment . '*$' )
let ind = ind - offset
if vverb
echo vverb_str "De-indent the end of a multiple statement."
endif
elseif curr_line =~ '^\s*`\<\(elsif\|else\|endif\)\>'
let ind = ind - offset
if vverb | echo vverb_str "De-indent `elsif or `else or `endif statement." | endif
endif
return ind
endfunction
let &cpo = s:cpo_save
unlet s:cpo_save
