if exists("b:current_syntax")
finish
endif
syn match srecRecStart "^S"
syn match srecRecTypeUnknown "^S."        contains=srecRecStart
syn match srecRecType        "^S[0-35-9]" contains=srecRecStart
syn match srecByteCount "^S.[0-9a-fA-F]\{2}"        contains=srecRecTypeUnknown nextgroup=srecAddressFieldUnknown,srecChecksum
syn match srecByteCount "^S[0-35-9][0-9a-fA-F]\{2}" contains=srecRecType
syn match srecAddressFieldUnknown "[0-9a-fA-F]\{2}" contained nextgroup=srecAddressFieldUnknown,srecChecksum
syn match srecNoAddress    "^S0[0-9a-fA-F]\{6}"  contains=srecByteCount nextgroup=srecDataOdd,srecChecksum
syn match srecDataAddress  "^S1[0-9a-fA-F]\{6}"  contains=srecByteCount nextgroup=srecDataOdd,srecChecksum
syn match srecDataAddress  "^S2[0-9a-fA-F]\{8}"  contains=srecByteCount nextgroup=srecDataOdd,srecChecksum
syn match srecDataAddress  "^S3[0-9a-fA-F]\{10}" contains=srecByteCount nextgroup=srecDataOdd,srecChecksum
syn match srecRecCount     "^S5[0-9a-fA-F]\{6}"  contains=srecByteCount nextgroup=srecDataUnexpected,srecChecksum
syn match srecRecCount     "^S6[0-9a-fA-F]\{8}"  contains=srecByteCount nextgroup=srecDataUnexpected,srecChecksum
syn match srecStartAddress "^S7[0-9a-fA-F]\{10}" contains=srecByteCount nextgroup=srecDataUnexpected,srecChecksum
syn match srecStartAddress "^S8[0-9a-fA-F]\{8}"  contains=srecByteCount nextgroup=srecDataUnexpected,srecChecksum
syn match srecStartAddress "^S9[0-9a-fA-F]\{6}"  contains=srecByteCount nextgroup=srecDataUnexpected,srecChecksum
syn match srecDataOdd        "[0-9a-fA-F]\{2}" contained nextgroup=srecDataEven,srecChecksum
syn match srecDataEven       "[0-9a-fA-F]\{2}" contained nextgroup=srecDataOdd,srecChecksum
syn match srecDataUnexpected "[0-9a-fA-F]\{2}" contained nextgroup=srecDataUnexpected,srecChecksum
syn match srecChecksum "[0-9a-fA-F]\{2}$" contained
hi def link srecRecStart            srecRecType
hi def link srecRecTypeUnknown      srecRecType
hi def link srecRecType             WarningMsg
hi def link srecByteCount           Constant
hi def srecAddressFieldUnknown term=italic cterm=italic gui=italic
hi def link srecNoAddress           DiffAdd
hi def link srecDataAddress         Comment
hi def link srecRecCount            srecNoAddress
hi def link srecStartAddress        srecDataAddress
hi def srecDataOdd             term=bold cterm=bold gui=bold
hi def srecDataEven            term=NONE cterm=NONE gui=NONE
hi def link srecDataUnexpected      Error
hi def link srecChecksum            DiffChange
let b:current_syntax = "srec"
