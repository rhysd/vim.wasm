if !has("syntax")
finish
endif
if !exists("syntax_on")
so <sfile>:p:h/synload.vim
endif
let syntax_manual = 1
augroup syntaxset
au! FileType *	exe "set syntax=" . &syntax
augroup END
if has("menu") && has("gui_running") && !exists("did_install_syntax_menu") && &guioptions !~# 'M'
source $VIMRUNTIME/menu.vim
endif
