if !has("syntax")
finish
endif
let syntax_on = 1
if exists("colors_name")
exe "colors " . colors_name
else
runtime! syntax/syncolor.vim
endif
let s:cpo_save = &cpo
set cpo&vim
au! Syntax
au Syntax *		call s:SynSet()
fun! s:SynSet()
syn clear
if exists("b:current_syntax")
unlet b:current_syntax
endif
let s = expand("<amatch>")
if s == "ON"
if &filetype == ""
echohl ErrorMsg
echo "filetype unknown"
echohl None
endif
let s = &filetype
elseif s == "OFF"
let s = ""
endif
if s != ""
for name in split(s, '\.')
exe "runtime! syntax/" . name . ".vim syntax/" . name . "/*.vim"
endfor
endif
endfun
au Syntax c,cpp,cs,idl,java,php,datascript
\ if (exists('b:load_doxygen_syntax') && b:load_doxygen_syntax)
\	|| (exists('g:load_doxygen_syntax') && g:load_doxygen_syntax)
\   | runtime! syntax/doxygen.vim
\ | endif
if exists("mysyntaxfile")
let s:fname = expand(mysyntaxfile)
if filereadable(s:fname)
execute "source " . fnameescape(s:fname)
endif
endif
let &cpo = s:cpo_save
unlet s:cpo_save
