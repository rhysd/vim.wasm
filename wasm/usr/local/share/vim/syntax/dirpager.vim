if exists("b:current_syntax") || &compatible
finish
endif
setlocal nowrap
syn keyword  DirPagerTodo	contained FIXME TODO XXX NOTE
syn region   DirPagerExe	start='^...x\|^......x\|^.........x' end='$'	contains=DirPagerTodo,@Spell
syn region   DirPagerDir	start='^d' end='$'	contains=DirPagerTodo,@Spell
syn region   DirPagerLink	start='^l' end='$'	contains=DirPagerTodo,@Spell
syn region   DirPagerSpecial	start='^b' end='$'	contains=DirPagerTodo,@Spell
syn region   DirPagerSpecial	start='^c' end='$'	contains=DirPagerTodo,@Spell
syn region   DirPagerFifo	start='^p' end='$'	contains=DirPagerTodo,@Spell
hi def link  DirPagerTodo	Todo
hi def	     DirPagerExe	ctermfg=Green	    guifg=Green
hi def	     DirPagerDir	ctermfg=Blue	    guifg=Blue
hi def	     DirPagerLink	ctermfg=Cyan	    guifg=Cyan
hi def	     DirPagerSpecial	ctermfg=Yellow	    guifg=Yellow
hi def	     DirPagerFifo	ctermfg=Brown	    guifg=Brown
let b:current_syntax = "dirpager"
