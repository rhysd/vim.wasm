if exists("b:current_syntax")
finish
endif
syn region wdiffOld start=+\[-+ end=+-]+
syn region wdiffNew start="{+" end="+}"
hi def link wdiffOld       Special
hi def link wdiffNew       Identifier
let b:current_syntax = "wdiff"
