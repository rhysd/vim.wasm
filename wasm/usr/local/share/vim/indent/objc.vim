if exists("b:did_indent")
finish
endif
let b:did_indent = 1
setlocal cindent
setlocal indentexpr=GetObjCIndent()
setlocal indentkeys-=:
setlocal indentkeys+=<:>
if exists("*GetObjCIndent")
finish
endif
function s:GetWidth(line, regexp)
let end = matchend(a:line, a:regexp)
let width = 0
let i = 0
while i < end
if a:line[i] != "\t"
let width = width + 1
else
let width = width + &ts - (width % &ts)
endif
let i = i + 1
endwhile
return width
endfunction
function s:LeadingWhiteSpace(line)
let end = strlen(a:line)
let width = 0
let i = 0
while i < end
let char = a:line[i]
if char != " " && char != "\t"
break
endif
if char != "\t"
let width = width + 1
else
let width = width + &ts - (width % &ts)
endif
let i = i + 1
endwhile
return width
endfunction
function GetObjCIndent()
let theIndent = cindent(v:lnum)
let prev_line = getline(v:lnum - 1)
let cur_line = getline(v:lnum)
if prev_line !~# ":" || cur_line !~# ":"
return theIndent
endif
if prev_line !~# ";"
let prev_colon_pos = s:GetWidth(prev_line, ":")
let delta = s:GetWidth(cur_line, ":") - s:LeadingWhiteSpace(cur_line)
let theIndent = prev_colon_pos - delta
endif
return theIndent
endfunction
