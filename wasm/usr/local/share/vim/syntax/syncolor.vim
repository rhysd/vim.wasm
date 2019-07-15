if !exists("syntax_cmd") || syntax_cmd == "on"
command -nargs=* SynColor hi <args>
command -nargs=* SynLink hi link <args>
else
if syntax_cmd == "enable"
command -nargs=* SynColor hi def <args>
command -nargs=* SynLink hi def link <args>
elseif syntax_cmd == "reset"
command -nargs=* SynColor hi <args>
command -nargs=* SynLink hi! link <args>
else
finish
endif
endif
if &background == "dark"
SynColor Comment	term=bold cterm=NONE ctermfg=Cyan ctermbg=NONE gui=NONE guifg=#80a0ff guibg=NONE
SynColor Constant	term=underline cterm=NONE ctermfg=Magenta ctermbg=NONE gui=NONE guifg=#ffa0a0 guibg=NONE
SynColor Special	term=bold cterm=NONE ctermfg=LightRed ctermbg=NONE gui=NONE guifg=Orange guibg=NONE
SynColor Identifier	term=underline cterm=bold ctermfg=Cyan ctermbg=NONE gui=NONE guifg=#40ffff guibg=NONE
SynColor Statement	term=bold cterm=NONE ctermfg=Yellow ctermbg=NONE gui=bold guifg=#ffff60 guibg=NONE
SynColor PreProc	term=underline cterm=NONE ctermfg=LightBlue ctermbg=NONE gui=NONE guifg=#ff80ff guibg=NONE
SynColor Type		term=underline cterm=NONE ctermfg=LightGreen ctermbg=NONE gui=bold guifg=#60ff60 guibg=NONE
SynColor Underlined	term=underline cterm=underline ctermfg=LightBlue gui=underline guifg=#80a0ff
SynColor Ignore	term=NONE cterm=NONE ctermfg=black ctermbg=NONE gui=NONE guifg=bg guibg=NONE
else
SynColor Comment	term=bold cterm=NONE ctermfg=DarkBlue ctermbg=NONE gui=NONE guifg=Blue guibg=NONE
SynColor Constant	term=underline cterm=NONE ctermfg=DarkRed ctermbg=NONE gui=NONE guifg=Magenta guibg=NONE
SynColor Special	term=bold cterm=NONE ctermfg=DarkMagenta ctermbg=NONE gui=NONE guifg=SlateBlue guibg=NONE
SynColor Identifier	term=underline cterm=NONE ctermfg=DarkCyan ctermbg=NONE gui=NONE guifg=DarkCyan guibg=NONE
SynColor Statement	term=bold cterm=NONE ctermfg=Brown ctermbg=NONE gui=bold guifg=Brown guibg=NONE
SynColor PreProc	term=underline cterm=NONE ctermfg=DarkMagenta ctermbg=NONE gui=NONE guifg=Purple guibg=NONE
SynColor Type		term=underline cterm=NONE ctermfg=DarkGreen ctermbg=NONE gui=bold guifg=SeaGreen guibg=NONE
SynColor Underlined	term=underline cterm=underline ctermfg=DarkMagenta gui=underline guifg=SlateBlue
SynColor Ignore	term=NONE cterm=NONE ctermfg=white ctermbg=NONE gui=NONE guifg=bg guibg=NONE
endif
SynColor Error		term=reverse cterm=NONE ctermfg=White ctermbg=Red gui=NONE guifg=White guibg=Red
SynColor Todo		term=standout cterm=NONE ctermfg=Black ctermbg=Yellow gui=NONE guifg=Blue guibg=Yellow
SynLink String		Constant
SynLink Character	Constant
SynLink Number		Constant
SynLink Boolean		Constant
SynLink Float		Number
SynLink Function	Identifier
SynLink Conditional	Statement
SynLink Repeat		Statement
SynLink Label		Statement
SynLink Operator	Statement
SynLink Keyword		Statement
SynLink Exception	Statement
SynLink Include		PreProc
SynLink Define		PreProc
SynLink Macro		PreProc
SynLink PreCondit	PreProc
SynLink StorageClass	Type
SynLink Structure	Type
SynLink Typedef		Type
SynLink Tag		Special
SynLink SpecialChar	Special
SynLink Delimiter	Special
SynLink SpecialComment	Special
SynLink Debug		Special
delcommand SynColor
delcommand SynLink
