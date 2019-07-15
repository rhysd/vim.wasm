if exists("b:current_syntax")
finish
endif
syn spell toplevel
syn match svnFirstLine  "\%^.*" nextgroup=svnRegion,svnBlank skipnl
syn match svnSummary    "^.\{0,50\}" contained containedin=svnFirstLine nextgroup=svnOverflow contains=@Spell
syn match svnOverflow   ".*" contained contains=@Spell
syn match svnBlank      "^.*" contained contains=@Spell
syn region svnRegion    end="\%$" matchgroup=svnDelimiter start="^--.*--$" contains=svnRemoved,svnRenamed,svnAdded,svnModified,svnProperty,@NoSpell
syn match svnRemoved    "^D    .*$" contained contains=@NoSpell
syn match svnRenamed    "^R[ M][ U][ +] .*$" contained contains=@NoSpell
syn match svnAdded      "^A[ M][ U][ +] .*$" contained contains=@NoSpell
syn match svnModified   "^M[ M][ U]  .*$" contained contains=@NoSpell
syn match svnProperty   "^_M[ U]  .*$" contained contains=@NoSpell
syn sync clear
syn sync match svnSync  grouphere svnRegion "^--.*--$"me=s-1
hi def link svnSummary     Keyword
hi def link svnBlank       Error
hi def link svnRegion      Comment
hi def link svnDelimiter   NonText
hi def link svnRemoved     Constant
hi def link svnAdded       Identifier
hi def link svnModified    Special
hi def link svnProperty    Special
hi def link svnRenamed     Special
let b:current_syntax = "svn"
