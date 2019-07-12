if exists("b:current_syntax")
finish
endif
syn match upstreamlog_Date /\u\l\l \u\l\l\s\{1,2}\d\{1,2} \d\d:\d\d:\d\d \d\d\d\d/
syn match upstreamlog_MsgD /Msg #\(Agt\|PC\|Srv\)\d\{4,5}D/ nextgroup=upstreamlog_Process skipwhite
syn match upstreamlog_MsgE /Msg #\(Agt\|PC\|Srv\)\d\{4,5}E/ nextgroup=upstreamlog_Process skipwhite
syn match upstreamlog_MsgI /Msg #\(Agt\|PC\|Srv\)\d\{4,5}I/ nextgroup=upstreamlog_Process skipwhite
syn match upstreamlog_MsgW /Msg #\(Agt\|PC\|Srv\)\d\{4,5}W/ nextgroup=upstreamlog_Process skipwhite
syn region upstreamlog_Process start="(" end=")" contained
syn match upstreamlog_IPaddr /\( \|(\)\zs\d\{1,3}\.\d\{1,3}\.\d\{1,3}\.\d\{1,3}/
syn match upstreamlog_Profile /Using default configuration for profile \zs\S\{1,8}\ze/
syn match upstreamlog_Profile /Now running profile \zs\S\{1,8}\ze/
syn match upstreamlog_Profile /in profile set \zs\S\{1,8}\ze/
syn match upstreamlog_Profile /Migrate disk backup from profile \zs\S\{1,8}\ze/
syn match upstreamlog_Profile /Profileset=\zs\S\{1,8}\ze,/
syn match upstreamlog_Profile /Vault \(disk\|tape\) backup to vault \d\{1,4} from profile \zs\S\{1,8}\ze/
syn match upstreamlog_Profile /Profile name \zs\"\S\{1,8}\"/
syn match upstreamlog_Profile / Profile: \zs\S\{1,8}/
syn match upstreamlog_Profile /  Profile: \zs\S\{1,8}\ze, /
syn match upstreamlog_Profile /, profile: \zs\S\{1,8}\ze,/
syn match upstreamlog_Profile /found Profile: \zs\S\{1,8}\ze,/
syn match upstreamlog_Profile /Backup Profile: \zs\S\{1,8}\ze Version date/
syn match upstreamlog_Profile /Backup profile: \zs\S\{1,8}\ze  Version date/
syn match upstreamlog_Profile /Full of \zs\S\{1,8}\ze$/
syn match upstreamlog_Profile /Incr. of \zs\S\{1,8}\ze$/
syn match upstreamlog_Profile /Profile=\zs\S\{1,8}\ze,/
syn region upstreamlog_Target start="Computer: \zs" end="\ze[\]\)]" 
syn region upstreamlog_Target start="Computer name \zs\"" end="\"\ze" 
syn region upstreamlog_Target start="request to registered name \zs" end=" "
hi def link upstreamlog_Date	Underlined
hi def link upstreamlog_MsgD	Type
hi def link upstreamlog_MsgE	Error
hi def link upstreamlog_MsgW	Constant
hi def link upstreamlog_Process	Statement
hi def link upstreamlog_IPaddr	Identifier
hi def link upstreamlog_Profile	Identifier
hi def link upstreamlog_Target	Identifier
let b:current_syntax = "upstreamlog"
