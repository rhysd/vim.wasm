if exists("b:current_syntax")
finish
endif
setlocal isk=@,46-57,_,-,#,=,192-255
syn match pcapBad '^.\+$'	       "define any line as bad
syn match pcapBadword '\k\+' contained "define any sequence of keywords as bad
syn match pcapBadword ':' contained    "define any single : as bad
syn match pcapBadword '\\' contained   "define any single \ as bad
syn match pcapKeyword contained ':\(fo\|hl\|ic\|rs\|rw\|sb\|sc\|sf\|sh\)'
syn match pcapKeyword contained ':\(br\|du\|fc\|fs\|mx\|pc\|pl\|pw\|px\|py\|xc\|xs\)#\d\+'
syn match pcapKeyword contained ':\(af\|cf\|df\|ff\|gf\|if\|lf\|lo\|lp\|nd\|nf\|of\|rf\|rg\|rm\|rp\|sd\|st\|tf\|tr\|vf\)=\k*'
syn match pcapEnd ':\\$' contained
syn match pcapDefineLast '^\s.\+$' contains=pcapBadword,pcapKeyword
syn match pcapDefine '^\s.\+$' contains=pcapBadword,pcapKeyword,pcapEnd
syn match pcapHeader '^\k[^|]\+\(|\k[^|]\+\)*:\\$'
syn match pcapComment "#.*$"
syn sync minlines=50
hi def link pcapBad WarningMsg
hi def link pcapBadword WarningMsg
hi def link pcapComment Comment
let b:current_syntax = "pcap"
