if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn region  xpm2PixelString	start="^"  end="$"  contains=@xpm2Colors
syn keyword xpm2Todo		TODO FIXME XXX  contained
syn match   xpm2Comment		"\!.*$"  contains=@Spell,xpm2Todo
command -nargs=+ Hi hi def <args>
if has("gui_running") || has("termguicolors") && &termguicolors
let color  = ""
let chars  = ""
let colors = 0
let cpp    = 0
let n      = 0
let i      = 1
while i <= line("$")		" scanning all lines
let s = getline(i)
if match(s,"\!.*$") != -1
let s = matchstr(s, "^[^\!]*")
endif
if s != ""			" does line contain a string?
if n == 0			" first string is the Values string
let colors = substitute(s, '\s*\d\+\s\+\d\+\s\+\(\d\+\).*', '\1', '')
let cpp = substitute(s, '\s*\d\+\s\+\d\+\s\+\d\+\s\+\(\d\+\).*', '\1', '')
if cpp =~ '[^0-9]'
break  " if cpp is not made of digits there must be something wrong
endif
if s !~ '/'
exe 'syn match xpm2Values /' . s . '/'
endif
hi def link xpm2Values Statement
let n = 1			" n = color index
elseif n <= colors		" string is a color specification
let chars = substitute(s, '\(.\{'.cpp.'}\s\+\).*', '\1', '')
let color = substitute(s, '.*\sc\s\+\(.\{-}\)\s*\(\(g4\=\|[ms]\)\s.*\)*\s*', '\1', '')
if color == s
let color = substitute(s, '.*\sg\s\+\(.\{-}\)\s*\(\(g4\|[ms]\)\s.*\)*\s*', '\1', '')
if color == s
let color = substitute(s, '.*\sg4\s\+\(.\{-}\)\s*\([ms]\s.*\)*\s*', '\1', '')
if color == s
let color = substitute(s, '.*\sm\s\+\(.\{-}\)\s*\(s\s.*\)*\s*', '\1', '')
if color == s
let color = ""
endif
endif
endif
endif
if color =~ '#\x\{10,}$'
let color = substitute(color, '\(\x\x\)\x\x', '\1', 'g')
elseif color =~ '#\x\{7,}$'
let color = substitute(color, '\(\x\x\)\x', '\1', 'g')
elseif color =~ '#\x\{3}$'
let color = substitute(color, '\(\x\)\(\x\)\(\x\)', '0\10\20\3', '')
endif
let s = escape(s, '/\*^$.~[]')
let chars = escape(chars, '/\*^$.~[]')
let s = substitute(s, "[ \t][ \t]*", "\\\\s\\\\+", "g")
let chars = substitute(chars, "[ \t][ \t]*", "\\\\s\\\\+", "g")
exe 'syn match xpm2Col'.n.'Def /'.s.'/ contains=xpm2Col'.n.'inDef'
exe 'hi def link xpm2Col'.n.'Def Constant'
exe 'syn match xpm2Col'.n.'inDef /^'.chars.'/hs=s+'.(cpp).' contained'
exe 'hi def link xpm2Col'.n.'inDef xpm2Color'.n
let chars = substitute(chars, '\\s\\+$', '', '')
exe 'syn match xpm2Color'.n.' /'.chars.'/ contained'
exe 'syn cluster xpm2Colors add=xpm2Color'.n
if color == ""  ||  substitute(color, '.*', '\L&', '') == 'none'
exe 'Hi xpm2Color'.n.' guifg=bg guibg=NONE'
elseif color !~ "'"
exe 'Hi xpm2Color'.n." guifg='".color."' guibg='".color."'"
endif
let n = n + 1
else
break			" no more color string
endif
endif
let i = i + 1
endwhile
unlet color chars colors cpp n i s
endif          " has("gui_running") || has("termguicolors") && &termguicolors
hi def link xpm2Type		Type
hi def link xpm2StorageClass	StorageClass
hi def link xpm2Todo		Todo
hi def link xpm2Comment		Comment
hi def link xpm2PixelString	String
delcommand Hi
let b:current_syntax = "xpm2"
let &cpo = s:cpo_save
unlet s:cpo_save
