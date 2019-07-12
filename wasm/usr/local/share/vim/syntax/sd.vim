if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn case ignore
syn match sdComment /\s*[#;].*$/
syn cluster sdIPCluster contains=sdIPError,sdIPSpecial
syn match sdIPError /\%(\d\{4,}\|25[6-9]\|2[6-9]\d\|[3-9]\d\{2}\)[\.0-9]*/ contained
syn match sdIPSpecial /\%(127\.\d\{1,3}\.\d\{1,3}\.\d\{1,3}\)/ contained
syn match sdIP contained /\%(\d\{1,4}\.\)\{3}\d\{1,4}/ contains=@sdIPCluster
syn keyword sdStatement AGGREGATE AUDIO_CHANNELS
syn keyword sdStatement BYTE_PER_PCKT BIT_PER_SAMPLE BITRATE
syn keyword sdStatement CLOCK_RATE CODING_TYPE CREATOR
syn match sdStatement /^\s*CODING_TYPE\>/ nextgroup=sdCoding skipwhite
syn match sdStatement /^\s*ENCODING_NAME\>/ nextgroup=sdEncoding skipwhite
syn keyword sdStatement FILE_NAME FRAME_LEN FRAME_RATE FORCE_FRAME_RATE
syn keyword sdStatement LICENSE
syn match sdStatement /^\s*MEDIA_SOURCE\>/ nextgroup=sdSource skipwhite
syn match sdStatement /^\s*MULTICAST\>/ nextgroup=sdIP skipwhite
syn keyword sdStatement PAYLOAD_TYPE PKT_LEN PRIORITY
syn keyword sdStatement SAMPLE_RATE
syn keyword sdStatement TITLE TWIN
syn keyword sdStatement VERIFY
syn keyword sdEncoding H26L MPV MP2T MP4V-ES
syn keyword sdCoding FRAME SAMPLE
syn keyword sdSource STORED LIVE
syn keyword sdSpecial TRUE FALSE NULL
syn keyword sdDelimiter STREAM STREAM_END
syn match sdError /^search .\{257,}/
hi def link sdIP Number
hi def link sdHostname Type
hi def link sdEncoding Identifier
hi def link sdCoding Identifier
hi def link sdSource Identifier
hi def link sdComment Comment
hi def link sdIPError Error
hi def link sdError Error
hi def link sdStatement Statement
hi def link sdIPSpecial Special
hi def link sdSpecial Special
hi def link sdDelimiter Delimiter
let b:current_syntax = "sd"
let &cpo = s:cpo_save
unlet s:cpo_save
