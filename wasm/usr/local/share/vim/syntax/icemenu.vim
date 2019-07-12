if exists("b:current_syntax")
finish
endif
syntax case ignore
syntax match _icon /"\=\/.*\.xpm"\=/
syntax match _icon /"\=\/.*\.png"\=/
syntax match _icon /"\=\/.*\.gif"\=/
syntax match _icon /"\-"/
syntax keyword _rules separator
syntax keyword _ids menu prog
highlight link _rules Underlined
highlight link _ids Type
highlight link _icon Special
let b:current_syntax = "IceMenu"
