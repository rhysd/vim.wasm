let paste#paste_cmd = {'n': ":call paste#Paste()<CR>"}
let paste#paste_cmd['v'] = '"-c<Esc>' . paste#paste_cmd['n']
let paste#paste_cmd['i'] = "\<c-\>\<c-o>\"+gP"
func! paste#Paste()
let ove = &ve
set ve=all
normal! `^
if @+ != ''
normal! "+gP
endif
let c = col(".")
normal! i
if col(".") < c	" compensate for i<ESC> moving the cursor left
normal! l
endif
let &ve = ove
endfunc
