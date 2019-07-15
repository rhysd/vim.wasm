if exists("b:did_ftplugin")
finish
endif
let s:save_cpo = &cpo
set cpo-=C
let s:undo_ftplugin = ""
let s:browsefilter = "All Files (*.*)\t*.*\n"
let s:match_words = ""
runtime! ftplugin/html.vim ftplugin/html_*.vim ftplugin/html/*.vim
unlet! b:did_ftplugin
set matchpairs-=<:>
if exists("b:undo_ftplugin")
let s:undo_ftplugin = b:undo_ftplugin
unlet b:undo_ftplugin
endif
if exists("b:browsefilter")
let s:browsefilter = b:browsefilter
unlet b:browsefilter
endif
if exists("b:match_words")
let s:match_words = b:match_words
unlet b:match_words
endif
runtime! ftplugin/ruby.vim ftplugin/ruby_*.vim ftplugin/ruby/*.vim
let b:did_ftplugin = 1
if exists("b:undo_ftplugin")
let s:undo_ftplugin = b:undo_ftplugin . " | " . s:undo_ftplugin
endif
if exists ("b:browsefilter")
let s:browsefilter = substitute(b:browsefilter,'\cAll Files (\*\.\*)\t\*\.\*\n','','') . s:browsefilter
endif
if exists("b:match_words")
let s:match_words = b:match_words . ',' . s:match_words
endif
if has("gui_win32")
let b:browsefilter="Haml Files (*.haml)\t*.haml\nSass Files (*.sass)\t*.sass\n" . s:browsefilter
endif
if exists("loaded_matchit")
let b:match_words = s:match_words
endif
setlocal comments= commentstring=-#\ %s
let b:undo_ftplugin = "setl cms< com< "
\ " | unlet! b:browsefilter b:match_words | " . s:undo_ftplugin
let &cpo = s:save_cpo
unlet s:save_cpo
