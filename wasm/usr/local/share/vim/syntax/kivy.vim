if exists("b:current_syntax")
finish
endif
syn include @pyth $VIMRUNTIME/syntax/python.vim
syn match kivyPreProc   /#:.*/
syn match kivyComment   /#.*/
syn match kivyRule      /<\I\i*\(,\s*\I\i*\)*>:/
syn match kivyAttribute /\<\I\i*\>/ nextgroup=kivyValue
syn region kivyValue start=":" end=/$/  contains=@pyth skipwhite
syn region kivyAttribute matchgroup=kivyIdent start=/[\a_][\a\d_]*:/ end=/$/ contains=@pyth skipwhite
hi def link kivyPreproc   PreProc
hi def link kivyComment   Comment
hi def link kivyRule      Function
hi def link kivyIdent     Statement
hi def link kivyAttribute Label
let b:current_syntax = "kivy"
