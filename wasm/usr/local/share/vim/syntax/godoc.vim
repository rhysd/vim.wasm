if exists('b:current_syntax')
finish
endif
syn case match
syn match godocTitle "^\([A-Z][A-Z ]*\)$"
hi def link godocTitle Title
let b:current_syntax = 'godoc'
