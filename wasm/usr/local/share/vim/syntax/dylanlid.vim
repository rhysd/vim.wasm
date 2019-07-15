if exists("b:current_syntax")
finish
endif
syn case ignore
syn region	dylanlidInfo		matchgroup=Statement start="^" end=":" oneline
syn region	dylanlidEntry		matchgroup=Statement start=":%" end="$" oneline
syn sync	lines=50
hi def link dylanlidInfo		Type
hi def link dylanlidEntry		String
let b:current_syntax = "dylanlid"
