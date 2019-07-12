if exists('b:current_syntax')
finish
endif
syn case match
syn match debsourcesKeyword        /\(deb-src\|deb\|main\|contrib\|non-free\|restricted\|universe\|multiverse\)/
syn match debsourcesComment        /#.*/  contains=@Spell
let s:cpo = &cpo
set cpo-=C
let s:supported = [
\ 'oldstable', 'stable', 'testing', 'unstable', 'experimental',
\ 'wheezy', 'jessie', 'stretch', 'buster', 'bullseye', 'bookworm',
\ 'sid', 'rc-buggy',
\
\ 'trusty', 'xenial', 'bionic', 'cosmic', 'disco', 'eoan', 'devel'
\ ]
let s:unsupported = [
\ 'buzz', 'rex', 'bo', 'hamm', 'slink', 'potato',
\ 'woody', 'sarge', 'etch', 'lenny', 'squeeze',
\
\ 'warty', 'hoary', 'breezy', 'dapper', 'edgy', 'feisty',
\ 'gutsy', 'hardy', 'intrepid', 'jaunty', 'karmic', 'lucid',
\ 'maverick', 'natty', 'oneiric', 'precise', 'quantal', 'raring', 'saucy',
\ 'utopic', 'vivid', 'wily', 'yakkety', 'zesty', 'artful'
\ ]
let &cpo=s:cpo
syn match debsourcesUri            '\(https\?://\|ftp://\|[rs]sh://\|debtorrent://\|\(cdrom\|copy\|file\):\)[^' 	<>"]\+'
exe 'syn match debsourcesDistrKeyword   +\([[:alnum:]_./]*\)\<\('. join(s:supported, '\|'). '\)\>\([-[:alnum:]_./]*\)+'
exe 'syn match debsourcesUnsupportedDistrKeyword +\([[:alnum:]_./]*\)\<\('. join(s:unsupported, '\|') .'\)\>\([-[:alnum:]_./]*\)+'
hi def link debsourcesLine                    Error
hi def link debsourcesKeyword                 Statement
hi def link debsourcesDistrKeyword            Type
hi def link debsourcesUnsupportedDistrKeyword WarningMsg
hi def link debsourcesComment                 Comment
hi def link debsourcesUri                     Constant
let b:current_syntax = 'debsources'
