if !exists("jproperties_lines")
let jproperties_lines = 256
endif
if !exists("jproperties_strict_syntax")
let jproperties_strict_syntax = 0
endif
if !exists("jproperties_show_messages")
let jproperties_show_messages = 0
endif
if exists("b:current_syntax")
finish
endif
syn case ignore
exec "syn sync lines=" . jproperties_lines
if jproperties_strict_syntax != 0
syn match   jpropertiesAssignment	"^\s*[^[:space:]]\+.*$" contains=jpropertiesIdentifier
syn match   jpropertiesIdentifier	"[^=:[:space:]]*" contained nextgroup=jpropertiesDelimiter
syn match   jpropertiesDelimiter	"\s*[=:[:space:]]\s*" contained nextgroup=jpropertiesString
syn match   jpropertiesEmptyIdentifier	"^\s*[=:]\s*" nextgroup=jpropertiesString
else
syn match   jpropertiesAssignment	"^\s*[^=:[:space:]]\+\s*[=:].*$" contains=jpropertiesIdentifier
syn match   jpropertiesIdentifier	"[^=:[:space:]]\+" contained nextgroup=jpropertiesDelimiter
syn match   jpropertiesDelimiter	"\s*[=:]\s*" contained nextgroup=jpropertiesString
endif
syn region  jpropertiesString		start="" skip="\\$" end="$" contained contains=jpropertiesSpecialChar,jpropertiesError,jpropertiesSpecial
if jproperties_show_messages != 0
syn match   jpropertiesSpecial		"{[^}]*}\{-1,\}" contained
syn match   jpropertiesSpecial		"'{" contained
syn match   jpropertiesSpecial		"''" contained
endif
syn match   jpropertiesSpecialChar	"\\u\x\{1,4}" contained
syn match   jpropertiesError		"\\u\X\{1,4}" contained
syn match   jpropertiesError		"\\u$"me=e-1 contained
syn match   jpropertiesSpecial		"\\[trn\\]" contained
syn match   jpropertiesSpecial		"\\\s" contained
syn match   jpropertiesSpecial		"\\$" contained
syn match   jpropertiesComment		"^\s*[#!].*$" contains=jpropertiesTODO
syn keyword jpropertiesTodo		TODO FIXME XXX contained
hi def link jpropertiesComment	Comment
hi def link jpropertiesTodo		Todo
hi def link jpropertiesIdentifier	Identifier
hi def link jpropertiesString	String
hi def link jpropertiesExtendString	String
hi def link jpropertiesCharacter	Character
hi def link jpropertiesSpecial	Special
hi def link jpropertiesSpecialChar	SpecialChar
hi def link jpropertiesError	Error
let b:current_syntax = "jproperties"
