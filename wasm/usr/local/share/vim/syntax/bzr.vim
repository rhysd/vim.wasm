if exists("b:current_syntax")
finish
endif
if exists("bzr_highlight_diff")
syn include @Diff syntax/diff.vim
endif
syn match bzrRemoved   "^removed:$" contained
syn match bzrAdded     "^added:$" contained
syn match bzrRenamed   "^renamed:$" contained
syn match bzrModified  "^modified:$" contained
syn match bzrUnchanged "^unchanged:$" contained
syn match bzrUnknown   "^unknown:$" contained
syn cluster Statuses contains=bzrRemoved,bzrAdded,bzrRenamed,bzrModified,bzrUnchanged,bzrUnknown
if exists("bzr_highlight_diff")
syn cluster Statuses add=@Diff
endif
syn region bzrRegion   start="^-\{14} This line and the following will be ignored -\{14}$" end="\%$" contains=@NoSpell,@Statuses
syn sync clear
syn sync match bzrSync  grouphere bzrRegion "^-\{14} This line and the following will be ignored -\{14}$"me=s-1
hi def link bzrRemoved    Constant
hi def link bzrAdded      Identifier
hi def link bzrModified   Special
hi def link bzrRenamed    Special
hi def link bzrUnchanged  Special
hi def link bzrUnknown    Special
let b:current_syntax = "bzr"
