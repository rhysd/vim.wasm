if exists("b:current_syntax")
finish
endif
syntax case match
syntax sync minlines=0 maxlines=0
syntax match tfsError /.*/
highlight link tfsError Error
syntax keyword tfsSpecialComment TODO XXX FIXME contained
highlight link tfsSpecialComment Todo
syntax match tfsComment ~\s*#.*~ contains=tfsSpecialComment
highlight link tfsComment Comment 
highlight link tfsSpecialChar Operator
syntax match tfsSpecialChar ~[*!+]~ contained
highlight link tfsDelimiter Delimiter
syntax match tfsDelimiter ~:~ contained
syntax region tfsRuleDevice matchgroup=tfsDeviceContainer start=~\[/~ end=~\]~ nextgroup=tfsRulePath oneline
highlight link tfsRuleDevice Label
highlight link tfsDeviceContainer PreProc
syntax match tfsRulePath ~/[-_a-zA-Z0-9/]*~ nextgroup=tfsRuleACL contained contains=tfsDelimiter 
highlight link tfsRulePath String
syntax match tfsRuleACL ~\(:\(\*\|[+]\{0,1\}[a-zA-Z0-9/]\+\):[RWEBXODCU!]\+\)\+$~ contained contains=tfsDelimiter,tfsRuleWho,tfsRuleWhat
syntax match tfsRuleWho ~\(\*\|[+]\{0,1\}[a-zA-Z0-9/]\+\)~ contained contains=tfsSpecialChar
highlight link tfsRuleWho Identifier
syntax match tfsRuleWhat ~[RWEBXODCU!]\+~ contained contains=tfsSpecialChar
highlight link tfsRuleWhat Structure
