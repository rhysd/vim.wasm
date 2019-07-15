if exists("b:current_syntax")
finish
endif
syn keyword xpmType		char
syn keyword xpmStorageClass	static
syn keyword xpmTodo		TODO FIXME XXX  contained
syn region  xpmComment		start="/\*"  end="\*/"  contains=xpmTodo
syn region  xpmPixelString	start=+"+  skip=+\\\\\|\\"+  end=+"+  contains=@xpmColors
if has("gui_running") || has("termguicolors") && &termguicolors
let color  = ""
let chars  = ""
let colors = 0
let cpp    = 0
let n      = 0
let i      = 1
while i <= line("$")		" scanning all lines
let s = matchstr(getline(i), '".\{-1,}"')
if s != ""			" does line contain a string?
if n == 0			" first string is the Values string
let colors = substitute(s, '"\s*\d\+\s\+\d\+\s\+\(\d\+\).*"', '\1', '')
let cpp = substitute(s, '"\s*\d\+\s\+\d\+\s\+\d\+\s\+\(\d\+\).*"', '\1', '')
if cpp =~ '[^0-9]'
break  " if cpp is not made of digits there must be something wrong
endif
if s !~ '/'
exe 'syn match xpmValues /' . s . '/'
endif
hi link xpmValues String
let n = 1		" n = color index
elseif n <= colors	" string is a color specification
let chars = substitute(s, '"\(.\{'.cpp.'}\s\).*"', '\1', '')
let color = substitute(s, '".*\sc\s\+\(.\{-}\)\s*\(\(g4\=\|[ms]\)\s.*\)*\s*"', '\1', '')
if color == s
let color = substitute(s, '".*\sg\s\+\(.\{-}\)\s*\(\(g4\|[ms]\)\s.*\)*\s*"', '\1', '')
if color == s
let color = substitute(s, '".*\sg4\s\+\(.\{-}\)\s*\([ms]\s.*\)*\s*"', '\1', '')
if color == s
let color = substitute(s, '".*\sm\s\+\(.\{-}\)\s*\(s\s.*\)*\s*"', '\1', '')
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
exe 'syn match xpmCol'.n.'Def /'.s.'/ contains=xpmCol'.n.'inDef'
exe 'hi link xpmCol'.n.'Def String'
exe 'syn match xpmCol'.n.'inDef /"'.chars.'/hs=s+'.(cpp+1).' contained'
exe 'hi link xpmCol'.n.'inDef xpmColor'.n
let chars = substitute(chars, '.$', '', '')
exe 'syn match xpmColor'.n.' /'.chars.'/ contained'
exe 'syn cluster xpmColors add=xpmColor'.n
if color == ""  ||  substitute(color, '.*', '\L&', '') == 'none'
exe 'hi xpmColor'.n.' guifg=bg'
exe 'hi xpmColor'.n.' guibg=NONE'
elseif color !~ "'"
exe 'hi xpmColor'.n." guifg='".color."'"
exe 'hi xpmColor'.n." guibg='".color."'"
endif
let n = n + 1
else
break		" no more color string
endif
endif
let i = i + 1
endwhile
unlet color chars colors cpp n i s
endif          " has("gui_running") || has("termguicolors") && &termguicolors
hi def link xpmType		Type
hi def link xpmStorageClass	StorageClass
hi def link xpmTodo		Todo
hi def link xpmComment		Comment
hi def link xpmPixelString	String
let b:current_syntax = "xpm"
