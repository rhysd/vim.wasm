if exists("b:current_syntax")
finish
endif
syn keyword tliObject LIST POPLIST WINDOW POPWINDOW OUTLINE CHECKMARK GOTO
syn keyword tliObject LABEL IMAGE RECT TRES PASSWORD POPEDIT POPIMAGE CHECKLIST
syn keyword tliField X Y W H BX BY BW BH SX SY FONT BFONT CYCLE DELAY TABS
syn keyword tliField STYLE BTEXT RECORD DATABASE KEY TARGET DEFAULT TEXT
syn keyword tliField LINKS MAXVAL
syn keyword tliStyle INVERTED HORIZ_RULE VERT_RULE NO_SCROLL NO_BORDER BOLD_BORDER
syn keyword tliStyle ROUND_BORDER ALIGN_RIGHT ALIGN_CENTER ALIGN_LEFT_START ALIGN_RIGHT_START
syn keyword tliStyle ALIGN_CENTER_START ALIGN_LEFT_END ALIGN_RIGHT_END ALIGN_CENTER_END
syn keyword tliStyle LOCKOUT BUTTON_SCROLL BUTTON_SELECT STROKE_FIND FILLED REGISTER
syn match tliSpecial	"@"
syn region tliString	start=+"+ end=+"+
syn case ignore
syn match tliNumber	"\d*"
syn match tliIdentifier	"\<\h\w*\>"
syn match tliComment	"#.*"
syn case match
hi def link tliNumber	Number
hi def link tliString	String
hi def link tliComment	Comment
hi def link tliSpecial	SpecialChar
hi def link tliIdentifier Identifier
hi def link tliObject     Statement
hi def link tliField      Type
hi def link tliStyle      PreProc
let b:current_syntax = "tli"
