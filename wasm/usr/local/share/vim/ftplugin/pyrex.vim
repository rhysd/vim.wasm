if exists("b:did_ftplugin")
finish
endif
let s:keepcpo= &cpo
set cpo&vim
runtime! ftplugin/python.vim ftplugin/python_*.vim ftplugin/python/*.vim
if has("gui_win32") && exists("b:browsefilter")
let  b:browsefilter = "Pyrex files (*.pyx,*.pxd)\t*.pyx;*.pxd\n" .
\ "Python Files (*.py)\t*.py\n" .
\ "C Source Files (*.c)\t*.c\n" .
\ "C Header Files (*.h)\t*.h\n" .
\ "C++ Source Files (*.cpp *.c++)\t*.cpp;*.c++\n" .
\ "All Files (*.*)\t*.*\n"
endif
let &cpo = s:keepcpo
unlet s:keepcpo
