if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn match podCommand    "^=encoding"  nextgroup=podCmdText contains=@NoSpell
syn match podCommand    "^=head[1234]"  nextgroup=podCmdText contains=@NoSpell
syn match podCommand    "^=item"        nextgroup=podCmdText contains=@NoSpell
syn match podCommand    "^=over"        nextgroup=podOverIndent skipwhite contains=@NoSpell
syn match podCommand    "^=back"        contains=@NoSpell
syn match podCommand    "^=cut"         contains=@NoSpell
syn match podCommand    "^=pod"         contains=@NoSpell
syn match podCommand    "^=for"         nextgroup=podForKeywd skipwhite contains=@NoSpell
syn match podCommand    "^=begin"       nextgroup=podForKeywd skipwhite contains=@NoSpell
syn match podCommand    "^=end"         nextgroup=podForKeywd skipwhite contains=@NoSpell
syn match podCmdText	".*$" contained contains=podFormat,@NoSpell
syn match podOverIndent	"\d\+" contained contains=@NoSpell
syn match podForKeywd	"\S\+" contained contains=@NoSpell
syn match podVerbatimLine	"^\s.*$" contains=@NoSpell
syn match podSpecial	"\(\<\|&\)\I\i*\(::\I\i*\)*([^)]*)" contains=@NoSpell
syn match podSpecial	"[$@%]\I\i*\(::\I\i*\)*\>" contains=@NoSpell
syn region podFormat	start="[IBSCLFX]<[^<]"me=e-1 end=">" oneline contains=podFormat,@NoSpell
syn region podFormat	start="[IBSCLFX]<<\s" end="\s>>" oneline contains=podFormat,@NoSpell
syn match  podFormat	"Z<>"
syn match  podFormat	"E<\(\d\+\|\I\i*\)>" contains=podEscape,podEscape2,@NoSpell
syn match  podEscape	"\I\i*>"me=e-1 contained contains=@NoSpell
syn match  podEscape2	"\d\+>"me=e-1 contained contains=@NoSpell
hi def link podCommand		Statement
hi def link podCmdText		String
hi def link podOverIndent	Number
hi def link podForKeywd		Identifier
hi def link podFormat		Identifier
hi def link podVerbatimLine	PreProc
hi def link podSpecial		Identifier
hi def link podEscape		String
hi def link podEscape2		Number
if exists("perl_pod_spellcheck_headings")
syn clear podCmdText
syn match podCmdText    ".*$" contained contains=podFormat
endif
if exists("perl_pod_formatting")
syn clear podFormat
syn region podFormat start="[CLF]<[^<]"me=e-1 end=">" oneline contains=podFormat,@NoSpell
syn region podFormat start="[CLF]<<\s" end="\s>>" oneline contains=podFormat,@NoSpell
syn match podFormat   "E<\(\d\+\|\I\i*\)>" contains=podEscape,podEscape2,@NoSpell
syn match podFormat   "Z<>" contains=podEscape,podEscape2,@NoSpell
syn match podBoldOpen    "B<" contains=@NoSpell
syn match podItalicOpen  "I<" contains=@NoSpell
syn match podNoSpaceOpen "S<" contains=@NoSpell
syn match podIndexOpen   "X<" contains=@NoSpell
syn match podBoldAlternativeDelimOpen    "B<< " contains=@NoSpell
syn match podItalicAlternativeDelimOpen  "I<< " contains=@NoSpell
syn match podNoSpaceAlternativeDelimOpen "S<< " contains=@NoSpell
syn match podIndexAlternativeDelimOpen   "X<< " contains=@NoSpell
syn region podBold start="B<[^<]"me=e end=">" oneline contains=podBoldItalic,podBoldOpen
syn region podBoldAlternativeDelim start="B<<\s" end="\s>>" oneline contains=podBoldAlternativeDelimOpen
syn region podItalic start="I<[^<]"me=e end=">" oneline contains=podItalicBold,podItalicOpen
syn region podItalicAlternativeDelim start="I<<\s" end="\s>>" oneline contains=podItalicAlternativeDelimOpen
syn region podBoldItalic contained start="I<[^<]"me=e end=">" oneline
syn region podItalicBold contained start="B<[^<]"me=e end=">" oneline
syn region podNoSpace start="S<[^<]"ms=s-2 end=">"me=e oneline contains=podNoSpaceOpen
syn region podNoSpaceAlternativeDelim start="S<<\s"ms=s-2 end="\s>>"me=e oneline contains=podNoSpaceAlternativeDelimOpen
syn region podIndex start="X<[^<]"ms=s-2 end=">"me=e oneline contains=podIndexOpen
syn region podIndexAlternativeDelim start="X<<\s"ms=s-2 end="\s>>"me=e oneline contains=podIndexAlternativeDelimOpen
syn match podVerbatimLine	"^\s.*$" contains=@NoSpell
syn clear podCmdText
if exists("perl_pod_spellcheck_headings")
syn match podCmdText ".*$" contained contains=podFormat,podBold,
\podBoldAlternativeDelim,podItalic,podItalicAlternativeDelim,
\podBoldOpen,podItalicOpen,podBoldAlternativeDelimOpen,
\podItalicAlternativeDelimOpen,podNoSpaceOpen
else
syn match podCmdText ".*$" contained contains=podFormat,podBold,
\podBoldAlternativeDelim,podItalic,podItalicAlternativeDelim,
\@NoSpell
endif
hi def podBold term=bold cterm=bold gui=bold
hi link podBoldAlternativeDelim podBold
hi link podBoldAlternativeDelimOpen podBold
hi link podBoldOpen podBold
hi link podNoSpace                 Identifier
hi link podNoSpaceAlternativeDelim Identifier
hi link podIndex                   Identifier
hi link podIndexAlternativeDelim   Identifier
hi def podItalic term=italic cterm=italic gui=italic
hi link podItalicAlternativeDelim podItalic
hi link podItalicAlternativeDelimOpen podItalic
hi link podItalicOpen podItalic
hi def podBoldItalic term=italic,bold cterm=italic,bold gui=italic,bold
hi def podItalicBold term=italic,bold cterm=italic,bold gui=italic,bold
endif
let b:current_syntax = "pod"
let &cpo = s:cpo_save
unlet s:cpo_save
