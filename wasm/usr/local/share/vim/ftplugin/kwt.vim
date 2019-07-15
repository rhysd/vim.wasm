runtime! ftplugin/cpp.vim ftplugin/cpp_*.vim ftplugin/cpp/*.vim
let s:cpo_save = &cpo
set cpo&vim
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "Kimwitu/Kimwitu++ Files (*.k)\t*.k\n" .
\ "Lex/Flex Files (*.l)\t*.l\n" .
\ "Yacc/Bison Files (*.y)\t*.y\n" .
\ "All Files (*.*)\t*.*\n"
endif
set efm+=kc%.%#:\ error\ at\ %f:%l:\ %m
if exists("b:undo_ftplugin")
let b:undo_ftplugin = b:undo_ftplugin . " | setlocal efm<"
\ . "| unlet! b:browsefiler"
else
let b:undo_ftplugin = "setlocal efm<"
\ . "| unlet! b:browsefiler"
endif
let &cpo = s:cpo_save
unlet s:cpo_save
