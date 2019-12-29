if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal indentexpr=SystemVerilogIndent()
setlocal indentkeys=!^F,o,O,0),0},=begin,=end,=join,=endcase,=join_any,=join_none
setlocal indentkeys+==endmodule,=endfunction,=endtask,=endspecify
setlocal indentkeys+==endclass,=endpackage,=endsequence,=endclocking
setlocal indentkeys+==endinterface,=endgroup,=endprogram,=endproperty,=endchecker
setlocal indentkeys+==`else,=`endif
if exists("*SystemVerilogIndent")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
function SystemVerilogIndent()
if exists('b:systemverilog_indent_width')
let offset = b:systemverilog_indent_width
else
let offset = shiftwidth()
endif
if exists('b:systemverilog_indent_modules')
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
let sv_openstat = '\(\<or\>\|\([*/]\)\@<![*(,{><+-/%^&|!=?:]\([*/]\)\@!\)'
let sv_comment = '\(//.*\|/\*.*\*/\s*\)'
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
elseif last_line =~ '`\@<!\<\(if\|else\)\>' ||
\ last_line =~ '^\s*\<\(for\|case\%[[zx]]\|do\|foreach\|forever\|randcase\)\>' ||
\ last_line =~ '^\s*\<\(always\|always_comb\|always_ff\|always_latch\)\>' ||
\ last_line =~ '^\s*\<\(initial\|specify\|fork\|final\)\>'
if last_line !~ '\(;\|\<end\>\)\s*' . sv_comment . '*$' ||
\ last_line =~ '\(//\|/\*\).*\(;\|\<end\>\)\s*' . sv_comment . '*$'
let ind = ind + offset
if vverb | echo vverb_str "Indent after a block statement." | endif
endif
elseif last_line =~ '^\s*\<\(function\|task\|class\|package\)\>' ||
\ last_line =~ '^\s*\<\(sequence\|clocking\|interface\)\>' ||
\ last_line =~ '^\s*\(\w\+\s*:\)\=\s*\<covergroup\>' ||
\ last_line =~ '^\s*\<\(property\|checker\|program\)\>'
if last_line !~ '\<end\>\s*' . sv_comment . '*$' ||
\ last_line =~ '\(//\|/\*\).*\(;\|\<end\>\)\s*' . sv_comment . '*$'
let ind = ind + offset
if vverb
echo vverb_str "Indent after function/task/class block statement."
endif
endif
elseif last_line =~ '^\s*\(\<extern\>\s*\)\=\<module\>'
let ind = ind + indent_modules
if vverb && indent_modules
echo vverb_str "Indent after module statement."
endif
if last_line =~ '[(,]\s*' . sv_comment . '*$' &&
\ last_line !~ '\(//\|/\*\).*[(,]\s*' . sv_comment . '*$'
let ind = ind + offset
if vverb
echo vverb_str "Indent after a multiple-line module statement."
endif
endif
elseif last_line =~ '\(\<begin\>\)\(\s*:\s*\w\+\)*' . sv_comment . '*$' &&
\ last_line !~ '\(//\|/\*\).*\(\<begin\>\)' &&
\ ( last_line2 !~ sv_openstat . '\s*' . sv_comment . '*$' ||
\ last_line2 =~ '^\s*[^=!]\+\s*:\s*' . sv_comment . '*$' )
let ind = ind + offset
if vverb | echo vverb_str "Indent after begin statement." | endif
elseif last_line =~ '[{(]' . sv_comment . '*$' &&
\ last_line !~ '\(//\|/\*\).*[{(]' &&
\ ( last_line2 !~ sv_openstat . '\s*' . sv_comment . '*$' ||
\ last_line2 =~ '^\s*[^=!]\+\s*:\s*' . sv_comment . '*$' )
let ind = ind + offset
if vverb | echo vverb_str "Indent after begin statement." | endif
elseif ( last_line !~ '\<begin\>' ||
\ last_line =~ '\(//\|/\*\).*\<begin\>' ) &&
\ last_line2 =~ '\<\(`\@<!if\|`\@<!else\|for\|always\|initial\|do\|foreach\|forever\|final\)\>.*' .
\ sv_comment . '*$' &&
\ last_line2 !~ '\(//\|/\*\).*\<\(`\@<!if\|`\@<!else\|for\|always\|initial\|do\|foreach\|forever\|final\)\>' &&
\ last_line2 !~ sv_openstat . '\s*' . sv_comment . '*$' &&
\ ( last_line2 !~ '\<begin\>' ||
\ last_line2 =~ '\(//\|/\*\).*\<begin\>' )
let ind = ind - offset
if vverb
echo vverb_str "De-indent after the end of one-line statement."
endif
elseif  last_line =~ sv_openstat . '\s*' . sv_comment . '*$' &&
\ last_line !~ '\(//\|/\*\).*' . sv_openstat . '\s*$' &&
\ last_line2 !~ sv_openstat . '\s*' . sv_comment . '*$'
let ind = ind + offset
if vverb | echo vverb_str "Indent after an open statement." | endif
elseif last_line =~ ')*\s*;\s*' . sv_comment . '*$' &&
\ last_line !~ '^\s*)*\s*;\s*' . sv_comment . '*$' &&
\ last_line !~ '\(//\|/\*\).*\S)*\s*;\s*' . sv_comment . '*$' &&
\ ( last_line2 =~ sv_openstat . '\s*' . sv_comment . '*$' &&
\ last_line2 !~ ';\s*//.*$') &&
\ last_line2 !~ '^\s*' . sv_comment . '$'
let ind = ind - offset
if vverb | echo vverb_str "De-indent after a close statement." | endif
elseif last_line =~ '^\s*`\<\(ifdef\|else\)\>'
let ind = ind + offset
if vverb
echo vverb_str "Indent after a `ifdef or `else statement."
endif
endif
if curr_line =~ '^\s*\<\(join\|join_any\|join_none\|\|end\|endcase\|while\)\>' ||
\ curr_line =~ '^\s*\<\(endfunction\|endtask\|endspecify\|endclass\)\>' ||
\ curr_line =~ '^\s*\<\(endpackage\|endsequence\|endclocking\|endinterface\)\>' ||
\ curr_line =~ '^\s*\<\(endgroup\|endproperty\|endchecker\|endprogram\)\>' ||
\ curr_line =~ '^\s*}'
let ind = ind - offset
if vverb | echo vverb_str "De-indent the end of a block." | endif
elseif curr_line =~ '^\s*\<endmodule\>'
let ind = ind - indent_modules
if vverb && indent_modules
echo vverb_str "De-indent the end of a module."
endif
elseif curr_line =~ '^\s*\<begin\>'
if last_line !~ '^\s*\<\(function\|task\|specify\|module\|class\|package\)\>' ||
\ last_line !~ '^\s*\<\(sequence\|clocking\|interface\|covergroup\)\>' ||
\ last_line !~ '^\s*\<\(property\|checker\|program\)\>' &&
\ last_line !~ '^\s*\()*\s*;\|)\+\)\s*' . sv_comment . '*$' &&
\ ( last_line =~
\ '\<\(`\@<!if\|`\@<!else\|for\|case\%[[zx]]\|always\|initial\|do\|foreach\|forever\|randcase\|final\)\>' ||
\ last_line =~ ')\s*' . sv_comment . '*$' ||
\ last_line =~ sv_openstat . '\s*' . sv_comment . '*$' )
let ind = ind - offset
if vverb
echo vverb_str "De-indent a stand alone begin statement."
endif
endif
elseif curr_line =~ '^\s*)' &&
\ ( last_line =~ sv_openstat . '\s*' . sv_comment . '*$' ||
\ last_line !~ sv_openstat . '\s*' . sv_comment . '*$' &&
\ last_line2 =~ sv_openstat . '\s*' . sv_comment . '*$' )
let ind = ind - offset
if vverb
echo vverb_str "De-indent the end of a multiple statement."
endif
elseif curr_line =~ '^\s*`\<\(else\|endif\)\>'
let ind = ind - offset
if vverb | echo vverb_str "De-indent `else and `endif statement." | endif
endif
return ind
endfunction
let &cpo = s:cpo_save
unlet s:cpo_save
