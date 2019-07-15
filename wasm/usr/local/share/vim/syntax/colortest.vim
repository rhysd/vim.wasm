if expand('%:p') != expand('<sfile>:p')
let s:fname = expand('<sfile>')
if exists('*fnameescape')
let s:fname = fnameescape(s:fname)
else
let s:fname = escape(s:fname, ' \|')
endif
if &mod || line('$') != 1 || getline(1) != ''
exe "new " . s:fname
else
exe "edit " . s:fname
endif
unlet s:fname
endif
syn clear
8
while search("_on_", "W") < 55
let col1 = substitute(expand("<cword>"), '\(\a\+\)_on_\a\+', '\1', "")
let col2 = substitute(expand("<cword>"), '\a\+_on_\(\a\+\)', '\1', "")
exec 'hi col_'.col1.'_'.col2.' ctermfg='.col1.' guifg='.col1.' ctermbg='.col2.' guibg='.col2
exec 'syn keyword col_'.col1.'_'.col2.' '.col1.'_on_'.col2
endwhile
8,54g/^" \a/exec 'hi col_'.expand("<cword>").' ctermfg='.expand("<cword>").' guifg='.expand("<cword>")| exec 'syn keyword col_'.expand("<cword>")." ".expand("<cword>")
nohlsearch
