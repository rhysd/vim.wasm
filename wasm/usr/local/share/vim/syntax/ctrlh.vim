syntax match CtrlHUnderline /_\b./  contains=CtrlHHide
syntax match CtrlHBold /\(.\)\b\1/  contains=CtrlHHide
syntax match CtrlHHide /.\b/  contained
hi def link CtrlHHide Ignore
hi def CtrlHUnderline term=underline cterm=underline gui=underline
hi def CtrlHBold term=bold cterm=bold gui=bold
