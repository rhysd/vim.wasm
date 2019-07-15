if exists("b:current_syntax")
finish
endif
syn match hexRecStart "^:"
syn match hexDataByteCount "^:[0-9a-fA-F]\{2}" contains=hexRecStart nextgroup=hexAddress
syn match hexAddress "[0-9a-fA-F]\{4}" transparent contained nextgroup=hexRecTypeUnknown,hexRecType
syn match hexAddressFieldUnknown "^:[0-9a-fA-F]\{8}"      contains=hexDataByteCount nextgroup=hexDataFieldUnknown,hexChecksum
syn match hexDataAddress         "^:[0-9a-fA-F]\{6}00"    contains=hexDataByteCount nextgroup=hexDataOdd,hexChecksum
syn match hexNoAddress           "^:[0-9a-fA-F]\{6}01"    contains=hexDataByteCount nextgroup=hexDataUnexpected,hexChecksum
syn match hexNoAddress           "^:[0-9a-fA-F]\{6}0[24]" contains=hexDataByteCount nextgroup=hexExtendedAddress
syn match hexNoAddress           "^:[0-9a-fA-F]\{6}0[35]" contains=hexDataByteCount nextgroup=hexStartAddress
syn match hexRecTypeUnknown "[0-9a-fA-F]\{2}" contained
syn match hexRecType        "0[0-5]"          contained
syn match hexDataFieldUnknown "[0-9a-fA-F]\{2}" contained nextgroup=hexDataFieldUnknown,hexChecksum
syn match hexDataOdd          "[0-9a-fA-F]\{2}" contained nextgroup=hexDataEven,hexChecksum
syn match hexDataEven         "[0-9a-fA-F]\{2}" contained nextgroup=hexDataOdd,hexChecksum
syn match hexDataUnexpected   "[0-9a-fA-F]\{2}" contained nextgroup=hexDataUnexpected,hexChecksum
syn match hexExtendedAddress "[0-9a-fA-F]\{4}" contained nextgroup=hexDataUnexpected,hexChecksum
syn match hexStartAddress    "[0-9a-fA-F]\{8}" contained nextgroup=hexDataUnexpected,hexChecksum
syn match hexChecksum "[0-9a-fA-F]\{2}$" contained
syn region hexExtAdrBlock start="^:[0-9a-fA-F]\{7}[24]" skip="^:[0-9a-fA-F]\{7}0" end="^:"me=s-1 fold transparent
hi def link hexRecStart            hexRecType
hi def link hexDataByteCount       Constant
hi def hexAddressFieldUnknown term=italic cterm=italic gui=italic
hi def link hexDataAddress         Comment
hi def link hexNoAddress           DiffAdd
hi def link hexRecTypeUnknown      hexRecType
hi def link hexRecType             WarningMsg
hi def hexDataFieldUnknown    term=italic cterm=italic gui=italic
hi def hexDataOdd             term=bold cterm=bold gui=bold
hi def hexDataEven            term=NONE cterm=NONE gui=NONE
hi def link hexDataUnexpected      Error
hi def link hexExtendedAddress     hexDataAddress
hi def link hexStartAddress        hexDataAddress
hi def link hexChecksum            DiffChange
let b:current_syntax = "hex"
